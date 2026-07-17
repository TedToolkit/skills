# BenchmarkDotNet evidence

Use this reference when a technology selection or architecture decision needs measured performance
evidence. Create and run a real BenchmarkDotNet project; do not substitute estimates, unit-test
durations, or a handwritten loop timer.

## Create the benchmark project

After the architecture draft and benchmark plan are approved, create an ADR-specific executable
project at `docs/adr/ADR-<number>-<slug>/benchmark/`. Do not add it to the main `.slnx` or default
CI build. Add or update its relative path in `docs/adr/Benchmark.slnx`; that file is only a
convenient catalog for opening ADR benchmark projects, never a normal build or CI target. Promote
it to `benchmarks/<Product>.<Area>.Benchmarks/` only when it becomes a maintained
performance suite; such a suite may use a dedicated performance solution. Copy
[benchmark-csproj-template.xml](../assets/benchmark-csproj-template.xml) and
[benchmark-program-template.cs](../assets/benchmark-program-template.cs), then replace all placeholders.

Reference the product project under test and use the repository's package-management convention for
`BenchmarkDotNet`. Set `TargetFrameworks` to the affected consumer TFMs that are supported by every
candidate and installed on the benchmark host. Do not benchmark every repository TFM by default.
If candidates cannot share a TFM, record that incompatibility as a decision constraint rather than
comparing unlike runtimes.

Create a benchmark class for each representative workload. Mark the established behavior as
`Baseline = true`; use `Params` or `ParamsSource` for material input shapes; consume computed values
so the JIT cannot eliminate the work. Add `MemoryDiagnoser` when allocations matter and an explicit
diagnoser only when it answers a decision question. Keep setup outside the measured operation unless
setup is part of the user-observable workload.

## Run and preserve the experiment

Run from the command line in Release mode without a debugger or competing workload. Run each
selected TFM explicitly, for example:

```powershell
dotnet run -c Release -f <tfm> -- --filter "*<scenario>*"
```

For multi-runtime comparison, target all required frameworks in the project and use the supported
runtime arguments for the installed BenchmarkDotNet version. Verify the generated report identifies
the intended runtime. BenchmarkDotNet isolates runs in generated processes; record the .NET SDK,
runtime, OS, CPU architecture, power mode, source revision, command, and configuration.

Copy [benchmark-run-manifest-template.md](../assets/benchmark-run-manifest-template.md) to
`docs/adr/ADR-<number>-<slug>/evidence/benchmark/run-manifest.md`. Copy the generated Markdown
summary, full JSON report, and any required CSV or HTML report from
`BenchmarkDotNet.Artifacts/results` into the same directory. Preserve benchmark project source in
the ADR's `benchmark/` directory, not under `evidence/`. Do not commit build output, generated
executable files, or the rest of `BenchmarkDotNet.Artifacts`.

## Interpret before deciding

Compare equivalent workloads, data, versions, capacity, warm-up, repetitions, and environment.
Report median or mean with dispersion, allocation, throughput or tail latency when material; do not
select from a single fastest run. State whether the result applies only to the measured TFM and host.

In the ADR, link the preserved reports and explain how performance results interact with API
compatibility, ecosystem maturity, licensing, security, migration risk, operational burden, and
ownership. The decision must name why the selected option wins overall, what trade-off is accepted,
and which measurement or condition would trigger reconsideration.
