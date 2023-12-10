/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

function to_dict_recursively(mixed $maybe_container)[]: mixed {
  if (!$maybe_container is KeyedContainer<_, _>) {
    return $maybe_container;
  }

  $out = dict[];

  foreach ($maybe_container as $key => $value) {
    $out[$key] = to_dict_recursively($value);
  }

  return $out;
}
