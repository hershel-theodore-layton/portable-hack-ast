/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

/**
 * Pha is best enjoyed on hhvm 4.103 or with `hhvm.hack_arr_dv_arrs=1`.
 * If you are using an hhvm version with darray as a distinct type,
 * you may also use this alternative implementation of parse:
 * `HH\ffp_parse_string_native(...) |> \json_decode($$, true, 512, \JSON_FB_HACK_ARRAYS)`
 * If you don't do this, you'll incur an extra runtime cost.
 */
function change_type_of_parse_tree_for_hhvm_4_102(
  AnyArray<arraykey, mixed> $value,
)[]: dict<arraykey, mixed> {
  if ($value is dict<_, _>) {
    // We are running on hhvm 4.103+ and we don't need to convert array kinds.
    return $value;
  }

  return to_dict_recursively($value) |> dict($$ as KeyedContainer<_, _>);
}
