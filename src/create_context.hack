/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

function create_context()[]: Context {
  return new _Private\ParseContext(
    new _Private\Structs(dict[]),
    new _Private\InternedStringStorage(keyset[], syntax_kind_from_string<>),
    new _Private\InternedStringStorage(keyset[], token_kind_from_string<>),
    new _Private\InternedStringStorage(keyset[], trivium_kind_from_string<>),
  )
    |> _Private\context_hide($$);
}
