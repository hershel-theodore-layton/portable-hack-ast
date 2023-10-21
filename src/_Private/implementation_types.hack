/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype Context = ParseContext;
newtype NodeId as arraykey = int;
newtype Script = TranslationUnit;
newtype SiblingId as arraykey = int;

function context_hide(ParseContext $ctx)[]: Context {
  return $ctx;
}

function context_reveal(Context $ctx)[]: ParseContext {
  return $ctx;
}

function node_id_add(NodeId $node_id, int $n)[]: NodeId {
  return $node_id + $n;
}

function node_id_to_int(NodeId $node_id)[]: int {
  return $node_id;
}

function node_id_from_int(int $node_id)[]: NodeId {
  return $node_id;
}

function sibling_id_add(SiblingId $sibling_id, int $n)[]: SiblingId {
  return $sibling_id + $n;
}

function sibling_id_to_int(SiblingId $sibling_id)[]: int {
  return $sibling_id;
}

function sibling_id_from_int(int $int)[]: SiblingId {
  return $int;
}

function translation_unit_hide(TranslationUnit $tu)[]: Script {
  return $tu;
}

function translation_unit_reveal(Script $script)[]: TranslationUnit {
  return $script;
}
