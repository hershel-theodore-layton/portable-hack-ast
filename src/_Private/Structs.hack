/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

// Note to self: This is incomplete
final class Structs {
  private int $size;
  public function __construct(
    private dict<string, vec<Pha\Member>> $rawMembers,
  )[] {
    $this->size = C\count($rawMembers);
  }

  public function asInternedStrings()[]: InternedStringStorage<SyntaxKind> {
    return new InternedStringStorage<SyntaxKind>(
      Vec\keys($this->rawMembers),
      Pha\syntax_kind_from_string<>,
    );
  }

  public function getRaw()[]: dict<string, vec<Member>> {
    return $this->rawMembers;
  }

  public function isOfSameSize(dict<string, vec<Member>> $new_members)[]: bool {
    return $this->size === C\count($new_members);
  }
}
