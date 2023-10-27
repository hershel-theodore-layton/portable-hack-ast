/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use type Facebook\HackTest\HackTest;
use namespace HH\Lib\{C, File, Str, Vec};
use namespace HTL\Pha;
use function json_encode_pure;

/**
 * This test enforces some basic safety:
 *  - If a function does not have a `@throws` doc block, it may not throw.
 *  - If an exception is thrown, it must be a PhaException.
 *  - All functions must be annotated with a pure context.
 */
final class EnumerateAllPossibleArgumentsTest extends HackTest {
  const string FUNCTIONS_FILE = __DIR__.'/../src/node_functions.hack';
  const string MY_DIRECTORY = __DIR__.'/EnumerateAllPossibleArgumentsTest/';

  const type TFunctionDefinition = shape(
    'name' => string,
    'parameters' => vec<self::TParameterDefinition>,
    'throws' => bool,
  );
  const type TParameterDefinition = shape('name' => string, 'type' => string);

  const string PREFIX = <<<'PREFIX'
/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use namespace HH\Lib\{File, Vec};
use namespace HTL\Pha;

async function math_001_async(): Awaitable<void> {
  $file = File\open_read_only(__DIR__ . '/../fixtures/001_math.hack');
    using ($file->closeWhenDisposed(), $file->tryLockx(File\LockType::SHARED)) {
      $source = await $file->readAllAsync();
    }

    list($script, $_) = Pha\parse($source, Pha\create_context());

    $nodes = Vec\concat(
      vec[Pha\SCRIPT_NODE],
      Pha\node_get_descendants($script, Pha\SCRIPT_NODE)
    );
    $nillable_nodes = $nodes;
    $nillable_nodes[] = Pha\NIL;

    $syntaxes = Vec\filter($nodes, Pha\node_is_syntax<>) |> Vec\map($$, Pha\as_syntax<>);
    $nillable_syntaxes = $syntaxes;
    $nillable_syntaxes[] = Pha\NIL;

    $tokens = Vec\filter($nodes, Pha\node_is_token<>) |> Vec\map($$, Pha\as_token<>);
    $nillable_tokens = $tokens;
    $nillable_tokens[] = Pha\NIL;

    $trivia = Vec\filter($nodes, Pha\node_is_trivium<>) |> Vec\map($$, Pha\as_trivium<>);
    $nillable_trivia = $trivia;
    $nillable_trivia[] = Pha\NIL;

    ()[] ==> {

PREFIX;

  const string SUFFIX = <<<'SUFFIX'
    }();
}

SUFFIX;

  const dict<string, string> ENUMERATORS = dict[
    'Syntax' => '$syntaxes',
    'NillableSyntax' => '$nillable_syntaxes',
    'Token' => '$tokens',
    'NillableToken' => '$nillable_tokens',
    'Trivium' => '$trivia',
    'NillableTrivium' => '$nillable_trivia',
    'Node' => '$nodes',
    'NillableNode' => '$nillable_nodes',
    'int' => 'Vec\\range(-100, 100)',
  ];

  <<__Override>>
  public static async function afterLastTestAsync(): Awaitable<void> {
    $test_code = await static::parseAsync(static::FUNCTIONS_FILE)
      |> static::scanForFunctionDefinitions($$)
      |> Vec\map($$, static::createTestCase<>)
      |> Str\join($$, "\n\n")
      |> static::PREFIX.$$.static::SUFFIX;

    await file_put_hackfmt_async(
      static::MY_DIRECTORY.'001_math.codegen.hack',
      $test_code,
    );
  }

  public async function testAllEnumerations(): Awaitable<void> {
    await math_001_async();
  }

  private static function scanForFunctionDefinitions(
    Pha\Script $script,
  )[]: vec<self::TFunctionDefinition> {
    return Pha\node_get_first_childx($script, Pha\SCRIPT_NODE)
      |> Pha\node_get_children($script, $$)
      |> Vec\filter(
        $$,
        $n ==> Pha\node_get_kind($script, $n) === Pha\KIND_FUNCTION_DECLARATION,
      )
      |> Vec\map(
        $$,
        $n ==> Pha\as_syntax($n)
          |> Pha\syntax_member(
            $script,
            $$,
            Pha\MEMBER_FUNCTION_DECLARATION_HEADER,
          )
          |> Pha\as_syntax($$)
          |> static::breakApartFunctionDeclHeader($script, $$),
      );
  }

  private static function breakApartFunctionDeclHeader(
    Pha\Script $script,
    Pha\Syntax $decl_header,
  )[]: self::TFunctionDefinition {
    $name = Pha\syntax_member($script, $decl_header, Pha\MEMBER_FUNCTION_NAME)
      |> Pha\as_token($$)
      |> Pha\token_get_text_trivium($script, $$)
      |> Pha\node_get_code($script, $$)
      |> 'Pha\\'.$$;

    $params = Pha\syntax_member(
      $script,
      $decl_header,
      Pha\MEMBER_FUNCTION_PARAMETER_LIST,
    )
      |> Pha\as_syntax($$)
      |> Pha\list_get_items_of_children($script, $$)
      |> Vec\map(
        $$,
        $n ==> Pha\as_syntax($n)
          |> shape(
            'name' => Pha\syntax_member($script, $$, Pha\MEMBER_PARAMETER_NAME)
              |> Pha\node_get_kind($script, $$) !== Pha\KIND_VARIABLE_TOKEN
                ? Pha\as_syntax($$)
                  |> Pha\syntax_member(
                    $script,
                    $$,
                    Pha\MEMBER_DECORATED_EXPRESSION_EXPRESSION,
                  )
                : $$
              |> Pha\as_token($$)
              |> Pha\token_get_text_trivium($script, $$)
              |> Pha\node_get_code($script, $$),
            'type' => Pha\syntax_member($script, $$, Pha\MEMBER_PARAMETER_TYPE)
              |> Pha\node_get_code($script, $$)
              |> Str\trim($$),
          ),
      );

    $throws = Pha\node_get_parent($script, $decl_header)
      |> Pha\node_get_code($script, $$)
      |> Str\contains($$, '@throws');

    return shape('name' => $name, 'parameters' => $params, 'throws' => $throws);
  }

  private static function createTestCase(
    self::TFunctionDefinition $func,
  )[]: string {
    $non_script_params =
      Vec\filter($func['parameters'], $p ==> $p['type'] !== 'Script');
    $invoke = $non_script_params === $func['parameters']
      ? $func['name'].'('
      : $func['name'].'($script, ';

    $types = Vec\map($non_script_params, $p ==> $p['type']);

    if (C\any($types, $t ==> !C\contains_key(static::ENUMERATORS, $t))) {
      $_error = null;
      return '// Could not enumerate: '.
        $func['name'].
        ': '.
        json_encode_pure($types, inout $_error);
    }

    $loops = Vec\map_with_key(
      $types,
      ($i, $t) ==>
        Str\format('foreach(%s as $p%d)', static::ENUMERATORS[$t], $i),
    )
      |> Str\join($$, "\n");

    $statement = Str\format(
      '%s%s);',
      $invoke,
      Vec\map_with_key($types, ($i, $_) ==> '$p'.$i) |> Str\join($$, ', '),
    );

    if ($func['throws']) {
      $statement = 'try { '.$statement.' } catch (Pha\PhaException $_) {}';
    }

    return $loops.$statement;
  }

  private static async function parseAsync(
    string $path,
  ): Awaitable<Pha\Script> {
    $file = File\open_read_only($path);
    using ($file->closeWhenDisposed(), $file->tryLockx(File\LockType::SHARED)) {
      $source = await $file->readAllAsync();
    }

    $ctx = Pha\create_context();
    list($script, $ctx) = Pha\parse($source, $ctx);

    return $script;
  }
}
