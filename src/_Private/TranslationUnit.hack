/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\Str;
use namespace HTL\Pha;
use type OutOfBoundsException;
use function dechex;

final class TranslationUnit {
  /**
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
      throw
        new PhaException(Str\format('No node has sibling id: %d', $node_id));
    }
  }

  public function getNodeBySiblingId(SiblingId $sibling_id)[]: Node {
    $sibling_id = sibling_id_to_int($sibling_id);
    try {
      return $this->siblings[$sibling_id];
    } catch (OutOfBoundsException $_) {
      throw
        new PhaException(Str\format('No node has sibling id: %d', $sibling_id));
    }
  }

  public function getParseContext()[]: ParseContext {
    return $this->ctx;
  }
}
