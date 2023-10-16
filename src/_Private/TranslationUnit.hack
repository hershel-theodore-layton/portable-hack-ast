/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\Str;
use namespace HTL\Pha;
use type OutOfBoundsException;
use function dechex;

final class TranslationUnit {
  public function __construct(
    private vec<Node> $sourceOrder,
    private vec<Node> $siblings,
    private string $sourceText,
    private ParseContext $ctx,
  )[] {}

  public function debugDumpHex()[]: string {
    $out = "SOURCE ORDER:\n";

    foreach ($this->sourceOrder as $node) {
      $node = node_to_int($node);
      $out .= '  '.Str\pad_left(dechex($node), 16, '0')."\n";
    }

    $out .= "SIBLINGS:\n";
    foreach ($this->siblings as $node) {
      $node = node_to_int($node);
      $out .= '  '.Str\pad_left(dechex($node), 16, '0')."\n";
    }

    $out .= "SOURCE TEXT:\n";
    $out .= $this->sourceText;

    return $out;
  }

  public function getNodeById(NodeId $node_id)[]: Node {
    $node_id = node_id_to_int($node_id);
    try {
      return $this->sourceOrder[$node_id];
    } catch (OutOfBoundsException $_) {
      throw new PhaException('No such Node with NodeId: '.$node_id);
    }
  }

  public function nodeKindFromInterned(
    Pha\NodeElaboratedGroup $group,
    InternedString<Kind> $interned,
  )[]: Kind {
    switch ($group) {
      case Pha\NodeElaboratedGroup::SYNTAX:
        return $this->ctx
          ->uninternSyntax(interned_string_recast_t<SyntaxKind>($interned));
      case Pha\NodeElaboratedGroup::TOKEN:
        return $this->ctx
          ->uninternToken(interned_string_recast_t<TokenKind>($interned));
      case Pha\NodeElaboratedGroup::TRIVIUM:
        return $this->ctx
          ->uninternTrivium(interned_string_recast_t<TriviumKind>($interned));
      case Pha\NodeElaboratedGroup::LIST:
        return Pha\KIND_LIST;
      case Pha\NodeElaboratedGroup::MISSING:
        return Pha\KIND_MISSING;
    }
  }
}
