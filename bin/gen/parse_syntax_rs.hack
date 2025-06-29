/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\{Dict, Str, Vec};

function parse_syntax_rs(
  string $syntax_generated_rs,
)[]: dict<string, vec<string>> {
  $start = <<<RUST
#[derive(Debug, Clone)]
#[repr(C)]
pub struct EndOfFileChildren<T, V>
RUST;

  $end = <<<RUST
#[derive(Debug, Clone)]
pub enum SyntaxVariant<T, V>
RUST;

  $read_from = Str\search($syntax_generated_rs, $start);
  invariant($read_from is nonnull, 'No start in syntax_generated.rs');
  $read_until = Str\search($syntax_generated_rs, $end);
  invariant($read_until is nonnull, 'No end in syntax_generated.rs');

  return Str\slice($syntax_generated_rs, $read_from, $read_until - $read_from)
    |> Str\trim($$)
    |> Str\split($$, "\n\n")
    |> Vec\map($$, $struct ==> {
      $lines = Str\split($struct, "\n")
        |> Vec\filter(
          $$,
          $l ==> Str\starts_with($l, 'pub ') || Str\starts_with($l, '    pub '),
        );
      $struct_name = Str\slice($lines[0], Str\length('pub struct '))
        |> Str\split($$, 'Children<', 2)[0];
      $children = Vec\slice($lines, 1)
        |> Vec\map(
          $$,
          $l ==>
            Str\slice($l, Str\length('    pub ')) |> Str\split($$, ': ', 2)[0],
        );
      return tuple(pascal_case_token_kind_name($struct_name), $children);
    })
    |> Dict\from_entries($$);
}
