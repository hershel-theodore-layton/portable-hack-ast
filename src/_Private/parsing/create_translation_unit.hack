/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Vec};

function create_translation_unit(
  vec<Intermediate> $intermediates,
  string $source_text,
  ParseContext $ctx,
)[]: TranslationUnit {
  list($parent_ranges, $siblings_intermediates) =
    layout_siblings($intermediates);
  $source_order = layout_source_order($intermediates);

  $id_to_source_idx = Vec\fill(C\count($intermediates), 0);
  foreach ($source_order as $source_order_idx => $intermediate) {
    $id_to_source_idx[$intermediate->getId()] = $source_order_idx;
  }

  $byte_offset = 0;
  $nodes = vec[];
  $list_sizes = dict[];
  foreach ($source_order as $source_order_idx => $intermediate) {
    $range = idx($parent_ranges, $intermediate->getId(), tuple(0, 0));
    $nodes[] = create_node(
      $intermediate,
      $source_order_idx,
      $id_to_source_idx[$intermediate->getParentId()],
      $range,
      $ctx,
      inout $byte_offset,
    );

    if ($intermediate->getGroup() === IntermediateGroup::LIST) {
      $size = $range[1] - $range[0];
      if ($size >= 0xff) {
        $list_sizes[node_id_from_int($source_order_idx)] = $size;
      }
    }
  }

  $siblings = Vec\map(
    $siblings_intermediates,
    $x ==> $nodes[$id_to_source_idx[$x->getId()]],
  );

  return
    new TranslationUnit($nodes, $siblings, $list_sizes, $source_text, $ctx);
}
