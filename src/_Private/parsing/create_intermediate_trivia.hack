/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\Str;
use namespace HTL\Pha;

function create_intermediate_trivia(
  int $id,
  int $count,
  dict<arraykey, mixed> $trivia,
)[]: vec<Intermediate> {
  $out = vec[];

  foreach ($trivia as $trivium) {
    $trivium as dict<_, _>;
    $out[] = new Intermediate(
      IntermediateGroup::TRIVIUM,
      $id + $count,
      $id,
      Pha\trivium_kind_from_string($trivium['kind'] as string),
      Str\length($trivium['text'] as string),
    );
    ++$count;
  }

  return $out;
}
