/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\{Dict, Regex, Str, Vec};

function parse_tokens(string $full_fidelity_token_kind)[]: shape(
  'fixed' => dict<string, string>,
  'variable' => dict<string, string>,
  /*_*/
) {
  $raw = $full_fidelity_token_kind;
  $start_at = <<<'START_AT'
Abstract -> "abstract"
START_AT;

  $suffix = <<<'SUFFIX'

  (* Variable text tokens *)
SUFFIX;

  $fixed_tokens = Str\slice($raw, Str\search($raw, $start_at) as nonnull)
    |> Str\slice($$, 0, Str\search($$, $suffix) as nonnull)
    |> Str\split($$, ' | ')
    |> Vec\map($$, Str\trim<>)
    |> Vec\filter($$)
    |> Vec\map(
      $$,
      $line ==> Regex\first_match($line, re'/(?<token>\w+) -> "(?<text>.+)"/')
        as nonnull,
    )
    |> Dict\pull(
      $$,
      $match ==> $match['text']
        |> $$ === '\\\\' ? '\\' : $$
        |> pascal_case_token_kind_name($$),
      $match ==> Str\replace($match['token'], '_once', 'Once')
        |> pascal_case_token_kind_name($$)
        |> Str\lowercase($$),
    )
    |> Dict\sort_by_key($$);

  $start_at = <<<'START_AT'
ErrorToken -> true
START_AT;

  $suffix = <<<'SUFFIX'

  | _ -> false
SUFFIX;

  $variable_tokens = Str\slice($raw, Str\search($raw, $start_at) as nonnull)
    |> Str\slice($$, 0, Str\search($$, $suffix) as nonnull)
    |> Str\split($$, ' | ')
    |> Vec\map($$, Str\trim<>)
    |> Vec\filter($$)
    |> Vec\map(
      $$,
      $line ==> Regex\first_match($line, re'/(?<token>\w+) -> true/')
        as nonnull,
    )
    |> Vec\map($$, $match ==> pascal_case_token_kind_name($match['token']))
    |> Dict\from_values($$, Str\lowercase<>);

  return shape(
    'fixed' => $fixed_tokens,
    'variable' => $variable_tokens,
  );
}
