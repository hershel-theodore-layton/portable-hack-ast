/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

final class Patch {
  public function __construct(
    private SourceRange $range,
    private string $text,
  )[] {}

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
