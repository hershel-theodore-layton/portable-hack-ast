/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use namespace HH\Lib\{File, Str};
use function escapeshellarg, md5, shell_exec;

async function file_put_hackfmt_async(
  string $path,
  string $source,
)[defaults]: Awaitable<void> {
  // <cheat>
  // Don't write to disk if the current process just wrote the same bytes.
  $apc_key = Str\format('!%s!(k:$path,v:$source)!::%s', __FUNCTION__, $path);
  $md5 = md5($source);

  $success = false;
  $previous_md5 = \apc_fetch($apc_key, inout $success);

  if ($success && $md5 === $previous_md5) {
    return;
  }
  // </cheat>

  $file = File\open_write_only($path, File\WriteMode::TRUNCATE);

  using (
    $file->closeWhenDisposed(),
    $file->tryLockx(File\LockType::EXCLUSIVE)
  ) {
    await $file->writeAllAsync($source);
  }

  shell_exec('hackfmt -i '.escapeshellarg($path));
  \apc_store($apc_key, $md5);
}
