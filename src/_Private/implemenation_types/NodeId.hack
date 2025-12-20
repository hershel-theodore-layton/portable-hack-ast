/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

newtype NodeId as arraykey = int;

function node_id_add(NodeId $node_id, int $n)[]: NodeId {
  return $node_id + $n;
}

function node_id_sub(NodeId $node_id, int $n)[]: NodeId {
  return $node_id - $n;
}

function node_id_diff(NodeId $a, NodeId $b)[]: NodeId {
  invariant(
    $a >= $b,
    '%s expected arguments to be ordered from large to small',
    __FUNCTION__,
  );

  return $a - $b;
}

function node_id_to_int(NodeId $node_id)[]: int {
  return $node_id;
}

function node_id_from_int(int $node_id)[]: NodeId {
  return $node_id;
}
