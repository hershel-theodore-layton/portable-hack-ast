/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\File;

/**
 * $file->truncate() is not available in hhvm 4.128.
 * Reimplement this based on the PHP apis of your.
 */
function ftruncate(File\Handle $file, int $size): void {
  \fopen($file->getPath(), 'r+') |> \ftruncate($$, $size);
}
