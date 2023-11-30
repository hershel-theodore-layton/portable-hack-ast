/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

function dematerialize_context(Context $ctx)[]: ReadyToSerializeContext {
  return _Private\context_reveal($ctx)
    |> shape(
      'context' => $$->dematerialize(),
      'context_hash' => $$->getMaterializationHash(),
    );
}

function dematerialize_script(Script $script)[]: ReadyToSerializeScript {
  return _Private\translation_unit_reveal($script)->dematerialize();
}

function materialize_context(dict<arraykey, mixed> $dematerialized)[]: Context {
  return _Private\ParseContext::materialize($dematerialized)
    |> _Private\context_hide($$);
}

/**
 * If you provide a value that was not returned by `dematerialize_script`,
 * you are invoking undefined behavior.
 */
function materialize_script(
  dict<arraykey, mixed> $dematerialized,
  Context $ctx,
)[]: Script {
  return _Private\context_reveal($ctx)
    |> _Private\TranslationUnit::materialize($dematerialized, $$)
    |> _Private\translation_unit_hide($$);
}
