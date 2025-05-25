/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use namespace HH\Lib\{C, File, Str, Vec};
use namespace HTL\{Pha, TestChain};

/**
 * This test enforces some basic safety:
 *  - If a function does not have a `@throws` doc block, it may not throw.
 *  - If an exception is thrown, it must be a PhaException.
 *  - All functions must be annotated with a pure context.
 */
<<TestChain\Discover>>
async function enumerate_all_possible_arguments_test_async(
  TestChain\Chain $chain,
)[defaults]: Awaitable<TestChain\Chain> {
  $test_code = await EnumerateAllPossibleArgumentsTest::parseAsync(
    EnumerateAllPossibleArgumentsTest::FUNCTIONS_FILE,
  )
    |> EnumerateAllPossibleArgumentsTest::scanForFunctionDefinitions($$)
    |> Vec\map($$, EnumerateAllPossibleArgumentsTest::createTestCase<>)
    |> Str\join($$, "\n\n")
    |> EnumerateAllPossibleArgumentsTest::PREFIX.
      $$.
      EnumerateAllPossibleArgumentsTest::SUFFIX;

  await file_put_hackfmt_async(
    EnumerateAllPossibleArgumentsTest::MY_DIRECTORY.'001_math.codegen.hack',
    $test_code,
  );

  return $chain->group(__FUNCTION__)
    ->testAsync('testAllEnumerations', async () ==> {
      await math_001_async();
    });
}

final class EnumerateAllPossibleArgumentsTest {
  const string FUNCTIONS_FILE = __DIR__.'/../src/node_functions.hack';
  const string MY_DIRECTORY = __DIR__.'/EnumerateAllPossibleArgumentsTest/';

  const type TFunctionDefinition = shape(
    'name' => string,
    'parameters' => vec<self::TParameterDefinition>,
    'throws' => bool,
    /*_*/
  );
  const type TParameterDefinition =
    shape('name' => string, 'type' => string /*_*/);

  const string PREFIX = <<<'PREFIX'
/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use namespace HH\Lib\{File, Vec};
use namespace HTL\Pha;

async function math_001_async()[defaults]: Awaitable<void> {
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

    $syntaxes = Vec\filter($nodes, Pha\is_syntax<>) |> Vec\map($$, Pha\as_syntax<>);
    $nillable_syntaxes = $syntaxes;
    $nillable_syntaxes[] = Pha\NIL;

    $tokens = Vec\filter($nodes, Pha\is_token<>) |> Vec\map($$, Pha\as_token<>);
    $nillable_tokens = $tokens;
    $nillable_tokens[] = Pha\NIL_TOKEN;

    $trivia = Vec\filter($nodes, Pha\is_trivium<>) |> Vec\map($$, Pha\as_trivium<>);

    $source_ranges = Vec\map($nodes, $n ==> Pha\node_get_source_range($script, $n));

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
    'SourceRange' => '$source_ranges',
  ];

  public static function scanForFunctionDefinitions(
    Pha\Script $script,
  )[]: vec<self::TFunctionDefinition> {
    $get_function_declaration_header = Pha\create_member_accessor(
      $script,
      Pha\MEMBER_FUNCTION_DECLARATION_HEADER,
    )
      |> Pha\returns_syntax($$);

    $is_function_declaration =
      Pha\create_syntax_matcher($script, Pha\KIND_FUNCTION_DECLARATION);

    return Pha\node_get_first_childx($script, Pha\SCRIPT_NODE)
      |> Pha\node_get_children($script, $$)
      |> Vec\filter($$, $is_function_declaration)
      |> Vec\map(
        $$,
        $n ==> Pha\as_syntax($n)
          |> $get_function_declaration_header($$)
          |> static::breakApartFunctionDeclHeader($script, $$),
      );
  }

  private static function breakApartFunctionDeclHeader(
    Pha\Script $script,
    Pha\Syntax $decl_header,
  )[]: self::TFunctionDefinition {
    $get_decorated_expression = Pha\create_member_accessor(
      $script,
      Pha\MEMBER_DECORATED_EXPRESSION_EXPRESSION,
    )
      |> Pha\returns_token($$);
    $get_function_name =
      Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_NAME)
      |> Pha\returns_token($$);
    $get_parameter_list =
      Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_PARAMETER_LIST)
      |> Pha\returns_syntax($$);
    $get_parameter_name =
      Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_NAME);
    $get_parameter_type =
      Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_TYPE);

    $is_variable_token =
      Pha\create_token_matcher($script, Pha\KIND_VARIABLE_TOKEN);

    $name = $get_function_name($decl_header)
      |> Pha\token_get_text($script, $$)
      |> 'Pha\\'.$$;

    $params = $get_parameter_list($decl_header)
      |> Pha\list_get_items_of_children($script, $$)
      |> Vec\map(
        $$,
        $n ==> Pha\as_syntax($n)
          |> shape(
            'name' => $get_parameter_name($$)
              |> !$is_variable_token($$)
                ? Pha\as_syntax($$) |> $get_decorated_expression($$)
                : Pha\as_token($$)
              |> Pha\token_get_text($script, $$),
            'type' => $get_parameter_type($$)
              |> Pha\node_get_code_compressed($script, $$),
          ),
      );

    $throws = Pha\node_get_parent($script, $decl_header)
      |> Pha\node_get_code($script, $$)
      |> Str\contains($$, '@throws');

    return shape('name' => $name, 'parameters' => $params, 'throws' => $throws);
  }

  public static function createTestCase(
    self::TFunctionDefinition $func,
  )[]: string {
    $non_script_params =
      Vec\filter($func['parameters'], $p ==> $p['type'] !== 'Script');
    $invoke = $non_script_params === $func['parameters']
      ? $func['name'].'('
      : $func['name'].'($script, ';

    $types = Vec\map($non_script_params, $p ==> $p['type']);

    if (C\any($types, $t ==> !C\contains_key(static::ENUMERATORS, $t))) {
      return
        '// Could not enumerate: '.$func['name'].': '.Str\join($types, ', ');
    }

    $loops = Vec\map_with_key(
      $types,
      ($i, $t) ==>
        Str\format('foreach(%s as $p%d) {', static::ENUMERATORS[$t], $i),
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

    return $loops.$statement.Str\repeat('}', C\count($types));
  }

  public static async function parseAsync(
    string $path,
  )[defaults]: Awaitable<Pha\Script> {
    $file = File\open_read_only($path);
    using ($file->closeWhenDisposed(), $file->tryLockx(File\LockType::SHARED)) {
      $source = await $file->readAllAsync();
    }

    $ctx = Pha\create_context();
    list($script, $ctx) = Pha\parse($source, $ctx);

    return $script;
  }
}
