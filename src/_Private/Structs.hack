/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Dict, Keyset, Vec};
use namespace HTL\Pha;

final class Structs {
  private int $size;
  private vec<int> $memberCounts;

  public function __construct(
    private dict<SyntaxKind, vec<Member>> $rawMembers,
  )[] {
    $this->size = C\count($rawMembers);
    $this->memberCounts = Vec\map($rawMembers, C\count<>);
  }

  public function asInternedStrings()[]: InternedStringStorage<SyntaxKind> {
    return new InternedStringStorage<SyntaxKind>(
      Keyset\keys($this->rawMembers),
      Pha\syntax_kind_from_string<>,
    );
  }

  public function getMemberCount(
    InternedString<SyntaxKind> $syntax_kind,
  )[]: int {
    return $this->memberCounts[interned_string_to_int($syntax_kind)];
  }

  public function getRaw()[]: dict<SyntaxKind, vec<Member>> {
    return $this->rawMembers;
  }

  public function isOfSameSize(dict<string, vec<Member>> $new_members)[]: bool {
    return $this->size === C\count($new_members);
  }

  //#region Materialization
  const string VERSION = 'VERSION';
  const int VERSION_NUMBER = 3;
  const string MEMBERS = 'MEMBERS';

  public function dematerialize()[]: dict<arraykey, mixed> {
    return dict[
      static::VERSION => static::VERSION_NUMBER,
      static::MEMBERS => Vec\flatten($this->rawMembers),
    ];
  }

  public static function materialize(dict<arraykey, mixed> $raw)[]: this {
    enforce(
      idx($raw, static::VERSION) === static::VERSION_NUMBER,
      'Could not materialize these Structs, '.
      'they were dematerialized with a later version of this library.',
    );

    return $raw[static::MEMBERS]
      |> as_vec_of_member($$)
      |> Dict\group_by($$, Pha\member_get_syntax_kind<>)
      |> new static($$);
  }
  //#endregion
}
