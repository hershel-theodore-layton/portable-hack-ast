/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\Math;

<<__Sealed(Maybe::class)>>
interface Taggable {}
<<__Sealed(Any::class, SyntaxTag::class, TokenTag::class, TriviumTag::class)>>
interface Maybe<+T as Any> extends Taggable {}
<<__Sealed(SyntaxTag::class, TokenTag::class, TriviumTag::class)>>
interface Any extends Maybe<Any> {}
<<__Sealed(NilTag::class)>>
interface SyntaxTag extends Maybe<SyntaxTag>, Any {}
<<__Sealed(NilTag::class)>>
interface TokenTag extends Maybe<TokenTag>, Any {}
<<__Sealed(NilTag::class)>>
interface TriviumTag extends Maybe<TriviumTag>, Any {}
interface NilTag extends SyntaxTag, TokenTag, TriviumTag {}

newtype Tagged<+T as Taggable> = int;

type Nil = Tagged<Maybe<NilTag>>;
type Node = Tagged<Any>;
type Syntax = Tagged<SyntaxTag>;
type Token = Tagged<TokenTag>;
type Trivium = Tagged<TriviumTag>;
type NillableNode = Tagged<Maybe<Any>>;
type NillableSyntax = Tagged<Maybe<SyntaxTag>>;
type NillableToken = Tagged<Maybe<TokenTag>>;
type NillableTrivium = Tagged<Maybe<TriviumTag>>;

const Nil NIL = 0;
const Syntax SCRIPT_NODE = Math\INT64_MIN;

function cast_away_nil<T as Any>(Tagged<Maybe<T>> $t)[]: Tagged<T> {
  return $t;
}

function node_from_int(int $int)[]: Node {
  return $int;
}

function node_to_int(NillableNode $node)[]: int {
  return $node;
}

function nodes_from_ints(vec<int> $ints)[]: vec<Node> {
  return $ints;
}

function nodes_to_ints(vec<NillableNode> $nodes)[]: vec<int> {
  return $nodes;
}

function syntax_from_int(int $int)[]: Syntax {
  return $int;
}

function syntax_from_node(NillableNode $node)[]: Syntax {
  return $node;
}

function syntaxes_from_nodes(vec<NillableNode> $nodes)[]: vec<Syntax> {
  return $nodes;
}

function token_from_int(int $int)[]: Token {
  return $int;
}

function token_from_node(NillableNode $node)[]: Token {
  return $node;
}

function tokens_from_nodes(vec<NillableNode> $nodes)[]: vec<Token> {
  return $nodes;
}

function trivia_from_nodes(vec<NillableNode> $nodes)[]: vec<Trivium> {
  return $nodes;
}

function trivium_from_int(int $int)[]: Trivium {
  return $int;
}

function trivium_from_node(NillableNode $node)[]: Trivium {
  return $node;
}
