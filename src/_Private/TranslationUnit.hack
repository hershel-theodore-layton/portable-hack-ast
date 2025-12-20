/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{Str, Vec};

final class TranslationUnit {
  const SOME_LARGE_JUMP = 64;

  private vec<SourceByteOffset> $lineBreaks;
  private Structs $structs;
  /**
   * @param $sourceOrder is keyed by NodeId (0..n-1).
   * @param $siblings is keyed by SiblingId (0..n-1).
   * @param $listSizes only contains the sizes of lists 255 and above.
   */
  public function __construct(
    private vec<Node> $sourceOrder,
    private vec<Node> $siblings,
    private dict<NodeId, int> $listSizes,
    private string $sourceText,
    private ParseContext $ctx,
  )[] {
    $line_breaks = vec[source_byte_offset_from_int(0)];

    $byte = 0;
    foreach (Str\split($sourceText, "\n") as $line) {
      $byte += Str\length($line) + 1;
      $line_breaks[] = source_byte_offset_from_int($byte);
    }

    $this->lineBreaks = $line_breaks;
    $this->structs = $ctx->getStructs();
  }

  public function cutSourceOrder(
    NodeId $from,
    NodeId $to_inclusive,
  )[]: vec<Node> {
    $from = node_id_to_int($from);
    $to_inclusive = node_id_to_int($to_inclusive);
    return Vec\slice($this->sourceOrder, $from, $to_inclusive - $from + 1);
  }

  public function cutSourceRange(SourceRange $range)[]: string {
    list($from, $to_exclusive) = source_range_reveal($range);
    $from = source_byte_offset_to_int($from);
    $to_exclusive =
      $to_exclusive is null ? null : source_byte_offset_to_int($to_exclusive);
    return $to_exclusive is null
      ? Str\slice($this->sourceText, $from)
      : Str\slice($this->sourceText, $from, $to_exclusive - $from);
  }

  public function getLineBreaks()[]: vec<SourceByteOffset> {
    return $this->lineBreaks;
  }

  public function getNodeById(NodeId $node_id)[]: NillableNode {
    return idx($this->sourceOrder, node_id_to_int($node_id), NIL);
  }

  public function getNodeByIdx(NodeId $node_id)[]: Node {
    return $this->sourceOrder[node_id_to_int($node_id)];
  }

  public function getNodeBySiblingId(SiblingId $sibling_id)[]: NillableNode {
    return idx($this->siblings, sibling_id_to_int($sibling_id), NIL);
  }

  public function getNodeBySiblingIdx(SiblingId $sibling_id)[]: Node {
    return $this->siblings[sibling_id_to_int($sibling_id)];
  }

  public function getParseContext()[]: ParseContext {
    return $this->ctx;
  }

  public function getSourceOrder()[]: vec<Node> {
    return $this->sourceOrder;
  }

  /**
   * Careful, if `$node` is not a `LIST` or `MISSING`, you'll get junk.
   */
  public function listGetSize(Syntax $syntax)[]: int {
    $stored_length = node_get_field_1($syntax);
    return $stored_length < FIELD_1_MASK
      ? $stored_length
      : $this->listSizes[node_get_id($syntax)];
  }

  public function sliceSiblings(SiblingId $start, int $length)[]: vec<Node> {
    return Vec\slice($this->siblings, sibling_id_to_int($start), $length);
  }

  public function syntaxGetChildCount(Syntax $syntax)[]: int {
    return node_get_field_0($syntax) === LIST_OR_MISSING_TAG_AFTER_SHIFT
      ? $this->listGetSize($syntax)
      : $this->structs
        ->getMemberCount(node_get_interned_kind<SyntaxKind>($syntax));
  }

  // #region Materialization
  const string VERSION = 'VERSION';
  const int VERSION_NUMBER = 3;
  const string SOURCE_ORDER = 'SOURCE_ORDER';
  const string SIBLINGS = 'SIBLINGS';
  const string LIST_SIZES = 'LIST_SIZES';
  const string SOURCE_TEXT = 'SOURCE_TEXT';
  const string CONTEXT_ID = 'CONTEXT_ID';

  public function dematerialize()[]: ReadyToSerializeScript {
    return shape(
      'script' => dict[
        static::VERSION => static::VERSION_NUMBER,
        static::SOURCE_ORDER => $this->sourceOrder,
        static::SIBLINGS => $this->siblings,
        static::LIST_SIZES => $this->listSizes,
        static::SOURCE_TEXT => $this->sourceText,
        static::CONTEXT_ID => $this->ctx->getMaterializationHash(),
      ],
      'context' => $this->ctx->dematerialize(),
      'context_hash' => $this->ctx->getMaterializationHash(),
    );
  }

  public static function materialize(
    dict<arraykey, mixed> $raw,
    ParseContext $ctx,
  )[]: TranslationUnit {
    enforce(
      idx($raw, static::VERSION) === static::VERSION_NUMBER,
      'Could not materialize this Script, '.
      'it was dematerialized with a different version of this library.',
    );
    enforce(
      $ctx->getMaterializationHash() === $raw[static::CONTEXT_ID],
      'The Context and the Script do not belong together.',
    );

    try {
      return new static(
        $raw['SOURCE_ORDER'] |> as_vec_of_node($$),
        $raw['SIBLINGS'] |> as_vec_of_node($$),
        $raw['LIST_SIZES'] |> as_dict_of_node_id_to_int($$),
        $raw['SOURCE_TEXT'] as string,
        $ctx,
      );
    } catch (\Exception $e) {
      throw new PhaException(
        'Failed to materialize this Script.',
        $e->getCode(),
        $e,
      );
    }
  }
}
