/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

function create_intermediate_syntax(
  Wrapped $next,
  int $id,
)[]: (Intermediate, vec<Wrapped>) {
  $syntax = $next->getItem();

  $intermediate = $next->createSyntax($id, $syntax['kind'] as string);

  $children = vec[];
  foreach ($syntax as $key => $el) {
    if ($key === 'kind') {
      continue;
    }

    $children[] = new Wrapped($el as dict<_, _>, $id);
  }

  return tuple($intermediate, $children);
}
