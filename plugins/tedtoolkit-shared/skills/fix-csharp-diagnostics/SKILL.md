---
name: fix-csharp-diagnostics
description: >-
  Use when fixing C# or .NET build diagnostics such as compiler errors, nullable warnings,
  analyzer warnings, obsolete API warnings, or style diagnostics reported by `dotnet build`,
  `dotnet test`, or similar commands, especially when the goal is a clean Release build without
  suppression shortcuts.
---

# Fix Csharp Diagnostics

Fix every C# build warning and error for the requested project or solution, and prove the final
Release build is clean. Treat suppressions as user-decided exceptions, never as your shortcut.
Do not stop until every warning is gone.

The working directory is already the repo root unless the user says otherwise. Prefer root-cause
fixes over cosmetic output changes, and leave the tree in a state the user can trust.

## Non-Negotiables

- **Use one explicit pass criterion.** Testing passes only when the in-scope target completes
  `dotnet build -c Release <target>` successfully with **zero warnings and zero errors**. A Debug
  build, a successful test run without a Release build, or a build that still emits warnings does
  not pass.
- **End at zero diagnostics.** Do not stop at "most warnings are gone" or "errors are fixed". The
  job is complete only when the target C# build command finishes with **zero warnings and zero
  errors**.
- **Do not suppress diagnostics without explicit approval.** Never add or modify `#pragma warning
  disable`, `#nullable disable`, `<NoWarn>`, `<WarningsNotAsErrors>`, `.editorconfig` severity
  downgrades, rulesets, `GlobalSuppressions.cs`, or similar suppression mechanisms unless the user
  explicitly chooses that path after you ask.
- **Prefer built-in code fixes first.** When a diagnostic is backed by a Roslyn/.NET code fix, try
  the built-in fix path before inventing a custom rewrite. Use `dotnet format analyzers` or other
  built-in Roslyn fix flows where they apply cleanly.
- **Fix the cause the diagnostic is pointing at.** Read the warning or error, open the relevant
  code, and change the code or API usage so the diagnostic becomes unnecessary.
- **Leave externally maintained content alone.** Never fix diagnostics by modifying a Git
  submodule, vendored source, or other independently maintained nested repository. Exclude those
  projects from the repair scope; if their diagnostics appear in an aggregate build, report them as
  excluded rather than treating them as a repair task.
- **Stop and ask when the last diagnostic is not safely fixable.** If you reach a warning or error
  that appears to require a tradeoff, pause and ask the user instead of choosing suppression
  yourself.

## Workflow

## 1. Resolve the exact build target and verification command

Start by identifying the narrowest target that satisfies the user's request:

- If the user named a specific `.csproj`, use that project.
- If the user named a solution or asked for the whole repo to be clean, use that solution target.
- If the user did not specify a target or scope, discover solution-level scope from every `.sln`,
  `.slnx`, and `.slnf` file in the repository before choosing a build target. Treat `.slnf` as a
  solution filter and resolve its referenced solution; do not overlook projects it intentionally
  includes. If this discovery finds multiple plausible C# targets, stop and ask which target should
  become warning-free. Do not guess.
- During discovery, identify Git submodules and independently maintained nested repositories, then
  exclude their projects from the candidate repair scope unless the user explicitly names one.

Prefer Release verification:

```sh
dotnet build -c Release <target>
```

Use `dotnet test -c Release <target>` only when the user explicitly wants test execution or the
repo uses tests as the authoritative build gate. The final reported command must be the one you
actually used to prove zero diagnostics.

## 2. Capture diagnostics before editing

Run the chosen command once and collect the full diagnostics list before making changes. Group them
by diagnostic ID and by file so repeated symptoms do not distract from the root cause.

During diagnosis, separate:

- **Compiler errors** such as `CSxxxx`
- **Compiler warnings** such as nullable, obsolete, async, or unused-code warnings
- **Analyzer diagnostics** such as `CAxxxx`, `IDExxxx`, and style rules

Treat generated-code paths carefully. Do not hand-edit generated files unless the project clearly
expects that; prefer fixing the generator input, template, or source that produced them.

## 3. Apply built-in code fixes first when available

For diagnostics with known Roslyn or analyzer code fixes, try the built-in fix route before writing
manual patches. Typical options include:

- `dotnet format analyzers <target>`
- `dotnet format analyzers --diagnostics <ID1,ID2,...> <target>`
- IDE/Roslyn-backed fixers when the environment exposes them

Only keep built-in fixes that preserve intent and move the build toward zero diagnostics. Review the
diff rather than assuming the fixer made the right semantic choice.

## 4. Fix remaining diagnostics one root cause at a time

For diagnostics that remain after built-in fixes, edit the actual code:

- Add null checks, adjust nullability annotations, or tighten control flow for nullable warnings.
- Replace obsolete APIs with supported alternatives for obsolete warnings.
- Remove dead code, unused locals, unreachable branches, or incorrect async patterns when those are
  the true cause.
- Adjust generic constraints, type conversions, method signatures, or missing usings for compiler
  errors.
- For analyzer complaints, prefer code changes that satisfy the rule instead of weakening the rule.

When many diagnostics share one cause, fix the shared cause first, then rebuild. Avoid file-wide
rewrites that are not justified by the diagnostics.

## 5. Rebuild repeatedly until the target is clean

After each meaningful batch of fixes, rerun the same Release command. Keep iterating until:

- the command exits successfully, and
- the output contains **no warnings** and **no errors**

Do not trust partial progress. The last rebuild is the proof.

## 6. Escalate the unresolved tail instead of suppressing it yourself

If you reach a diagnostic that still cannot be resolved cleanly after reasonable investigation, stop
and ask the user how to proceed. Present concise options such as:

1. Approve a targeted suppression such as `<NoWarn>` or `#pragma warning disable` for the specific
   diagnostic and scope.
2. Approve a non-suppression code or design change that you describe clearly.
3. Keep investigating with a specific direction or constraint from the user.

Make it explicit that **you have not applied any suppression** yet. The decision belongs to the
user.

## 7. Report completion precisely

When done, report:

- the target you cleaned
- the exact Release command you used for final verification
- the main root causes you fixed
- explicit confirmation that the final build had **zero warnings and zero errors**
- explicit confirmation that you did **not** add suppression mechanisms unless the user approved one
