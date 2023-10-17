/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use type Facebook\HackTest\ExpectationFailedException;
use namespace HH\Lib\Str;
use function json_encode_pure;

/**
 * This is not fbexpect!
 *
 * This function and the returned object are annotated with coeffects.
 * This expect-lib allows for pure test methods in HackTest.
 */
function expect<T>(T $value)[]: ExpectObj<T> {
  return new ExpectObj($value);
}

final class ExpectObj<T> {
  public function __construct(private T $value)[] {}

  public function toEqual(mixed $other)[]: void {
    if ($this->value === $other) {
      return;
    }

    static::fail(
      "Expected `a === b`, but got:\n - %s\n - %s",
      static::serializeValue($this->value),
      static::serializeValue($other),
    );
  }

  private static function serializeValue(mixed $value)[]: string {
    if ($value is null) {
      return 'null';
    }

    if ($value is int) {
      return Str\format('%d (%016x)', $value, $value);
    }

    $_error = null;
    return json_encode_pure($value, inout $_error);
  }

  private static function fail(
    Str\SprintfFormatString $format,
    mixed ...$args
  )[]: nothing {
    throw new ExpectationFailedException(\vsprintf($format, $args));
  }
}
