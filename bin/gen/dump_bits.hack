/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\Str;
use namespace HTL\Pha\_Private;

function dump_bits(mixed $value)[]: mixed {
  if (!$value is vec_or_dict<_>) {
    return $value;
  }
  foreach ($value as $k => $v) {
    if ($v is vec_or_dict<_>) {
      $value[$k] = dump_bits($v);
    } else if ($v is int) {
      $value[$k] = format_node($v);
    }
  }

  return $value;
}

function format_node(int $v)[]: string {
  return ($v >> _Private\FIELD_0_OFFSET) === _Private\TRIVIUM_TAG_AFTER_SHIFT
    ? Str\format(
        '%02b_%08b_%018b_%020b_%020b',
        ($v >> _Private\FIELD_0_OFFSET) & _Private\FIELD_0_MASK,
        ($v >> _Private\FIELD_1_OFFSET) & _Private\FIELD_1_MASK,
        ($v >> _Private\FIELD_2_OFFSET_FOR_TRIVIA) &
          _Private\FIELD_2_MASK_FOR_TRIVIA,
        ($v >> _Private\FIELD_3_OFFSET_FOR_TRIVIA) &
          _Private\FIELD_3_MASK_FOR_TRIVIA,
        ($v >> _Private\FIELD_4_OFFSET) & _Private\FIELD_4_MASK,
      )
    : Str\format(
        '%02b_%08b_%018b_%020b_%020b',
        ($v >> _Private\FIELD_0_OFFSET) & _Private\FIELD_0_MASK,
        ($v >> _Private\FIELD_1_OFFSET) & _Private\FIELD_1_MASK,
        ($v >> _Private\FIELD_2_OFFSET) & _Private\FIELD_2_MASK,
        ($v >> _Private\FIELD_3_OFFSET) & _Private\FIELD_3_MASK,
        ($v >> _Private\FIELD_4_OFFSET) & _Private\FIELD_4_MASK,
      );
}
