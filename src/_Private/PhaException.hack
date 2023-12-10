/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HTL\Pha;
use type Exception;

final class PhaException extends Exception implements Pha\PhaException {
  <<__Override>>
  public function getMessage()[]: string {
    return $this->message;
  }
}
