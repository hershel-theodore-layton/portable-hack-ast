/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype Context = ParseContext;

function context_hide(ParseContext $ctx)[]: Context {
  return $ctx;
}

function context_reveal(Context $ctx)[]: ParseContext {
  return $ctx;
}
