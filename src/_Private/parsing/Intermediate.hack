/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\Dict;
use type JsonSerializable;

final class Intermediate implements JsonSerializable {
  /**
   * A representation trick:
   *            token
   *              |
   *     --------------------
   *     |        |         |
   *(leading*)   ttt   (trailing)*
   */
  const string TOKEN_TEXT_TRIVIUM = 'token_text_trivium';

  public function __construct(
    private IntermediateGroup $group,
    private int $id,
    private int $parentId,
    private string $kind,
    private ?string $text = null,
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

  public function getKind()[]: string {
    return $this->kind;
  }

  public function getText()[]: ?string {
    return $this->text;
  }

  public function getTextx()[]: string {
    invariant(
      $this->text is nonnull,
      '%s (%s) has no text',
      $this->kind,
      $this->getGroupName(),
    );
    return $this->text;
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

  public function jsonSerialize()[]: dict<string, mixed> {
    return dict[
      'group' => $this->getGroupName(),
      'id' => $this->id,
      'parentId' => $this->parentId,
      'kind' => $this->kind,
      'text' => $this->text
    ]
      |> Dict\filter_nulls($$);
  }
}
