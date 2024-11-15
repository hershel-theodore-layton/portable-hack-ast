/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\{Regex, Str};

function snake_case_to_camel_case(string $string)[]: string {
  return Regex\replace_with(
    $string,
    re'/([a-z])_([a-z])/',
    $match ==> $match[1].Str\uppercase($match[2]),
  );
}
