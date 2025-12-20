# Large Script Support

In late 2025, Portable Hack AST got support for Scripts upto 16 MiB
<sub>Terms and conditions apply</sub>[^1]. This document explains the internal
changes that made that possible.

## Rationale

256KB ought to be enough for everybody, #Hershel Theodore Layton ~2023. Well,
not quite, but I considered it to be good enough for linting files. If you want
to use linting to improve code quality, you probably care about readability. A
256KB (10,000 line) class has no place in such a codebase.

On the other hand, there is other tooling besides linting, where missing one or
two omega files in a codebase is simply not acceptable. If you need to be able
to parse every symbol, you simply must be able to grok larger files. It is not
feasible to support arbitrarily large files with the architecture of
Portable Hack AST. The current size is a stretch, that required a few changes
in the core.

In order to bring Portable Hack AST to its knees you need to have a single file
that contains as much code as portable-hack-ast, portable-hack-ast-extras,
portable-hack-ast-linters, and portable-hack-ast-linters-server five times over.
Only then will you see:
```
Implementation limit: Source may not exceed 1048575 (0xfffff) nodes, got 1051545.
```

## Node layout

All versions of Portable Hack AST use a bitpacked `int` to store information
about a Node. This update changes how these bits are used to be able to
represent larger Scripts without using more than one `int` per Node. The layout
used before this update will be called the 2023 layout. The layout introduced
in this update will be called the 2025 layout.

## The Encoding

In both layouts, Nodes have five fields, A through E. The purpose of each field
has remained the same, only the sizes of these fields have changed.

- Field A. For switching on the NodeElaboratedGroup. This is how Pha knows if a Node
   is a Syntax, Token, Trivium, List/Missing.
- Field B. For identifying what kind of Node this is. For Syntax, Token, and Trivium,
   this literally encodes the Kind of the Node. For List and Missing, this
   encodes the number of children.
- Field C. How to get to your parent Node. When dealing with the AST, you frequently
   need to access the children, and the parent of a Node. When querying children
   you also need to access parent information behind the scenes. Safe to say,
   this information is accessed very frequently, and is therefore stored inside
   the Node for quick access.
- Field D. The chameleon field:
  - For Syntaxes, Lists, and Missing, this encodes the SiblingId of the first
    child. This information is vital to return children (and access members)
    quickly.
  - For Tokens, this encodes the index of the token text trivium. This is a
    cute trick Pha pulls to store Trivia and their source text in order.
  - For Trivia, this encodes the SourceByteOffset **to the first byte in the
    source text**. This information is vital when printing any Node. This
    this information is stored inline in the Trivium to utilize memory to the
    fullest.
- Field E. The **NodeId** of the current Node. The single most frequently accessed
  piece of information about a Node.

Field A and B cannot be shrunk. There are simply too many unique token and syntax
kinds to get by with even one bit fewer.

Field D (on a Trivium) is the limiting factor as it comes the maximum size in
bytes a source file can be. If D cannot index into the source text, operations
like printing the code of a Node could not work.

Field E limits the number of nodes that can be in a single Script. Nodes must
have a unique ID for many operations in the AST.

### The 2023 layout

|Name|Size   |
|---:|:------|
|A&B |10 bits|
|C   |18 bits|
|D   |18 bits|
|E   |18 bits|

 - Field C contains the NodeId of the parent Node. Since NodeId's are 18 bits in
this version, Field C has to be 18 bits.
 - Field D must be at least as large as a SiblingId. SiblingId's can be as large
   as a NodeId, so also 18 bits.
 - Field E is a NodeId, so 18 bits it is.

### The 2025 layout

Syntaxes and Tokens in the 2025 layout:

|Name|Size   |
|---:|:------|
|A&B |10 bits|
|C   |14 bits|
|D   |20 bits|
|E   |20 bits|

- Field C, the field that contained the parent NodeId, has been shrunk from 18 to
14 bits. Instead of storing the NodeId, the different between the current NodeId
and the parent NodeId is stored. If the result of this subtraction exceeds the
amount of space available, 0 is stored instead.

- Field D and E can now contain 20 bit NodeId and SiblingId values, instead of
18 bits ones.


Trivia in the 2025 layout:

|Name|Size   |
|---:|:------|
|A&B |10 bits|
|C   |10 bits|
|D   |24 bits|
|E   |20 bits|

- Field C on Trivia is even smaller than it is on Syntaxes and Tokens. These
stolen bits are given to Field D instead. 10 bits is still enough to encode
1022 leading Trivia, a token text trivium, and a trailing Trivium. This only
becomes a pratical limitation when a single token is preceeded by a lot of single
line comments, 511 to be exact. 511 leading single line comments, and their
preceding indent whitespace, would barely fit in here.

- Field D, this field limits the size of source text in bytes. So the extra bits
here allow scripts upto 16 MiB!

## The Trade-offs

Shrinking Field C has performance implications. Where the 2023 encoding could
always guarantee a `O(1)` access to a parent Node, the 2025 encoding must have
fallback strategy to recompute this value when it is missing. These places have
been marked with `// slow path:`. This happens in two functions:
 - node_get_child_at_offset
 - node_get_parent

These functions are very frequently used. The first is used to implement member
access on Syntaxes, see `create_member_accessor()`. The second is used directly in all sort of tooling, f.e. finding the enclosing class of a method.

These three slow paths have different levels of impact:
 - `// slow path: Need to check with the list-sizes or syntax member counts`
   - The real world use case that hits this slow path is member access on
     Syntax. It is a contant time `O(1)` check to verify if your Syntax actually
     has 7 members if you try to access member at index `6`. This also happens
     on List nodes if you iterate them with `node_get_child_at_offset()`.
     `node_get_children()` is unaffected an the recommended way to iterate over
     Lists.
  - `// slow path: Can not jump to child, must verify every intermediate node`
    `// is a trivium, to ensure the trivium returned is a child of ``$node``.`
    - This happens when you access a specific Trivium using
    `node_get_child_at_offset()` on a Token with more than 1022 leading Trivia.
    `node_get_children()` is unaffected.
  - `// slow path: Can not find my parent from bits, must find myself by selecting`
    `// an ancestor each time. The last ancestor before me is my parent.`
    - This is the most painful change and rather easy to run into. The real
      world use case is accessing the surrounding classlike from a method,
      provided the class is very large. The same goes for accessing all the
      ancestors of code in a large file. F.e. the last handful of functions in
      [this file](src/node_functions.hack) can not tell in `O(1)` that the
      declaration list is their parent. What happens in these cases, is that
      the ancestors will do linear scans through their children to find the
      next ancestor of the node. If this proves to be a noticeable performance
      regression in real world usage, a 2026 encoding could introduce special
      a lookup table in the Script for these cases. The 374,684 byte test
      [file](vendor/hershel-theodore-layton/portable-hack-ast-linters-server/bin/portable-hack-ast-linters-ser
ver-bundled.resource)
      that includes all code of portable-hack-ast, portable-hack-ast-extras,
      portable-hack-ast-linters, and portable-hack-ast-linters-server has
      579 of these cases. That is rare enough to make a lookup table feasible.

[^1]: Scripts must contain fewer than 1,048,576 nodes, so not every 15.99MiB
Script can be parsed.