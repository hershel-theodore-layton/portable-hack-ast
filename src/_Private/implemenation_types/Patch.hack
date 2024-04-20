/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype Patch = PatchNode;

function patch_node_hide(PatchNode $patch_node)[]: Patch {
  return $patch_node;
}

function patch_node_reveal(Patch $patch)[]: PatchNode {
  return $patch;
}
