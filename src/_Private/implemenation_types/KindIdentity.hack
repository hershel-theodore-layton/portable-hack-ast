/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype KindIdentity as arraykey = int;

function kind_identity_from_int(int $int)[]: KindIdentity {
  return $int;
}

function kind_identity_to_int(KindIdentity $kind_identity)[]: int {
  return $kind_identity;
}
