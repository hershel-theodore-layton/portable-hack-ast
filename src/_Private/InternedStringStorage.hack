/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Dict};

final class InternedStringStorage<T> {
  private dict<string, int> $flipped;
  private int $size;

  public function __construct(
    private vec<string> $items,
    private (function(string)[]: T) $castFunc,
  )[] {
    $this->flipped = Dict\flip($items);
    $this->size = C\count($items);
  }

  public function fromInterned(InternedString<T> $interned)[]: T {
    return
      $this->items[interned_string_to_int($interned)] |> ($this->castFunc)($$);
  }

  public function intern(string $string)[]: InternedString<T> {
    return interned_string_from_int<T>($this->flipped[$string]);
  }

  public function isOfSameSize(keyset<string> $new_names)[]: bool {
    return $this->size === C\count($new_names);
  }
}
