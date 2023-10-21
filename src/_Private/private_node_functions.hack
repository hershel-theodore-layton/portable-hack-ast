/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HTL\Pha;

/**
 * Mind the sign extension,
 * so `10`, and `11` will be `...11111110` and `...11111111` respectively.
 */
function node_get_field_0(NillableNode $node)[]: int {
  return node_to_int($node) >> 62;
}

function node_get_field_1(NillableNode $node)[]: int {
  return node_to_int($node) >> 54 |> $$ & 0xff;
}

function node_get_field_2(NillableNode $node)[]: int {
  return node_to_int($node) >> 36 |> $$ & 0x3ffff;
}

function node_get_field_3(NillableNode $node)[]: int {
  return node_to_int($node) >> 18 |> $$ & 0x3ffff;
}

function node_get_field_4(NillableNode $node)[]: int {
  return node_to_int($node) & 0x3ffff;
}

function node_get_id(Node $node)[]: NodeId {
  return node_get_field_4($node) |> node_id_from_int($$);
}

/**
 * Careful, if `$node` is `LIST` or `MISSING`, you'll get junk.
 */
function node_get_interned_kind<T as Kind>(Node $node)[]: InternedString<T> {
  return node_get_field_1($node) |> interned_string_from_int<T>($$);
}

function node_get_parent_id(Node $node)[]: NodeId {
  return node_get_field_2($node) |> node_id_from_int($$);
}

function syntax_get_first_child_sibling_id(Syntax $node)[]: SiblingId {
  return node_get_field_3($node) |> sibling_id_from_int($$);
}
