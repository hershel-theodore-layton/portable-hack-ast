/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

final class PatchSet {
  private vec<Replacement> $replacements;

  public function __construct(
    private string $beforeText,
    vec<Replacement> $replacements,
  )[] {
    $source_end = source_byte_offset_from_int(Str\length($beforeText));
    $replacements = Vec\map(
      $replacements,
      $r ==> new Replacement(
        $r->getPosition(),
        source_range_hide(
          tuple($r->getStartOffset(), $r->getEndOffset() ?? $source_end),
        ),
        $r->getText(),
      ),
    );
    // Preserve input order for insertions at the same position.
    $this->replacements =
      Vec\map_with_key($replacements, ($i, $r) ==> tuple($i, $r))
      |> Vec\sort_by(
        $$,
        $entry ==> tuple(
          $entry[1]->getStartOffset(),
          $entry[1]->getEndOffset() === $entry[1]->getStartOffset() ? 0 : 1,
          $entry[0],
        ),
      )
      |> Vec\map($$, $entry ==> $entry[1]);
    $shifted = Vec\drop($this->replacements, 1);
    $with_next = Vec\zip($this->replacements, $shifted);

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
    if (C\is_empty($this->replacements)) {
      return $this->beforeText;
    }

    $out = '';
    $read_start = 0;

    foreach ($this->replacements as $replacement) {
      $out .= Str\slice(
        $this->beforeText,
        $read_start,
        source_byte_offset_to_int($replacement->getStartOffset()) - $read_start,
      );

      $out .= $replacement->getText();
      $end = $replacement->getEndOffset();
      invariant(
        $end is nonnull,
        'Patch ends are normalized to source offsets.',
      );
      $read_start = source_byte_offset_to_int($end);
    }

    return $out.Str\slice($this->beforeText, $read_start);
  }

  public function cayBeCombinedWith(PatchSet $other)[]: bool {
    return $this->beforeText === $other->beforeText;
  }

  public function getBeforeText()[]: string {
    return $this->beforeText;
  }

  public function getReplacements()[]: vec<Replacement> {
    return $this->replacements;
  }
}
