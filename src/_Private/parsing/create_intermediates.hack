/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function create_intermediates(
  dict<arraykey, mixed> $parse_tree,
  inout dict<SyntaxKind, vec<Member>> $known_member_names,
  inout keyset<TokenKind> $known_token_kinds,
  inout keyset<TriviumKind> $known_trivium_kinds,
)[]: vec<Intermediate> {
  $id = 0;
  $completed = vec[];
  $queue = vec[new Wrapped($parse_tree, $id)];
  $queue_ptr = 0;

  do {
    $to_parse = $queue[$queue_ptr];
    switch ($to_parse->getItem()['kind'] as string) {
      case 'token':
        $wrapped_nodes = vec[];
        list($token, $trivia) = create_intermediate_token($to_parse, $id);
        $intermediates = Vec\concat(vec[$token], $trivia);
        $token_kind = $token->getTokenKind();
        if (!C\contains_key($known_token_kinds, $token_kind)) {
          $known_token_kinds[] = $token_kind;
        }
        foreach ($trivia as $trivium) {
          $trivium_kind = $trivium->getTriviumKind();
          if (!C\contains_key($known_trivium_kinds, $trivium_kind)) {
            $known_trivium_kinds[] = $trivium_kind;
          }
        }
        break;
      case 'list':
        list($list, $wrapped_nodes) = create_intermediate_list($to_parse, $id);
        $intermediates = vec[$list];
        break;
      case 'missing':
        $wrapped_nodes = vec[];
        $intermediates = vec[create_intermediate_missing($to_parse, $id)];
        break;
      default /* syntax */:
        list($syntax, $wrapped_nodes) =
          create_intermediate_syntax($to_parse, $id);
        $intermediates = vec[$syntax];
        if (!C\contains_key($known_member_names, $syntax->getSyntaxKind())) {
          $new_names = vec[];

          foreach (Vec\keys($to_parse->getItem()) as $member_name) {
            if ($member_name !== 'kind') {
              $new_names[] = Pha\member_from_string($member_name as string);
            }
          }

          $known_member_names[$syntax->getSyntaxKind()] = $new_names;
        }
    }

    ++$queue_ptr;
    $id += C\count($intermediates);

    foreach ($intermediates as $intermediate) {
      $completed[] = $intermediate;
    }

    foreach ($wrapped_nodes as $node) {
      $queue[] = $node;
    }
  } while (C\contains_key($queue, $queue_ptr));

  return Vec\sort_by($completed, $i ==> $i->getId());
}
