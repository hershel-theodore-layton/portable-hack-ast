/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\{Dict, Regex, Str, Vec};

<<__Memoize>>
function parse_syntax(string $full_fidelity_syntax): dict<string, vec<string>> {
  $raw = $full_fidelity_syntax;
  $start_at = <<<'START_AT'
EndOfFile of { end_of_file_token: t }
START_AT;

  // This end marker got removed in 5e981d0023960407eba62c2fa46704f7d24a5522
  // Defaulting to `Str\length($$) - 4` in those cases.
  $end_at = <<<'END_AT'
end

module MakeValidated (Token : TokenType) (SyntaxValue : SyntaxValueType)
END_AT;

  return Str\slice($raw, Str\search($raw, $start_at) as nonnull)
    |> Str\slice($$, 0, Str\search($$, $end_at) ?? (Str\length($$) - 4))
    |> Str\split($$, '|')
    |> Vec\map(
      $$,
      $decl ==> Str\split(Str\trim($decl), ' of ') as (string, string),
    )
    |> Dict\pull(
      $$,
      $t ==> Str\trim($t[1], "{}\n [")
        |> Regex\split($$, re'/: t;?/')
        |> Vec\map($$, Str\trim<>)
        |> Vec\filter($$)
        |> Vec\sort($$),
      $t ==> pascal_case_token_kind_name($t[0]),
    );
}
