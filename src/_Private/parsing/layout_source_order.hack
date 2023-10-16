/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Dict};

function layout_source_order(
  vec<Intermediate> $intermediates,
)[]: vec<Intermediate> {
  $parents_to_children =
    Dict\group_by($intermediates, $x ==> $x->getParentId());
  $out = vec[$intermediates[0], $intermediates[1]];

  // A `vec[]` is used as a `Stack<T>`, since we can't have `[write_props]`.
  // This makes pushing a little cumbersome, see `$stack->push($to_push)`.
  $stack = vec[tuple(1, 0)];
  $stack_ptr = 0;
  $stack_top = 0;

  do {
    list($node_id, $child_number) = $stack[$stack_ptr];
    $children = idx($parents_to_children, $node_id, vec[]);
    ++$stack[$stack_ptr][1];

    if (C\count($children) > $child_number) {
      $child = $children[$child_number];
      $out[] = $child;

      // `$stack->push($to_push)`, but without `[write_props]`
      $to_push = tuple($child->getId(), 0);
      ++$stack_ptr;
      if ($stack_ptr > $stack_top) {
        $stack[] = $to_push;
        ++$stack_top;
      } else {
        $stack[$stack_ptr] = $to_push;
      }
    } else {
      --$stack_ptr;
    }
  } while ($stack_ptr !== -1);

  return $out;
}
