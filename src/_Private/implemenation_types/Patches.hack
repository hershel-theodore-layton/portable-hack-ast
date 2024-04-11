/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype Patches = PatchSet;

function patch_set_hide(PatchSet $patch_set)[]: Patches {
  return $patch_set;
}

function patch_set_reveal(Patches $patches)[]: PatchSet {
  return $patches;
}
