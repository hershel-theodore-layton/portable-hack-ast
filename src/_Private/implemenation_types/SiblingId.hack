/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype SiblingId as arraykey = int;

function sibling_id_add(SiblingId $sibling_id, int $n)[]: SiblingId {
  return $sibling_id + $n;
}

function sibling_id_to_int(SiblingId $sibling_id)[]: int {
  return $sibling_id;
}

function sibling_id_from_int(int $int)[]: SiblingId {
  return $int;
}
