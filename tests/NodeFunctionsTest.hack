/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use namespace HH\Lib\{C, File, Str, Vec};
use namespace HTL\{Pha, TestChain};

/**
 * The tests in this class are in no particular order.
 * New tests are just appended to the end (right before fixtures).
 * Test and provider names are snake_case, because:
 *  - It is a style I am used to.
 *  - Most of them refer to a snake_case function name.
 *  - Reading whole sentences in snake_case is easier
 *    to me than reading the same sentence in camelCase.
 */
<<TestChain\Discover>>
async function node_functions_test_async(
  TestChain\Chain $chain,
)[defaults]: Awaitable<TestChain\Chain> {
  $fixtures = new Fixtures\Fixtures(
    new Fixtures\Math(await parse_fixture_async('001_math.hack')),
    new Fixtures\Tiny(await parse_fixture_async('002_tiny.hack')),
  );

  return $chain->group(__FUNCTION__)
    ->testWith2Params(
      'provide_node_get_group',
      ()[]: vec<(Pha\Node, Pha\NodeGroup)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple(Pha\SCRIPT_NODE, Pha\NodeGroup::SYNTAX),
          tuple($math->declarationList, Pha\NodeGroup::SYNTAX),
          tuple($math->namespaceDeclarationHeader, Pha\NodeGroup::SYNTAX),
          tuple($math->namespaceToken, Pha\NodeGroup::TOKEN),
          tuple($math->licenseComment, Pha\NodeGroup::TRIVIUM),
        ];
      },
      (
        Pha\Node $node,
        Pha\NodeGroup $expected,
      )[] ==> {
        expect(Pha\node_get_group($node))->toEqual($expected);
      },
    )
    ->testWith2Params(
      'test_node_get_elaborated_group',
      ()[]: vec<(Pha\Node, Pha\NodeElaboratedGroup)> ==> {
        $math = $fixtures->math;
        // Future Test: Access a Missing to get `::MISSING`.
        return vec[
          tuple(Pha\SCRIPT_NODE, Pha\NodeElaboratedGroup::SYNTAX),
          tuple($math->declarationList, Pha\NodeElaboratedGroup::LIST),
          tuple($math->namespaceDeclarationHeader, Pha\NodeElaboratedGroup::SYNTAX),
          tuple($math->namespaceToken, Pha\NodeElaboratedGroup::TOKEN),
          tuple($math->licenseComment, Pha\NodeElaboratedGroup::TRIVIUM),
        ];
      },
      (
        Pha\Node $node,
        Pha\NodeElaboratedGroup $group,
      )[] ==> {
        expect(Pha\node_get_elaborated_group($node))->toEqual($group);
      },
    )
    ->testWith2Params(
      'test_node_get_kind',
      ()[]: vec<(Pha\Node, Pha\Kind)> ==> {
        $math = $fixtures->math;
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
      },
      (Pha\Node $node, Pha\Kind $kind)[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\node_get_kind($script, $node))->toEqual($kind);
      },
    )
    ->testWith2Params(
      'provide_syntax_get_members',
      ()[]: vec<(Pha\Syntax, vec<Pha\Member>)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple(Pha\SCRIPT_NODE, vec[Pha\MEMBER_SCRIPT_DECLARATIONS]),
          tuple($math->declarationList, vec[]),
          tuple(
            $math->namespaceDeclarationHeader,
            vec[Pha\MEMBER_NAMESPACE_KEYWORD, Pha\MEMBER_NAMESPACE_NAME],
          ),
        ];
      },
      (
        Pha\Syntax $node,
        vec<Pha\Member> $member_names,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\syntax_get_members($script, $node))->toEqual($member_names);
      },
    )
    ->test(
      'test_as_nonnil',
      ()[] ==> {
        expect(Pha\as_nonnil(Pha\SCRIPT_NODE))->toEqual(Pha\SCRIPT_NODE);
        expect(() ==> Pha\as_nonnil(Pha\NIL))->toThrowPhaException(
          'as_nonnil got NIL',
        );
      },
    )
    ->testWith2Params(
      'test_node_get_first_child',
      ()[]: vec<(Pha\NillableNode, Pha\NillableNode)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple(Pha\SCRIPT_NODE, $math->declarationList),
          tuple($math->declarationList, $math->namespaceDeclaration),
          tuple($math->namespaceDeclaration, $math->namespaceDeclarationHeader),
          tuple($math->namespaceDeclarationHeader, $math->namespaceToken),
          tuple($math->namespaceToken, $math->licenseComment),
          tuple($math->licenseComment, Pha\NIL),
          tuple(Pha\NIL, Pha\NIL),
        ];
      },
      (
        Pha\NillableNode $parent,
        Pha\NillableNode $first_child,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\node_get_first_child($script, $parent))->toEqual($first_child);
      },
    )
    ->test('test_node_get_first_childx', ()[] ==> {
      $math = $fixtures->math;
      expect(
        Pha\node_get_first_childx($math->script, $math->declarationList),
      )->toEqual(Pha\node_get_first_child($math->script, $math->declarationList));
      expect(
        () ==> Pha\node_get_first_childx($math->script, $math->licenseComment),
      )->toThrowPhaException(
        'expected at least one child, got delimited_comment with 0 children.',
      );
    })
    ->testWith2Params(
      'test_node_get_parent',
      ()[]: vec<(Pha\Node, Pha\Node)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple(Pha\SCRIPT_NODE, Pha\SCRIPT_NODE),
          tuple($math->declarationList, Pha\SCRIPT_NODE),
          tuple($math->namespaceDeclaration, $math->declarationList),
          tuple($math->namespaceDeclarationHeader, $math->namespaceDeclaration),
          tuple($math->namespaceToken, $math->namespaceDeclarationHeader),
          tuple($math->licenseComment, $math->namespaceToken),
        ];
      },
      (
        Pha\Node $node,
        Pha\Node $parent,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\node_get_parent($script, $node))->toEqual($parent);
      },
    )
    ->testWith3Params(
      'test_node_get_child_at_offset',
      ()[]: vec<(Pha\NillableNode, int, ?Pha\Kind)> ==> {
        $math = $fixtures->math;
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
      },
      (
        Pha\NillableNode $node,
        int $offset,
        ?Pha\Kind $kind,
      )[] ==> {
        // We need to test against the Kind,
        // because we have no other way to get a reference to the nth child just yet.
        $script = $fixtures->math->script;
        $child = Pha\node_get_child_at_offset($script, $node, $offset);
        expect(
          $child === Pha\NIL
            ? null
            : Pha\node_get_kind($script, Pha\as_nonnil($child)),
        )->toEqual($kind);
      },
    )
    ->test('test_node_get_child_at_offset_preconditions', ()[] ==> {
      $script = $fixtures->math->script;
      expect(() ==> Pha\node_get_child_at_offset($script, Pha\SCRIPT_NODE, -1))
        ->toThrowPhaException('expected a valid offset (0 or greater), got -1.');
    })
    ->test('test_node_get_child_at_offsetx', ()[] ==> {
      $math = $fixtures->math;
      expect(
        Pha\node_get_child_at_offsetx(
          $math->script,
          $math->namespaceDeclaration,
          0,
        ),
      )
        ->toEqual($math->namespaceDeclarationHeader);

      expect(
        () ==> Pha\node_get_child_at_offsetx(
          $math->script,
          $math->namespaceDeclaration,
          3,
        ),
      )->toThrowPhaException(
        'expected more children, the given namespace_declaration has no child at offset 3 (4th child).',
      );
    })
    ->testWith3Params(
      'test_syntax_member',
      ()[]: vec<(Pha\Syntax, Pha\Member, Pha\Kind)> ==> {
        $math = $fixtures->math;
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
      },
      (
        Pha\Syntax $syntax,
        Pha\Member $member,
        Pha\Kind $expected_kind,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(
          Pha\syntax_member($script, $syntax, $member)
            |> Pha\node_get_kind($script, $$),
        )->toEqual($expected_kind);
      },
    )
    ->test('test_syntax_member_preconditions', ()[] ==> {
      $math = $fixtures->math;
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
    })
    ->testWith2Params(
      'test_node_get_children',
      ()[]: vec<(Pha\NillableNode, vec<Pha\Kind>)> ==> {
        $math = $fixtures->math;
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
      },
      (
        Pha\NillableNode $node,
        vec<Pha\Kind> $kinds,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Vec\map(
          Pha\node_get_children($script, $node),
          $n ==> Pha\node_get_kind($script, $n),
        ))->toEqual($kinds);
      },
    )
    ->testWith2Params(
      'test_node_get_last_child',
      ()[]: vec<(Pha\NillableNode, vec<Pha\Kind>)> ==> {
        $math = $fixtures->math;
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
      },
      (
        Pha\NillableNode $node,
        vec<Pha\Kind> $kinds_only_look_at_last,
      )[] ==> {
        $script = $fixtures->math->script;
        $last_kind = C\last($kinds_only_look_at_last);
        $last_child = Pha\node_get_last_child($script, $node);

        if ($last_kind is null) {
          expect($last_child)->toBeNil();
        } else {
          expect(Pha\node_get_kind($script, Pha\as_nonnil($last_child)))
            ->toEqual($last_kind);
        }
      },
    )
    ->test('test_node_get_last_childx', ()[] ==> {
      $math = $fixtures->math;
      expect(Pha\node_get_last_childx($math->script, $math->namespaceToken))
        ->toEqual(Pha\node_get_last_child($math->script, $math->namespaceToken));
      expect(
        () ==> Pha\node_get_last_childx($math->script, $math->licenseComment),
      )->toThrowPhaException(
        'expected at least one child, got delimited_comment without children.',
      );
    })
    ->testWith2Params(
      'test_get_last_descendant',
      ()[]: vec<(Pha\NillableNode, Pha\NillableNode)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple(Pha\NIL, Pha\NIL),
          tuple(Pha\SCRIPT_NODE, $math->endOfFileTokenText),
          tuple($math->missingTypeParameterList, Pha\NIL),
          tuple($math->namespaceDeclaration, $math->newlineAfterNamespaceSemicolon),
          tuple($math->endOfFileTokenText, Pha\NIL),
        ];
      },
      (
        Pha\NillableNode $node,
        Pha\NillableNode $last_descendant,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\node_get_last_descendant($script, $node))->toEqual(
          $last_descendant,
        );
      },
    )
    ->testWith2Params(
      'test_get_last_descendant_or_self',
      ()[]: vec<(Pha\Node, Pha\Node)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple(Pha\SCRIPT_NODE, $math->endOfFileTokenText),
          tuple($math->missingTypeParameterList, $math->missingTypeParameterList),
          tuple($math->namespaceDeclaration, $math->newlineAfterNamespaceSemicolon),
          tuple($math->endOfFileTokenText, $math->endOfFileTokenText),
        ];
      },
      (
        Pha\Node $node,
        Pha\Node $last_descendant,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\node_get_last_descendant_or_self($script, $node))
          ->toEqual($last_descendant);
      },
    )
    ->testWith2Params(
      'test_node_get_descendants',
      ()[]: vec<(Pha\NillableNode, vec<Pha\Node>)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple(
            $math->namespaceEmptyBody,
            vec[
              $math->namespaceSemicolon,
              $math->namespaceSemicolonTextTrivium,
              $math->newlineAfterNamespaceSemicolon,
            ],
          ),
          tuple(Pha\NIL, vec[]),
        ];
      },
      (
        Pha\NillableNode $node,
        vec<Pha\Node> $descendants,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\node_get_descendants($script, $node))->toEqual($descendants);
      },
    )
    ->testWith2Params(
      'test_node_get_ancestors',
      ()[]: vec<(Pha\NillableNode, vec<Pha\Node>)> ==> {
        $math = $fixtures->math;
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
      },
      (
        Pha\NillableNode $node,
        vec<Pha\Node> $ancestors,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\node_get_ancestors($script, $node))->toEqual($ancestors);
      },
    )
    ->testWith2Params(
      'test_syntax_get_parent',
      ()[]: vec<(Pha\Syntax, Pha\Syntax)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple(Pha\SCRIPT_NODE, Pha\SCRIPT_NODE),
          tuple($math->declarationList, Pha\SCRIPT_NODE),
          tuple($math->namespaceDeclaration, $math->declarationList),
          tuple($math->namespaceDeclarationHeader, $math->namespaceDeclaration),
        ];
      },
      (
        Pha\Syntax $node,
        Pha\Syntax $parent,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\syntax_get_parent($script, $node))->toEqual($parent);
      },
    )
    ->testWith2Params(
      'test_token_get_parent',
      ()[]: vec<(Pha\Token, Pha\Syntax)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple($math->namespaceToken, $math->namespaceDeclarationHeader),
          tuple($math->endOfFileToken, $math->endOfFileSyntax),
        ];
      },
      (
        Pha\Token $node,
        Pha\Syntax $parent,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\token_get_parent($script, $node))->toEqual($parent);
      },
    )
    ->testWith2Params(
      'test_node_is_x',
      ()[]: vec<(
        Pha\NillableNode,
        shape('syntax' => bool, 'token' => bool, 'trivium' => bool /*_*/),
      )> ==> {
        $math = $fixtures->math;
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
      },
      (
        Pha\NillableNode $node,
        shape('syntax' => bool, 'token' => bool, 'trivium' => bool /*_*/) $results,
      )[] ==> {
        expect(Pha\is_syntax($node))->toEqual($results['syntax']);
        expect(Pha\is_token($node))->toEqual($results['token']);
        expect(Pha\is_trivium($node))->toEqual($results['trivium']);
      },
    )
    ->testWith2Params(
      'test_node_get_syntax_ancestors',
      ()[]: vec<(Pha\NillableNode, vec<Pha\Syntax>)> ==> {
        $math = $fixtures->math;
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
      },
      (
        Pha\NillableNode $node,
        vec<Pha\Syntax> $ancestors,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\node_get_syntax_ancestors($script, $node))->toEqual($ancestors);
      },
    )
    ->testWith2Params(
      'test_node_get_code',
      ()[]: vec<(Pha\NillableNode, string)> ==> {
        $math = $fixtures->math;
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
      },
      (
        Pha\NillableNode $node,
        string $code,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\node_get_code($script, $node))->toEqual($code);
      },
    )
    ->testWith2Params(
      'test_token_get_text_trivium',
      ()[]: vec<(Pha\Token, Pha\Trivium)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple($math->namespaceToken, $math->namespaceTokenTextTrivium),
          tuple($math->endOfFileToken, $math->endOfFileTokenText),
        ];
      },
      (
        Pha\Token $node,
        Pha\Trivium $text_trivium,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\token_get_text_trivium($script, $node))->toEqual($text_trivium);
      },
    )
    ->testWith2Params(
      'list_get_items_of_children',
      ()[]: vec<(Pha\NillableSyntax, vec<Pha\Node>)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple(Pha\NIL, vec[]),
          tuple($math->missingTypeParameterList, vec[]),
          tuple($math->parameterList, vec[$math->parameterA, $math->parameterB]),
        ];
      },
      (
        Pha\NillableSyntax $node,
        vec<Pha\Node> $children_of_items,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\list_get_items_of_children($script, $node))->toEqual(
          $children_of_items,
        );
      },
    )
    ->testWith3Params(
      'test_create_matcher',
      ()[]: vec<((function(Pha\NillableNode)[]: bool), Pha\NillableNode, bool)> ==> {
        $math = $fixtures->math;
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
      },
      (
        (function(Pha\NillableNode)[]: bool) $is_x,
        Pha\NillableNode $node,
        bool $matches,
      )[] ==> {
        expect($is_x($node))->toEqual($matches);
      },
    )
    ->testWith3Params(
      'test_create_member_accessor',
      ()[]: vec<(Pha\Syntax, (function(Pha\Syntax)[]: Pha\Node), Pha\Node)> ==> {
        $math = $fixtures->math;
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
      },
      (
        Pha\Syntax $node,
        (function(Pha\Syntax)[]: Pha\Node) $get_member,
        Pha\Node $result,
      )[] ==> {
        expect($get_member($node))->toEqual($result);
      },
    )
    ->test('test_create_member_accessor_unknown_node', ()[] ==> {
      $math = $fixtures->math;
      $script = $math->script;
      $get_member =
        Pha\create_member_accessor($script, Pha\MEMBER_BINARY_OPERATOR);

      expect(() ==> $get_member($math->functionDeclaration))
        ->toThrowPhaException(
          'No syntax accessor defined for function_declaration.',
        );
    })
    ->testWith2Params(
      'test_index_get_nodes_by_kind',
      ()[]: vec<(Pha\SyntaxKind, vec<Pha\Syntax>)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple(Pha\KIND_FUNCTION_DECLARATION, vec[$math->functionDeclaration]),
          tuple(Pha\KIND_REQUIRE_CLAUSE, vec[]),
          tuple(
            Pha\KIND_BINARY_EXPRESSION,
            vec[$math->ternaryCondition, $math->ternaryTrue, $math->ternaryFalse],
          ),
        ];
      },
      (
        Pha\SyntaxKind $kind,
        vec<Pha\Syntax> $nodes,
      )[] ==> {
        $math = $fixtures->math;
        expect(Pha\index_get_nodes_by_kind($math->syntaxIndex, $kind))->toEqual(
          $nodes,
        );
      },
    )
    ->testWith2Params(
      'test_token_get_text',
      ()[]: vec<(Pha\NillableToken, string)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple(Pha\NIL, ''),
          tuple($math->namespaceSemicolon, ';'),
          tuple($math->namespaceToken, 'namespace'),
        ];
      },
      (
        Pha\NillableToken $node,
        string $text,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\token_get_text($script, $node))->toEqual($text);
      },
    )
    ->testWith2Params(
      'test_node_get_code_compressed',
      ()[]: vec<(Pha\NillableNode, string)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple($math->ternaryExpression, '$a>$b?$a-$b:$b-$a'),
          tuple($math->namespaceToken, 'namespace'),
          tuple($math->licenseComment, ''),
          tuple(Pha\NIL, ''),
        ];
      },
      (
        Pha\NillableNode $node,
        string $compressed_code,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\node_get_code_compressed($script, $node))->toEqual(
          $compressed_code,
        );
      },
    )
    ->testWith3Params(
      'test_source_range_get_line_and_column_numbers',
      ()[]: vec<(Pha\Node, (int, int), (int, int))> ==> {
        $math = $fixtures->math;
        return vec[
          tuple(Pha\SCRIPT_NODE, tuple(0, 0), tuple(6, 1)),
          tuple($math->declarationList, tuple(0, 0), tuple(6, 1)),
          tuple($math->licenseComment, tuple(0, 0), tuple(0, 55)),
          tuple($math->newlineAfterLicenseComment, tuple(0, 55), tuple(0, 56)),
          tuple($math->functionDeclaration, tuple(1, 34), tuple(5, 2)),
          tuple($math->missingTypeParameterList, tuple(3, 13), tuple(3, 13)),
          tuple(
            $math->functionDeclarationHeaderLeftParen,
            tuple(3, 13),
            tuple(3, 14),
          ),
          tuple($math->parameterList, tuple(3, 14), tuple(3, 28)),
          tuple($math->parameterA, tuple(3, 14), tuple(3, 20)),
          tuple($math->returnStatement, tuple(3, 39), tuple(4, 38)),
        ];
      },
      (
        Pha\Node $node,
        (int, int) $start,
        (int, int) $end,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(
          Pha\node_get_source_range($script, $node)
            |> Pha\source_range_to_line_and_column_numbers($script, $$)
            |> tuple($$->getStart(), $$->getEnd()),
        )->toEqual(tuple($start, $end));
      },
    )
    ->testWith2Params(
      'test_source_range_format',
      ()[]: vec<(Pha\SourceRange, string)> ==> {
        return vec[
          tuple(
            Pha\_Private\source_range_hide(
              tuple(Pha\_Private\source_byte_offset_from_int(0), null),
            ),
            '[0, ...]',
          ),
          tuple(
            Pha\_Private\source_range_hide(
              tuple(
                Pha\_Private\source_byte_offset_from_int(14),
                Pha\_Private\source_byte_offset_from_int(32),
              ),
            ),
            '[14, 32]',
          ),
        ];
      },
      (
        Pha\SourceRange $range,
        string $expected,
      )[] ==> {
        expect(Pha\source_range_format($range))->toEqual($expected);
      },
    )
    ->test('test_patch_node_invalid_argument', ()[] ==> {
      $math = $fixtures->math;

      // okay
      Pha\patch_node(
        $math->licenseComment,
        '// no license',
        shape('trivia' => Pha\RetainTrivia::NEITHER),
      );

      expect(
        () ==> Pha\patch_node(
          $math->licenseComment,
          '// no license',
          shape('trivia' => Pha\RetainTrivia::LEADING),
        ),
      )
        ->toThrowPhaException(
          'You may not replace a trivium with HTL\Pha\RetainTrivia::LEADING set. '.
          'This instruction does not make sense.',
        );
    })
    ->testWith2Params(
      'test_patches_apply',
      ()[]: vec<(vec<Pha\Patch>, string)> ==> {
        $tiny = $fixtures->tiny;
        return vec[
          tuple(
            vec[Pha\patch_node($tiny->functionName, 'noop')],
            'function noop()[]: void {}',
          ),
          tuple(
            vec[Pha\patch_node($tiny->functionBodyLines, ' $_ = 1 + 2; ')],
            'function tiny()[]: void { $_ = 1 + 2; }',
          ),
          tuple(
            vec[Pha\patch_node(
              $tiny->functionDeclarationHeader,
              'function big()[]: void',
              shape('trivia' => Pha\RetainTrivia::BOTH),
            )],
            'function big()[]: void {}',
          ),
          tuple(
            vec[
              Pha\patch_node($tiny->paramaterList, 'int $a, int $b'),
              Pha\patch_node($tiny->functionName, 'add'),
              Pha\patch_node($tiny->contexts, '[write_props]'),
              Pha\patch_node(
                $tiny->returnType,
                'int',
                shape('trivia' => Pha\RetainTrivia::TRAILING),
              ),
              Pha\patch_node($tiny->functionBodyLines, ' return $a + $b; '),
            ],
            'function add(int $a, int $b)[write_props]: int { return $a + $b; }',
          ),
        ];
      },
      (
        vec<Pha\Patch> $patches,
        string $expected,
      )[] ==> {
        $script = $fixtures->tiny->script;
        expect(Pha\patches_apply(Pha\patches($script, ...$patches)))
          ->toEqual($expected);

        $patch_set = Pha\patches($script);

        foreach ($patches as $p) {
          $patch_set = Pha\patches_combine_without_conflict_resolution(
            vec[$patch_set, Pha\patches($script, $p)],
          );
        }

        expect(Pha\patches_apply($patch_set))->toEqual($expected);
      },
    )
    ->testWith2Params(
      'test_provide_patches_apply_overlapping_nodes',
      ()[]: vec<(vec<Pha\Patch>, string)> ==> {
        $tiny = $fixtures->tiny;
        return vec[
          tuple(
            vec[
              Pha\patch_node($tiny->functionBody, ';'),
              Pha\patch_node($tiny->functionBodyLines, ' throw new Exception(); '),
            ],
            "The following two patches conflict:\n".
            " - [24, 26]\n".
            ";\n".
            " - [25, 25]\n".
            ' throw new Exception(); ',
          ),
        ];
      },
      (
        vec<Pha\Patch> $patches,
        string $message,
      )[] ==> {
        $script = $fixtures->tiny->script;
        expect(() ==> Pha\patches($script, ...$patches))->toThrowPhaException(
          $message,
        );
      },
    )
    ->testWith2Params(
      'test_patches_combine_without_conflict_resolution',
      ()[]: vec<(vec<Pha\Patches>, string)> ==> {
        $math = $fixtures->math;
        $tiny = $fixtures->tiny;

        return vec[
          tuple(vec[], 'expected Patches, but none were provided'),
          tuple(
            vec[
              Pha\patches(
                $tiny->script,
                Pha\patch_node($tiny->functionName, 'short'),
              ),
              Pha\patches(
                $tiny->script,
                Pha\patch_node($tiny->functionName, 'long'),
              ),
            ],
            "The following two patches conflict:\n".
            " - [9, 13]\n".
            "short\n".
            " - [9, 13]\n".
            'long',
          ),
          tuple(
            vec[
              Pha\patches(
                $tiny->script,
                Pha\patch_node($tiny->functionName, 'short'),
              ),
              Pha\patches(
                $tiny->script,
                Pha\patch_node(
                  $tiny->functionDeclarationHeader,
                  'function long()[]: void ',
                ),
              ),
            ],
            "The following two patches conflict:\n".
            " - [0, 24]\n".
            "function long()[]: void \n".
            " - [9, 13]\n".
            'short',
          ),
          tuple(
            vec[
              Pha\patches(
                $math->script,
                Pha\patch_node($math->firstMinusToken, '+'),
              ),
              Pha\patches($tiny->script, Pha\patch_node($tiny->contexts, '')),
            ],
            'HTL\Pha\patches_combine_without_conflict_resolution expected that all Patches could be combined, '.
            'but one of the Patches was created for a different Script.',
          ),
        ];
      },
      (
        vec<Pha\Patches> $patches,
        string $expected_message,
      )[] ==> {
        expect(() ==> Pha\patches_combine_without_conflict_resolution($patches))
          ->toThrowPhaException($expected_message);
      },
    )
    ->test('test_returns_syntax', ()[] ==> {
      $math = $fixtures->math;
      $ternary_get_test =
        Pha\create_member_accessor($math->script, Pha\MEMBER_CONDITIONAL_TEST);
      $ternary_get_test_typed = Pha\returns_syntax($ternary_get_test);

      expect($ternary_get_test_typed($math->ternaryExpression))->toEqual(
        $ternary_get_test($math->ternaryExpression),
      );

      $ternary_get_colon_ill_typed =
        Pha\create_member_accessor($math->script, Pha\MEMBER_CONDITIONAL_COLON)
        |> Pha\returns_syntax($$);

      expect(() ==> $ternary_get_colon_ill_typed($math->ternaryExpression))
        ->toThrowPhaException('HTL\Pha\as_syntax expected a Syntax, got Token.');
    })
    ->test('test_returns_token', ()[] ==> {
      $math = $fixtures->math;
      $ternary_get_colon =
        Pha\create_member_accessor($math->script, Pha\MEMBER_CONDITIONAL_COLON);
      $ternary_get_colon_typed = Pha\returns_token($ternary_get_colon);

      expect($ternary_get_colon_typed($math->ternaryExpression))->toEqual(
        $ternary_get_colon($math->ternaryExpression),
      );

      $ternary_get_test_ill_typed =
        Pha\create_member_accessor($math->script, Pha\MEMBER_CONDITIONAL_TEST)
        |> Pha\returns_token($$);

      expect(() ==> $ternary_get_test_ill_typed($math->ternaryExpression))
        ->toThrowPhaException('HTL\Pha\as_token expected a Token, got Syntax.');
    })
    ->testWith2Params(
      'test_node_is_token_text_trivium',
      ()[]: vec<(Pha\NillableNode, bool)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple($math->endOfFileTokenText, true),
          tuple($math->namespaceTokenTextTrivium, true),
          tuple($math->namespaceSemicolonTextTrivium, true),
          tuple($math->endOfFileToken, false),
          tuple($math->newlineAfterLicenseComment, false),
          tuple($math->licenseComment, false),
          tuple(Pha\NIL, false),
        ];
      },
      (
        Pha\NillableNode $node,
        bool $expected,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\node_is_token_text_trivium($script, $node))->toEqual($expected);
      },
    )
    ->testWith2Params(
      'test_node_get_code_without_leading_or_trailing_trivia',
      ()[]: vec<(Pha\NillableNode, string)> ==> {
        $math = $fixtures->math;
        return vec[
          tuple(
            $math->functionDeclarationHeader,
            'function math(int $a, int $b)[]: int',
          ),
          tuple($math->parameterList, 'int $a, int $b'),
          tuple($math->parameterA, 'int $a'),
          tuple(
            $math->functionBody,
            "{\n  return \$a > \$b ? \$a - \$b : \$b - \$a;\n}",
          ),
          tuple($math->newlineAfterLicenseComment, ''),
          tuple($math->missingTypeParameterList, ''),
          tuple(Pha\NIL, ''),
        ];
      },
      (
        Pha\NillableNode $node,
        string $expected,
      )[] ==> {
        $script = $fixtures->math->script;
        expect(Pha\node_get_code_without_leading_or_trailing_trivia($script, $node))
          ->toEqual($expected);
      },
    );
}

async function parse_fixture_async(
  string $fixture,
)[defaults]: Awaitable<Pha\Script> {
  $file = File\open_read_only(__DIR__.'/fixtures/'.$fixture);
  using ($file->closeWhenDisposed(), $file->tryLockx(File\LockType::SHARED)) {
    $source = await $file->readAllAsync();
  }

  // The tests for tiny.hack were written before the license header
  // and the trailing newline was added.
  // This chop chop take center restores the tests without altering them.
  if ($fixture === '002_tiny.hack') {
    $source = Str\split($source, "\n")[1];
  }
  $ctx = Pha\create_context();
  list($script, $ctx) = Pha\parse($source, $ctx);

  return $script;
}
