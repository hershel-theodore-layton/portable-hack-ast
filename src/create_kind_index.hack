/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

function create_syntax_kind_index(Script $script)[]: SyntaxIndex {
  $c = _Private\translation_unit_reveal($script)->getParseContext();
  return script_get_syntaxes_without_missing_and_list($script)
    |> _Private\Index::create<Syntax, SyntaxKind>($c, NodeGroup::SYNTAX, $$)
    |> _Private\index_hide($$);
}

function create_token_kind_index(Script $script)[]: TokenIndex {
  $c = _Private\translation_unit_reveal($script)->getParseContext();
  return script_get_tokens($script)
    |> _Private\Index::create<Token, TokenKind>($c, NodeGroup::TOKEN, $$)
    |> _Private\index_hide($$);
}

function create_trivium_kind_index(Script $script)[]: TriviumIndex {
  $c = _Private\translation_unit_reveal($script)->getParseContext();
  return script_get_trivia($script)
    |> _Private\Index::create<Trivium, TriviumKind>($c, NodeGroup::TRIVIUM, $$)
    |> _Private\index_hide($$);
}
