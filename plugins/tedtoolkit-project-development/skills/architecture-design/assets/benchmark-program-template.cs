using BenchmarkDotNet.Running;

return BenchmarkSwitcher
    .FromAssembly(typeof(Program).Assembly)
    .Run(args);
