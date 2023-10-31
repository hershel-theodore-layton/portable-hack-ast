/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype Script = TranslationUnit;

function translation_unit_hide(TranslationUnit $tu)[]: Script {
  return $tu;
}

function translation_unit_reveal(Script $script)[]: TranslationUnit {
  return $script;
}
