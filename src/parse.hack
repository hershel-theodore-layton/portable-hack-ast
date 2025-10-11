/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

use namespace HH;

function parse(string $source, Context $ctx)[]: (Script, Context) {
  $ffp_parsed = HH\ffp_parse_string($source) as dict<_, _>;
  $parse_tree = $ffp_parsed['parse_tree'] as dict<_, _>;
  return parse_from_tree($parse_tree, $source, $ctx);
}
