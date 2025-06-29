/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\{Dict, Str, Vec};

function parse_token_rs(string $token_kind_rs)[]: dict<string, string> {
  $start = <<<RUST
impl TokenKind {
    pub fn to_string(self) -> &'static str {
        match self {
RUST;

  $end = <<<RUST
    pub fn from_string(
        keyword: &[u8],
        only_reserved: bool,
    ) -> Option<Self> {
RUST;

  $read_from = Str\search($token_kind_rs, $start);
  invariant($read_from is nonnull, 'No start in token_kind.rs');
  $read_until = Str\search($token_kind_rs, $end);
  invariant($read_until is nonnull, 'No end in token_kind.rs');

  return Str\slice($token_kind_rs, $read_from, $read_until - $read_from)
    |> Str\trim($$)
    |> Str\split($$, "\n")
    |> Vec\filter($$, $x ==> Str\starts_with($x, '            TokenKind::'))
    |> Vec\map($$, $kind ==> {
      $parts = Str\split($kind, ' => ', 2);
      $name = $parts[0] |> Str\split($$, '::', 2)[1];
      $repr =
        $parts[1] |> Str\strip_prefix($$, '"') |> Str\strip_suffix($$, '",');

      return tuple(pascal_case_token_kind_name($name), $repr);
    })
    // @historical_artifact: self_token used to be named `self`
    // It would be strange to have KIND_SELF and KIND_SELF_TOKEN.
    // For this reason, self_token is ignored.
    |> Vec\filter($$, $tuple ==> $tuple[0] !== 'self_token')
    |> Dict\from_entries($$);
}
