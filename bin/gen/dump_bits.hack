/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\Str;
use namespace HTL\Pha;
use namespace HTL\Pha\_Private;

function dump_bits(mixed $value)[]: mixed {
  if (!$value is vec_or_dict<_>) {
    return $value;
  }
  foreach ($value as $k => $v) {
    $v = mix($v);
    if ($v is vec_or_dict<_>) {
      $value[$k] = dump_bits($v);
    } else if ($v is int) {
      $value[$k] = format_node($v);
    }
  }

  return $value;
}

// Erase type information for hhvm 25.6+.
function mix(mixed $mixed)[]: mixed {
  return $mixed;
}

function format_node(int $v)[]: string {
  $group = Pha\node_get_elaborated_group(_Private\node_from_int($v));
  switch ($group) {
    case Pha\NodeElaboratedGroup::SYNTAX:
      $prefix = 'syn';
      break;
    case Pha\NodeElaboratedGroup::TOKEN:
      $prefix = 'tok';
      break;
    case Pha\NodeElaboratedGroup::TRIVIUM:
      $prefix = 'tri';
      break;
    case Pha\NodeElaboratedGroup::LIST:
      $prefix = 'lst';
      break;
    case Pha\NodeElaboratedGroup::MISSING:
      $prefix = 'mis';
  }

  return $group === Pha\NodeElaboratedGroup::TRIVIUM
    ? Str\format(
        '%s %02x   %03x  %06x  %05x',
        $prefix,
        ($v >> _Private\FIELD_1_OFFSET) & _Private\FIELD_1_MASK,
        ($v >> _Private\FIELD_2_OFFSET_FOR_TRIVIA) &
          _Private\FIELD_2_MASK_FOR_TRIVIA,
        ($v >> _Private\FIELD_3_OFFSET_FOR_TRIVIA) &
          _Private\FIELD_3_MASK_FOR_TRIVIA,
        ($v >> _Private\FIELD_4_OFFSET) & _Private\FIELD_4_MASK,
      )
    : Str\format(
        '%s %02x  %04x   %05x  %05x',
        $prefix,
        ($v >> _Private\FIELD_1_OFFSET) & _Private\FIELD_1_MASK,
        ($v >> _Private\FIELD_2_OFFSET) & _Private\FIELD_2_MASK,
        ($v >> _Private\FIELD_3_OFFSET) & _Private\FIELD_3_MASK,
        ($v >> _Private\FIELD_4_OFFSET) & _Private\FIELD_4_MASK,
      );
}
