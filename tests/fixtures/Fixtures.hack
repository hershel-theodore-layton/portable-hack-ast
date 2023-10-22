/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests\Fixtures;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

final class Fixtures {
  public function __construct(public Math $math)[] {}
}

abstract class Fixture {
  public function __construct(public Pha\Script $script)[] {}
}

final class Math extends Fixture {
  public Pha\Syntax $declarationList;
  public Pha\Syntax $namespaceDeclaration;
  public Pha\Syntax $namespaceDeclarationHeader;
  public Pha\Token $namespaceToken;
  public Pha\Syntax $namespaceName;
  public Pha\Trivium $licenseComment;
  public Pha\Syntax $functionDeclaration;
  public Pha\Syntax $functionDeclarationHeader;
  public Pha\Syntax $missingTypeParameterList;
  public Pha\Syntax $parameterList;
  public Pha\Syntax $functionBody;
  public Pha\Syntax $functionStatements;
  public Pha\Syntax $returnStatement;
  public Pha\Syntax $ternaryExpression;
  public Pha\Syntax $ternaryCondition;
  public Pha\Syntax $ternaryTrue;
  public Pha\Syntax $ternaryFalse;

  public function __construct(Pha\Script $script)[] {
    parent::__construct($script);

    $this->declarationList = Pha\node_get_first_child($script, Pha\SCRIPT_NODE)
      |> Pha\node_as_syntax($$);

    list($this->namespaceDeclaration, $this->functionDeclaration) =
      Pha\node_get_children($script, $this->declarationList)
      |> Vec\map($$, Pha\node_as_syntax<>);

    $this->namespaceDeclarationHeader = $this->memberAsSyntax(
      $this->namespaceDeclaration,
      Pha\MEMBER_NAMESPACE_HEADER,
    );

    $this->namespaceToken = $this->member(
      $this->namespaceDeclarationHeader,
      Pha\MEMBER_NAMESPACE_KEYWORD,
    )
      |> Pha\node_as_token($$);

    $this->namespaceName = $this->memberAsSyntax(
      $this->namespaceDeclarationHeader,
      Pha\MEMBER_NAMESPACE_NAME,
    );

    $this->licenseComment =
      Pha\node_get_first_child($script, $this->namespaceToken)
      |> Pha\node_as_trivium($$);

    $this->functionDeclarationHeader = $this->memberAsSyntax(
      $this->functionDeclaration,
      Pha\MEMBER_FUNCTION_DECLARATION_HEADER,
    );

    $this->missingTypeParameterList = $this->memberAsSyntax(
      $this->functionDeclarationHeader,
      Pha\MEMBER_FUNCTION_TYPE_PARAMETER_LIST,
    );

    $this->parameterList = $this->memberAsSyntax(
      $this->functionDeclarationHeader,
      Pha\MEMBER_FUNCTION_PARAMETER_LIST,
    );

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
      |> Pha\node_as_syntax($$);

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

    $this->ternaryFalse = $this->memberAsSyntax(
      $this->ternaryExpression,
      Pha\MEMBER_CONDITIONAL_ALTERNATIVE,
    );
  }

  private function member(Pha\Syntax $node, Pha\Member $member)[]: Pha\Node {
    return Pha\syntax_member($this->script, $node, $member);
  }

  private function memberAsSyntax(
    Pha\Syntax $node,
    Pha\Member $member,
  )[]: Pha\Syntax {
    return $this->member($node, $member) |> Pha\node_as_syntax($$);
  }
}
