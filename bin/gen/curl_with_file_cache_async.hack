/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Asio;
use namespace HH\Lib\{File, OS, Str};
use function curl_init, curl_getinfo, md5;
use function error_log;
use const CURLINFO_HTTP_CODE;

const string FOUR_OH_FOUR = 'This file does not exist, returning null!';

async function curl_with_file_cache_async(
  string $url,
)[defaults]: Awaitable<?string> {
  $cache_file = CACHE_DIR.md5($url).'.curl-cache';

  try {
    $f = File\open_read_only($cache_file);
    using ($f->closeWhenDisposed(), $f->tryLockx(File\LockType::SHARED)) {
      $contents = await $f->readAllAsync();
    }
  } catch (OS\NotFoundException $_) {
    $ch = curl_init($url);
    $contents = await Asio\curl_exec($ch);
    $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    error_log(Str\format('[%d]: %s', $status, $url));
    if ($status === 404) {
      $contents = FOUR_OH_FOUR;
    }

    if ($status === 200 || $status === 404) {
      \file_put_contents($cache_file, $contents);
    }
  }

  return $contents === FOUR_OH_FOUR ? null : $contents;
}
