/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\{Keyset, Str, Vec};

async function mixin_hhvm_next_commits_async(
  vec<string> $commit_hashes,
)[defaults]: Awaitable<(dict<string, keyset<string>>, dict<string, string>)> {

  $parsed = await Vec\map_async($commit_hashes, async $hash ==> {
    $gh_content = 'https://raw.githubusercontent.com/facebook/hhvm/';
    $parser_dir = '/hphp/hack/src/parser/';

    $syntax_generated_rs = $gh_content.$hash.$parser_dir.'syntax_generated.rs';
    $token_kind_rs = $gh_content.$hash.$parser_dir.'token_kind.rs';

    concurrent {
      $syntax = await curl_with_file_cache_async($syntax_generated_rs);
      $tokens = await curl_with_file_cache_async($token_kind_rs);
    }

    invariant($syntax is nonnull, 'Failed download %s', $syntax_generated_rs);
    invariant($tokens is nonnull, 'Failed download %s', $token_kind_rs);

    return tuple(parse_syntax_rs($syntax), parse_token_rs($tokens));
  });

  $syntaxes = HHVM_FOUR_SYNTAXES;
  $tokens = HHVM_FOUR_TOKENS;

  foreach ($parsed as list($new_syntaxes, $new_tokens)) {
    foreach ($new_syntaxes as $syntax_kind => $children) {
      $syntaxes[$syntax_kind] ??= keyset[];
      $syntaxes[$syntax_kind] =
        Keyset\union($syntaxes[$syntax_kind], $children);
    }

    foreach ($new_tokens as $token_kind => $name) {
      $tokens[Str\lowercase($token_kind)] ??= $name;
    }
  }

  return tuple($syntaxes, $tokens);
}
