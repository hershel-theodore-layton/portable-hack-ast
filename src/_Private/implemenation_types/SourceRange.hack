/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype SourceRange = (SourceByteOffset, ?SourceByteOffset);

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
