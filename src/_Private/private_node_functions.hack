/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

const int FIELD_0_SIZE = 0b11;
const int FIELD_1_SIZE = 0xff;
const int FIELD_2_SIZE = 0x3ffff;
const int FIELD_3_SIZE = 0x3ffff;
const int FIELD_4_SIZE = 0x3ffff;
const int FIELD_0_OFFSET = 62;
const int FIELD_1_OFFSET = 54;
const int FIELD_2_OFFSET = 36;
const int FIELD_3_OFFSET = 18;
const int FIELD_4_OFFSET = 0;

/**
 * Mind the sign extension,
 * so `10`, and `11` will be `...11111110` and `...11111111` respectively.
 */
function node_get_field_0(NillableNode $node)[]: int {
  return node_to_int($node) >> FIELD_0_OFFSET;
}

function node_get_field_1(NillableNode $node)[]: int {
  return node_to_int($node) >> FIELD_1_OFFSET |> $$ & FIELD_1_SIZE;
}

function node_get_field_2(NillableNode $node)[]: int {
  return node_to_int($node) >> FIELD_2_OFFSET |> $$ & FIELD_2_SIZE;
}

function node_get_field_3(NillableNode $node)[]: int {
  return node_to_int($node) >> FIELD_3_OFFSET |> $$ & FIELD_3_SIZE;
}

function node_get_field_4(NillableNode $node)[]: int {
  return node_to_int($node) & FIELD_4_SIZE;
}

function node_get_id(Node $node)[]: NodeId {
  return node_get_field_4($node) |> node_id_from_int($$);
}

/**
 * Careful, if `$node` is `LIST` or `MISSING`, you'll get junk.
 */
function node_get_interned_kind<<<__Explicit>> T as Kind>(
  Node $node,
)[]: InternedString<T> {
  return node_get_field_1($node) |> interned_string_from_int<T>($$);
}

function node_get_parent_id(Node $node)[]: NodeId {
  return node_get_field_2($node) |> node_id_from_int($$);
}

function syntax_get_first_child_sibling_id(Syntax $node)[]: SiblingId {
  return node_get_field_3($node) |> sibling_id_from_int($$);
}
