/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\Str;
use namespace HTL\Pha;
use function gettype;

final class ParseContext {
  public function __construct(
    private Structs $structs,
    private InternedStringStorage<SyntaxKind> $syntaxKinds,
    private InternedStringStorage<TokenKind> $tokenKinds,
    private InternedStringStorage<TriviumKind> $triviumKinds,
  )[] {}

  public function getStructs()[]: Structs {
    return $this->structs;
  }

  public function getSyntaxKinds()[]: InternedStringStorage<SyntaxKind> {
    return $this->syntaxKinds;
  }

  public function getTokenKinds()[]: InternedStringStorage<TokenKind> {
    return $this->tokenKinds;
  }

  public function getTriviumKinds()[]: InternedStringStorage<TriviumKind> {
    return $this->triviumKinds;
  }

  public function upgradeIfNeeded(
    dict<SyntaxKind, vec<Member>> $new_member_names,
    keyset<TokenKind> $new_token_kinds,
    keyset<TriviumKind> $new_trivium_kinds,
  )[]: ParseContext {
    $structs = $this->structs;
    $syntax_kinds = $this->syntaxKinds;
    $token_kinds = $this->tokenKinds;
    $trivium_kinds = $this->triviumKinds;

    $upgrade_needed = false;

    if (!$structs->isOfSameSize($new_member_names)) {
      $upgrade_needed = true;
      $structs = new Structs($new_member_names);
      $syntax_kinds = $structs->asInternedStrings();
    }

    if (!$token_kinds->isOfSameSize($new_token_kinds)) {
      $upgrade_needed = true;
      $token_kinds = new InternedStringStorage<TokenKind>(
        $new_token_kinds,
        Pha\token_kind_from_string<>,
      );
    }

    if (!$trivium_kinds->isOfSameSize($new_trivium_kinds)) {
      $upgrade_needed = true;
      $trivium_kinds = new InternedStringStorage<TriviumKind>(
        $new_trivium_kinds,
        Pha\trivium_kind_from_string<>,
      );
    }

    return $upgrade_needed
      ? new ParseContext($structs, $syntax_kinds, $token_kinds, $trivium_kinds)
      : $this;
  }

  // #region Materialization
  const string VERSION = 'VERSION';
  const int VERSION_NUMBER = 3;
  const string STRUCTS = 'STRUCTS';
  const string SYNTAX_KINDS = 'SYNTAX_KINDS';
  const string TOKEN_KINDS = 'TOKEN_KINDS';
  const string TRIVIUM_KINDS = 'TRIVIUM_KINDS';

  // Memoize because this value can be shared across many scripts.
  <<__Memoize>>
  public function getMaterializationHash()[]: string {
    return $this->dematerialize()
      |> static::toHashable($$)
      |> \sha1($$, false) as string;
  }

  // Memoize because this value can be shared across many scripts.
  <<__Memoize>>
  public function dematerialize()[]: dict<arraykey, mixed> {
    return dict[
      static::VERSION => static::VERSION_NUMBER,
      static::STRUCTS => $this->structs->dematerialize(),
      static::SYNTAX_KINDS => $this->syntaxKinds->asVec(),
      static::TOKEN_KINDS => $this->tokenKinds->asVec(),
      static::TRIVIUM_KINDS => $this->triviumKinds->asVec(),
    ];
  }

  public static function materialize(dict<arraykey, mixed> $raw)[]: this {
    $version = idx($raw, static::VERSION, -1);
    enforce(
      $version === static::VERSION_NUMBER,
      'Could not materialize this Context, '.
      'it was dematerialized with a later version of this library.',
    );

    try {
      return new static(
        $raw[static::STRUCTS] |> Structs::materialize($$ as dict<_, _>),
        $raw[static::SYNTAX_KINDS]
          |> as_vec_of_syntax_kind($$)
          |> keyset($$)
          |> new InternedStringStorage($$, Pha\syntax_kind_from_string<>),
        $raw[static::TOKEN_KINDS]
          |> as_vec_of_token_kind($$)
          |> keyset($$)
          |> new InternedStringStorage($$, Pha\token_kind_from_string<>),
        $raw[static::TRIVIUM_KINDS]
          |> as_vec_of_trivium_kind($$)
          |> keyset($$)
          |> new InternedStringStorage($$, Pha\trivium_kind_from_string<>),
      );
    } catch (\Exception $e) {
      throw
        new PhaException('Could not materialize Context.', $e->getCode(), $e);
    }
  }

  /**
   * The encoding does not need to make sense, as long as it is not ambiguous.
   * json_encode_pure is wasn't available in 4.102, so something inline was done.
   * Changing this breaks backwards compatibility with VERSION=2 serialization.
   * This can be removed when VERSION=3 comes around.
   *
   * The encoding will look a little like json, but instead of quoting strings,
   * they will be encoded as `s<length><bytes>`. This is not ambiguous with
   * anything, since no json construct starts with an `s`.
   */
  private static function toHashable(mixed $mixed)[]: string {
    if ($mixed is string) {
      return 's'.Str\length($mixed).$mixed;
    } else if ($mixed is int) {
      return (string)$mixed;
    } else if ($mixed is dict<_, _>) {
      $out = '{';
      foreach ($mixed as $k => $v) {
        $out .= static::toHashable($k).':'.static::toHashable($v).',';
      }
      $out .= '}';

      return $out;
    } else if ($mixed is vec<_>) {
      $out = '[';
      foreach ($mixed as $v) {
        $out .= static::toHashable($v).',';
      }
      $out .= ']';

      return $out;
    } else if ($mixed is AnyArray<_, _>) {
      $out = '{?';
      foreach ($mixed as $k => $v) {
        $out .= static::toHashable($k).':'.static::toHashable($v).',';
      }
      $out .= '?}';

      return $out;
    }

    invariant_violation('Unhandled type: %s', gettype($mixed) as string);
  }
  // #endregion
}
