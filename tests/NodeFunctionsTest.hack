/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use type Facebook\HackTest\{DataProvider, HackTest};
use namespace HH\Lib\{C, File, Vec};
use namespace HTL\Pha;

/**
 * The tests in this class are in no particular order.
 * New tests are just appended to the end (right before fixtures).
 * Test and provider names are snake_case, because:
 *  - It is a style I am used to.
 *  - Most of them refer to a snake_case function name.
 *  - Reading whole sentences in snake_case is easier
 *    to me than reading the same sentence in camelCase.
 */
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
      new Fixtures\Math(await static::parseFixtureAsync('001_math.hack')),
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
    expect(Pha\node_get_group($node))->toEqual($expected);
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

  public function provide_node_get_nth_child(
  )[]: vec<(Pha\NillableNode, int, ?Pha\Kind)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\SCRIPT_NODE, 0, Pha\KIND_LIST),
      tuple(Pha\SCRIPT_NODE, 1, null),
      tuple($math->declarationList, 0, Pha\KIND_NAMESPACE_DECLARATION),
      tuple($math->declarationList, 1, Pha\KIND_FUNCTION_DECLARATION),
      tuple($math->declarationList, 2, Pha\KIND_END_OF_FILE),
      tuple($math->declarationList, 3, null),
      tuple(
        $math->namespaceDeclaration,
        0,
        Pha\KIND_NAMESPACE_DECLARATION_HEADER,
      ),
      tuple($math->namespaceDeclaration, 1, Pha\KIND_NAMESPACE_EMPTY_BODY),
      tuple($math->namespaceDeclarationHeader, 0, Pha\KIND_NAMESPACE),
      tuple($math->namespaceDeclarationHeader, 1, Pha\KIND_QUALIFIED_NAME),
      tuple($math->namespaceToken, 0, Pha\KIND_DELIMITED_COMMENT),
      tuple($math->namespaceToken, 1, Pha\KIND_END_OF_LINE),
      tuple($math->namespaceToken, 2, Pha\KIND_TOKEN_TEXT),
      tuple($math->namespaceToken, 3, Pha\KIND_WHITESPACE),
      tuple($math->namespaceToken, 4, null),
      tuple($math->licenseComment, 0, null),
      tuple(Pha\NIL, 0, null),
    ];
  }

  // We need to test against the Kind,
  // because we have no other way to get a reference to the nth child just yet.
  <<DataProvider('provide_node_get_nth_child')>>
  public function test_node_get_nth_child(
    Pha\NillableNode $node,
    int $n,
    ?Pha\Kind $kind_of_nth_child,
  )[]: void {
    $script = $this->fixtures()->math->script;
    $nth_child = Pha\node_get_nth_child($script, $node, $n);
    expect(
      $nth_child === Pha\NIL
        ? null
        : Pha\node_get_kind($script, Pha\node_as_nonnil($nth_child)),
    )->toEqual($kind_of_nth_child);
  }

  public function test_node_get_nth_child_preconditions()[]: void {
    $script = $this->fixtures()->math->script;
    expect(() ==> Pha\node_get_nth_child($script, Pha\SCRIPT_NODE, -1))
      ->toThrowPhaException('expected a valid offset (0 or greater), got -1.');
  }

  public function test_node_get_nth_childx()[]: void {
    $math = $this->fixtures()->math;
    expect(
      Pha\node_get_nth_childx($math->script, $math->namespaceDeclaration, 0),
    )
      ->toEqual($math->namespaceDeclarationHeader);

    expect(
      () ==>
        Pha\node_get_nth_childx($math->script, $math->namespaceDeclaration, 3),
    )->toThrowPhaException(
      'expected at least 3 children, the given namespace_declaration has no 3rd child.',
    );
  }

  public function provide_syntax_member(
  )[]: vec<(Pha\Syntax, Pha\Member, Pha\Kind)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(
        $math->namespaceDeclaration,
        Pha\MEMBER_NAMESPACE_HEADER,
        Pha\KIND_NAMESPACE_DECLARATION_HEADER,
      ),
      tuple(
        $math->namespaceDeclaration,
        Pha\MEMBER_NAMESPACE_BODY,
        Pha\KIND_NAMESPACE_EMPTY_BODY,
      ),
      tuple(
        $math->namespaceDeclarationHeader,
        Pha\MEMBER_NAMESPACE_KEYWORD,
        Pha\KIND_NAMESPACE,
      ),
      tuple(
        $math->namespaceDeclarationHeader,
        Pha\MEMBER_NAMESPACE_NAME,
        Pha\KIND_QUALIFIED_NAME,
      ),
    ];
  }

  <<DataProvider('provide_syntax_member')>>
  public function test_syntax_member(
    Pha\Syntax $syntax,
    Pha\Member $member,
    Pha\Kind $expected_kind,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(
      Pha\syntax_member($script, $syntax, $member)
        |> Pha\node_get_kind($script, $$),
    )->toEqual($expected_kind);
  }

  public function test_syntax_member_preconditions()[]: void {
    $math = $this->fixtures()->math;
    expect(
      () ==> Pha\syntax_member(
        $math->script,
        $math->namespaceDeclaration,
        Pha\MEMBER_FUNCTION_BODY,
      ),
    )->toThrowPhaException(
      'This namespace_declaration does not have a member named function_body.',
    );
  }

  public function provide_node_get_children(
  )[]: vec<(Pha\NillableNode, vec<Pha\Kind>)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\SCRIPT_NODE, vec[Pha\KIND_LIST]),
      tuple(
        $math->declarationList,
        vec[
          Pha\KIND_NAMESPACE_DECLARATION,
          Pha\KIND_FUNCTION_DECLARATION,
          Pha\KIND_END_OF_FILE,
        ],
      ),
      tuple(
        $math->namespaceDeclaration,
        vec[
          Pha\KIND_NAMESPACE_DECLARATION_HEADER,
          Pha\KIND_NAMESPACE_EMPTY_BODY,
        ],
      ),
      tuple(
        $math->namespaceToken,
        vec[
          Pha\KIND_DELIMITED_COMMENT,
          Pha\KIND_END_OF_LINE,
          Pha\KIND_TOKEN_TEXT,
          Pha\KIND_WHITESPACE,
        ],
      ),
      tuple($math->licenseComment, vec[]),
      tuple(Pha\NIL, vec[]),
    ];
  }

  <<DataProvider('provide_node_get_children')>>
  public function test_node_get_children(
    Pha\NillableNode $node,
    vec<Pha\Kind> $kinds,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Vec\map(
      Pha\node_get_children($script, $node),
      $n ==> Pha\node_get_kind($script, $n),
    ))->toEqual($kinds);
  }

  <<DataProvider('provide_node_get_children')>>
  public function test_node_get_last_child(
    Pha\NillableNode $node,
    vec<Pha\Kind> $kinds_only_look_at_last,
  )[]: void {
    $script = $this->fixtures()->math->script;
    $last_kind = C\last($kinds_only_look_at_last);
    $last_child = Pha\node_get_last_child($script, $node);

    if ($last_kind is null) {
      expect($last_child)->toBeNil();
    } else {
      expect(Pha\node_get_kind($script, Pha\node_as_nonnil($last_child)))
        ->toEqual($last_kind);
    }
  }

  public function test_node_get_last_childx()[]: void {
    $math = $this->fixtures()->math;
    expect(Pha\node_get_last_childx($math->script, $math->namespaceToken))
      ->toEqual(Pha\node_get_last_child($math->script, $math->namespaceToken));
    expect(
      () ==> Pha\node_get_last_childx($math->script, $math->licenseComment),
    )->toThrowPhaException(
      'expected at least one child, got delimited_comment without children.',
    );
  }

  private function fixtures()[]: Fixtures\Fixtures {
    return $this->fixtures as nonnull;
  }

  <<__Memoize>>
  private static async function parseFixtureAsync(
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
