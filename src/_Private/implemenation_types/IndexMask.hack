/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype IndexMask as arraykey = int;

function index_mask_from_int(int $int)[]: IndexMask {
  return $int;
}

function index_mask_to_int(IndexMask $index_mask)[]: int {
  return $index_mask;
}
