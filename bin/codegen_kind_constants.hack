#!/usr/bin/env hhvm
/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private\Bin;

use namespace HH\Lib\{C, Dict, File, IO, Keyset, Str, Vec};
use type UnexpectedValueException;
use function escapeshellarg;

const string CACHE_DIR = __DIR__.'/../.var/cache/curl_cache/';
const int GITHUB_FETCH_CONCURRENCY = 4;
const string GENERATED = "// #region GENERATED CODE DO NOT EDIT BY HAND!\n";

<<__EntryPoint>>
async function codegen_kind_constants_async()[defaults]: Awaitable<void> {
  try {
    \shell_exec('mkdir -p '.escapeshellarg(CACHE_DIR));
    list($self, $major, $start, $end) = extract_major_start_and_end_from_argv();
    list($syntaxes, $tokens) =
      await download_full_fidelity_syntax_type_and_token_kind_from_github_async(
        $major,
        $start,
        $end,
      );
    list($syntaxes, $tokens) = merge_definitions($syntaxes, $tokens);
  } catch (UnexpectedValueException $e) {
    await (IO\request_error() ?? IO\request_output())->writeAllAsync(
      $e->getMessage(),
    );
    return;
  }

  $sort = $things ==> Dict\sort_by_key(
    $things,
    ($a, $b) ==> Str\uppercase($a) <=> Str\uppercase($b),
  );

  $sort_with_keyset_values = $things ==> Dict\sort_by_key(
    $things,
    ($a, $b) ==> Str\uppercase($a) <=> Str\uppercase($b),
  );

  $calling_card = Str\format(
    "// This code was generated by %s \"%d.%d-%d\".\n\n",
    $self,
    $major,
    $start,
    $end,
  );

  $kind_constants = GENERATED.$calling_card;

  $ambiguous_kinds = Keyset\intersect(Vec\keys($syntaxes), Vec\keys($tokens));

  $syntax_kind_to_const = Dict\map_with_key(
    $syntaxes,
    ($kind, $_) ==> 'KIND_'.
      Str\uppercase(
        C\contains_key($ambiguous_kinds, $kind) ? $kind.'_SYNTAX' : $kind,
      ),
  );

  $token_kind_to_const = Dict\map_with_key(
    $tokens,
    ($kind, $_) ==> 'KIND_'.
      Str\uppercase(
        C\contains_key($ambiguous_kinds, $kind) ? $kind.'_TOKEN' : $kind,
      ),
  );

  foreach ($sort_with_keyset_values($syntaxes) as $name => $_) {
    $kind_constants .= Str\format(
      "const SyntaxKind %s = %s;\n",
      $syntax_kind_to_const[$name],
      string_export_pure($name),
    );
  }

  $kind_constants .= "\n";

  foreach ($sort($tokens) as $name => $repr) {
    $kind_constants .= Str\format(
      "const TokenKind %s = %s;\n",
      $token_kind_to_const[$name],
      string_export_pure($repr),
    );
  }

  $kind_constants .= "// #endregion\n";

  $kind_file = File\open_read_write(__DIR__.'/../src/Kind.hack');
  using (
    $kind_file->closeWhenDisposed(),
    $kind_file->tryLockx(File\LockType::EXCLUSIVE)
  ) {
    $kind_functions = await $kind_file->readAllAsync()
      |> Str\slice($$, 0, Str\search($$, GENERATED) ?? Str\length($$));
    $kind_file->seek(0);
    ftruncate($kind_file, 0);
    await $kind_file->writeAllAsync($kind_functions.$kind_constants);
  }

  $member_to_owner = dict[];

  foreach ($syntaxes as $owner => $members) {
    foreach ($members as $member) {
      $member_to_owner[$member] = $owner;
    }
  }

  $member_constants = GENERATED.$calling_card;

  foreach (Dict\sort_by_key($member_to_owner) as $member => $owner) {
    $member_constants .= Str\format(
      "const Member MEMBER_%s = tuple(%s, %s);\n",
      Str\uppercase($member),
      $syntax_kind_to_const[$owner],
      string_export_pure($member),
    );
  }

  $member_constants .= "// #endregion\n";

  $member_file = File\open_read_write(__DIR__.'/../src/Member.hack');
  using (
    $member_file->closeWhenDisposed(),
    $member_file->tryLockx(File\LockType::EXCLUSIVE)
  ) {
    $member_functions = await $member_file->readAllAsync()
      |> Str\slice($$, 0, Str\search($$, GENERATED) ?? Str\length($$));
    $member_file->seek(0);
    ftruncate($member_file, 0);
    await $member_file->writeAllAsync($member_functions.$member_constants);
  }
}
