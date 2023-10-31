/** portable-hack-ast is MIT licensed, see /LICENSE. */
use namespace Facebook\HHAST;
use namespace HH\Lib\{C, Regex, Str, Vec};
use namespace HTL\Pha;

<<__EntryPoint>>
async function mem_usage_async(): Awaitable<void> {
  $argv = \HH\global_get('argv') ??
    Vec\concat(vec[__FILE__], \HH\global_get('_GET') as Container<_>)
    |> $$ as Container<_>
    |> Vec\map($$, $a ==> $a as string);

  if (C\count($argv) < 3) {
    echo 'Please pass a base directory and a library. '.
      'In a url use, ?0=hhast_or_pha&1=basedir';
    return;
  }

  list(, $lib, $base_dir) = $argv;
  echo 'Parsing: '.$base_dir.' with '.$lib."\n";

  if ($lib === 'pha') {
    $usage = await mem_usage_pha_async($base_dir);
  } else if ($lib === 'hhast') {
    $usage = await mem_usage_hhast_async($base_dir);
  } else {
    echo 'Please pass hhast or pha as arg 1, got: '.$lib;
    return;
  }

  echo Str\format('%g megabytes used.', $usage / 1_000_000.);
}

async function mem_usage_pha_async(string $base_path): Awaitable<int> {
  $sources = fat_glob($base_path) |> Vec\map($$, \file_get_contents<>);
  $ctx = Pha\create_context();
  $scripts = vec[];

  foreach ($sources as $s) {
    list($script, $ctx) = Pha\parse($s, $ctx);
    $scripts[] = $script;
  }

  $memory_usage = \memory_get_usage(true);

  // Ensure the scripts didn't get optimized away by hhvm.
  foreach ($scripts as $script) {
    Pha\node_get_children($script, Pha\SCRIPT_NODE);
  }

  return $memory_usage;
}

async function mem_usage_hhast_async(string $base_path): Awaitable<int> {
  $files = fat_glob($base_path) |> Vec\map($$, HHAST\File::fromPath<>);

  $scripts = await Vec\map_async($files, HHAST\from_file_async<>);

  $memory_usage = \memory_get_usage(true);

  // Ensure the scripts didn't get optimized away by hhvm.
  foreach ($scripts as $script) {
    $script->getChildren();
  }

  return $memory_usage;
}

function fat_glob(string $base_path): vec<string> {
  return Vec\concat(
    \glob($base_path.'/*.hack'),
    \glob($base_path.'/*/*.hack'),
    \glob($base_path.'/*/*/*.hack'),
    \glob($base_path.'/*/*/*/*.hack'),
    \glob($base_path.'/*/*/*/*/*.hack'),
    \glob($base_path.'/*/*/*/*/*/*.hack'),
    \glob($base_path.'/*/*/*/*/*/*/*.hack'),
  )
    |> Vec\filter(
      $$,
      $p ==> Regex\first_match($p, re'@/bin/[^/]+\.hack@') is null,
    );
}
