/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests\Fixtures;

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
  public Pha\Trivium $licenseComment;

  public function __construct(Pha\Script $script)[] {
    parent::__construct($script);
    $this->declarationList = Pha\node_get_first_child($script, Pha\SCRIPT_NODE)
      |> Pha\node_as_syntax($$);
    $this->namespaceDeclaration =
      Pha\node_get_first_child($script, $this->declarationList)
      |> Pha\node_as_syntax($$);
    $this->namespaceDeclarationHeader =
      Pha\node_get_first_child($script, $this->namespaceDeclaration)
      |> Pha\node_as_syntax($$);
    $this->namespaceToken =
      Pha\node_get_first_child($script, $this->namespaceDeclarationHeader)
      |> Pha\node_as_token($$);
    $this->licenseComment =
      Pha\node_get_first_child($script, $this->namespaceToken)
      |> Pha\node_as_trivium($$);
  }
}
