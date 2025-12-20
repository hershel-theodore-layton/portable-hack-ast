#!/usr/bin/env hhvm
/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\{C, IO, Str, Vec};
use namespace HTL\Pha;

<<__EntryPoint>>
async function main_async()[defaults]: Awaitable<void> {
  $source = await IO\request_input()->readAllAsync();
  $ctx = Pha\create_context();
  list($script, $ctx) = Pha\parse($source, $ctx);
  $dema = Pha\dematerialize_script($script);
  echo \json_encode($dema, \JSON_PRETTY_PRINT);
}

function compactify(
  mixed $value,
  vec<string> $path,
)[defaults]: Traversable<string> {
  $pretty_path =
    Str\join($path, '.') |> Str\lowercase($$) |> Str\pad_right($$, 30, '.');

  if ($value is int) {
    yield Str\format("%s -> An int\n", $pretty_path);
    return;
  }

  if ($value is string) {
    yield Str\format(
      "%s -> A string of length: %d\n",
      $pretty_path,
      Str\length($value),
    );
    return;
  }

  if ($value is vec<_> && C\every($value, $x ==> $x is arraykey)) {
    $value_type = C\first($value)
      |> $$ is null ? '_' : ($$ is int ? 'int' : 'string');
    yield Str\format(
      "%s -> A vec<%s> of length: %d\n",
      $pretty_path,
      $value_type,
      C\count($value),
    );
    return;
  }

  if ($value is vec<_>) {
    foreach ($value as $items) {
      foreach (($items as vec<_>) as $string) {
        invariant($string is string, 'I expected a vec<vec<string>>');
      }
    }

    yield Str\format(
      "%s -> A vec<vec<string>> of length: %d\n",
      $pretty_path,
      C\count($value),
    );
  }

  if ($value is dict<_, _> && C\every($value, $x ==> $x is int)) {
    $key_type =
      C\first_key($value) |> $$ is null ? '_' : \gettype($$) as string;
    yield Str\format(
      "%s -> A dict<%s, int> of length: %d\n",
      $pretty_path,
      $key_type,
      C\count($value),
    );
    return;
  }

  if ($value is dict<_, _>) {
    foreach ($value as $k => $v) {
      foreach (compactify($v, Vec\concat($path, vec[(string)$k])) as $sub) {
        yield $sub;
      }
    }
  }
}
