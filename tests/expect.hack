/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use type Facebook\HackTest\ExpectationFailedException;
use namespace HH\Lib\Str;
use namespace HTL\Pha;
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

  public function toBeNil()[]: void where T as Pha\NillableNode {
    $this->toEqual(Pha\NIL);
  }

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

  public function toThrowPhaException<Tret>(string $pattern)[]: void
  where
    T as (function()[]: mixed) {
    try {
      ($this->value)();
      static::fail('Expected a PhaException, got none');
    } catch (Pha\PhaException $e) {
      // Implement some nice patterns later.
      if (!Str\contains($e->getMessage(), $pattern)) {
        static::fail(
          "Did not see the excepted pattern:\n - '%s'\n - '%s'",
          $pattern,
          $e->getMessage(),
        );
      }
    }
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
