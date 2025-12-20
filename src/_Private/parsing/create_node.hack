/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\Math;

function create_node(
  Intermediate $node,
  int $source_order_idx,
  int $parent_idx,
  (int, int) $child_range,
  ParseContext $ctx,
  inout int $byte_offset,
)[]: Node {
  // See bin/pseudo-fields.documentation.txt
  switch ($node->getGroup()) {
    case IntermediateGroup::SYNTAX:
      $field_0 = SYNTAX_TAG;
      $field_1 = $ctx->getSyntaxKinds()->intern($node->getSyntaxKind())
        |> interned_string_to_int($$);
      $field_3 = $child_range[0];
      break;
    case IntermediateGroup::TOKEN:
      $field_0 = TOKEN_TAG;
      $field_1 = $ctx->getTokenKinds()->intern($node->getTokenKind())
        |> interned_string_to_int($$);
      $field_3 = $source_order_idx + $node->getTokenTextTriviumOffsetx();
      break;
    case IntermediateGroup::TRIVIUM:
      $field_0 = TRIVIUM_TAG;
      $field_1 = $ctx->getTriviumKinds()->intern($node->getTriviumKind())
        |> interned_string_to_int($$);
      $field_3 = $byte_offset;
      $byte_offset += $node->getTextLengthx();
      break;
    case IntermediateGroup::LIST:
      $field_0 = LIST_OR_MISSING_TAG;
      // + 1, because a range from x to x is of length 1, not 0.
      $field_1 =
        Math\minva(FIELD_1_MASK, $child_range[1] - $child_range[0] + 1);
      $field_3 = $child_range[0];
      break;
    case IntermediateGroup::MISSING:
      $field_0 = LIST_OR_MISSING_TAG;
      $field_1 = 0;
      $field_3 = 0;
  }

  $field_2 = $parent_idx;
  $field_4 = $source_order_idx;

  return node_from_int(
    ($field_0) |
      ($field_1 << FIELD_1_OFFSET) |
      ($field_2 << FIELD_2_OFFSET) |
      ($field_3 << FIELD_3_OFFSET) |
      ($field_4 << FIELD_4_OFFSET),
  );
}
