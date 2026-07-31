---
name: run-fix
description: >-
  Reproduce, diagnose, and fix a failing named .NET project in Release. Use when the user identifies
  a csproj, application, library, or test project and wants its build, run, or tests driven from the
  observed failure to a verified root-cause fix.
---

# Run Fix

**Reproduce** the failure, prove its root cause, gate the proposed edit, and finish with a clean
Release verification. Keep the repair within the named project's failure boundary.

When only compiler or analyzer diagnostics remain, invoke `fix-csharp-diagnostics` for that cleanup.
This skill retains ownership of the observed failure and final Release verification.

## 1. Resolve and classify the project

List tracked projects with `git ls-files '*.csproj'`; outside Git, search the filesystem. Match the
requested base name case-insensitively.

- One match selects the project.
- Zero or multiple matches require the user to identify the exact target.

Read the project, repository scripts, CI, and documentation. Classify it as:

- a test project, using the repository's authoritative TUnit or test command;
- an executable, using Release build then Release run; or
- a library, using Release build.

When a test-project repair changes TUnit tests and `tunit-unit-testing` is available, invoke it for
their expression, layout, lifecycle, isolation, and mocks; this skill retains ownership of
reproduction and final Release verification.

Complete when one project path, one type, and one exact Release command sequence are recorded.

## 2. Reproduce before editing

Run the selected command:

```sh
dotnet test -c Release "<path>"             # test fallback
dotnet build -c Release "<path>"            # executable or library
dotnet run -c Release --project "<path>"    # executable after build
```

If the command is green, report the verified terminal state. Otherwise preserve the full diagnostic,
assertion, exception, and stack trace needed to explain the failure.

Complete when the failure is reproducible and its observable evidence is captured.

## 3. Prove the root cause

Trace compiler diagnostics to their source, test failures through setup/action/assertion and
production behavior, and runtime exceptions from the first relevant stack frame into the violated
invariant.

When evidence is insufficient, add the smallest temporary observation and mark every added line:

```csharp
System.Console.WriteLine($"[run-fix] x={x}"); // run-fix:debug
```

Instrumentation may observe state; it must preserve behavior. Re-run the Release command after each
observation.

Complete when one explanation accounts for the captured failure, one bounded source edit addresses
that cause, and every temporary line is inventoried.

## 4. Gate the fix

Present:

- the root cause and evidence;
- the exact file and proposed behavioral edit;
- the Release verification command; and
- all temporary `// run-fix:debug` lines.

Wait for explicit approval before applying the fix. A request that already says to fix the failure
is pre-approval after this diagnosis is presented.

## 5. Fix and re-verify

Apply the approved root-cause edit and rerun the same Release command.

- A new failure starts a fresh diagnosis.
- The same failure invalidates the root-cause hypothesis; revise it from evidence.
- A fix that requires unrelated behavior or broad scope returns to the user as a new decision.

Iterate until the command is green or a concrete unresolved blocker is reported.

## 6. Remove instrumentation and prove the final state

Search the repository for `run-fix:debug` and remove every line added by this run. If the fix landed,
rerun the exact Release command after cleanup.

Complete only when:

- no added debug sentinel remains;
- the final Release command is green; and
- the diff contains the approved repair without unrelated edits.

Report the project and mode, root cause, approved fix, exact final command and result, and clean
instrumentation check.

## 7. Gate commit and push

Offer to commit the verified fix. If approved, read
[commit-style.md](../../references/commit-style.md), create the focused local commit with
`commit_group.sh`, and report its hash. Ask separately before a normal push; the commit remains local
without that approval.
