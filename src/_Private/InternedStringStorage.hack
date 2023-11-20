/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Dict};

final class InternedStringStorage<T as Kind> {
  private vec<T> $items;
  private dict<T, int> $flipped;
  private int $size;

  /**
   * @param $items is keyed by interned string (0..n-1).
   */
  public function __construct(
    private keyset<T> $asKeyset,
    private (function(string)[]: T) $castFunc,
  )[] {
    $this->items = vec($this->asKeyset);
    $this->flipped = Dict\flip($this->items);
    $this->size = C\count($this->items);
  }

  public function asKeyset()[]: keyset<T> {
    return $this->asKeyset;
  }

  public function asVec()[]: vec<string> {
    return $this->items;
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
