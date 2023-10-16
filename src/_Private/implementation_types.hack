/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype Context = ParseContext;
newtype NodeId = int;
newtype Script = TranslationUnit;

function context_hide(ParseContext $ctx)[]: Context {
  return $ctx;
}

function context_reveal(Context $ctx)[]: ParseContext {
  return $ctx;
}

function node_id_to_int(NodeId $node_id)[]: int {
  return $node_id;
}

function node_id_from_int(int $node_id)[]: NodeId {
  return $node_id;
}

function translation_unit_hide(TranslationUnit $tu)[]: Script {
  return $tu;
}

function translation_unit_reveal(Script $script)[]: TranslationUnit {
  return $script;
}
