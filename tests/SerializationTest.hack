/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use namespace HH\Lib\{C, Str, Vec};
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

      $source = '<?hh /* comment */ function f(): void {}';
      list($_script, $sample_ctx) = Pha\parse($source, Pha\create_context());
      $sample_raw = Pha\dematerialize_context($sample_ctx)['context'];

      foreach (
        dict[
          'SYNTAX_KINDS' => 'syntax',
          'TOKEN_KINDS' => 'token',
          'TRIVIUM_KINDS' => 'trivia',
        ] as $field => $group
      ) {
        $filler =
          Vec\take($names, 255 - C\count($sample_raw[$field] as vec<_>));
        $fit_raw = Pha\dematerialize_context(Pha\create_context())['context'];
        $fit_raw[$field] = $filler;
        if ($field === 'SYNTAX_KINDS') {
          $fit_raw['STRUCTS'] = dict[
            'VERSION' => 3,
            'MEMBERS' => Vec\map($filler, $name ==> tuple($name, 'child')),
          ];
        }
        list($_fit_script, $fit_ctx) =
          Pha\parse($source, Pha\materialize_context($fit_raw));
        expect(C\count(
          Pha\dematerialize_context($fit_ctx)['context'][$field] as vec<_>,
        ))
          ->toEqual(255);
        expect(()[] ==> Pha\parse($source, $fit_ctx))->toReturn();

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
        expect(()[] ==> Pha\parse($source, $ctx))
          ->toThrowPhaException('distinct '.$group.' kinds');

        foreach (vec[256, 257] as $count) {
          $raw[$field] =
            Vec\map(Vec\range(0, $count - 1), $i ==> Str\format('kind_%d', $i));
          expect(()[] ==> Pha\materialize_context($raw))
            ->toThrowPhaException(
              Str\format('Cannot store %d distinct %s kinds.', $count, $group),
            );
        }
      }
    })
    ->test('context_hash_roundtrip', ()[defaults] ==> {
      // Context names are byte strings; hashing must preserve non-UTF-8 bytes
      // and string boundaries, which a JSON encoder cannot always represent.
      $hashes = keyset[];
      foreach (vec["\xff", "\xfe", 's1a', 'a'] as $name) {
        list($script, $ctx) = Pha\parse_from_tree(
          dict[
            'kind' => 'script',
            'script_declarations' => dict['kind' => $name],
          ],
          '',
          Pha\create_context(),
        );
        $raw = Pha\dematerialize_context($ctx);
        $hashes[] = $raw['context_hash'];
        $restored = Pha\materialize_context($raw['context']);
        expect(Pha\dematerialize_context($restored)['context_hash'])
          ->toEqual($raw['context_hash']);
        expect(
          ()[] ==> Pha\materialize_script(
            Pha\dematerialize_script($script)['script'],
            $restored,
          ),
        )->toReturn();
      }
      expect(C\count($hashes))->toEqual(4);
      $old = Pha\dematerialize_context(Pha\create_context())['context'];
      $old['VERSION'] = 3;
      expect(()[] ==> Pha\materialize_context($old))->toThrowPhaException(
        'it was dematerialized with version 3, but this version is version 4.',
      );
    })
    ->test('distant_parents', ()[defaults] ==> {
      $scripts = vec[
        parse('<?hh function f(): void {}'),
        parse('<?hh '.Str\repeat('/*c*/ ', 600).'function f(): void {}'),
        parse('<?hh function f(): void {'.Str\repeat('; ', 4000).'}'),
        parse(
          '<?hh '.
          Str\repeat('/*c*/ ', 600).
          'function '.
          Str\repeat('/*d*/ ', 600).
          'f(): void {}',
        ),
      ];
      // A synthetic list puts children at every offset, including exactly
      // 16,383 and 16,384, independently of FFP's syntax layouts.
      list($boundary_script, $_ctx) = Pha\parse_from_tree(
        dict[
          'kind' => 'script',
          'script_declarations' => dict[
            'kind' => 'list',
            'elements' => Vec\fill(16384, dict['kind' => 'missing']),
          ],
        ],
        '',
        Pha\create_context(),
      );
      $scripts[] = $boundary_script;
      $seen_boundaries = keyset[];
      foreach ($scripts as $index => $script) {
        $raw = dematerialize($script);
        $offsets = $raw['script']['DISTANT_PARENT_OFFSETS'] as dict<_, _>;
        expect(C\is_empty($offsets))->toEqual($index === 0);
        $restored = Pha\materialize_script(
          $raw['script'],
          Pha\materialize_context($raw['context']),
        );
        foreach (vec[$script, $restored] as $candidate) {
          expect(Pha\node_get_parent($candidate, Pha\SCRIPT_NODE))
            ->toEqual(Pha\SCRIPT_NODE);
          $tu = Pha\_Private\translation_unit_reveal($candidate);
          $overflow_count = 0;
          foreach ($tu->getSourceOrder() as $parent) {
            $children = Pha\node_get_children($candidate, $parent);
            foreach ($children as $child_index => $child) {
              expect(
                Pha\node_get_child_at_offset($candidate, $parent, $child_index),
              )
                ->toEqual($child);
              expect(Pha\node_get_parent($candidate, $child))->toEqual($parent);
              $offset = Pha\node_get_source_order($child) -
                Pha\node_get_source_order($parent);
              $limit = Pha\is_trivium($child) ? 1023 : 16383;
              $packed_offset = Pha\_Private\node_get_parent_offset($child);
              expect($packed_offset)->toEqual($offset > $limit ? 0 : $offset);
              if ($offset > $limit) {
                ++$overflow_count;
                expect($tu->getDistantParentOffset(Pha\node_get_id($child)))
                  ->toEqual($offset);
              }
              if ($offset === $limit || $offset === $limit + 1) {
                $seen_boundaries[] = $offset;
              }
            }
            expect(Pha\node_get_child_at_offset(
              $candidate,
              $parent,
              C\count($children),
            ))
              ->toEqual(Pha\NIL);
            expect(Pha\node_get_child_at_offset(
              $candidate,
              $parent,
              C\count($children) + 1024,
            ))
              ->toEqual(Pha\NIL);
          }
          expect($overflow_count)->toEqual(C\count($offsets));
        }
      }
      expect(C\count($seen_boundaries))->toEqual(4);
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
        'it was dematerialized with version 42, but this version is version 4.',
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
