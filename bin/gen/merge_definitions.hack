/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\{Keyset, Vec};

function merge_definitions(
  keyset<string> $full_fidelity_syntax,
  keyset<string> $full_fidelity_token_kind,
): (dict<string, keyset<string>>, dict<string, string>) {
  $syntaxes = dict[];
  foreach (Vec\map($full_fidelity_syntax, parse_syntax<>) as $syntax) {
    foreach ($syntax as $kind => $fields) {
      $syntaxes[$kind] = Keyset\union($syntaxes[$kind] ?? vec[], $fields);
    }
  }

  $tokens = dict[];
  foreach (Vec\map($full_fidelity_token_kind, parse_tokens<>) as $token) {
    foreach ($token['variable'] as $name => $repr) {
      $tokens[$name] ??= $repr;
    }

    foreach ($token['fixed'] as $name => $repr) {
      $tokens[$name] ??= $repr;
    }
  }

  return tuple($syntaxes, $tokens);
}
