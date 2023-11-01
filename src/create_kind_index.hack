/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

function create_syntax_kind_index(Script $script)[]: SyntaxIndex {
  return script_get_syntaxes_without_missing_and_list($script)
    |> _Private\Index::create<Syntax, SyntaxKind>(NodeGroup::SYNTAX, $$)
    |> _Private\index_hide($$);
}

function create_token_kind_index(Script $script)[]: TokenIndex {
  return script_get_tokens($script)
    |> _Private\Index::create<Token, TokenKind>(NodeGroup::TOKEN, $$)
    |> _Private\index_hide($$);
}

function create_trivium_kind_index(Script $script)[]: TriviumIndex {
  return script_get_trivia($script)
    |> _Private\Index::create<Trivium, TriviumKind>(NodeGroup::TRIVIUM, $$)
    |> _Private\index_hide($$);
}
