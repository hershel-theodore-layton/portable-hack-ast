/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

use type IExceptionWithPureGetMessage;

/**
 * The exception thrown for all the known reachable error states.
 * If an other exception is thrown from this library,
 * this is a bug and you may report it as such.
 */
interface PhaException extends IExceptionWithPureGetMessage {}
