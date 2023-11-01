/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype KindIndex<Tnode as Node, Tkind as Kind> = Index<Tnode, Tkind>;

function index_hide<Tnode as Node, Tkind as Kind>(
  Index<Tnode, Tkind> $index,
)[]: KindIndex<Tnode, Tkind> {
  return $index;
}

function index_reveal<Tnode as Node, Tkind as Kind>(
  KindIndex<Tnode, Tkind> $index,
)[]: Index<Tnode, Tkind> {
  return $index;
}
