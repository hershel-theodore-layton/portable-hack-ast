/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

/**
 * @param $parse_tree ought to be the `$ffp_parsed['parse_tree']` of a script.
 * @see `\HH\ffp_parse_string()` and `\HH\ffp_parse_string_native()`.
 */
function parse_from_tree(
  dict<arraykey, mixed> $parse_tree,
  string $source_text,
  Context $ctx,
)[]: (Script, Context) {
  $ctx = _Private\context_reveal($ctx);
  $structs = $ctx->getStructs();
  $member_names = $structs->getRaw();
  $known_token_kinds = keyset[];
  $known_trivium_kinds = keyset[];

  $intermediates = _Private\create_intermediates(
    $parse_tree,
    inout $member_names,
    inout $known_token_kinds,
    inout $known_trivium_kinds,
  );

  $ctx = $ctx->upgradeIfNeeded(
    $member_names,
    $known_token_kinds,
    $known_trivium_kinds,
  );

  $tu = _Private\create_translation_unit($intermediates, $source_text, $ctx);

  return
    tuple(_Private\translation_unit_hide($tu), _Private\context_hide($ctx));
}
