/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

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
      $trivium['kind'] as string,
      $trivium['text'] as string,
    );
    ++$count;
  }

  return $out;
}
