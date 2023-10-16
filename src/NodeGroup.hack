/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

enum NodeElaboratedGroup: int {
  TRIVIUM = 0;
  TOKEN = 1;
  SYNTAX = 2;
  LIST = 3;
  MISSING = 4;
}
