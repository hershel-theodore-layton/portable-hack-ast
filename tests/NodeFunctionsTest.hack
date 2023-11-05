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
      tuple($math->declarationList, Pha\KIND_NODE_LIST),
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

  public function test_as_nonnil()[]: void {
    expect(Pha\as_nonnil(Pha\SCRIPT_NODE))->toEqual(Pha\SCRIPT_NODE);
    expect(() ==> Pha\as_nonnil(Pha\NIL))->toThrowPhaException(
      'as_nonnil got NIL',
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
      Pha\node_get_first_childx($math->script, $math->declarationList),
    )->toEqual(Pha\node_get_first_child($math->script, $math->declarationList));
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
      tuple(Pha\SCRIPT_NODE, 0, Pha\KIND_NODE_LIST),
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
        : Pha\node_get_kind($script, Pha\as_nonnil($nth_child)),
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
      'Expected a function_declaration to get member function_body, '.
      'but got namespace_declaration.',
    );
  }

  public function provide_node_get_children(
  )[]: vec<(Pha\NillableNode, vec<Pha\Kind>)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\SCRIPT_NODE, vec[Pha\KIND_NODE_LIST]),
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
      tuple($math->endOfFileToken, vec[Pha\KIND_TOKEN_TEXT]),
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
      expect(Pha\node_get_kind($script, Pha\as_nonnil($last_child)))
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

  public function provide_get_last_descendant(
  )[]: vec<(Pha\NillableNode, Pha\NillableNode)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\NIL, Pha\NIL),
      tuple(Pha\SCRIPT_NODE, $math->endOfFileTokenText),
      tuple($math->missingTypeParameterList, Pha\NIL),
      tuple($math->namespaceDeclaration, $math->newlineAfterNamespaceSemicolon),
      tuple($math->endOfFileTokenText, Pha\NIL),
    ];
  }

  <<DataProvider('provide_get_last_descendant')>>
  public function test_get_last_descendant(
    Pha\NillableNode $node,
    Pha\NillableNode $last_descendant,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\node_get_last_descendant($script, $node))->toEqual(
      $last_descendant,
    );
  }

  public function provide_get_last_descendant_or_self(
  )[]: vec<(Pha\Node, Pha\Node)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\SCRIPT_NODE, $math->endOfFileTokenText),
      tuple($math->missingTypeParameterList, $math->missingTypeParameterList),
      tuple($math->namespaceDeclaration, $math->newlineAfterNamespaceSemicolon),
      tuple($math->endOfFileTokenText, $math->endOfFileTokenText),
    ];
  }

  <<DataProvider('provide_get_last_descendant_or_self')>>
  public function test_get_last_descendant_or_self(
    Pha\Node $node,
    Pha\Node $last_descendant,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\node_get_last_descendant_or_self($script, $node))
      ->toEqual($last_descendant);
  }

  public function provide_node_get_descendants(
  )[]: vec<(Pha\NillableNode, vec<Pha\Node>)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(
        $math->namespaceEmptyBody,
        vec[$math->namespaceSemicolon, $math->namespaceSemicolonTextTrivium],
      ),
      tuple(Pha\NIL, vec[]),
    ];
  }

  <<DataProvider('provide_node_get_descendants')>>
  public function test_node_get_descendants(
    Pha\NillableNode $node,
    vec<Pha\Node> $descendants,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\node_get_descendants($script, $node))->toEqual($descendants);
  }

  public function provide_node_get_ancestors(
  )[]: vec<(Pha\NillableNode, vec<Pha\Node>)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\SCRIPT_NODE, vec[Pha\SCRIPT_NODE]),
      tuple($math->declarationList, vec[Pha\SCRIPT_NODE]),
      tuple(
        $math->licenseComment,
        vec[
          $math->namespaceToken,
          $math->namespaceDeclarationHeader,
          $math->namespaceDeclaration,
          $math->declarationList,
          Pha\SCRIPT_NODE,
        ],
      ),
      tuple(Pha\NIL, vec[]),
    ];
  }

  <<DataProvider('provide_node_get_ancestors')>>
  public function test_node_get_ancestors(
    Pha\NillableNode $node,
    vec<Pha\Node> $ancestors,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\node_get_ancestors($script, $node))->toEqual($ancestors);
  }

  public function provide_syntax_get_parent()[]: vec<(Pha\Syntax, Pha\Syntax)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\SCRIPT_NODE, Pha\SCRIPT_NODE),
      tuple($math->declarationList, Pha\SCRIPT_NODE),
      tuple($math->namespaceDeclaration, $math->declarationList),
      tuple($math->namespaceDeclarationHeader, $math->namespaceDeclaration),
    ];
  }

  <<DataProvider('provide_syntax_get_parent')>>
  public function test_syntax_get_parent(
    Pha\Syntax $node,
    Pha\Syntax $parent,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\syntax_get_parent($script, $node))->toEqual($parent);
  }

  public function provide_token_get_parent()[]: vec<(Pha\Token, Pha\Syntax)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple($math->namespaceToken, $math->namespaceDeclarationHeader),
      tuple($math->endOfFileToken, $math->endOfFileSyntax),
    ];
  }

  <<DataProvider('provide_token_get_parent')>>
  public function test_token_get_parent(
    Pha\Token $node,
    Pha\Syntax $parent,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\token_get_parent($script, $node))->toEqual($parent);
  }

  public function provide_node_is_x()[]: vec<(
    Pha\NillableNode,
    shape('syntax' => bool, 'token' => bool, 'trivium' => bool),
  )> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(
        Pha\SCRIPT_NODE,
        shape('syntax' => true, 'token' => false, 'trivium' => false),
      ),
      tuple(
        $math->declarationList,
        shape('syntax' => true, 'token' => false, 'trivium' => false),
      ),
      tuple(
        $math->missingTypeParameterList,
        shape('syntax' => true, 'token' => false, 'trivium' => false),
      ),
      tuple(
        $math->namespaceToken,
        shape('syntax' => false, 'token' => true, 'trivium' => false),
      ),
      tuple(
        $math->licenseComment,
        shape('syntax' => false, 'token' => false, 'trivium' => true),
      ),
      tuple(
        Pha\NIL,
        shape('syntax' => false, 'token' => false, 'trivium' => false),
      ),
    ];
  }

  <<DataProvider('provide_node_is_x')>>
  public function test_node_is_x(
    Pha\NillableNode $node,
    shape('syntax' => bool, 'token' => bool, 'trivium' => bool) $results,
  )[]: void {
    expect(Pha\is_syntax($node))->toEqual($results['syntax']);
    expect(Pha\is_token($node))->toEqual($results['token']);
    expect(Pha\is_trivium($node))->toEqual($results['trivium']);
  }

  public function provide_node_get_syntax_ancestors(
  )[]: vec<(Pha\NillableNode, vec<Pha\Syntax>)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\SCRIPT_NODE, vec[Pha\SCRIPT_NODE]),
      tuple($math->declarationList, vec[Pha\SCRIPT_NODE]),
      tuple(
        $math->licenseComment,
        vec[
          $math->namespaceDeclarationHeader,
          $math->namespaceDeclaration,
          $math->declarationList,
          Pha\SCRIPT_NODE,
        ],
      ),
      tuple(Pha\NIL, vec[]),
    ];
  }

  <<DataProvider('provide_node_get_syntax_ancestors')>>
  public function test_node_get_syntax_ancestors(
    Pha\NillableNode $node,
    vec<Pha\Syntax> $ancestors,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\node_get_syntax_ancestors($script, $node))->toEqual($ancestors);
  }

  public function provide_node_get_code()[]: vec<(Pha\NillableNode, string)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\NIL, ''),
      tuple(
        $math->licenseComment,
        '/** portable-hack-ast is MIT licensed, see /LICENSE. */',
      ),
      tuple(
        $math->namespaceToken,
        "/** portable-hack-ast is MIT licensed, see /LICENSE. */\n".
        'namespace ',
      ),
      tuple(
        $math->namespaceDeclaration,
        "/** portable-hack-ast is MIT licensed, see /LICENSE. */\n".
        "namespace HTL\\Pha\\Tests\\Fixtures;\n",
      ),
      tuple(
        $math->returnStatement,
        "  return \$a > \$b ? \$a - \$b : \$b - \$a;\n",
      ),
      tuple($math->missingTypeParameterList, ''),
      tuple($math->endOfFileSyntax, ''),
    ];
  }

  <<DataProvider('provide_node_get_code')>>
  public function test_node_get_code(
    Pha\NillableNode $node,
    string $code,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\node_get_code($script, $node))->toEqual($code);
  }

  public function provide_token_get_text_trivium(
  )[]: vec<(Pha\Token, Pha\Trivium)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple($math->namespaceToken, $math->namespaceTokenTextTrivium),
      tuple($math->endOfFileToken, $math->endOfFileTokenText),
    ];
  }

  <<DataProvider('provide_token_get_text_trivium')>>
  public function test_token_get_text_trivium(
    Pha\Token $node,
    Pha\Trivium $text_trivium,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\token_get_text_trivium($script, $node))->toEqual($text_trivium);
  }

  public function provide_list_get_items_of_children(
  )[]: vec<(Pha\NillableSyntax, vec<Pha\Node>)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\NIL, vec[]),
      tuple($math->missingTypeParameterList, vec[]),
      tuple($math->parameterList, vec[$math->parameterA, $math->parameterB]),
    ];
  }

  <<DataProvider('provide_list_get_items_of_children')>>
  public function test_list_get_items_of_children(
    Pha\NillableSyntax $node,
    vec<Pha\Node> $children_of_items,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\list_get_items_of_children($script, $node))->toEqual(
      $children_of_items,
    );
  }

  public function provide_create_matcher(
  )[]: vec<((function(Pha\NillableNode)[]: bool), Pha\NillableNode, bool)> {
    $math = $this->fixtures()->math;
    $script = $math->script;

    $is_always_false = Pha\create_matcher($script, vec[], vec[], vec[]);
    $is_list_or_missing =
      Pha\create_syntax_matcher($script, Pha\KIND_NODE_LIST, Pha\KIND_MISSING);
    $is_list = Pha\create_syntax_matcher($script, Pha\KIND_NODE_LIST);
    $is_missing = Pha\create_syntax_matcher($script, Pha\KIND_MISSING);

    $is_return_statement_or_minus_or_delimited_comment = Pha\create_matcher(
      $script,
      vec[Pha\KIND_RETURN_STATEMENT],
      vec[Pha\KIND_MINUS],
      vec[Pha\KIND_DELIMITED_COMMENT],
    );
    // Testing the vec-ish branch of the switch requires 8+ kinds.
    $is_operator = Pha\create_token_matcher(
      $script,
      Pha\KIND_PLUS,
      Pha\KIND_MINUS,
      Pha\KIND_STAR,
      Pha\KIND_SLASH,
      Pha\KIND_LESS_THAN,
      Pha\KIND_GREATER_THAN,
      Pha\KIND_LESS_THAN_EQUAL,
      Pha\KIND_GREATER_THAN_EQUAL,
      Pha\KIND_EQUAL_EQUAL_EQUAL,
    );

    return vec[
      tuple($is_always_false, Pha\SCRIPT_NODE, false),
      tuple($is_list_or_missing, Pha\NIL, false),
      tuple($is_list_or_missing, Pha\NIL, false),
      tuple($is_list, $math->declarationList, true),
      tuple($is_list, $math->missingTypeParameterList, false),
      tuple($is_missing, $math->declarationList, false),
      tuple($is_missing, $math->missingTypeParameterList, true),
      tuple($is_list_or_missing, $math->missingTypeParameterList, true),
      tuple($is_list_or_missing, $math->licenseComment, false),
      tuple(
        $is_return_statement_or_minus_or_delimited_comment,
        $math->returnStatement,
        true,
      ),
      tuple(
        $is_return_statement_or_minus_or_delimited_comment,
        $math->firstMinusToken,
        true,
      ),
      tuple(
        $is_return_statement_or_minus_or_delimited_comment,
        $math->licenseComment,
        true,
      ),
      tuple(
        $is_return_statement_or_minus_or_delimited_comment,
        Pha\SCRIPT_NODE,
        false,
      ),
      tuple($is_operator, $math->firstMinusToken, true),
      tuple($is_operator, $math->namespaceToken, false),
    ];
  }

  <<DataProvider('provide_create_matcher')>>
  public function test_create_matcher(
    (function(Pha\NillableNode)[]: bool) $is_x,
    Pha\NillableNode $node,
    bool $matches,
  )[]: void {
    expect($is_x($node))->toEqual($matches);
  }

  public function provide_create_member_accessor(
  )[]: vec<(Pha\Syntax, (function(Pha\Syntax)[]: Pha\Node), Pha\Node)> {
    $math = $this->fixtures()->math;
    $script = $math->script;
    return vec[
      tuple(
        $math->functionDeclaration,
        Pha\create_member_accessor(
          $script,
          Pha\MEMBER_FUNCTION_DECLARATION_HEADER,
          Pha\MEMBER_METHODISH_FUNCTION_DECL_HEADER,
        ),
        $math->functionDeclarationHeader,
      ),
      tuple(
        $math->functionDeclaration,
        Pha\create_member_accessor(
          $script,
          Pha\MEMBER_METHODISH_FUNCTION_DECL_HEADER,
          Pha\MEMBER_FUNCTION_DECLARATION_HEADER,
        ),
        $math->functionDeclarationHeader,
      ),
    ];
  }

  <<DataProvider('provide_create_member_accessor')>>
  public function test_create_member_accessor(
    Pha\Syntax $node,
    (function(Pha\Syntax)[]: Pha\Node) $get_member,
    Pha\Node $result,
  )[]: void {
    expect($get_member($node))->toEqual($result);
  }

  public function test_create_member_accessor_unknown_node()[]: void {
    $math = $this->fixtures()->math;
    $script = $math->script;
    $get_member =
      Pha\create_member_accessor($script, Pha\MEMBER_BINARY_OPERATOR);

    expect(() ==> $get_member($math->functionDeclaration))
      ->toThrowPhaException(
        'No syntax accessor defined for function_declaration.',
      );
  }

  public function provide_index_get_nodes_by_kind(
  )[]: vec<(Pha\SyntaxKind, vec<Pha\Syntax>)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\KIND_FUNCTION_DECLARATION, vec[$math->functionDeclaration]),
      tuple(Pha\KIND_REQUIRE_CLAUSE, vec[]),
      tuple(
        Pha\KIND_BINARY_EXPRESSION,
        vec[$math->ternaryCondition, $math->ternaryTrue, $math->ternaryFalse],
      ),
    ];
  }

  <<DataProvider('provide_index_get_nodes_by_kind')>>
  public function test_index_get_nodes_by_kind(
    Pha\SyntaxKind $kind,
    vec<Pha\Syntax> $nodes,
  )[]: void {
    $math = $this->fixtures()->math;
    expect(Pha\index_get_nodes_by_kind($math->syntaxIndex, $kind))->toEqual(
      $nodes,
    );
  }

  public function provide_token_get_text()[]: vec<(Pha\NillableToken, string)> {
    $math = $this->fixtures()->math;
    return vec[
      tuple(Pha\NIL, ''),
      tuple($math->namespaceSemicolon, ';'),
      tuple($math->namespaceToken, 'namespace'),
    ];
  }

  <<DataProvider('provide_token_get_text')>>
  public function test_token_get_text(
    Pha\NillableToken $node,
    string $text,
  )[]: void {
    $script = $this->fixtures()->math->script;
    expect(Pha\token_get_text($script, $node))->toEqual($text);
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

    $ctx = Pha\create_context();
    list($script, $ctx) = Pha\parse($source, $ctx);

    return $script;
  }
}
