#!/usr/bin/env bash
set -euo pipefail

mkdir -p .binstub src unrelated
cat > App.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework></PropertyGroup>
</Project>
EOF
printf '%s\n' 'public sealed class InScope { } // CA2000' >src/InScope.cs
printf '%s\n' 'USER-OWNED-OUTSIDE-BYTES' >unrelated/Outside.cs
sha256sum unrelated/Outside.cs | cut -d' ' -f1 >outside.sha256
cat > .binstub/dotnet <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>dotnet-commands.log
if [[ " $* " == *" format analyzers "* ]]; then
  [[ " $* " == *" --diagnostics CA2000 "* ]] || { echo 'missing diagnostic bound' >&2; exit 31; }
  [[ " $* " == *" --include src/InScope.cs "* ]] || { echo 'missing path bound' >&2; exit 32; }
  sed -i 's/ \/\/ CA2000//' src/InScope.cs
  exit 0
fi
if [[ " $* " == *" build "* ]]; then
  if [[ " $* " == *" --no-incremental "* && $(grep -c CA2000 src/InScope.cs || true) == 0 ]]; then
    echo 'Build succeeded.'
    echo '0 Warning(s)'
    echo '0 Error(s)'
    exit 0
  fi
  echo 'src/InScope.cs(1,1): warning CA2000: dispose object'
  exit 1
fi
echo "unexpected dotnet command: $*" >&2
exit 33
EOF
chmod +x .binstub/dotnet
cat > .binstub/dotnet.cmd <<'EOF'
@echo off
bash "%~dp0dotnet" %*
EOF
: >dotnet-commands.log
rm setup_fixture.sh
git init -q -b main
git config user.name "Diagnostics fixture"
git config user.email "fixture@example.com"
git add -A
git commit -qm "fixture"
