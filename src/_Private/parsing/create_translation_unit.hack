/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Str, Vec};

function create_translation_unit(
  vec<Intermediate> $intermediates,
  string $source_text,
  ParseContext $ctx,
)[]: TranslationUnit {
  enforce(
    Str\length($source_text) < FIELD_3_MASK_FOR_TRIVIA,
    'Implementation limit: Source may not exceed %d (0x%x) bytes, got %d.',
    FIELD_3_MASK_FOR_TRIVIA,
    FIELD_3_MASK_FOR_TRIVIA,
    Str\length($source_text),
  );

  enforce(
    C\count($intermediates) < FIELD_4_MASK,
    'Implementation limit: Source may not exceed %d (0x%x) nodes, got %d.',
    FIELD_4_MASK,
    FIELD_4_MASK,
    C\count($intermediates),
  );

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
      // + 1, because a range from x to x is of length 1, not 0.
      $size = $range[1] - $range[0] + 1;
      if ($size >= FIELD_1_MASK) {
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
