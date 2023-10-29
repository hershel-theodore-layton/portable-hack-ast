/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\Math;
use namespace HTL\Pha;

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

const int FIELD_01_MASK =
  (FIELD_0_SIZE << FIELD_0_OFFSET) | (FIELD_1_SIZE << FIELD_1_OFFSET);
const int SYNTAX_TAG = Math\INT64_MIN;
const int TOKEN_TAG = 1 << 62;
const int TRIVIUM_TAG = 0;
const int LIST_OR_MISSING_TAG = (Math\INT64_MIN) | (1 << 62);

const int MAX_INTERNED_STRING = FIELD_1_SIZE;

function create_syntax_mask(Script $script, SyntaxKind $kind)[]: int {
  if ($kind === Pha\KIND_LIST_EXPRESSION || $kind === Pha\KIND_MISSING) {
    // This is a hack, these nodes don't have an identity.
    // Just return the greatest trivium kind there is.
    // If we ever get to a world with max trivia, consider this
    // a classic case of "This should never happen.".
    return TRIVIUM_TAG | (MAX_INTERNED_STRING << FIELD_1_OFFSET);
  }

  $ctx = translation_unit_reveal($script)->getParseContext();
  return $ctx->getSyntaxKinds()->internOrMax($kind)
    |> interned_string_to_int($$) << FIELD_1_OFFSET
    |> $$ | SYNTAX_TAG;
}

function create_token_mask(Script $script, TokenKind $kind)[]: int {
  $ctx = translation_unit_reveal($script)->getParseContext();
  return $ctx->getTokenKinds()->internOrMax($kind)
    |> interned_string_to_int($$) << FIELD_1_OFFSET
    |> $$ | TOKEN_TAG;
}

function create_trivium_mask(Script $script, TriviumKind $kind)[]: int {
  $ctx = translation_unit_reveal($script)->getParseContext();
  return $ctx->getTriviumKinds()->internOrMax($kind)
    |> interned_string_to_int($$) << FIELD_1_OFFSET
    |> $$ | TRIVIUM_TAG;
}

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

function node_get_identity_mask(Node $node)[]: int {
  return node_to_int($node) & FIELD_01_MASK;
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
 * This *may* read past the end of the Node to find the very next trivium.
 * This is a very strange function, therefore private.
 */
function node_get_next_trivium(
  Script $script,
  NillableNode $node,
)[]: NillableTrivium {
  if ($node === NIL) {
    return NIL;
  }

  $tu = translation_unit_reveal($script);

  do {
    $node = cast_away_nil($node)
      |> node_get_id($$)
      |> node_id_add($$, 1)
      |> $tu->getNodeById($$);
  } while (!Pha\is_trivium($node) && $node !== NIL);

  return $node === NIL ? NIL : trivium_from_node($node);
}

function node_get_parent_id(Node $node)[]: NodeId {
  return node_get_field_2($node) |> node_id_from_int($$);
}

function syntax_get_first_child_sibling_id(Syntax $node)[]: SiblingId {
  return node_get_field_3($node) |> sibling_id_from_int($$);
}
