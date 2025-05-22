/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Project_JidVfBr9MLh6\GeneratedTestChain;

use namespace HTL\TestChain;

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroupAsync(\HTL\Pha\Tests\enumerate_all_possible_arguments_test_async<>)
    ->addTestGroupAsync(\HTL\Pha\Tests\node_functions_test_async<>)
    ->addTestGroup(\HTL\Pha\Tests\serialization_test<>);
}
