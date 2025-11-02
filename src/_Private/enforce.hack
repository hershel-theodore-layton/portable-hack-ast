/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\Str;
use function vsprintf;

/**
 * Think `invariant(...)`, but for `PhaException` instead.
 * Side note: `invariant()` only evaluates the `$format` and `$args`
 * arguments if `$assertion` is false.
 * If the evaluation is computationally expensive,
 * use `if (!$assertion) { ... }` instead.
 */
function enforce(
  bool $assertion,
  Str\SprintfFormatString $format,
  mixed ...$args
)[]: void {
  if (!$assertion) {
    throw new PhaException(vsprintf($format, $args) as string);
  }
}
