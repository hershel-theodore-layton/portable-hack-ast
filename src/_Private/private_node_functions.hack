/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\Math;
use namespace HTL\Pha;

const int FIELD_4_SIZE = 18;
const int FIELD_3_SIZE = 18;
const int FIELD_2_SIZE = 18;
const int FIELD_1_SIZE = 8;
const int FIELD_0_SIZE = 2;

const int FIELD_4_OFFSET = 0;
const int FIELD_3_OFFSET = FIELD_4_OFFSET + FIELD_4_SIZE;
const int FIELD_2_OFFSET = FIELD_3_OFFSET + FIELD_3_SIZE;
const int FIELD_1_OFFSET = FIELD_2_OFFSET + FIELD_2_SIZE;
const int FIELD_0_OFFSET = FIELD_1_OFFSET + FIELD_1_SIZE;

const int FIELD_4_MASK = (1 << FIELD_4_SIZE) - 1;
const int FIELD_3_MASK = (1 << FIELD_3_SIZE) - 1;
const int FIELD_2_MASK = (1 << FIELD_2_SIZE) - 1;
const int FIELD_1_MASK = (1 << FIELD_1_SIZE) - 1;
const int FIELD_0_MASK = (1 << FIELD_0_SIZE) - 1;

// This mask is the KindIdentity mask for non-LIST and non-MISSING nodes.
const int FIELD_01_PRE_SHIFT_MASK =
  (FIELD_0_MASK << FIELD_0_OFFSET) | (FIELD_1_MASK << FIELD_1_OFFSET);
// This mask is the IndexMask for non-LIST and non-MISSING nodes.
const int FIELD_14_PRE_SHIFT_MASK =
  (FIELD_1_MASK << FIELD_1_OFFSET) | (FIELD_4_MASK << FIELD_4_OFFSET);

const int SYNTAX_TAG = Math\INT64_MIN;
const int TOKEN_TAG = 1 << 62;
const int TRIVIUM_TAG = 0;
const int LIST_OR_MISSING_TAG = Math\INT64_MIN | (1 << 62);

const int SYNTAX_TAG_AFTER_SHIFT = SYNTAX_TAG >> FIELD_0_OFFSET;
const int TOKEN_TAG_AFTER_SHIFT = TOKEN_TAG >> FIELD_0_OFFSET;
const int TRIVIUM_TAG_AFTER_SHIFT = TRIVIUM_TAG >> FIELD_0_OFFSET;
const int LIST_OR_MISSING_TAG_AFTER_SHIFT =
  LIST_OR_MISSING_TAG >> FIELD_0_OFFSET;

const int MAX_INTERNED_STRING = FIELD_1_MASK;

/**
 * Careful, if `$kind` is `KIND_NODE_LIST` or `KIND_MISSING`, you'll get a non
 * matching identity.
 */
function create_syntax_identity(
  Script $script,
  SyntaxKind $kind,
)[]: KindIdentity {
  if ($kind === Pha\KIND_NODE_LIST || $kind === Pha\KIND_MISSING) {
    // This is a hack, these nodes don't have an identity.
    // Just return the greatest trivium kind there is.
    // If we ever get to a world with max trivia, consider this
    // a classic case of "This should never happen.".
    return TRIVIUM_TAG | (MAX_INTERNED_STRING << FIELD_1_OFFSET)
      |> kind_identity_from_int($$);
  }

  $ctx = translation_unit_reveal($script)->getParseContext();
  return $ctx->getSyntaxKinds()->internOrMax($kind)
    |> interned_string_to_int($$) << FIELD_1_OFFSET
    |> $$ | SYNTAX_TAG
    |> kind_identity_from_int($$);
}

function create_token_identity(
  Script $script,
  TokenKind $kind,
)[]: KindIdentity {
  $ctx = translation_unit_reveal($script)->getParseContext();
  return $ctx->getTokenKinds()->internOrMax($kind)
    |> interned_string_to_int($$) << FIELD_1_OFFSET
    |> $$ | TOKEN_TAG
    |> kind_identity_from_int($$);
}

function create_trivium_identity(
  Script $script,
  TriviumKind $kind,
)[]: KindIdentity {
  $ctx = translation_unit_reveal($script)->getParseContext();
  return $ctx->getTriviumKinds()->internOrMax($kind)
    |> interned_string_to_int($$) << FIELD_1_OFFSET
    |> $$ | TRIVIUM_TAG
    |> kind_identity_from_int($$);
}

/**
 * Mind the sign extension,
 * so `10`, and `11` will be `...11111110` and `...11111111` respectively.
 */
function node_get_field_0(NillableNode $node)[]: int {
  return node_to_int($node) >> FIELD_0_OFFSET;
}

function node_get_field_1(NillableNode $node)[]: int {
  return node_to_int($node) >> FIELD_1_OFFSET |> $$ & FIELD_1_MASK;
}

function node_get_field_2(NillableNode $node)[]: int {
  return node_to_int($node) >> FIELD_2_OFFSET |> $$ & FIELD_2_MASK;
}

function node_get_field_3(NillableNode $node)[]: int {
  return node_to_int($node) >> FIELD_3_OFFSET |> $$ & FIELD_3_MASK;
}

function node_get_field_4(NillableNode $node)[]: int {
  return node_to_int($node) & FIELD_4_MASK;
}

function node_get_id(Node $node)[]: NodeId {
  return node_get_field_4($node) |> node_id_from_int($$);
}

/**
 * Careful, if `$node` is `LIST` or `MISSING`, you'll get junk.
 */
function node_get_index_mask(Node $node)[]: IndexMask {
  return
    node_to_int($node) & FIELD_14_PRE_SHIFT_MASK |> index_mask_from_int($$);
}

/**
 * Careful, if `$node` is `LIST` or `MISSING`, you'll get junk.
 */
function node_get_interned_kind<<<__Explicit>> T as Kind>(
  Node $node,
)[]: InternedString<T> {
  return node_get_field_1($node) |> interned_string_from_int<T>($$);
}

/**
 * Careful, if `$node` is `LIST` or `MISSING`, you'll get junk.
 */
function node_get_kind_identity(Node $node)[]: KindIdentity {
  return
    node_to_int($node) & FIELD_01_PRE_SHIFT_MASK |> kind_identity_from_int($$);
}

/**
 * This *may* read past the end of the Node to find the very next trivium.
 * This is a very strange function, therefore private.
 */
function node_get_next_trivium(
  Script $script,
  NillableNode $node,
)[]: NillableTrivium {
  if ($node === NIL) {
    return NIL_TRIVIUM;
  }

  $tu = translation_unit_reveal($script);

  do {
    $node = cast_away_nil($node)
      |> node_get_id($$)
      |> node_id_add($$, 1)
      |> $tu->getNodeById($$);
  } while (!Pha\is_trivium($node) && $node !== NIL);

  return $node === NIL ? NIL_TRIVIUM : trivium_from_node($node);
}

function node_get_parent_id_UNSAFE(Node $node)[]: NodeId {
  return
    node_get_field_4($node) - node_get_field_2($node) |> node_id_from_int($$);
}

function node_is_between_or_at_boundary(
  Node $compare,
  NodeId $start,
  NodeId $end,
)[]: bool {
  return node_get_id($compare)
    |> node_id_to_int($$)
    |> $$ >= node_id_to_int($start) && $$ <= node_id_to_int($end);
}

function syntax_get_first_child_sibling_id(Syntax $node)[]: SiblingId {
  return node_get_field_3($node) |> sibling_id_from_int($$);
}

function token_get_token_text_trivium_id(Token $token)[]: NodeId {
  return node_get_field_3($token) |> node_id_from_int($$);
}

function trivium_get_source_byte_offset(Trivium $trivium)[]: SourceByteOffset {
  return node_get_field_3($trivium) |> source_byte_offset_from_int($$);
}
