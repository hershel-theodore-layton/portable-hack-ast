/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\Tests;

use namespace HTL\{Pha, TestChain};

<<TestChain\Discover>>
function serialization_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('test_serialization', ()[defaults] ==> {
      $script = parse('<<Attribute(1, 2, 3)>> function func1()[]: void { }');

      $dematerialized = dematerialize($script);

      expect(
        Pha\materialize_script(
          $dematerialized['script'],
          Pha\materialize_context($dematerialized['context']),
        )
          |> \var_export($$, true),
      )->toEqual(\var_export($script, true));

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
      )->toThrowPhaException('with a different version of this library');
    });
}

// Testing roundtrippability through \fb_compact_serialize(),
// because is does some awful magic to arrays.
function dematerialize(
  Pha\Script $script,
)[defaults]: Pha\ReadyToSerializeScript {
  $_ok = null;
  $_err = null;
  return Pha\dematerialize_script($script)
    |> \fb_compact_serialize($$)
    |> \fb_compact_unserialize($$, inout $_ok, inout $_err)
    |> shape(
      'context' =>
        Pha\_Private\change_array_kinds_for_hhvm_4_102($$['context']),
      'context_hash' => $$['context_hash'],
      'script' => Pha\_Private\change_array_kinds_for_hhvm_4_102($$['script']),
    );
}

function parse(string $code)[]: Pha\Script {
  $ctx = Pha\create_context();
  list($script, $_) = Pha\parse($code, $ctx);
  return $script;
}
