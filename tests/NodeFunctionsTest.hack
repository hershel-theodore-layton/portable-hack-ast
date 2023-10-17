/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use type Facebook\HackTest\{DataProvider, HackTest};
use namespace HH\Lib\File;
use namespace HTL\Pha;

final class NodeFunctionsTest extends HackTest {
  const string FIXTURE_DIR = __DIR__.'/fixtures/';
  public async function provide_001_math_async(): Awaitable<vec<(Pha\Script)>> {
    return vec[tuple(await static::parse_fixture_async('001_math.hack'))];
  }

  // A bit of a silly test, but there are no other nodes available yet.
  public function test_node_get_group()[]: void {
    expect(Pha\node_get_group(Pha\SCRIPT_NODE))->toEqual(Pha\NodeGroup::SYNTAX);
  }

  // Again a bit of a silly test, but there are no other nodes available yet.
  public function test_node_get_elaborated_group()[]: void {
    expect(Pha\node_get_elaborated_group(Pha\SCRIPT_NODE))->toEqual(
      Pha\NodeElaboratedGroup::SYNTAX,
    );
  }

  // The silly tests just keep coming, but I need node_get_children().
  // WIthout it, I can't write good tests.
  <<DataProvider('provide_001_math_async')>>
  public function test_node_get_kind(Pha\Script $script)[]: void {
    expect(Pha\node_get_kind($script, Pha\SCRIPT_NODE))->toEqual('script');
  }

  <<__Memoize>>
  private static async function parse_fixture_async(
    string $fixture,
  ): Awaitable<Pha\Script> {
    $file = File\open_read_only(static::FIXTURE_DIR.$fixture);
    using ($file->closeWhenDisposed(), $file->tryLockx(File\LockType::SHARED)) {
      $source = await $file->readAllAsync();
    }

    $ctx = new Pha\_Private\ParseContext(
      new Pha\_Private\Structs(dict[]),
      new Pha\_Private\InternedStringStorage(
        vec[],
        Pha\syntax_kind_from_string<>,
      ),
      new Pha\_Private\InternedStringStorage(
        vec[],
        Pha\token_kind_from_string<>,
      ),
      new Pha\_Private\InternedStringStorage(
        vec[],
        Pha\trivium_kind_from_string<>,
      ),
    )
      |> Pha\_Private\context_hide($$);

    list($script, $_) = Pha\parse($source, $ctx);

    return $script;
  }
}
