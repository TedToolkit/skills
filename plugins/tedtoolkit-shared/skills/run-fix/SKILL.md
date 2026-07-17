---
name: run-fix
description: >-
  Use when a user wants a named .NET project built, run, or tested in Release and wants a failing
  project diagnosed and fixed, especially for requests that name a `.csproj`, app, library, or
  test project and ask to drive the failure to its root cause instead of masking it. Do not use
  this skill for general test authoring, test-style review, or TUnit-specific test design when the
  main task is adding or improving tests rather than fixing a failing project.
---

# Run Fix

Given a **project name**, run that project in Release the way its type demands, drive any failure to
its root cause, fix it, and prove it's green again — leaving the tree exactly as clean as you found
it.

If the target project uses **TUnit**, treat [`tunit-unit-testing`](../tunit-unit-testing/SKILL.md)
as the source of truth for TUnit-specific execution, assertion, and test-structure rules. This
skill owns the diagnose-fix-verify workflow; `tunit-unit-testing` owns TUnit conventions.

The working directory is already the repo root — **do not `cd`**.

## Non-negotiables

- **Read-only until the fix gate.** Locating the project, running it, and reading errors change
  nothing. The *one* investigative exception is temporary debug instrumentation (step 3) when the
  output alone won't reveal the cause — and that's temporary by construction. The actual fix waits
  for the user's approval (step 4). Everything else before that gate only reads and runs.
- **All debug instrumentation must vanish.** Mark every debug line you add with the sentinel
  `// run-fix:debug` so it's trivially findable, and before you declare the job done, remove every
  one and prove the project is *still green without it* (step 6). Debug code left in the tree is a
  silent regression — treat leaving any behind as a failure of the task.
- **Verify in Release — the same config you'll report.** Debug and Release diverge in real ways
  (optimizations, `DefineConstants`, warnings-as-errors, conditional compilation). Fixing under
  Debug and assuming Release is how a "green" fix ships broken.
- **Don't widen scope.** Fix the failure in front of you. If the genuine fix would sprawl into
  unrelated code or change the project's intended behavior, stop and report what you found rather
  than rewriting half the project.

## 0. Locate the project by name

The user gives a name, not a path (with or without the `.csproj` suffix). Resolve it to exactly one
project file:

```sh
git ls-files '*.csproj'        # all projects tracked in the repo
```

Match the given name case-insensitively against the file's base name (`Foo.Tests` matches
`tests/Foo.Tests/Foo.Tests.csproj`). Outside a git repo, fall back to a filesystem search for
`*.csproj`.

- **Exactly one match** → that's the project; remember its path.
- **No match** → say so and ask for the right name; don't guess at a near-miss.
- **More than one match** → list them and ask which one. Picking the wrong project wastes a whole
  build cycle.

## 1. Classify the project

Read the `.csproj`. The contents tell you how it's meant to be exercised:

- **TUnit test project** — references `TUnit`. Verify it using the TUnit execution path from
  `tunit-unit-testing`, which means `dotnet run`, not `dotnet test`.
- **Other test project** — references `Microsoft.NET.Test.Sdk`, sets
  `<IsTestProject>true</IsTestProject>`, or pulls in another test framework (`xunit`, `nunit`,
  `MSTest`). Its job is to run tests, but its entry point is still `dotnet test`.
- **Executable** — `<OutputType>Exe</OutputType>` (or `WinExe`). It has an entry point and is meant
  to run.
- **Library** — neither of the above. It has no entry point, so the most you can do is compile it;
  "running" it isn't a thing.

This classification picks the command in step 2 — getting it right matters because `dotnet run` on a
library or `dotnet test` on an app just produces a confusing non-failure.

## 2. Run it in Release

Run the command for the project's type, scoped to the project path from step 0:

```sh
# TUnit test project (per tunit-unit-testing)
dotnet run -c Release --project "<path>"

# other test project
dotnet test -c Release "<path>"

# executable: build first (clean compile errors surface faster), then run
dotnet build -c Release "<path>"
dotnet run -c Release --project "<path>"

# library
dotnet build -c Release "<path>"
```

If it's **green on the first try** — build succeeds, the app runs cleanly, or every test passes —
there's nothing to fix. Report that and stop; don't invent work.

Otherwise, capture the failure output verbatim; it's the input to the next step.

When the failing project is a TUnit test project and the likely fix touches test code, consult
`tunit-unit-testing` for test-writing rules instead of restating them here.

## 3. Diagnose down to the root cause

Diagnosis is the reasoning core of this skill, and it happens in turn 1 *before*
the gate. Work from the step-2 failure output verbatim plus the project's path and
type, and read the failure all the way down to what actually went wrong — not just
the surface symptom:

- **Compile error** — the diagnostic names file, line, and code (`CS0103`,
  `CS0246`, …); open that location and understand *why* it's wrong (typo, missing
  member, wrong type, absent `using`).
- **Test failure** — read the failing assertion and the expected-vs-actual, then
  the code under test. The bug is usually in the production code, not the test —
  find the cause, don't bend the test to pass.
- **Runtime error** — read the exception type and stack-trace top frame; that's
  where it threw.

If the output alone doesn't pin the cause — wrong value mid-computation, an
unclear branch, hidden state — add **temporary** instrumentation to expose it,
tagging every line so it's removable, then re-run step 2's command and read what
it prints. This is investigation, **not** the fix — observe, don't change behavior.

```csharp
System.Console.WriteLine($"[run-fix] x={x}, count={items.Count}"); // run-fix:debug
```

Land on: the root cause in plain terms, the concrete fix (file + the edit), and a
note of any `// run-fix:debug` lines you left in the tree.

This stays within the read-only-until-gate rule: you only read, run, and add
removable instrumentation here — you do **not** apply the fix. That waits for the
gate (step 4).

## 4. Present the diagnosis and fix plan — then wait

Using your step-3 diagnosis, show the user, before editing the real fix:

- the **root cause** in plain terms (what's wrong and why the run fails),
- the **concrete change** you'll make and **where** (file + the edit),
- **how you'll verify** (the exact Release command from step 2),
- a note of **any `// run-fix:debug` instrumentation currently in the tree** — it'll be removed in
  step 6 regardless.

Ask whether to proceed, and **wait for explicit approval**. Don't start editing source until then.

The gate exists so you never make *unrequested* edits — not to nag. If the user's original request
already authorized the fix ("just fix it", "run it and fix whatever breaks", "go ahead and fix it"),
they've pre-approved: present the diagnosis for the record, then proceed straight to step 5 without a
second round-trip.

## 5. Apply the fix and re-verify

After approval, apply the approved root cause + fix from step 4, then re-verify with
the step-2 Release command:

- Make the change, then re-run the step-2 command and read the result:
  - **Green** → done.
  - **A different failure** → progress; diagnose it afresh and iterate.
  - **The same failure** → the root-cause read was off; re-diagnose rather than
    retrying the same edit.
- Iterate a few times. If it still won't go green after a genuine effort, **stop** —
  a half-fixed tree honestly reported beats a "fixed" one that isn't.

Whichever way it ends, cleanup (step 6) runs regardless of success — note whether
you reached green, the change(s) you made, any remaining failure if you stopped, and
the `// run-fix:debug` lines still in the tree.

## 6. Remove all debug instrumentation

Whether the fix succeeded or stopped, the debug code must go — and because every
line is tagged, this one grep sweeps up whatever instrumentation was added during
diagnosis or the fix, so you don't need to track each line by hand:

```sh
grep -rn "run-fix:debug" .        # every added line is tagged — find them all
```

Delete every match. Then, if the fix landed, **run the Release command one final time** to confirm
the project is still green *without* the debug code — instrumentation can mask or alter behavior, so
a clean run is the only proof the real fix stands on its own. This final clean run is the true "done"
gate; the earlier green in step 5 doesn't count until this one passes.

## 7. Offer to commit

Summarize, then offer to commit the fix. Don't commit unprompted — the user may want to review or
batch it.

If they say yes, commit the fix as a **single house-style commit** — a fix is one logical change,
so it doesn't need splitting. The message follows the project convention: gitmoji + Conventional
Commits with a descriptive subject and a body explaining the root cause and the fix (what and why,
not how); a bug fix typically lands as `🐛 fix(<scope>): <subject>`. Stage just the fix's files and
commit with the bundled script — files as arguments, the message piped in on a **quoted** heredoc
(this passes emoji, non-ASCII text, `` ` ``, and `$` through literally; don't drop the quotes):

```sh
bash "${CLAUDE_PLUGIN_ROOT}"/scripts/commit_group.sh <files...> <<'MSG'
🐛 fix(<scope>): <subject>

<Body: root cause and fix — what changed and why>
MSG
```

(If your fix genuinely touched unrelated things, commit those separately — but a focused fix is
normally one commit.)

Then **offer to push** — report the new commits and ask before publishing; pushing is the one
outward, hard-to-undo step, so it's gated, never automatic and **never `--force`**. If they
approve, `git push` (or `git push -u origin HEAD` if the branch has no upstream); if they decline,
say the commits are local and ready to push later.

## Report when done

- the **project** and the **mode** you ran it in (test / run / build),
- the **root cause** of the failure,
- the **fix** you applied (and that the user approved it),
- the **final Release result** — green, run after debug removal,
- explicit confirmation that **no `// run-fix:debug` line remains** in the tree.
