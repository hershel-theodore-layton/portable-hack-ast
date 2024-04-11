/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

final class PatchSet {
  private string $beforeText;

  public function __construct(
    TranslationUnit $tu,
    private vec<Patch> $patches,
  )[] {
    $this->beforeText = $tu->cutSourceRange(SOURCE_RANGE_WHOLE_SCRIPT);

    $sorted = Vec\sort_by($patches, $p ==> $p->getStartOffset());
    $shifted = Vec\drop($sorted, 1);
    $with_next = Vec\zip($sorted, $shifted);

    foreach ($with_next as list($cur, $next)) {
      if (Pha\source_range_overlaps($cur->getRange(), $next->getRange())) {
        throw new PhaException(
          Str\format(
            "The following two patches conflict:\n - %s\n%s\n - %s\n%s",
            Pha\source_range_format($cur->getRange()),
            $cur->getText(),
            Pha\source_range_format($next->getRange()),
            $next->getText(),
          ),
        );
      }
    }
  }

  public function apply()[]: string {
    if (C\is_empty($this->patches)) {
      return $this->beforeText;
    }

    $out = '';
    $read_start = 0;

    foreach ($this->patches as $patch) {
      invariant(
        $read_start is nonnull,
        'Only the last patch may have an open end.',
      );
      $out .= Str\slice(
        $this->beforeText,
        $read_start,
        source_byte_offset_to_int($patch->getStartOffset()) - $read_start,
      );

      $out .= $patch->getText();
      $read_start = $patch->getEndOffset()
        |> $$ is null ? null : source_byte_offset_to_int($$);
    }

    if ($read_start is null) {
      return $out;
    }

    return $out.Str\slice($this->beforeText, $read_start);
  }
}
