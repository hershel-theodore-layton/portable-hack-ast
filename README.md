# portable-hack-ast

_Query the Hack AST in a light and portable manner._

### Careful

This library contains a lot of functions that take a `Script` and one or more
`Node` parameters. Every function expects that the `Node` is part of the `Script`
or `NIL`. If you hand an unrelated `Script` and a `Node` to a function,
the result of the operation is undefined. _This doesn't mean it is unsafe, but_
_you may get incorrect results or exceptions._
