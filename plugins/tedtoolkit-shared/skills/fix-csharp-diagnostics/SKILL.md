---
name: fix-csharp-diagnostics
description: >-
  Eliminate C# and .NET compiler, nullable, obsolete-API, analyzer, and style diagnostics at their
  root cause. Use when an in-scope project or solution must reach a zero-warning, zero-error Release
  build, including a diagnostics-only tail reached from another repair workflow.
---

# Fix Csharp Diagnostics

Drive one Release command to **zero warnings and zero errors**. Treat suppression as a gated design
exception. Keep submodules, vendored source, and independently maintained nested repositories
outside the repair boundary.

When the command also exposes failing assertions or runtime behavior, invoke `run-fix` for that
behavioral failure.

## 1. Resolve the exact build target and verification command

Identify the narrowest target that satisfies the request:

- If the user named a specific `.csproj`, use that project.
- If the user named a solution or asked for the whole repo to be clean, use that solution target.
- If the user did not specify a target or scope, discover solution-level scope from every `.sln`,
  `.slnx`, and `.slnf` file in the repository before choosing a build target. Treat `.slnf` as a
  solution filter and resolve its referenced solution. If discovery finds multiple plausible
  targets, ask which one must become warning-free.
- During discovery, identify Git submodules and independently maintained nested repositories, then
  exclude their projects from the candidate repair scope unless the user explicitly names one.

Prefer Release verification:

```sh
dotnet build -c Release <target>
```

Use `dotnet test -c Release <target>` when the user requests tests or the repository defines it as
the authoritative gate. Complete this step when one exact command and repair boundary are recorded.

## 2. Capture diagnostics before editing

Run the chosen command once before editing. Group the complete diagnostic set by ID, file, and
shared cause. Complete when every emitted warning and error belongs to one group.

During diagnosis, separate:

- **Compiler errors** such as `CSxxxx`
- **Compiler warnings** such as nullable, obsolete, async, or unused-code warnings
- **Analyzer diagnostics** such as `CAxxxx`, `IDExxxx`, and style rules

Repair generated diagnostics at the generator input, template, or source unless the repository
explicitly maintains the generated file.

## 3. Gate the repair plan

Present the exact target and command, diagnostic groups, their root-cause hypotheses, proposed edit
boundary, and verification plan. Wait for explicit approval before changing source, project files,
or analyzer configuration. A request that already directs you to fix the diagnostics is pre-approval
after this plan is shown.

## 4. Apply built-in code fixes first when available

For diagnostics with known Roslyn or analyzer code fixes, try the built-in fix route before writing
manual patches. Typical options include:

- `dotnet format analyzers <target>`
- `dotnet format analyzers --diagnostics <ID1,ID2,...> <target>`
- IDE/Roslyn-backed fixers when the environment exposes them

Keep only fixes whose diff preserves intent. Correct unrelated fixer output before moving on.

## 5. Fix remaining diagnostics one root cause at a time

For diagnostics that remain after built-in fixes, edit the actual code:

- Add null checks, adjust nullability annotations, or tighten control flow for nullable warnings.
- Replace obsolete APIs with supported alternatives for obsolete warnings.
- Remove dead code, unused locals, unreachable branches, or incorrect async patterns when those are
  the true cause.
- Adjust generic constraints, type conversions, method signatures, or missing usings for compiler
  errors.
- For analyzer complaints, prefer code changes that satisfy the rule instead of weakening the rule.

Fix shared causes before individual symptoms, then rebuild. Keep edits within the
diagnostic-backed boundary.

## 6. Rebuild repeatedly until the target is clean

After each meaningful batch of fixes, rerun the same Release command. Keep iterating until:

- the command exits successfully, and
- the output contains **no warnings** and **no errors**

The final rebuild is the proof; partial reduction does not satisfy this completion criterion.

## 7. Escalate the unresolved tail instead of suppressing it yourself

If a remaining diagnostic requires a behavioral trade-off or suppression, ask the user to choose:

1. Approve a targeted suppression such as `<NoWarn>` or `#pragma warning disable` for the specific
   diagnostic and scope.
2. Approve a non-suppression code or design change that you describe clearly.
3. Keep investigating with a specific direction or constraint from the user.

Apply no suppression before that decision. This includes pragmas, nullable disabling, `NoWarn`,
severity downgrades, rulesets, and global suppressions.

## 8. Report completion precisely

When done, report:

- the target you cleaned
- the exact Release command you used for final verification
- the main root causes you fixed
- explicit confirmation that the final build had **zero warnings and zero errors**
- explicit confirmation that you did **not** add suppression mechanisms unless the user approved one
