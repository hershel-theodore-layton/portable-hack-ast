/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

enum NodeElaboratedGroup: int {
  SYNTAX = 0;
  TOKEN = 1;
  TRIVIUM = 2;
  LIST = 3;
  MISSING = 4;
}
