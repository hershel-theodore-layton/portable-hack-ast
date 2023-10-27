/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{Str, Vec};

final class TranslationUnit {
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
  )[] {}

  public function debugDumpHex()[]: string {
    $out = "SOURCE ORDER:\n";

    $dump_node = $node ==> Str\format(
      '%x|%02x|%05x|%05x|%05x',
      node_get_field_0($node) & 0b11,
      node_get_field_1($node),
      node_get_field_2($node),
      node_get_field_3($node),
      node_get_field_4($node),
    );

    foreach ($this->sourceOrder as $node) {
      $out .= '  '.$dump_node($node)."\n";
    }

    $out .= "SIBLINGS:\n";
    foreach ($this->siblings as $node) {
      $out .= '  '.$dump_node($node)."\n";
    }

    $out .= "SOURCE TEXT:\n";
    $out .= $this->sourceText;

    return $out;
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

  /**
   * Careful, if `$node` is not a `LIST` or `MISSING`, you'll get junk.
   */
  public function listGetSize(Syntax $syntax)[]: int {
    $stored_length = node_get_field_1($syntax);
    return $stored_length < FIELD_1_SIZE
      ? $stored_length
      : $this->listSizes[node_get_id($syntax)];
  }

  public function sliceSiblings(SiblingId $start, int $length)[]: vec<Node> {
    return Vec\slice($this->siblings, sibling_id_to_int($start), $length);
  }

  public function sliceSourceOrder(NodeId $start, int $length)[]: vec<Node> {
    return Vec\slice($this->sourceOrder, node_id_to_int($start), $length);
  }

  public function sliceSourceText(int $start, int $length)[]: string {
    return Str\slice($this->sourceText, $start, $length);
  }
}
