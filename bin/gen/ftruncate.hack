/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\File;

/**
 * $file->truncate() is not available in hhvm 4.128.
 * Reimplement this based on the PHP apis of your.
 */
function ftruncate(File\Handle $file, int $size): void {
  // Even more legacy baggage.
  // $file->getPath() used to return a path object.
  // This gets the string path on any version of hhvm.
  $path = (): string ==> {
    $path_as_object_or_string = $file->getPath();
    if ($path_as_object_or_string is string) {
      return $path_as_object_or_string;
    }

    return $path_as_object_or_string->toString();
  }();

  \fopen($path, 'r+') |> \ftruncate($$, $size);
}
