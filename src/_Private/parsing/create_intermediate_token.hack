/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Str};
use namespace HTL\Pha;

function create_intermediate_token(
  Wrapped $next,
  int $id,
)[]: (Intermediate, vec<Intermediate>) {
  $token = $next->getItem()['token'] as dict<_, _>;
  $leading_raw = $token['leading'] as dict<_, _>;
  $trailing_raw = $token['trailing'] as dict<_, _>;

  $intermediate = $next->createToken(
    $id,
    Pha\token_kind_from_string($token['kind'] as string),
    C\count($leading_raw),
  );

  $count = 1;
  $leading = create_intermediate_trivia($id, $count, $leading_raw);
  $count += C\count($leading_raw);

  $synthetic_token_text_trivium = new Intermediate(
    IntermediateGroup::TRIVIUM,
    $id + $count,
    $id,
    Pha\KIND_TOKEN_TEXT,
    Str\length($token['text'] as string),
  );
  ++$count;

  $trailing = create_intermediate_trivia($id, $count, $trailing_raw);

  $trivia = vec[];

  foreach ($leading as $trivium) {
    $trivia[] = $trivium;
  }

  $trivia[] = $synthetic_token_text_trivium;

  foreach ($trailing as $trivium) {
    $trivia[] = $trivium;
  }

  return tuple($intermediate, $trivia);
}
