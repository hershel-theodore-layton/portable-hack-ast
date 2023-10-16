/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

function create_intermediate_missing(Wrapped $next, int $id)[]: Intermediate {
  return $next->createMissing($id);
}
