/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

final class LineAndColumnNumbers {
  public function __construct(
    private int $startLine,
    private int $startColumn,
    private int $endLine,
    private int $endColumn,
  )[] {}

  public function getStartLine()[]: int {
    return $this->startLine;
  }

  public function getStartLineOneBased()[]: int {
    return $this->startLine + 1;
  }

  public function getStartColumn()[]: int {
    return $this->startColumn;
  }

  public function getStartColumnOneBased()[]: int {
    return $this->startColumn + 1;
  }

  public function getEndLine()[]: int {
    return $this->endLine;
  }

  public function getEndLineOneBased()[]: int {
    return $this->endLine + 1;
  }

  public function getEndColumn()[]: int {
    return $this->endColumn;
  }

  public function getEndColumnOneBased()[]: int {
    return $this->endColumn + 1;
  }

  public function getStart()[]: (int, int) {
    return tuple($this->startLine, $this->startColumn);
  }

  public function getStartOneBased()[]: (int, int) {
    return
      tuple($this->getStartLineOneBased(), $this->getStartColumnOneBased());
  }

  public function getEnd()[]: (int, int) {
    return tuple($this->endLine, $this->endColumn);
  }

  public function getEndOneBased()[]: (int, int) {
    return tuple($this->getEndLineOneBased(), $this->getEndColumnOneBased());
  }
}
