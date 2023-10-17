/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests\Fixtures;

function math(int $a, int $b)[]: int {
  return $a > $b ? $a - $b : $b - $a;
}
