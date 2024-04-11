/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype SourceRange = (SourceByteOffset, ?SourceByteOffset);

const SourceRange SOURCE_RANGE_WHOLE_SCRIPT =
  tuple(SOURCE_BYTE_OFFSET_ZERO, SOURCE_BYTE_OFFSET_END);

function source_range_hide(
  (SourceByteOffset, ?SourceByteOffset) $range,
)[]: SourceRange {
  return $range;
}

function source_range_reveal(
  SourceRange $range,
)[]: (SourceByteOffset, ?SourceByteOffset) {
  return $range;
}
