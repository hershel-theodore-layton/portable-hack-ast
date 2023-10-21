/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

use namespace HH\Lib\Str;

/**
 * @package This file contains all the functions that operate on `Node`.
 * Think of them as methods on the `Node` "class".
 *
 * Some help for searching:
 *  - All functions are in `camel_case()`. `SHOUT_CASE` things are constants.
 *  - Functions that start with `node_` will work on all Nodes,
 *    sometimes even nillable nodes.
 *  - Functions that start with `syntax_`, `token_`, or `trivium_` only work on
 *    syntaxes, tokens, and trivia (or their nillable counterparts) respectively.
 *  - If you have a (nillable) `Node`, but you need a `Syntax`, `Token`,
 *    or `Trivium`, use `node_as_{syntax,token,trivium}()` or use
 *    `node_as_nillable_{syntax,token,trivium}()` if you want nil on errors.
 *    Think of them as `as Syntax` and `?as Syntax` respectively.
 *  - If you have a Nillable<T> and you wish to remove the NIL,
 *    use `node_as_nonnil()`. It returns a nonnill T or throws an exception.
 */

function node_as_nonnil<T as _Private\Any>(
  _Private\Tagged<_Private\Maybe<T>> $node,
)[]: _Private\Tagged<T> {
  if ($node === NIL) {
    throw new _Private\PhaException(Str\format('%s got NIL', __FUNCTION__));
  }

  return _Private\cast_away_nil($node);
}

function node_as_syntax(NillableNode $node)[]: Syntax {
  $ret = node_as_syntax_or_nil($node);

  if ($ret !== NIL) {
    return _Private\cast_away_nil($ret);
  }

  throw new _Private\PhaException(Str\format(
    '%s expected a Syntax, got %s.',
    __FUNCTION__,
    node_get_group_name($node),
  ));
}

function node_as_syntax_or_nil(NillableNode $node)[]: NillableSyntax {
  return $node !== NIL &&
    node_get_group(_Private\cast_away_nil($node)) === NodeGroup::SYNTAX
    ? _Private\syntax_from_node($node)
    : NIL;
}

function node_as_token(NillableNode $node)[]: Token {
  $ret = node_as_token_or_nil($node);

  if ($ret !== NIL) {
    return _Private\cast_away_nil($ret);
  }

  throw new _Private\PhaException(Str\format(
    '%s expected a Token, got %s.',
    __FUNCTION__,
    node_get_group_name($node),
  ));
}

function node_as_token_or_nil(NillableNode $node)[]: NillableToken {
  return $node !== NIL &&
    node_get_group(_Private\cast_away_nil($node)) === NodeGroup::TOKEN
    ? _Private\token_from_node($node)
    : NIL;
}

function node_as_trivium(NillableNode $node)[]: Trivium {
  $ret = node_as_trivium_or_nil($node);

  if ($ret !== NIL) {
    return _Private\cast_away_nil($ret);
  }

  throw new _Private\PhaException(Str\format(
    '%s expected a Trivium, got %s.',
    __FUNCTION__,
    node_get_group_name($node),
  ));
}

function node_as_trivium_or_nil(NillableNode $node)[]: NillableTrivium {
  return $node !== NIL &&
    node_get_group(_Private\cast_away_nil($node)) === NodeGroup::TRIVIUM
    ? _Private\trivium_from_node($node)
    : NIL;
}

function node_get_elaborated_group(Node $node)[]: NodeElaboratedGroup {
  switch (_Private\node_get_field_0($node)) {
    case 0:
      return NodeElaboratedGroup::TRIVIUM;
    case 1:
      return NodeElaboratedGroup::TOKEN;
    case -2:
      return NodeElaboratedGroup::SYNTAX;
    default:
      return _Private\node_get_field_1($node) === 0
        ? NodeElaboratedGroup::MISSING
        : NodeElaboratedGroup::LIST;
  }
}

function node_get_first_child(
  Script $script,
  NillableNode $node,
)[]: NillableNode {
  if ($node === NIL) {
    return NIL;
  }

  $node = _Private\cast_away_nil($node);
  $tu = _Private\translation_unit_reveal($script);

  switch (node_get_elaborated_group($node)) {
    case NodeElaboratedGroup::SYNTAX:
    case NodeElaboratedGroup::TOKEN:
    case NodeElaboratedGroup::LIST:
      return _Private\node_get_field_4($node) + 1
        |> _Private\node_id_from_int($$)
        |> $tu->getNodeByIdx($$);

    case NodeElaboratedGroup::TRIVIUM:
    case NodeElaboratedGroup::MISSING:
      return NIL;
  }
}

function node_get_first_childx(Script $script, Node $node)[]: Node {
  $first_child = node_get_first_child($script, $node);

  if ($first_child === NIL) {
    throw new _Private\PhaException(Str\format(
      '%s expected at least one child, got %s with 0 children.',
      __FUNCTION__,
      node_get_kind($script, $node) |> kind_to_string($$),
    ));
  }

  return _Private\cast_away_nil($first_child);
}

function node_get_group(Node $node)[]: NodeGroup {
  switch (_Private\node_get_field_0($node)) {
    case 0:
      return NodeGroup::TRIVIUM;
    case 1:
      return NodeGroup::TOKEN;
    default:
      return NodeGroup::SYNTAX;
  }
}

function node_get_group_name(NillableNode $node)[]: string {
  if ($node === NIL) {
    return 'NIL';
  }

  switch (node_get_group(_Private\cast_away_nil($node))) {
    case NodeGroup::SYNTAX:
      return 'Syntax';
    case NodeGroup::TOKEN:
      return 'Token';
    case NodeGroup::TRIVIUM:
      return 'Trivium';
  }
}

function node_get_kind(Script $script, Node $node)[]: Kind {
  $tu = _Private\translation_unit_reveal($script);

  switch (node_get_elaborated_group($node)) {
    case NodeElaboratedGroup::SYNTAX:
      $kinds = $tu->getParseContext()->getSyntaxKinds();
      return _Private\node_get_field_1($node)
        |> _Private\interned_string_from_int<SyntaxKind>($$)
        |> $kinds->fromInterned($$);

    case NodeElaboratedGroup::TOKEN:
      $kinds = $tu->getParseContext()->getTokenKinds();
      return _Private\node_get_field_1($node)
        |> _Private\interned_string_from_int<TokenKind>($$)
        |> $kinds->fromInterned($$);

    case NodeElaboratedGroup::TRIVIUM:
      $kinds = $tu->getParseContext()->getTriviumKinds();
      return _Private\node_get_field_1($node)
        |> _Private\interned_string_from_int<TriviumKind>($$)
        |> $kinds->fromInterned($$);

    case NodeElaboratedGroup::LIST:
      return KIND_LIST;
    case NodeElaboratedGroup::MISSING:
      return KIND_MISSING;
  }
}

/**
 * Huh, shouldn't this return a NillableNode?
 * No, every Node is defined to have a parent.
 * The `SCRIPT_NODE` is defined to have a parent of `SCRIPT_NODE`.
 */
function node_get_parent(Script $script, Node $node)[]: Node {
  $tu = _Private\translation_unit_reveal($script);
  return _Private\node_get_field_2($node)
    |> _Private\node_id_from_int($$)
    |> $tu->getNodeByIdx($$);
}

function syntax_get_members(Script $script, Syntax $node)[]: vec<Member> {
  $tu = _Private\translation_unit_reveal($script);
  $structs = $tu->getParseContext()->getStructs();
  $kind = node_get_kind($script, $node) |> kind_to_string($$);
  // This default is needed for List and Missing.
  // They don't get "learned" in the same way any other syntax would.
  return $structs->getRaw()[$kind] ?? vec[];
}
