/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha\_Private;

/**
 * You are not allowed to observe the `mixed` values, aside from serializing them.
 * I wanted to perform the serialization myself, but `\fb_compact_unserialize()`
 * can not be called from a pure context.
 * This means I am leaving the actual encoding up to you, the caller. :)
 *
 * The serialized 'context' may be the same across some scripts.
 * You'd do well to deduplicate those before storing them.
 * You can use the 'context_hash' for this.
 */
type ReadyToSerializeContext = shape(
  'context' => dict<arraykey, mixed>,
  'context_hash' => string,
);

type ReadyToSerializeScript = shape(
  'script' => dict<arraykey, mixed>,
  'context' => dict<arraykey, mixed>,
  'context_hash' => string,
);
