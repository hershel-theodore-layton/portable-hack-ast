/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{Math, Str};

function create_node(
  Intermediate $node,
  int $source_order_idx,
  int $parent_idx,
  (int, int) $child_range,
  ParseContext $ctx,
  inout int $byte_offset,
)[]: Node {
  $kind = $node->getKind();

  // See bin/pseudo-fields.documentation.txt
  switch ($node->getGroup()) {
    case IntermediateGroup::SYNTAX:
      $field_0 = Math\INT64_MIN; // 10
      $field_1 =
        $ctx->getSyntaxKinds()->intern($kind) |> interned_string_to_int($$);
      $field_3 = $child_range[0];
      break;
    case IntermediateGroup::TOKEN:
      $field_0 = 1 << 62; // 01
      $field_1 =
        $ctx->getTokenKinds()->intern($kind) |> interned_string_to_int($$);
      $field_3 = $source_order_idx + $node->getTokenTextTriviumOffsetx();
      break;
    case IntermediateGroup::TRIVIUM:
      $field_0 = 0;
      $field_1 =
        $ctx->getTriviumKinds()->intern($kind) |> interned_string_to_int($$);
      $field_3 = $byte_offset;
      $byte_offset += Str\length($node->getTextx());
      break;
    case IntermediateGroup::LIST:
      $field_0 = Math\INT64_MIN | (1 << 62); // 11
      // + 1, because a range from x to x is of length 1, not 0.
      $field_1 =
        Math\minva(FIELD_1_SIZE, $child_range[1] - $child_range[0] + 1);
      $field_3 = $child_range[0];
      break;
    case IntermediateGroup::MISSING:
      $field_0 = Math\INT64_MIN | (1 << 62); // 11
      $field_1 = 0;
      $field_3 = 0;
  }

  $field_2 = $parent_idx;
  $field_4 = $source_order_idx;

  return node_from_int(
    ($field_0) |
      ($field_1 << 54) |
      ($field_2 << 36) |
      ($field_3 << 18) |
      $field_4,
  );
}
