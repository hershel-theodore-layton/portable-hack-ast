/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HTL\Pha;

final class Intermediate {
  public function __construct(
    private IntermediateGroup $group,
    private int $id,
    private int $parentId,
    private Kind $kind,
    private ?int $textLength = null,
    private ?int $tokenTextTriviumOffset = null,
  )[] {}

  public function getGroup()[]: IntermediateGroup {
    return $this->group;
  }

  public function getGroupName()[]: string {
    return IntermediateGroup::getNames()[$this->group];
  }

  public function getId()[]: int {
    return $this->id;
  }

  public function getParentId()[]: int {
    return $this->parentId;
  }

  public function getSyntaxKind()[]: SyntaxKind {
    invariant(
      $this->group === IntermediateGroup::SYNTAX,
      '%s can not be called on a %s.',
      __FUNCTION__,
      $this->getGroupName(),
    );
    return $this->kind |> Pha\syntax_kind_from_kind($$);
  }

  public function getTokenKind()[]: TokenKind {
    invariant(
      $this->group === IntermediateGroup::TOKEN,
      '%s can not be called on a %s.',
      __FUNCTION__,
      $this->getGroupName(),
    );
    return $this->kind |> Pha\token_kind_from_kind($$);
  }

  public function getTriviumKind()[]: TriviumKind {
    invariant(
      $this->group === IntermediateGroup::TRIVIUM,
      '%s can not be called on a %s.',
      __FUNCTION__,
      $this->getGroupName(),
    );
    return $this->kind |> Pha\trivium_kind_from_kind($$);
  }

  public function getTextLength()[]: ?int {
    return $this->textLength;
  }

  public function getTextLengthx()[]: int {
    invariant(
      $this->textLength is nonnull,
      '%s (%s) has no text',
      $this->kind,
      $this->getGroupName(),
    );
    return $this->textLength;
  }

  public function getTokenTextTriviumOffset()[]: ?int {
    return $this->tokenTextTriviumOffset;
  }

  public function getTokenTextTriviumOffsetx()[]: int {
    invariant(
      $this->tokenTextTriviumOffset is nonnull,
      '%s (%s) has no token text trivium offset',
      $this->kind,
      $this->getGroupName(),
    );
    return $this->tokenTextTriviumOffset;
  }
}
