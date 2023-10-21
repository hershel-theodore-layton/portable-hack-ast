/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use type Facebook\HackTest\{DataProvider, HackTest};
use namespace HH\Lib\File;
use namespace HTL\Pha;

final class NodeFunctionsTest extends HackTest {
  const string FIXTURE_DIR = __DIR__.'/fixtures/';
  private ?Fixtures\Fixtures $fixtures;

  /**
   * Emulates beforeFirstTestAsync(), but that method is static.
   * Reading $fixtures as a static property requires read_globals.
   * This is not possible from a test context, hence some hoop jumping.
   */
  <<__Override>>
  public async function beforeEachTestAsync(): Awaitable<void> {
    if ($this->fixtures is nonnull) {
      return;
    }

    $this->fixtures = new Fixtures\Fixtures(
      new Fixtures\Math(await static::parse_fixture_async('001_math.hack')),
    );
  }

  public function provide_node_get_group()[]: vec<(Pha\Node, Pha\NodeGroup)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\SCRIPT_NODE, Pha\NodeGroup::SYNTAX),
      tuple($math->declarationList, Pha\NodeGroup::SYNTAX),
      tuple($math->namespaceDeclarationHeader, Pha\NodeGroup::SYNTAX),
      tuple($math->namespaceToken, Pha\NodeGroup::TOKEN),
      tuple($math->licenseComment, Pha\NodeGroup::TRIVIUM),
    ];
  }

  <<DataProvider('provide_node_get_group')>>
  public function test_node_get_group(
    Pha\Node $node,
    Pha\NodeGroup $expected,
  )[]: void {
    expect(Pha\node_get_group(Pha\SCRIPT_NODE))->toEqual(Pha\NodeGroup::SYNTAX);
  }

  public function provide_node_get_elaborated_group(
  )[]: vec<(Pha\Node, Pha\NodeElaboratedGroup)> {
    $math = $this->fixtures()->math;
    // Future Test: Access a Missing to get `::MISSING`.
    return vec[
      tuple(Pha\SCRIPT_NODE, Pha\NodeElaboratedGroup::SYNTAX),
      tuple($math->declarationList, Pha\NodeElaboratedGroup::LIST),
      tuple($math->namespaceDeclarationHeader, Pha\NodeElaboratedGroup::SYNTAX),
      tuple($math->namespaceToken, Pha\NodeElaboratedGroup::TOKEN),
      tuple($math->licenseComment, Pha\NodeElaboratedGroup::TRIVIUM),
    ];
  }

  <<DataProvider('provide_node_get_elaborated_group')>>
  public function test_node_get_elaborated_group(
    Pha\Node $node,
    Pha\NodeElaboratedGroup $group,
  )[]: void {
    expect(Pha\node_get_elaborated_group($node))->toEqual($group);
  }

  public function provide_node_get_kind()[]: vec<(Pha\Node, Pha\Kind)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\SCRIPT_NODE, Pha\KIND_SCRIPT),
      tuple($math->declarationList, Pha\KIND_LIST),
      tuple(
        $math->namespaceDeclarationHeader,
        Pha\KIND_NAMESPACE_DECLARATION_HEADER,
      ),
      tuple($math->namespaceToken, Pha\KIND_NAMESPACE),
      tuple($math->licenseComment, Pha\KIND_DELIMITED_COMMENT),
    ];
  }

  <<DataProvider('provide_node_get_kind')>>
  public function test_node_get_kind(Pha\Node $node, Pha\Kind $kind)[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\node_get_kind($script, $node))->toEqual($kind);
  }

  public function provide_syntax_get_members(
  )[]: vec<(Pha\Syntax, vec<Pha\Member>)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\SCRIPT_NODE, vec[Pha\MEMBER_SCRIPT_DECLARATIONS]),
      tuple($math->declarationList, vec[]),
      tuple(
        $math->namespaceDeclarationHeader,
        vec[Pha\MEMBER_NAMESPACE_KEYWORD, Pha\MEMBER_NAMESPACE_NAME],
      ),
    ];
  }

  <<DataProvider('provide_syntax_get_members')>>
  public function test_syntax_get_members(
    Pha\Syntax $node,
    vec<Pha\Member> $member_names,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\syntax_get_members($script, $node))->toEqual($member_names);
  }

  public function test_node_as_nonnil()[]: void {
    expect(Pha\node_as_nonnil(Pha\SCRIPT_NODE))->toEqual(Pha\SCRIPT_NODE);
    expect(() ==> Pha\node_as_nonnil(Pha\NIL))->toThrowPhaException(
      'node_as_nonnil got NIL',
    );
  }

  public function provide_node_get_first_child(
  )[]: vec<(Pha\NillableNode, Pha\NillableNode)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\SCRIPT_NODE, $math->declarationList),
      tuple($math->declarationList, $math->namespaceDeclaration),
      tuple($math->namespaceDeclaration, $math->namespaceDeclarationHeader),
      tuple($math->namespaceDeclarationHeader, $math->namespaceToken),
      tuple($math->namespaceToken, $math->licenseComment),
      tuple($math->licenseComment, Pha\NIL),
      tuple(Pha\NIL, Pha\NIL),
    ];
  }

  <<DataProvider('provide_node_get_first_child')>>
  public function test_node_get_first_child(
    Pha\NillableNode $parent,
    Pha\NillableNode $first_child,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\node_get_first_child($script, $parent))->toEqual($first_child);
  }

  public function test_node_get_first_childx()[]: void {
    $math = $this->fixtures()->math;
    expect(
      () ==> Pha\node_get_first_childx($math->script, $math->licenseComment),
    )->toThrowPhaException(
      'expected at least one child, got delimited_comment with 0 children.',
    );
  }

  public function provide_node_get_parent()[]: vec<(Pha\Node, Pha\Node)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\SCRIPT_NODE, Pha\SCRIPT_NODE),
      tuple($math->declarationList, Pha\SCRIPT_NODE),
      tuple($math->namespaceDeclaration, $math->declarationList),
      tuple($math->namespaceDeclarationHeader, $math->namespaceDeclaration),
      tuple($math->namespaceToken, $math->namespaceDeclarationHeader),
      tuple($math->licenseComment, $math->namespaceToken),
    ];
  }

  <<DataProvider('provide_node_get_parent')>>
  public function test_node_get_parent(
    Pha\Node $node,
    Pha\Node $parent,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\node_get_parent($script, $node))->toEqual($parent);
  }

  private function fixtures()[]: Fixtures\Fixtures {
    return $this->fixtures as nonnull;
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
