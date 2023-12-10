#!/usr/bin/env hhvm
/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\IO;
use namespace HTL\Pha;

<<__EntryPoint>>
async function main_async(): Awaitable<void> {
  $source = await IO\request_input()->readAllAsync();
  $ctx = Pha\create_context();
  list($script, $ctx) = Pha\parse($source, $ctx);
  $dema = Pha\dematerialize_script($script);
  echo \fb_compact_serialize($dema['script']);
}
