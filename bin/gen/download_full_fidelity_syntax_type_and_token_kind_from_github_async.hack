/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\{Async, Str, Vec};

async function download_full_fidelity_syntax_type_and_token_kind_from_github_async(
  int $major,
  int $start,
  int $end,
): Awaitable<(keyset<string>, keyset<string>)> {
  $versions = Vec\range($start, $end)
    |> Vec\map($$, $minor ==> 'HHVM-'.$major.'.'.$minor);

  $root = 'https://raw.githubusercontent.com/facebook/hhvm';
  $semaphore =
    new Async\Semaphore(GITHUB_FETCH_CONCURRENCY, curl_with_file_cache_async<>);

  $fetch = async $urls ==>
    await Vec\map_async($urls, $url ==> $semaphore->waitForAsync($url))
    |> Vec\filter_nulls($$)
    |> keyset($$);

  concurrent {
    $syntaxes = await $fetch(
      Vec\map(
        $versions,
        $v ==> Str\format(
          '%s/%s/hphp/hack/src/parser/full_fidelity_syntax_type.ml',
          $root,
          $v,
        ),
      ),
    );
    $tokens = await $fetch(Vec\map(
      $versions,
      $v ==> Str\format(
        '%s/%s/hphp/hack/src/parser/full_fidelity_token_kind.ml',
        $root,
        $v,
      ),
    ));
  }

  return tuple($syntaxes, $tokens);
}
