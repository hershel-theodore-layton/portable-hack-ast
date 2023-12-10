/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

use type Exception;

/**
 * The exception thrown for all the known reachable error states.
 * If an other exception is thrown from this library,
 * this is a bug and you may report it as such.
 */
interface PhaException {
  require extends Exception;
  public function getMessage()[]: string;
}
