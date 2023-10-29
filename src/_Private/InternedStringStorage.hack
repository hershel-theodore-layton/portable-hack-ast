/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Dict};
use namespace HTL\Pha;

final class InternedStringStorage<T as Kind> {
  private dict<T, int> $flipped;
  private int $size;

  /**
   * @param $items is keyed by interned string (0..n-1).
   */
  public function __construct(
    private vec<T> $items,
    private (function(string)[]: T) $castFunc,
  )[] {
    $this->flipped = Dict\flip($items);
    $this->size = C\count($items);
  }

  public function fromInterned(InternedString<T> $interned)[]: T {
    return
      $this->items[interned_string_to_int($interned)] |> ($this->castFunc)($$);
  }

  public function intern(T $string)[]: InternedString<T> {
    return interned_string_from_int<T>($this->flipped[$string]);
  }

  public function internOrMax(T $string)[]: InternedString<T> {
    return interned_string_from_int<T>(
      idx($this->flipped, $string, MAX_INTERNED_STRING),
    );
  }

  public function isOfSameSize(keyset<string> $new_names)[]: bool {
    return $this->size === C\count($new_names);
  }
}
