# Large Script Support

In late 2025, Portable Hack AST got support for Scripts up to 16 MiB
<sub>Terms and conditions apply</sub>[^1]. This document explains the internal
changes that made that possible.

## Rationale

256KB ought to be enough for everybody, #Hershel Theodore Layton ~2023. Well,
not quite, but I considered it to be good enough for linting files. If you want
to use linting to improve code quality, you probably care about readability. A
256KB (10,000-line) class has no place in such a codebase.

On the other hand, there is other tooling besides linting, where missing one or
two omega files in a codebase is simply not acceptable. If you need to be able
to parse every symbol, you simply must be able to grok larger files. It is not
feasible to support arbitrarily large files with the architecture of
Portable Hack AST. The current size is a stretch that required a few changes
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
    information is stored inline in the Trivium to utilize memory to the
    fullest.
- Field E. The **NodeId** of the current Node. The single most frequently accessed
  piece of information about a Node.

Fields A and B cannot be shrunk. There are simply too many unique token and syntax
kinds to get by with even one bit fewer.

Field D (on a Trivium) is the limiting factor when it comes to the maximum size in
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

 - Field C contains the NodeId of the parent Node. Since NodeIds are 18 bits in
this version, Field C has to be 18 bits.
 - Field D must be at least as large as a SiblingId. SiblingIds can be as large
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
14 bits. Instead of storing the NodeId, the difference between the current NodeId
and the parent NodeId is stored. If the result of this subtraction exceeds the
amount of space available, 0 is stored instead.

- Fields D and E can now contain 20-bit NodeId and SiblingId values, instead of
18-bit ones.


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
becomes a practical limitation when a single token is preceded by a lot of single-
line comments, 511 to be exact. 511 leading single-line comments, and their
preceding indent whitespace, would barely fit in here.

- Field D, this field limits the size of source text in bytes. So the extra bits
here allow scripts up to 16 MiB!

## The Trade-offs

Shrinking Field C requires a fallback when a parent offset does not fit.
`node_get_parent()` uses a Script lookup table for these exceptional offsets;
ordinary Nodes retain their packed offsets. Parent lookup is constant time even
for comment-heavy Tokens and large declaration Lists.

`node_get_child_at_offset()` also uses this table to verify a candidate child's
parent when the packed offset overflows. This replaces the syntax/list count
fallback and the linear scan through a Token's intermediate Trivia. Indexed
child lookup remains constant time without additional storage. This function
also implements Syntax member access through `create_member_accessor()`.

Enumerating a Token's children or finding its last child still scans its Trivia.
A child-to-parent index does not store the child count or last-child position.
Use `node_get_children()` to enumerate children rather than repeatedly probing
indices.

The table is included in serialized Scripts (version 4); older cached Scripts
must be reparsed. Contexts also advance to version 4, replacing the custom
context-hash encoding with `serialize_pure()`. Cached version 3 Contexts must be
regenerated; the nested Structs format remains version 3.

[^1]: Scripts must contain fewer than 1,048,576 nodes, so not every 15.99MiB
Script can be parsed.
