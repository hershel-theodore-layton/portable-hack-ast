/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests\Fixtures;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

final class Fixtures {
  public function __construct(public Math $math)[] {}
}

abstract class Fixture {
  public Pha\SyntaxIndex $syntaxIndex;
  public Pha\TokenIndex $tokenIndex;
  public Pha\TriviumIndex $triviumIndex;

  public function __construct(public Pha\Script $script)[] {
    $this->syntaxIndex = Pha\create_syntax_kind_index($script);
    $this->tokenIndex = Pha\create_token_kind_index($script);
    $this->triviumIndex = Pha\create_trivium_kind_index($script);
  }
}

final class Math extends Fixture {
  public Pha\Syntax $declarationList;
  public Pha\Syntax $namespaceDeclaration;
  public Pha\Syntax $namespaceDeclarationHeader;
  public Pha\Token $namespaceToken;
  public Pha\Trivium $namespaceTokenTextTrivium;
  public Pha\Syntax $namespaceName;
  public Pha\Syntax $namespaceEmptyBody;
  public Pha\Token $namespaceSemicolon;
  public Pha\Trivium $namespaceSemicolonTextTrivium;
  public Pha\Trivium $newlineAfterNamespaceSemicolon;
  public Pha\Trivium $licenseComment;
  public Pha\Trivium $newlineAfterLicenseComment;
  public Pha\Syntax $functionDeclaration;
  public Pha\Syntax $functionDeclarationHeader;
  public Pha\Syntax $missingTypeParameterList;
  public Pha\Token $functionDeclarationHeaderLeftParen;
  public Pha\Syntax $parameterList;
  public Pha\Syntax $parameterA;
  public Pha\Syntax $parameterB;
  public Pha\Syntax $functionBody;
  public Pha\Syntax $functionStatements;
  public Pha\Syntax $returnStatement;
  public Pha\Syntax $ternaryExpression;
  public Pha\Syntax $ternaryCondition;
  public Pha\Syntax $ternaryTrue;
  public Pha\Token $firstMinusToken;
  public Pha\Syntax $ternaryFalse;
  public Pha\Syntax $endOfFileSyntax;
  public Pha\Token $endOfFileToken;
  public Pha\Trivium $endOfFileTokenText;

  public function __construct(Pha\Script $script)[] {
    parent::__construct($script);

    $this->declarationList = Pha\node_get_first_child($script, Pha\SCRIPT_NODE)
      |> Pha\as_syntax($$);

    list($this->namespaceDeclaration, $this->functionDeclaration) =
      Pha\node_get_children($script, $this->declarationList)
      |> Vec\map($$, Pha\as_syntax<>);

    $this->namespaceDeclarationHeader = $this->memberAsSyntax(
      $this->namespaceDeclaration,
      Pha\MEMBER_NAMESPACE_HEADER,
    );

    $this->namespaceToken = $this->member(
      $this->namespaceDeclarationHeader,
      Pha\MEMBER_NAMESPACE_KEYWORD,
    )
      |> Pha\as_token($$);

    $this->namespaceTokenTextTrivium = C\findx(
      Pha\node_get_children($script, $this->namespaceToken),
      $n ==> Pha\node_get_kind($script, $n) === Pha\KIND_TOKEN_TEXT,
    )
      |> Pha\as_trivium($$);

    $this->namespaceName = $this->memberAsSyntax(
      $this->namespaceDeclarationHeader,
      Pha\MEMBER_NAMESPACE_NAME,
    );

    $this->namespaceEmptyBody = $this->memberAsSyntax(
      $this->namespaceDeclaration,
      Pha\MEMBER_NAMESPACE_BODY,
    );

    $this->namespaceSemicolon =
      $this->member($this->namespaceEmptyBody, Pha\MEMBER_NAMESPACE_SEMICOLON)
      |> Pha\as_token($$);

    $this->namespaceSemicolonTextTrivium =
      Pha\node_get_first_child($script, $this->namespaceSemicolon)
      |> Pha\as_trivium($$);

    $this->newlineAfterNamespaceSemicolon =
      Pha\node_get_last_childx($script, $this->namespaceSemicolon)
      |> Pha\as_trivium($$);

    $this->licenseComment =
      Pha\node_get_first_child($script, $this->namespaceToken)
      |> Pha\as_trivium($$);

    $this->newlineAfterLicenseComment =
      Pha\node_get_child_at_offsetx($script, $this->namespaceToken, 1)
      |> Pha\as_trivium($$);

    $this->functionDeclarationHeader = $this->memberAsSyntax(
      $this->functionDeclaration,
      Pha\MEMBER_FUNCTION_DECLARATION_HEADER,
    );

    $this->missingTypeParameterList = $this->memberAsSyntax(
      $this->functionDeclarationHeader,
      Pha\MEMBER_FUNCTION_TYPE_PARAMETER_LIST,
    );

    $this->functionDeclarationHeaderLeftParen = $this->member(
      $this->functionDeclarationHeader,
      Pha\MEMBER_FUNCTION_LEFT_PAREN,
    )
      |> Pha\as_token($$);

    $this->parameterList = $this->memberAsSyntax(
      $this->functionDeclarationHeader,
      Pha\MEMBER_FUNCTION_PARAMETER_LIST,
    );

    list($this->parameterA, $this->parameterB) =
      Pha\node_get_descendants($script, $this->parameterList)
      |> Vec\filter(
        $$,
        $n ==>
          Pha\node_get_kind($script, $n) === Pha\KIND_PARAMETER_DECLARATION,
      )
      |> Vec\map($$, Pha\as_syntax<>);

    $this->functionBody = $this->memberAsSyntax(
      $this->functionDeclaration,
      Pha\MEMBER_FUNCTION_BODY,
    );

    $this->functionStatements = $this->memberAsSyntax(
      $this->functionBody,
      Pha\MEMBER_COMPOUND_STATEMENTS,
    );

    $this->returnStatement =
      Pha\node_get_first_child($script, $this->functionStatements)
      |> Pha\as_syntax($$);

    $this->ternaryExpression = $this->memberAsSyntax(
      $this->returnStatement,
      Pha\MEMBER_RETURN_EXPRESSION,
    );

    $this->ternaryCondition = $this->memberAsSyntax(
      $this->ternaryExpression,
      Pha\MEMBER_CONDITIONAL_TEST,
    );

    $this->ternaryTrue = $this->memberAsSyntax(
      $this->ternaryExpression,
      Pha\MEMBER_CONDITIONAL_CONSEQUENCE,
    );

    $this->firstMinusToken =
      Pha\syntax_member($script, $this->ternaryTrue, Pha\MEMBER_BINARY_OPERATOR)
      |> Pha\as_token($$);

    $this->ternaryFalse = $this->memberAsSyntax(
      $this->ternaryExpression,
      Pha\MEMBER_CONDITIONAL_ALTERNATIVE,
    );

    $this->endOfFileSyntax =
      Pha\node_get_last_child($script, $this->declarationList)
      |> Pha\as_syntax($$);

    $this->endOfFileToken =
      Pha\node_get_last_child($script, $this->endOfFileSyntax)
      |> Pha\as_token($$);

    $this->endOfFileTokenText =
      Pha\node_get_last_child($script, $this->endOfFileToken)
      |> Pha\as_trivium($$);
  }

  private function member(Pha\Syntax $node, Pha\Member $member)[]: Pha\Node {
    return Pha\syntax_member($this->script, $node, $member);
  }

  private function memberAsSyntax(
    Pha\Syntax $node,
    Pha\Member $member,
  )[]: Pha\Syntax {
    return $this->member($node, $member) |> Pha\as_syntax($$);
  }
}
