/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use namespace HH\Lib\File;
use function escapeshellarg, shell_exec;

async function file_put_hackfmt_async(string $path, string $source): Awaitable<void> {
  $file = File\open_write_only($path, File\WriteMode::TRUNCATE);

  using (
    $file->closeWhenDisposed(),
    $file->tryLockx(File\LockType::EXCLUSIVE)
  ) {
    await $file->writeAllAsync($source);
  }

  shell_exec('hackfmt -i '.escapeshellarg($path));
}
