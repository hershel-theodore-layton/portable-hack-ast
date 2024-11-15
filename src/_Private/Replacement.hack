/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HTL\Pha;

final class Replacement {
  public function __construct(
    private Pha\LineAndColumnNumbers $lineAndColumnNumbers,
    private SourceRange $range,
    private string $text,
  )[] {}

  public function getPosition()[]: Pha\LineAndColumnNumbers {
    return $this->lineAndColumnNumbers;
  }

  public function getEndOffset()[]: ?SourceByteOffset {
    return $this->range |> source_range_reveal($$)[1];
  }

  public function getRange()[]: SourceRange {
    return $this->range;
  }

  public function getStartOffset()[]: SourceByteOffset {
    return $this->range |> source_range_reveal($$)[0];
  }

  public function getText()[]: string {
    return $this->text;
  }
}
