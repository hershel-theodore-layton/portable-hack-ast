/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HTL\Pha;
use type ExceptionWithPureGetMessage;

final class PhaException
  extends ExceptionWithPureGetMessage
  implements Pha\PhaException {}
