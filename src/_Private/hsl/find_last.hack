/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\C;

/**
 * Semantically equivalent to `Vec\reverse($container) |> C\find($$, $predicate)`,
 * but without the runtime overhead of reversing the vec first.
 */
function find_last<T>(
  vec<T> $container,
  (function(T)[_]: bool) $predicate,
)[ctx $predicate]: ?T {
  for ($i = C\count($container); $i >= 0; --$i) {
    $el = $container[$i];
    if ($predicate($el)) {
      return $el;
    }
  }

  return null;
}
