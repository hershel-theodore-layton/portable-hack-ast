/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

use namespace HH\Lib\{C, Str};

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

function node_get_children(Script $script, NillableNode $node)[]: vec<Node> {
  if ($node === NIL) {
    return vec[];
  }

  $node = _Private\cast_away_nil($node);
  $tu = _Private\translation_unit_reveal($script);

  switch (node_get_elaborated_group($node)) {
    case NodeElaboratedGroup::SYNTAX:
      $node = _Private\syntax_from_node($node);
      return $tu->sliceSiblings(
        _Private\syntax_get_first_child_sibling_id($node),
        C\count(syntax_get_members($script, $node)),
      );

    case NodeElaboratedGroup::TOKEN:
      $parent_id = _Private\node_get_id($node);
      $child_id = $parent_id;
      $children = vec[];

      for (; ; ) {
        $child_id = _Private\node_id_add($child_id, 1);
        $child = $tu->getNodeByIdx($child_id);
        if ($child === NIL) {
          return $children;
        }

        $child = _Private\cast_away_nil($child);

        if (_Private\node_get_parent_id($child) !== $parent_id) {
          return $children;
        }

        $children[] = $child;
      }

    case NodeElaboratedGroup::LIST:
      $node = _Private\syntax_from_node($node);
      return $tu->sliceSiblings(
        _Private\syntax_get_first_child_sibling_id($node),
        $tu->listGetSize($node),
      );

    case NodeElaboratedGroup::TRIVIUM:
    case NodeElaboratedGroup::MISSING:
      return vec[];
  }
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
      return _Private\node_get_id($node)
        |> _Private\node_id_to_int($$) + 1
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
      return _Private\node_get_interned_kind<SyntaxKind>($node)
        |> $kinds->fromInterned($$);

    case NodeElaboratedGroup::TOKEN:
      $kinds = $tu->getParseContext()->getTokenKinds();
      return _Private\node_get_interned_kind<TokenKind>($node)
        |> $kinds->fromInterned($$);

    case NodeElaboratedGroup::TRIVIUM:
      $kinds = $tu->getParseContext()->getTriviumKinds();
      return _Private\node_get_interned_kind<TriviumKind>($node)
        |> $kinds->fromInterned($$);

    case NodeElaboratedGroup::LIST:
      return KIND_LIST;
    case NodeElaboratedGroup::MISSING:
      return KIND_MISSING;
  }
}

function node_get_nth_child(
  Script $script,
  NillableNode $node,
  int $n,
)[]: NillableNode {
  if ($n === 0) {
    return node_get_first_child($script, $node);
  }

  _Private\enforce(
    $n > 0,
    '%s expected a valid offset (0 or greater), got %d.',
    __FUNCTION__,
    $n,
  );

  if ($node === NIL) {
    return NIL;
  }

  $node = _Private\cast_away_nil($node);

  $tu = _Private\translation_unit_reveal($script);

  switch (node_get_elaborated_group($node)) {
    case NodeElaboratedGroup::SYNTAX:
    case NodeElaboratedGroup::LIST:
      $child_node = _Private\syntax_from_node($node)
        |> _Private\syntax_get_first_child_sibling_id($$)
        |> _Private\sibling_id_add($$, $n)
        |> $tu->getNodeBySiblingId($$);

      if ($child_node === NIL) {
        return NIL;
      }

      $child_node = _Private\cast_away_nil($child_node);
      return
        _Private\node_get_parent_id($child_node) === _Private\node_get_id($node)
          ? $child_node
          : NIL;

    case NodeElaboratedGroup::TOKEN:
      $child_node = _Private\node_get_id($node)
        |> _Private\node_id_add($$, 1 + $n)
        |> $tu->getNodeById($$);

      if ($child_node === NIL) {
        return NIL;
      }

      $child_node = _Private\cast_away_nil($child_node);
      return
        _Private\node_get_parent_id($child_node) === _Private\node_get_id($node)
          ? $child_node
          : NIL;

    case NodeElaboratedGroup::TRIVIUM:
    case NodeElaboratedGroup::MISSING:
      return NIL;
  }
}

function node_get_nth_childx(Script $script, Node $node, int $n)[]: Node {
  $nth_child = node_get_nth_child($script, $node, $n);

  _Private\enforce(
    $nth_child !== NIL,
    'This %s has no %s child.',
    node_get_kind($script, $node) |> kind_to_string($$),
    _Private\grammatical_nth($n),
  );

  return _Private\cast_away_nil($nth_child);
}

/**
 * Huh, shouldn't this return a NillableNode?
 * No, every Node is defined to have a parent.
 * The `SCRIPT_NODE` is defined to have a parent of `SCRIPT_NODE`.
 */
function node_get_parent(Script $script, Node $node)[]: Node {
  $tu = _Private\translation_unit_reveal($script);
  return _Private\node_get_parent_id($node)
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

function syntax_member(Script $script, Syntax $node, Member $member)[]: Node {
  $ii = 0;

  foreach (syntax_get_members($script, $node) as $m) {
    if ($m === $member) {
      return node_get_nth_childx($script, $node, $ii);
    }

    ++$ii;
  }

  throw new _Private\PhaException(Str\format(
    'This %s does not have a member named %s.',
    node_get_kind($script, $node) |> kind_to_string($$),
    $member |> member_to_string($$),
  ));
}
