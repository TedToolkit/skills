---
name: write-csharp-api-comments
description: >-
  Document C# APIs with accurate XML documentation and focused adjacent comments. Use when writing
  or reviewing caller-visible contracts, examples, exceptions, lifecycle, ownership, concurrency,
  or non-obvious implementation rationale, including prose required by an annotation skill.
---

# Write C# API Comments

Write caller contracts that remain true when the implementation is read line by line.

When a referenced TedToolkit package can represent part of the contract, invoke
`use-boxing-annotations`, `use-const-annotations`, `use-documentation-annotations`,
`use-maintenance-annotations`, or `use-ownership-annotations` for its machine-readable semantics.
This skill retains the prose.

## Steps

1. Read repository guidance and resolve the prose language from the user's request or `CLAUDE.md`.
   Use the nearest established documentation language only when guidance is silent; ask when it
   remains ambiguous.
2. Resolve the documentation surface from the user's explicit request and the nearest applicable
   repository guidance. Inspect only those declarations, their implementation and caller-visible
   paths, and comments needed to keep that surface accurate. Visibility alone does not expand scope.
3. Draft only facts a caller cannot safely infer. Show the complete proposal and wait for explicit
   approval before modifying source.
4. After approval, update comments and applicable annotations together. Complete when every XML tag
   maps to the current signature, every contract matches behavior, and every example is usable in
   the documented consumer context.

## Choose the right form

- Use `///` XML documentation for API purpose, calling rules, and contracts visible to consumers.
- Use a focused `//` comment only for a local reason that code cannot express, such as a protocol rule,
  benchmark-backed limit, race avoidance, or compatibility workaround.
- Use an attribute only when a referenced annotation package represents the contract precisely. Do not
  introduce a package merely to decorate a comment.
- When an existing TedToolkit annotation package represents the contract, apply the selected skill
  and [attribute-arguments.md](../../references/attribute-arguments.md).
- XML documentation comments may use literal Unicode normally, subject to well-formed XML. Add a
  familiar emoji or visible symbol proactively when it makes a caller-facing contract easier to scan:
  for example, `⚠️` for a hazard or restriction, `💡` for a usage tip, `✅` for a guarantee, and `⏱️`
  for timing or blocking behavior. Keep the explanatory text explicit; use a marker at the start of a
  `<remarks>`, `<example>`, or multi-step note rather than replacing a summary, XML element, or prose
  with an icon. Prefer the real character over `\u...` escape text in XML documentation, and avoid
  invisible characters or decorative repetition.
- Remove comments that restate identifiers, syntax, or immediately visible control flow.

## Rules

- Document every declaration placed in scope by the request or nearest repository policy. When a
  policy requires complete documentation for a changed public, protected, or internal surface,
  cover the relevant types, constructors, methods, properties, indexers, events, fields, constants,
  enums and members, and delegates; state that policy-driven expansion in the proposal. Otherwise,
  omit unrelated declarations even when they share a file. Document a `private` member only when it
  is in scope and carries a non-obvious invariant, compatibility rule, performance limit, ownership
  rule, or concurrency rule.
- Start type summaries with `Represents ...`; use a third-person verb for members, such as `Gets ...`,
  `Creates ...`, `Adds ...`, or `Returns ...`.
- For a type, document what it represents plus material invariants, thread model, or lifecycle. For an
  enum, document the value domain and each member's business meaning; also explain combinations and
  `None` for a `[Flags]` enum. For a delegate, document invocation timing, context, nullability, and
  callback-exception behavior.
- Give every documented type or member a `<summary>`. For methods and constructors, include one
  `<param>` for every parameter and one `<typeparam>` for every generic type parameter. For non-void
  methods, include `<returns>`. For properties and indexers, include `<value>` when the value contract
  is not fully obvious from the summary. Include `<exception>` for every caller-visible exception path
  that belongs to the contract. Use `<remarks>` for lifecycle, threading, performance, compatibility,
  encoding, culture, or versioning details that do not belong in the summary.
- Describe nullability, units, range, timezone, encoding, cancellation, and ownership when relevant.
  Describe a `Task` or `ValueTask` result after completion, not merely that it is asynchronous.
- For a property or indexer, document what it represents, valid ranges, defaults, mutation effects,
  expensive computation or I/O, and missing-item behavior as applicable. Use `<value>` for a property
  value contract. For an event, document when it fires, sender, thread context, and subscriber-error behavior.
- Document only exceptions actually thrown that callers need to handle. Use semantic links instead of
  plain text names: `<see cref="..."/>` and `<seealso cref="..."/>` for symbols, `<paramref name="..."/>`
  and `<typeparamref name="..."/>` for parameters, `<see langword="null"/>` and other keywords, and
  `<c>...</c>` for values or code.
- Use `<inheritdoc/>` for a fully inherited interface or override contract, or `<inheritdoc cref="..."/>`
  when the intended source contract is otherwise ambiguous. Add explicit documentation when the member
  adds a precondition, exception, side effect, example, or other restriction.
- Put `//` comments immediately beside the relevant code and explain why: an external protocol,
  measured performance boundary, race avoidance, compatibility constraint, or unrepresentable assumption.
- Represent maintenance work with an actionable removal condition or issue reference; use the
  maintenance annotation skill when its package is available.

## Examples

- Add `<example>` only when it changes caller understanding: setup is non-obvious, lifecycle or
  disposal matters, effects or ordering are easy to misuse, or a realistic edge case prevents a
  likely mistake. Do not force examples for routine calls whose summary, parameters, and return
  contract already make correct use clear. Apply the same test to constructors.
- Make every `<example>` practically usable and correct. The code must call real accessible APIs, use
  current parameter names and overloads, include required setup such as `await`, `using`, cancellation
  tokens, disposal, or dependency creation, and match actual return values, exceptions, and side
  effects. Do not invent helper types, namespaces, outputs, or behavior merely to make the example read
  well.
- Keep examples small but runnable in the target project or in a normal consumer project that references
  the documented API. Prefer a complete success path first; add an error or edge-case example only when
  it teaches a real contract.
- If a member uses `<inheritdoc/>`, keep the canonical example on the interface, abstract member, or
  base member that owns the contract. Add a local `<example>` only when the implementation adds behavior
  that callers must understand.

## Review before proposing changes

For every in-scope method or function, account for inputs, null and empty results, exceptions,
cancellation, observable state or I/O, threading or blocking, resource ownership, and an example
only when it materially clarifies one of those contracts. Confirm that unrelated declarations were
not pulled into the proposal unless repository policy required them. Prefer a smaller proven
contract over speculative detail; ask for the intended contract when behavior remains ambiguous.
