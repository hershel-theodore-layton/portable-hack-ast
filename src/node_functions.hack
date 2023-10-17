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
