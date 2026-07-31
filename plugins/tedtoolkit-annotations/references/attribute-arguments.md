# Annotation argument text

Use this reference whenever a TedToolkit annotation takes a symbol name or human-readable text.

- Express C# source symbols with `nameof(...)`; keep literal strings for contracts, rationale,
  state labels, and other human-readable values.
- Use visible Unicode normally in human-readable text, including Chinese and ordinary full-width
  punctuation.
- Keep control and format characters, zero-width and bidirectional controls, U+0085,
  U+2028/U+2029, and unpaired surrogates out of attribute text. Rider may render them as `\u...`
  escapes and make review unreliable.
- Put optional visual markers such as `⚠️`, `✅`, `💡`, and `⏱️` in caller-facing XML prose, not
  in symbol names or as substitutes for the contract text.
- Keep XML documentation well-formed and semantically equivalent to the annotation.

