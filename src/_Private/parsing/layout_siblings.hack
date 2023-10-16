/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{Dict, Vec};

/**
 * Get the children of syntax and list nodes.
 * For other nodes, the children are implied:
 *  - Token -> All trivia are sequential
 *  - Trivium / Missing -> Has no children
 *
 * @return (dict<parent_id, (start, end)>, vec<siblings>)
 */
function layout_siblings(
  vec<Intermediate> $intermediates,
)[]: (dict<int, (int, int)>, vec<Intermediate>) {
  $heritage = Vec\filter(
    $intermediates,
    $x ==> (
      $intermediates[$x->getParentId()]->getGroup()
      |> $$ === IntermediateGroup::SYNTAX || $$ === IntermediateGroup::LIST
    ) &&
      $x->getId() !== 0,
  )
    |> Dict\group_by($$, $x ==> $x->getParentId());

  return tuple(extract_ranges($heritage), Vec\flatten($heritage));
}
