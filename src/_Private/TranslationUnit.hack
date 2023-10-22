/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\Str;
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
}
