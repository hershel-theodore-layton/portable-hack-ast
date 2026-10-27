/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

/**
 * Think `invariant(...)`, but for `PhaException` instead.
 * The message is formatted only when the assertion fails.
 */
function enforce(bool $assertion, (function()[]: string) $message)[]: void {
  if (!$assertion) {
    throw new PhaException($message());
  }
}
