/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH;
use namespace HH\Lib\{Regex, Str, Vec};
use type UnexpectedValueException;

function extract_major_start_and_end_from_argv(
)[defaults]: (string, int, int, int) {
  $argv = HH\global_get('argv') as vec<_>
    |> Vec\concat($$, Vec\fill(10, "\0"))
    |> Vec\map($$, $el ==> $el as string);

  list($program, $range) = $argv;

  if ($range === "\0") {
    throw new UnexpectedValueException(Str\format(
      "Usage:   %s <version range>\nExample: %s \"4.94-172\"\n",
      $program,
      $program,
    ));
  }

  $regex = re'/^(?<major>\d)\.(?<minor_start>\d{1,3})-(?<minor_end>\d{1,3})$/';
  $range = Regex\first_match($range, $regex);

  if ($range is null) {
    throw new UnexpectedValueException(
      "Please supply the hhvm version range in this form:\n\n  4.102-168\n\n",
    );
  }

  $to_int = $str ==> Str\to_int($str) as nonnull;

  $ret = tuple(
    $program,
    $to_int($range['major']),
    $to_int($range['minor_start']),
    $to_int($range['minor_end']),
  );

  if ($ret[1] < 4 || $ret[2] < 94) {
    throw new UnexpectedValueException(
      "Sorry, unable to parse code from before HHVM-4.94.\n".
      "The following commit formatted all the generated ocaml.\n".
      "https://github.com/facebook/hhvm/commit/951c48c3eb069e1854b5f84b7f40f3e9d276c036\n".
      "The parsing logic breaks on unformatted ocaml.\n",
    );
  }

  return $ret;
}
