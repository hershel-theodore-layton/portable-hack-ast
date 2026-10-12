/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use namespace HH\Lib\{Str, Vec};
use namespace HTL\{HH4Shim, Pha, TestChain};
use function json_decode_with_error, json_encode_with_error, var_export;

<<TestChain\Discover>>
function serialization_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('kind_capacity', ()[] ==> {
      $names = Vec\map(Vec\range(0, 254), $i ==> Str\format('kind_%d', $i));
      $storage = new Pha\_Private\InternedStringStorage(
        keyset(Vec\map($names, Pha\syntax_kind_from_string<>)),
        Pha\syntax_kind_from_string<>,
        'syntax',
      );
      expect(
        $storage->intern(Pha\syntax_kind_from_string('kind_254'))
          |> Pha\_Private\interned_string_to_int($$),
      )->toEqual(254);
      expect(
        $storage->internOrMax(Pha\syntax_kind_from_string('absent'))
          |> Pha\_Private\interned_string_to_int($$),
      )->toEqual(255);

      foreach (
        dict[
          'SYNTAX_KINDS' => 'syntax',
          'TOKEN_KINDS' => 'token',
          'TRIVIUM_KINDS' => 'trivia',
        ] as $field => $group
      ) {
        $raw = Pha\dematerialize_context(Pha\create_context())['context'];
        $raw[$field] = $names;
        if ($field === 'SYNTAX_KINDS') {
          $raw['STRUCTS'] = dict[
            'VERSION' => 3,
            'MEMBERS' => Vec\map($names, $name ==> tuple($name, 'child')),
          ];
        }
        $ctx = Pha\materialize_context($raw);
        expect(Pha\dematerialize_context($ctx)['context'][$field])
          ->toEqual($names);
        expect(
          ()[] ==> Pha\parse('<?hh /* comment */ function f(): void {}', $ctx),
        )
          ->toThrowPhaException('distinct '.$group.' kinds');

        foreach (vec[256, 257] as $count) {
          $raw[$field] =
            Vec\map(Vec\range(0, $count - 1), $i ==> Str\format('kind_%d', $i));
          expect(()[] ==> Pha\materialize_context($raw))
            ->toThrowPhaException(
              Str\format(
                'Cannot store %d distinct %s kinds: the packed representation supports at most 255.',
                $count,
                $group,
              ),
            );
        }
      }
    })
    ->test('test_serialization', ()[defaults] ==> {
      $script = parse('<<Attribute(1, 2, 3)>> function func1()[]: void { }');

      $dematerialized = dematerialize($script);

      expect(
        Pha\materialize_script(
          $dematerialized['script'],
          Pha\materialize_context($dematerialized['context']),
        )
          |> var_export($$, true),
      )->toEqual(var_export($script, true));

      expect(
        ()[] ==> Pha\materialize_script(
          $dematerialized['script'],
          Pha\create_context(),
        ),
      )->toThrowPhaException(
        'The Context and the Script do not belong together',
      );

      $dematerialized['script']['VERSION'] = 42;
      expect(
        ()[] ==> Pha\materialize_script(
          $dematerialized['script'],
          Pha\materialize_context($dematerialized['context']),
        ),
      )->toThrowPhaException(
        'it was dematerialized with version 42, but this version is version 3.',
      );
    });
}

// Testing roundtrippability through \fb_compact_serialize() and json_encode(),
// because they do some awful magic to arrays.
function dematerialize(
  Pha\Script $script,
)[defaults]: Pha\ReadyToSerializeScript {
  $_err = null;
  return Pha\dematerialize_script($script)
    |> json_encode_with_error($$, inout $_err)
    |> json_decode_with_error($$ as string, inout $_err, true)
    |> HH4Shim\to_mixed($$) as dict<_, _>
    |> shape(
      'context' => $$['context'] as dict<_, _>,
      'context_hash' => $$['context_hash'] as string,
      'script' => $$['script'] as dict<_, _>,
    );
}

function parse(string $code)[]: Pha\Script {
  $ctx = Pha\create_context();
  list($script, $_) = Pha\parse($code, $ctx);
  return $script;
}
