/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

function grammatical_nth(int $n)[]: string {
  // Can't just use NumberFormatter, because it has no contexts.
  $last_two_digits = $n % 100;

  if (
    $last_two_digits === 11 ||
    $last_two_digits === 12 ||
    $last_two_digits === 13
  ) {
    return $n.'th';
  }

  $last_digit = $n % 10;

  if ($last_digit === 1) {
    return $n.'st';
  } else if ($last_digit === 2) {
    return $n.'nd';
  } else if ($last_digit === 3) {
    return $n.'rd';
  }

  return $n.'th';
}
