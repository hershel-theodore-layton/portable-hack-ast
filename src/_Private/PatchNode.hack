/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Str};
use namespace HTL\Pha;

final class PatchNode {
  public function __construct(
    private Pha\Node $node,
    private string $text,
    private Pha\RetainTrivia $retainTrivia,
  )[] {
    // Missing nodes don't have tokens, which means they can't have trivia either.
    // The algorithm for slicing leading and trailing trivia depends on tokens.
    // By special casing it here, we remove a special case from the algorithm.
    if (Pha\is_missing($node)) {
      $this->retainTrivia = Pha\RetainTrivia::NEITHER;
    }

    if (
      $this->retainTrivia !== Pha\RetainTrivia::NEITHER && Pha\is_trivium($node)
    ) {
      throw new PhaException(Str\format(
        'You may not replace a trivium with %s::%s set. '.
        'This instruction does not make sense.',
        Pha\RetainTrivia::class,
        Pha\RetainTrivia::getNames()[$retainTrivia],
      ));
    }
  }

  public function toReplacement(Script $script)[]: Replacement {
    if ($this->retainTrivia === Pha\RetainTrivia::NEITHER) {
      return new Replacement(
        Pha\node_get_source_range($script, $this->node),
        $this->text,
      );
    }

    list($keep_leading, $keep_trailing) =
      retain_trivia_keep_leading_and_trailing($this->retainTrivia);

    $descendants = Pha\node_get_descendants($script, $this->node);

    $start_node = $keep_leading
      ? C\findx(
          $descendants,
          $d ==> Pha\is_trivium($d) &&
            Pha\node_get_kind($script, $d) === Pha\KIND_TOKEN_TEXT,
        )
      : $this->node;

    $end_node = $keep_trailing
      ? C\findx(
          $descendants,
          $d ==> Pha\is_trivium($d) &&
            Pha\node_get_kind($script, $d) === Pha\KIND_TOKEN_TEXT,
        )
      : $this->node;

    $start = Pha\node_get_source_range($script, $start_node)
      |> source_range_reveal($$)[0];

    $end = Pha\node_get_source_range($script, $end_node)
      |> source_range_reveal($$)[1];

    return new Replacement(source_range_hide(tuple($start, $end)), $this->text);
  }
}
