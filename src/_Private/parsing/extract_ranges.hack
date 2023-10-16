/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\C;

function extract_ranges(
  dict<int, vec<mixed>> $heritage,
)[]: dict<int, (int, int)> {
  $out = dict[];
  $start_range = 0;

  foreach ($heritage as $id => $children) {
    $past_end = $start_range + C\count($children);
    $out[$id] = tuple($start_range, $past_end - 1);
    $start_range = $past_end;
  }

  return $out;
}
