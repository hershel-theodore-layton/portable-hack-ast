# portable-hack-ast

_Query the Hack AST in a light and portable manner._

### Careful

This library contains a lot of functions that take a `Script` and one or more
`Node` parameters. Every function expects that the `Node` is part of the `Script`
or `NIL`. If you hand an unrelated `Script` and a `Node` to a function,
the result of the operation is undefined. _This doesn't mean it is unsafe, but_
_you may get incorrect results or exceptions._

### Memory use

Pha uses a lot less memory than hhast does. Getting an accurate measurement was
shockingly difficult. HHVM's optimizer is shockingly good at deleting your code
in a puff of optimization. At other times, it seemed like you needed to help it,
by making changes which are semantic noops. This change for dropped the memory
use of the program by 35%. `if $x not in $keyset { $keyset[] = $x; }`.

Even though the `$scripts` vec should be filled, hhvm "knows" you won't observe
it, so all the memory is reclaimed before the call to `\memory_get_usage(true)`.

```HACK
foreach ($sources as $s) {
  list($script, $ctx) = Pha\parse($s, $ctx);
  $scripts[] = $script;
}

$memory_usage = \memory_get_usage(true);

// Ensure the scripts didn't get optimized away by hhvm.
foreach ($scripts as $script) {
  Pha\node_get_children($script, Pha\SCRIPT_NODE);
}
```

Here are the results of this pre-release version:
These results were measured in repo auth mode running in a webserver.

Parsing: ../vendor/hhvm/hhast with pha
28.0874 megabytes used.

Parsing: ../vendor/hhvm/hhast with hhast
1063.71 megabytes used.

An extra 800 kilobytes could be reclaimed by making sure the `$ctx` had all the
used kinds before starting. I inserted this loop before the main loop.
```HACK
foreach ($sources as $s) {
  list(, $ctx) = Pha\parse($s, $ctx);
}
```

Parsing: ../vendor/hhvm/hhast with pha
27.2852 megabytes used.

It would be interesting to see where the memory is being used.

## Stack exhaustion

_This doesn't belong in a README._

I have tested for stack exhastuion, but quickly came to the conclusion that the
Hack typechecker would become your bottleneck before this library gives out.\*
Given the following code:

```HACK
function some_function_name(): void {
  $_ = 4 |> (((...(((())))...)))
  //           ^^^        ^^^
  //            |          |
  // -----------/----------/
  // These dots represent 2400 more parens each.
}
```

The typechecker took 8 extra seconds to start.
No programmer would ever write this of course!

\* The default stack depth of `\HH\ffp_parse_string(...)` is bound by the
`\json_decode_with_error()` default stack depth (512 at the time of writing).
This input caused a TypeError `(null value returned from HH\ffp_parse_string())`.
