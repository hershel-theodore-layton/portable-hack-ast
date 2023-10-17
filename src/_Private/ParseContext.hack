/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HTL\Pha;

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
    dict<string, vec<string>> $new_member_names,
    keyset<string> $new_token_kinds,
    keyset<string> $new_trivium_kinds,
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
        vec($new_token_kinds),
        Pha\token_kind_from_string<>,
      );
    }

    if (!$trivium_kinds->isOfSameSize($new_trivium_kinds)) {
      $upgrade_needed = true;
      $trivium_kinds = new InternedStringStorage<TriviumKind>(
        vec($new_trivium_kinds),
        Pha\trivium_kind_from_string<>,
      );
    }

    return $upgrade_needed
      ? new ParseContext($structs, $syntax_kinds, $token_kinds, $trivium_kinds)
      : $this;
  }
}
