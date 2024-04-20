/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HTL\Pha;

function retain_trivia_keep_leading_and_trailing(
  Pha\RetainTrivia $retain_trivia,
)[]: (bool, bool) {
  switch ($retain_trivia) {
    case Pha\RetainTrivia::BOTH:
      return tuple(true, true);
    case Pha\RetainTrivia::NEITHER:
      return tuple(false, false);
    case Pha\RetainTrivia::LEADING:
      return tuple(true, false);
    case Pha\RetainTrivia::TRAILING:
      return tuple(false, true);
  }
}
