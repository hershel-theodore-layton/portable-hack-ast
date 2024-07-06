# portable-hack-ast

_Query the Hack AST in a light and portable manner._

### Quick start

[Just want linters? look here :)](https://github.com/hershel-theodore-layton/portable-hack-ast-linters)

Want to build your own tools on top of the AST?:
 - `composer require hershel-theodore-layton/portable-hack-ast hershel-theodore-layton/portable-hack-ast-extras`
 - Read this README
 - Familiarize yourself with [Node kinds](./src/Kind.hack) and [Members](./src/Member.hack)
 - Autocomplete your way through the API
 - ???
 - Profit

### What is an AST?

An AST is how Hack and HHVM see and reason about your source code.
If you see this piece of code, you can immediately identify and name parts.

```HACK
$var = Math\minva(1, 2 + 3 * 4);
```

This is a statement, let's identify some parts:
 - `minva` is a name, but it belongs together with `Math`.
 - `Math\minva` is a qualified name, which probably resolves to `HH\Lib\Math\minva`.
 - `Math\minva(1, 2 + 3 * 4)` is a function call, which has arguments.
 - `1` is a simple literal number expression.
 - `2 + 3 * 4` is a complex expression, the `3 * 4` binds more tightly.
 - `3 * 4` is a binary expression and the operand is the `KIND_STAR` (`*`) token
 - `2 + 3 * 4` is one too, where the whole part `3 * 4` is the right hand side.
 - `$var = Math\minva(1, 2 + 3 * 4)` is an assignment expression.

If you have been programming for a couple of years (or decades), you do this
classification almost without thinking about it[^1]. Computers also reason about
code this way for a while, before they translate it to something you can run.

### Why would I use an AST?

Let's say this function was a widely used function in a massive codebase.

```HACK
namespace MyNamespace\Rendering;

function to_html(
  Renderable $render,
  bool $be_unsafe = false, 
  bool $use_cache = false,
): string {
  // Code...
}

// In a completely different file...
$rendered = Rendering\to_html($something_untrusted, true);
```

Oh no, you thought you were enabling the cache, but you turned off safety checks!
Luckily this was caught in code review, but this could have ended badly.
Let's `grep` around to see if there are other instances of api confusion.

You will quickly hit a stumbling block, `Rendering\to_html(...)` is called from
hundreds of thousands of places, many of which only pass a `Renderable`.
Oh, let's make the regex more complex to find results with multiple arguments.
And while we are at it, let's also exclude `to_html(..., false, ...)`.
Good luck with that! If the first argument is complex, you are stuck.
You will spend most your regex trying to skip it, but that is almost impossible.

Take a step back and use the right too for the job.
There should be a tool for this, but [pfff](https://github.com/facebookarchive/pfff) got archived in 2017.
Let's build our own, it can't be that much work, can it?
The example is a little large for a README, but very illustrative.

```HACK
function check_for_unsafe_render_calls(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\Resolver $resolver,
)[]: vec<shape('code' => string, 'line' => int)> {
  $get_thing_being_called =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_CALL_RECEIVER);
  $get_arguments =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_CALL_ARGUMENT_LIST);

  $to_txt = $n ==> Pha\node_get_code($script, $n);
  $to_short_txt = $n ==> Pha\node_get_code_compressed($script, $n);
  $to_function_name = $n ==> Pha\resolve_name($resolver, $script, $n);
  $to_line = $n ==>
    Pha\node_get_line_and_column_numbers($script, $n)->getStartLineOneBased();

  $is_calling_to_html = $call ==> $get_thing_being_called($call)
    |> $to_function_name($$) === 'MyNamespace\Rendering\to_html';

  $is_unsafe = $call ==> $get_arguments($call)
    |> Pha\as_syntax($$)
    |> Pha\list_get_items_of_children($script, $$)
    |> C\count($$) > 1 && $to_short_txt($$[1]) !== 'false';

  return Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_FUNCTION_CALL_EXPRESSION,
  )
    |> Vec\filter($$, $call ==> $is_calling_to_html($call) && $is_unsafe($call))
    |> Vec\map(
      $$,
      $call ==> shape('code' => $to_txt($call), 'line' => $to_line($call)),
    );
}
```

We start this function with a `Script`, a `SyntaxIndex`, and a `Resolver`:
 - `Script` respresents your source code. We can query it to get insights.
 - `SyntaxIndex` is used for getting a list of function calls in the Script.
 - `Resolver` will figure out which function you are calling, because namespaces.

Let's define some functions for accessing the data we need:
 - `$get_thing_being_called` gets `Rendering\to_html` from `Rendering\to_html(...)`.
 - `$get_arguments` gets the `$r, true` from `Rendering\to_html($r, true)`.
 - `$to_txt` gets the full text with comments and spaces for the final result.
 - `$to_short_txt` gets the `false` without spaces or comments to compare with.
 - `$to_function_name` gets the function name including the whole namespace.
 - `$to_line` gets the line number at which the code started.

Combine these parts step by step to get `$is_calling_to_html` and `$is_unsafe`.

`Pha\index_get_nodes_by_kind(...)` picks all the function calls from a file.
We filter out only those ones we are interested in.
Transform the output for easy viewing, and you have your codebase wide search ready.

We have just written our very own super specialized linter.
For some more examples of what you can do with an ast, see [`HTL\PhaLinters`](https://github.com/hershel-theodore-layton/portable-hack-ast-linters)

### Getting started

```HACK
$code = ''; // your source code goes here...
// You want to reuse $ctx if you can.
$ctx = Pha\create_context();
// The $script is what you are after, the $ctx is the updated $ctx.
// The object in $ctx is never changed, so use this `list()` assignment to get the new one.
list($script, $ctx) = Pha\parse($code, $ctx);

// Some tools...
// These indexes allow you to use Pha\index_get_nodes_by_kind()
$syntax_index = Pha\create_syntax_kind_index($script);
$token_index = Pha\create_token_kind_index($script);
$trivium_index = Pha\create_trivium_kind_index($script);

// Store your work in a cache (sqlite, apc, files on disk).
$ready_to_serialize = Pha\dematerialize_script($script);
// And get them back.
$deserialized = $ready_to_serialize;
$ctx = Pha\materialize_context($deserialized['context']);
Pha\materialize_script($deserialized['script'], $ctx);

// resolver, and pragma_map require you install portable-hack-ast-extras
// This allows you to resolve names to the namespace they belong in.
$resolver = Pha\create_name_resolver($script, $syntax_index, $token_index);
// This gives you all the `pragma()` declarations and `<<Pragma()>>` annotations.
$pragma_map = Pha\create_pragma_map($script, $syntax_index);
```

The full API for interacting with all these values can be found in [node_functions.hack](./src/node_functions.hack).
There are about 50 functions at the time of writing, so with some auto complete,
you should get the hang of it quite quickly.

For definitions of kinds and members, see [Kind.hack](./src/Kind.hack) and [Member.hack](./src/Member.hack).
If the definitions are incomplete for your hhvm version, you can create them at runtime.
 - `Pha\syntax_kind_from_string(...)`
 - `Pha\token_kind_from_string(...)`
 - `Pha\trivium_kind_from_string(...)`
 - `Pha\member_from_tuple(...)`

### Performance

This library pulls out all the stops in the name of performance. You can parse
very large codebases and keep all the Scripts in memory, no sweat[^2].
HHAST is the target of this benchmark, since it contains a lot of codegenned
definitions, which adequately represent codebases with large classes.

```
Parsing: ../vendor/hhvm/hhast with hhast
1063.71 megabytes used.

Parsing: ../vendor/hhvm/hhast with pha
29.2615 megabytes used.
```

Runtime is more difficult to pin a number on, but Pha is blazingly fast.
I am able to lint everything in the `HTL\` namespace in < 400 milliseconds.
When adding parsing to it (not caching anything), the results still outshine
HHAST, even with HHAST's `.var/cache/hhvm/hhast/parser-cache` mechanism enabled.

### Behind the name

"Portable" Hack AST, what does portable mean?

This codebase is portable between Hack AST versions (read hhvm versions).
Everything in the `HTL\` namespace supports a wide range of hhvm versions.
In order to do that with an AST library, you can't hardcode definitions.
The structure and layout of the AST is dynamically learned at runtime.

The parsed structure is portable between different invocations of the program.
It is represented as two `vec<Node ~ int>`, and a `dict<Kind ~ string, int>`.
When you dematerialize and serialize a Script, you encode arrays of value types.
They can be deserialized and materialized without the loss of information.
This operation is very quick, and may even be used to "swap" large Scripts
to disk if memory pressure becomes too large.

This code is simple enough to be ported to a different language all together.
95% of the code performs simple operations, which would translate 1-to-1 to any
other programming language which would perform better than Hack on HHVM.
The performance of Pha on HHVM suffices for codebases I work with (for now).
When the amount of code I ingest grows another 20&times;, I know there is a path
forward I can take to achieve more performance in a couple of days.

### Naming of conversions

`x_from_y`: (also xs_from_ys)
 - X is a newtype and Y is the underlying type.
 - The value is not checked in any way.
 - It is an unchecked downcast.

`x_to_y`: (also xs_to_ys)
 - X is a newtype and Y is the underlying type.
 - This function strips the newtype away.

`as_x` (where x is not an array):
 - X is a newtype.
 - The unnamed argument is a less specific newtype.
 - Throws if the runtime value does not match.
 - This is a checked downcast.

`as_x` (where x is an array):
 - Restores the runtime value after serialization.
 - Will perform array kind conversion if needed.

`x_hide`:
 - X is an object type.
 - This function "hides" (removes) the methods.
 - No check needed to be performed.

`x_reveal`:
 - X is an object type.
 - The argument is a newtype created by x_hide.
 - This function "reveals" the methods again.

`cast_away_nil`:
 - Perform an unchecked cast from Nillable&lt;T&gt; to T.

### Why use PHA over HHAST or something similar?

1. Pha uses a lot less memory and is faster than HHAST.
   - This means you can write large, complex, whole codebase analysis tools.
2. Pha can represent an invalid Hack file.
   - This makes it particularly suitable for as-you-type tooling.
   - HHAST will break type invariants when your code is not syntactically correct.
3. Pha is portable between different versions/builds of hhvm.
   - This unshackles the linters you get from the version of hhvm you are running.
4. Pha doesn't suppress errors or perform unsafe casts.
   - Sound types for the win!!!
5. Pha runs in the pure context, read `[]`.
   - This makes code easier to reason about and predictable.
   - It makes auditing code easier, because pure code can't do funny business[^3]
     without type system breakers like HH_FIXME and [`Coeffects\backdoor`](https://docs.hhvm.com/hack/reference/function/HH.Coeffects.backdoor/)

### Careful

This library contains a lot of functions that take a `Script` and one or more
`Node` parameters. Every function expects that the `Node` is part of the `Script`
or `NIL`. If you hand an unrelated `Script` and a `Node` to a function,
the result of the operation is undefined[^4].

### Serialization

The caching mechanism is very fast and small. This is important, because most
parsing is actually reparsing. Uncached performance only matters when:
 - Checking out a new repository for the first time.
 - Switching branches to one that you have never seen before.
 - Pulling changes / syncing with HEAD.

As noted in [performance](#performance), uncached parse performance is still good,
but cached performance is a lot better still. In order to cache Scripts
effectively, you must dematerialize them first. You may not observe the
dematerialized representation, it is subject to change. The following table
doesn't account for serialization overhead. The serialized size of a given script
is often about 10 &times; the source size in bytes[^5].

| Key name     | Type                 | Approximate size                                |
| -----------: | :------------------- | :---------------                                |
| VERSION      | int                  | 8 bytes                                         |
| SOURCE_ORDER | vec&lt;int&gt;       | node count &times; 8 bytes                      |
| SIBLINGS     | vec&lt;int&gt;       | syntax&token count &times; 8 bytes              |
| LIST_SIZES   | dict&lt;int, int&gt; | list count where size &gt; 253 &times; 16 bytes |
| SOURCE_TEXT  | string               | Str\length() of source in bytes                 |
| CONTEXT_ID   | string               | 40 bytes                                        |

The Context will also need to be serialized, but a Context is rarely unique.
If you deduplicate them by `context_hash`, the storage requirements fade away.

[^1]: Some some cases, you do think about this, when the precedence is weird.
[^2]: In order to verify these claims, you will have to `git checkout`
      [this commit](https://github.com/hershel-theodore-layton/portable-hack-ast/blob/86e57bd5ea999c57facb790ed61179e4011f5623/bin/mem_usage.hack)
      and run mem_usage.hack in repo auth mode.
[^3]: I am not saying HHAST does, has done, or will do funny business. I am just
      saying that auditing for funny business is easier in pure well-typed code.
[^4]: This doesn't mean it is unsafe, but you may get incorrect results or exceptions.
[^5]: A quick utility is included in `bin/serializer.hack` to verify serialized sizes.
