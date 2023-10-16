/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

final class Wrapped {
  public function __construct(
    private dict<arraykey, mixed> $item,
    private int $parentId,
  )[] {}

  public function getItem()[]: dict<arraykey, mixed> {
    return $this->item;
  }

  public function createList(int $id)[]: Intermediate {
    return
      new Intermediate(IntermediateGroup::LIST, $id, $this->parentId, 'list');
  }

  public function createMissing(int $id)[]: Intermediate {
    return new Intermediate(
      IntermediateGroup::MISSING,
      $id,
      $this->parentId,
      'missing',
    );
  }

  public function createSyntax(int $id, string $kind)[]: Intermediate {
    return
      new Intermediate(IntermediateGroup::SYNTAX, $id, $this->parentId, $kind);
  }

  public function createToken(
    int $pid,
    string $kind,
    int $number_of_leading,
  )[]: Intermediate {
    return new Intermediate(
      IntermediateGroup::TOKEN,
      $pid,
      $this->parentId,
      $kind,
      null,
      $number_of_leading + 1,
    );
  }
}
