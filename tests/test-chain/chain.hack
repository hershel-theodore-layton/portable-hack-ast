/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Project_JidVfBr9MLh6\GeneratedTestChain;

use namespace HTL\TestChain;

async function tests_async<T as TestChain\Chain>(
  TestChain\ChainController<T> $controller
)[defaults]: Awaitable<TestChain\ChainController<T>> {
  return $controller
    ->addTestGroupAsync(\HTL\Pha\Tests\enumerate_all_possible_arguments_test_async<>)
    ->addTestGroupAsync(\HTL\Pha\Tests\node_functions_test_async<>)
    ->addTestGroup(\HTL\Pha\Tests\serialization_test<>);
}
