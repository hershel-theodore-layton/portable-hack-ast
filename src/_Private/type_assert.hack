/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HTL\Pha;

// These functions assert to AnyArray<_, _> to survive fb_compact_serialize...

function as_dict_of_node_id_to_int(mixed $raw)[]: dict<NodeId, int> {
  $out = dict[];

  foreach (($raw as AnyArray<_, _>) as $k => $v) {
    $out[node_id_from_int($k as int)] = $v as int;
  }

  return $out;
}

function as_vec_of_member(mixed $raw)[]: vec<Member> {
  $out = vec[];

  foreach (($raw as AnyArray<_, _>) as $v) {
    $v as AnyArray<_, _>;
    $out[] = Pha\member_from_tuple(
      tuple(Pha\syntax_kind_from_string($v[0] as string), $v[1] as string),
    );
  }

  return $out;
}

function as_vec_of_node(mixed $raw)[]: vec<Node> {
  $out = vec[];

  foreach (($raw as AnyArray<_, _>) as $v) {
    $out[] = node_from_int($v as int);
  }

  return $out;
}

function as_vec_of_syntax_kind(mixed $raw)[]: vec<SyntaxKind> {
  $out = vec[];

  foreach (($raw as AnyArray<_, _>) as $v) {
    $out[] = Pha\syntax_kind_from_string($v as string);
  }

  return $out;
}

function as_vec_of_token_kind(mixed $raw)[]: vec<TokenKind> {
  $out = vec[];

  foreach (($raw as AnyArray<_, _>) as $v) {
    $out[] = Pha\token_kind_from_string($v as string);
  }

  return $out;
}

function as_vec_of_trivium_kind(mixed $raw)[]: vec<TriviumKind> {
  $out = vec[];

  foreach (($raw as AnyArray<_, _>) as $v) {
    $out[] = Pha\trivium_kind_from_string($v as string);
  }

  return $out;
}
