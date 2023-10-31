/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype SourceByteOffset = int;

function source_byte_offset_from_int(int $int)[]: SourceByteOffset {
  return $int;
}

function source_byte_offset_to_int(SourceByteOffset $offset)[]: int {
  return $offset;
}
