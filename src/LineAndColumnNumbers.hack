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

  public function getStartColumn()[]: int {
    return $this->startColumn;
  }

  public function getEndLine()[]: int {
    return $this->endLine;
  }

  public function getEndColumn()[]: int {
    return $this->endColumn;
  }

  public function getStart()[]: (int, int) {
    return tuple($this->startLine, $this->startColumn);
  }

  public function getEnd()[]: (int, int) {
    return tuple($this->endLine, $this->endColumn);
  }
}
