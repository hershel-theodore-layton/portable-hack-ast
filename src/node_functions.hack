/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

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
 */

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
