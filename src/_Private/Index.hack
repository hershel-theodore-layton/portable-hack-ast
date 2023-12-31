/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

final class Index<Tnode as Node, Tkind as Kind> {
  /**
   * @param $nodes are sorted by kind, then sub sorted by source order.
   * @param $ranges values are (start, length).
   *   The order is interned string numeric order, but this is not relied upon.
   */
  public function __construct(
    private ParseContext $ctx,
    private Pha\NodeGroup $group,
    private vec<Tnode> $nodes,
    private dict<InternedString<Tkind>, (int, int)> $ranges,
  )[] {}

  /**
   * The returned nodes are in source order.
   */
  public function getByKind(Tkind $kind)[]: vec<Tnode> {
    switch ($this->group) {
      case Pha\NodeGroup::SYNTAX:
        $interned = Pha\syntax_kind_from_kind($kind)
          |> $this->ctx->getSyntaxKinds()->internOrMax($$);
        break;
      case Pha\NodeGroup::TOKEN:
        $interned = Pha\token_kind_from_kind($kind)
          |> $this->ctx->getTokenKinds()->internOrMax($$);
        break;
      case Pha\NodeGroup::TRIVIUM:
        $interned = Pha\trivium_kind_from_kind($kind)
          |> $this->ctx->getTriviumKinds()->internOrMax($$);
    }

    return idx($this->ranges, $interned)
      |> $$ is null ? vec[] : Vec\slice($this->nodes, $$[0], $$[1]);
  }

  /**
   * Careful, `Tnode_` ought to be `Syntax`, `Token`, or `Trivium`, not /just/
   * `Node`, but there is no way to enforce this.
   * If `Tnode_` is `Syntax`, please exclude the LIST and MISSING nodes.
   * `$group` has to belong together with `Tnode_` and `Tkind_`.
   */
  public static function create<Tnode_ as Node, <<__Explicit>> Tkind_ as Kind>(
    ParseContext $ctx,
    Pha\NodeGroup $group,
    vec<Tnode_> $nodes,
  )[]: Index<Tnode_, Tkind_> {
    if (C\is_empty($nodes)) {
      return new Index<Tnode_, Tkind_>($ctx, $group, vec[], dict[]);
    }

    $sorted = Vec\sort_by($nodes, node_get_index_mask<>);
    $ranges = dict[];
    $last_interned = node_get_interned_kind<Tkind_>(C\firstx($sorted));
    $start_range = 0;

    // This $i is just the loop counter, I need it to outlive the loop.
    // A foreach ($sorted as $i => $node) would be more expressive, but
    // HHClientLinter warns about the shadowing, so a manual `++$i` it is...
    $i = 0;
    foreach ($sorted as $node) {
      $interned = node_get_interned_kind<Tkind_>($node);
      if ($interned !== $last_interned) {
        $ranges[$last_interned] = tuple($start_range, $i - $start_range);
        $start_range = $i;
        $last_interned = $interned;
      }
      ++$i;
    }

    $ranges[$last_interned] = tuple($start_range, $i - $start_range + 1);

    return new Index<Tnode_, Tkind_>($ctx, $group, $sorted, $ranges);
  }
}
