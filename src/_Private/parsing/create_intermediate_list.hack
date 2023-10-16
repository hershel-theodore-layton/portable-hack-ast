/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\Vec;

function create_intermediate_list(
  Wrapped $next,
  int $id,
)[]: (Intermediate, vec<Wrapped>) {
  $list = $next->getItem();

  // Could be a dict or a vec, depending on json_decode() options...
  // This is a square bracket array literal in the json,
  // but the default for `\json_decode()` remains to create a dict.
  // If users decode from `HH\ffp_parse_string_native(...)` and json_decode()
  // with `\JSON_DECODE_HACK_ARRAYS`, we'd see vecs here.
  $elements = $list['elements'] as Container<_>;
  $intermediate = $next->createList($id);
  $children = Vec\map($elements, $el ==> new Wrapped($el as dict<_, _>, $id));

  return tuple($intermediate, $children);
}
