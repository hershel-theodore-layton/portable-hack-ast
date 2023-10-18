/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests\Fixtures;

use namespace HTL\Pha;

final class Fixtures {
  public function __construct(public Math $math)[] {}
}

abstract class Fixture {
  final public function __construct(public Pha\Script $script)[] {}
}

final class Math extends Fixture {}
