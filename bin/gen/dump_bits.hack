/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\Str;
use namespace HTL\Pha\_Private;

function dump_bits(mixed $value)[]: mixed {
  if (!$value is vec_or_dict<_, _>) {
    return $value;
  }
  foreach ($value as $k => $v) {
    if ($v is vec_or_dict<_, _>) {
      $value[$k] = dump_bits($v);
    } else if ($v is int) {
      $value[$k] = format_node($v);
    }
  }

  return $value;
}

function format_node(int $v)[]: string {
  return Str\format(
    '%02b_%08b_%018b_%018b_%018b',
    ($v >> _Private\FIELD_0_OFFSET) & _Private\FIELD_0_MASK,
    ($v >> _Private\FIELD_1_OFFSET) & _Private\FIELD_1_MASK,
    ($v >> _Private\FIELD_2_OFFSET) & _Private\FIELD_2_MASK,
    ($v >> _Private\FIELD_3_OFFSET) & _Private\FIELD_3_MASK,
    ($v >> _Private\FIELD_4_OFFSET) & _Private\FIELD_4_MASK,
  );
}
