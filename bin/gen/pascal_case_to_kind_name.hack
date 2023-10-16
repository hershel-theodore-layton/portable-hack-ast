/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\{C, Regex, Str};

function pascal_case_token_kind_name(string $string): string {
  $fixup_xhp_casing = (string $name) ==> C\contains_key(
    keyset[
      'xhp_category_declaration',
      'xhp_children_declaration',
      'xhp_children_parenthesized_list',
      'xhp_class_attribute',
      'xhp_class_attribute_declaration',
      'xhp_close',
      'xhp_enum_type',
      'xhp_expression',
      'xhp_open',
      'xhp_required',
      'xhp_simple_attribute',
      'xhp_spread_attribute',
    ],
    $name,
  )
    ? $name
    : Str\replace($name, 'xhp_', 'XHP_');

  $fixup_implicit_expressions = (string $name) ==> C\contains_key(
    keyset[
      'literal_expression',
      'prefixed_string_expression',
      'pipe_variable_expression',
      'variable_expression',
    ],
    $name,
  )
    ? Str\strip_suffix($name, '_expression')
    : $name;

  $string = Str\replace($string, 'XHP', 'Xhp')
    |> Regex\replace_with(
      $$,
      re'/([a-z])([A-Z])/',
      $match ==> $match[1].'_'.Str\lowercase($match[2]),
    );
  $string[0] = Str\lowercase($string[0]);
  return $string |> $fixup_xhp_casing($$) |> $fixup_implicit_expressions($$);
}
