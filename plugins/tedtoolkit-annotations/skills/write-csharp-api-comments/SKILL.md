---
name: write-csharp-api-comments
description: >-
  Write, review, or revise C# XML documentation and adjacent comments for types and API members:
  classes, structs, records, interfaces, enums, delegates, constructors, methods, functions,
  properties, indexers, events, fields, and constants. Use when improving human-readable API
  documentation, explaining non-obvious constraints, or reviewing whether comments match behavior.
---

# Write C# API Comments

Use the rules in this skill as the self-contained standard for drafting and reviewing C# API comments.

## Workflow

1. Read root `CLAUDE.md` and `AGENTS.md` before inspecting the target. Use the human language for
   README and code-comment prose declared in `CLAUDE.md`; `AGENTS.md` is only a direct reference to
   that source of truth. A language explicitly requested by the user takes precedence. If neither
   source explicitly states the language, ask the user before drafting or editing comments; do not
   infer it from existing comments, identifiers, or the C# implementation language.
2. Inspect the type or member declaration, implementation, and existing documentation. Identify only
   facts a caller cannot safely infer from the code.
3. Draft the XML documentation and any needed annotations. Show the proposed change and wait for
   explicit approval before modifying source files.
4. After approval, update documentation and annotations in the same change. Re-read the edited member
   to ensure every XML element agrees with the signature and behavior.

## Choose the right form

- Use `///` XML documentation for API purpose, calling rules, and contracts visible to consumers.
- Use a focused `//` comment only for a local reason that code cannot express, such as a protocol rule,
  benchmark-backed limit, race avoidance, or compatibility workaround.
- Use an attribute only when a referenced annotation package represents the contract precisely. Do not
  introduce a package merely to decorate a comment.
- When an attribute argument names a C# source symbol, use `nameof(...)` instead of a handwritten
  string. Retain literal strings only for human-readable or otherwise non-symbol annotation values.
- Keep attribute arguments plain: do not use Unicode escape literals such as `\uXXXX` or
  `\UXXXXXXXX`, non-printing or invisible Unicode, special symbols, emoji, or non-ASCII punctuation
  in attributes. Prefer `nameof(...)`, numeric values, enum values, and simple printable ASCII strings.
- XML documentation comments may use literal Unicode normally, subject to well-formed XML. Add a
  familiar emoji or visible symbol proactively when it makes a caller-facing contract easier to scan:
  for example, `⚠️` for a hazard or restriction, `💡` for a usage tip, `✅` for a guarantee, and `⏱️`
  for timing or blocking behavior. Keep the explanatory text explicit; use a marker at the start of a
  `<remarks>`, `<example>`, or multi-step note rather than replacing a summary, XML element, or prose
  with an icon. Prefer the real character over `\u...` escape text in XML documentation, and avoid
  invisible characters or decorative repetition.
- Delete a comment that restates the identifier, syntax, or immediately visible control flow.

## Rules

- Document every `public`, `protected`, and `internal` type and member. Cover classes, structs,
  records, interfaces, enums, delegates, constructors, methods, properties, indexers, events, fields,
  and constants. Document a `private` member only for a non-obvious invariant, compatibility rule,
  performance limit, ownership rule, or concurrency rule.
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
- Never leave bare `TODO`, `FIXME`, or `HACK`. Use a maintenance annotation with an actionable removal
  condition or issue reference.

## Examples

- Default to at least one `<example>` for every public, protected, or internal method or function that
  has a meaningful caller-facing invocation. Also provide examples for constructors when construction
  is part of the caller contract. Omit an example only when no correct, useful invocation can be shown,
  such as a purely inherited member whose contract owner already contains the example.
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

## Contract checklist

For each method or function, determine whether callers need to know its input requirements, result
including `null` or empty cases, exception conditions, cancellation behavior, observable state or I/O,
threading or blocking constraints, disposable-resource ownership, and at least one realistic example.
Use a TedToolkit annotation package only when that package is already referenced by the project;
annotations complement rather than replace XML documentation.

## Review before proposing changes

Check that every XML tag maps to a real signature element, every parameter name is current, every
exception matches an observable throw path, every `cref` resolves to the intended symbol, and every
example can actually be compiled or executed in the documented API's expected consumer context. Prefer a
smaller accurate contract over speculative detail. If source behavior is ambiguous, ask for the intended
contract instead of inventing one.
