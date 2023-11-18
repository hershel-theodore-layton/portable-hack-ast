/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use namespace HH\Lib\{File, Vec};
use namespace HTL\Pha;

async function math_001_async(): Awaitable<void> {
  $file = File\open_read_only(__DIR__.'/../fixtures/001_math.hack');
  using ($file->closeWhenDisposed(), $file->tryLockx(File\LockType::SHARED)) {
    $source = await $file->readAllAsync();
  }

  list($script, $_) = Pha\parse($source, Pha\create_context());

  $nodes = Vec\concat(
    vec[Pha\SCRIPT_NODE],
    Pha\node_get_descendants($script, Pha\SCRIPT_NODE),
  );
  $nillable_nodes = $nodes;
  $nillable_nodes[] = Pha\NIL;

  $syntaxes =
    Vec\filter($nodes, Pha\is_syntax<>) |> Vec\map($$, Pha\as_syntax<>);
  $nillable_syntaxes = $syntaxes;
  $nillable_syntaxes[] = Pha\NIL;

  $tokens = Vec\filter($nodes, Pha\is_token<>) |> Vec\map($$, Pha\as_token<>);
  $nillable_tokens = $tokens;
  $nillable_tokens[] = Pha\NIL;

  $trivia =
    Vec\filter($nodes, Pha\is_trivium<>) |> Vec\map($$, Pha\as_trivium<>);
  $nillable_trivia = $trivia;
  $nillable_trivia[] = Pha\NIL;

  $source_ranges =
    Vec\map($nodes, $n ==> Pha\node_get_source_range($script, $n));

  ()[] ==> {
    // Could not enumerate: Pha\as_nonnil: ["_Private\\Tagged<_Private\\Maybe<T>>"]

    foreach ($nillable_nodes as $p0)
      try {
        Pha\as_syntax($p0);
      } catch (Pha\PhaException $_) {
      }

    foreach ($nillable_nodes as $p0)
      Pha\as_syntax_or_nil($p0);

    foreach ($nillable_nodes as $p0)
      try {
        Pha\as_token($p0);
      } catch (Pha\PhaException $_) {
      }

    foreach ($nillable_nodes as $p0)
      Pha\as_token_or_nil($p0);

    foreach ($nillable_nodes as $p0)
      try {
        Pha\as_trivium($p0);
      } catch (Pha\PhaException $_) {
      }

    foreach ($nillable_nodes as $p0)
      Pha\as_trivium_or_nil($p0);

    // Could not enumerate: Pha\create_matcher: ["vec<SyntaxKind>","vec<TokenKind>","vec<TriviumKind>"]

    // Could not enumerate: Pha\create_member_accessor: ["Member"]

    // Could not enumerate: Pha\create_syntax_matcher: ["SyntaxKind","SyntaxKind"]

    // Could not enumerate: Pha\create_token_matcher: ["TokenKind","TokenKind"]

    // Could not enumerate: Pha\create_trivium_matcher: ["TriviumKind","TriviumKind"]

    // Could not enumerate: Pha\index_get_nodes_by_kind: ["_Private\\KindIndex<Tnode, Tkind>","Tkind"]

    foreach ($nillable_nodes as $p0)
      Pha\is_syntax($p0);

    foreach ($nillable_nodes as $p0)
      Pha\is_token($p0);

    foreach ($nillable_nodes as $p0)
      Pha\is_trivium($p0);

    foreach ($nillable_syntaxes as $p0)
      try {
        Pha\list_get_items_of_children($script, $p0);
      } catch (Pha\PhaException $_) {
      }

    foreach ($nillable_nodes as $p0)
      Pha\node_get_ancestors($script, $p0);

    foreach ($nillable_nodes as $p0)
      Pha\node_get_children($script, $p0);

    foreach ($nillable_nodes as $p0)
      Pha\node_get_code($script, $p0);

    foreach ($nillable_nodes as $p0)
      Pha\node_get_code_compressed($script, $p0);

    foreach ($nillable_nodes as $p0)
      Pha\node_get_descendants($script, $p0);

    foreach ($nodes as $p0)
      Pha\node_get_elaborated_group($p0);

    foreach ($nillable_nodes as $p0)
      Pha\node_get_first_child($script, $p0);

    foreach ($nodes as $p0)
      try {
        Pha\node_get_first_childx($script, $p0);
      } catch (Pha\PhaException $_) {
      }

    foreach ($nodes as $p0)
      Pha\node_get_group($p0);

    foreach ($nillable_nodes as $p0)
      Pha\node_get_group_name($p0);

    foreach ($nodes as $p0)
      Pha\node_get_id($p0);

    foreach ($nodes as $p0)
      Pha\node_get_kind($script, $p0);

    foreach ($nillable_nodes as $p0)
      Pha\node_get_last_child($script, $p0);

    foreach ($nodes as $p0)
      try {
        Pha\node_get_last_childx($script, $p0);
      } catch (Pha\PhaException $_) {
      }

    foreach ($nillable_nodes as $p0)
      Pha\node_get_last_descendant($script, $p0);

    foreach ($nodes as $p0)
      Pha\node_get_last_descendant_or_self($script, $p0);

    foreach ($nillable_nodes as $p0)
      foreach (Vec\range(-100, 100) as $p1)
        try {
          Pha\node_get_nth_child($script, $p0, $p1);
        } catch (Pha\PhaException $_) {
        }

    foreach ($nodes as $p0)
      foreach (Vec\range(-100, 100) as $p1)
        try {
          Pha\node_get_nth_childx($script, $p0, $p1);
        } catch (Pha\PhaException $_) {
        }

    foreach ($nodes as $p0)
      Pha\node_get_parent($script, $p0);

    foreach ($nodes as $p0)
      Pha\node_get_source_order($p0);

    foreach ($nodes as $p0)
      Pha\node_get_source_range($script, $p0);

    foreach ($nillable_nodes as $p0)
      Pha\node_get_syntax_ancestors($script, $p0);

    Pha\script_get_syntaxes($script);

    Pha\script_get_syntaxes_without_missing_and_list($script);

    Pha\script_get_tokens($script);

    Pha\script_get_trivia($script);

    foreach ($source_ranges as $p0)
      Pha\source_range_to_file_and_line_numbers($script, $p0);

    foreach ($syntaxes as $p0)
      Pha\syntax_get_members($script, $p0);

    foreach ($syntaxes as $p0)
      Pha\syntax_get_parent($script, $p0);

    // Could not enumerate: Pha\syntax_member: ["Syntax","Member"]

    foreach ($tokens as $p0)
      Pha\token_get_parent($script, $p0);

    foreach ($nillable_tokens as $p0)
      Pha\token_get_text($script, $p0);

    foreach ($tokens as $p0)
      Pha\token_get_text_trivium($script, $p0);

    foreach ($trivia as $p0)
      Pha\trivium_get_parent($script, $p0);
  }();
}
