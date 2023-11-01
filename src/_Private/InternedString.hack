/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype InternedString<+T> as arraykey = int;

function interned_string_from_int<<<__Explicit>> T>(
  int $int,
)[]: InternedString<T> {
  return $int;
}

function interned_string_recast_t<<<__Explicit>> T>(
  InternedString<mixed> $interned_string,
)[]: InternedString<T> {
  return $interned_string;
}

function interned_string_to_int(InternedString<mixed> $interned_string)[]: int {
  return $interned_string;
}
