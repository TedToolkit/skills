#!/usr/bin/env python3
"""Measure normalized UTF-8 route closures and enforce strict shrinkage."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path


def normalized_size(data: bytes) -> int:
    text = data.decode("utf-8").replace("\r\n", "\n").replace("\r", "\n")
    return len(text.encode("utf-8"))


def read_at(repo: Path, path: str, ref: str | None) -> bytes:
    if ref is None:
        return (repo / path).read_bytes()
    result = subprocess.run(
        ["git", "show", f"{ref}:{path}"],
        cwd=repo,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode:
        raise RuntimeError(result.stderr.decode("utf-8", errors="replace").strip())
    return result.stdout


def measure(repo: Path, routes: dict[str, dict[str, object]], ref: str | None) -> dict[str, int]:
    measured: dict[str, int] = {}
    for name, route in routes.items():
        paths = route["files"]
        if len(paths) != len(set(paths)):
            raise ValueError(f"{name}: duplicate path")
        measured[name] = sum(normalized_size(read_at(repo, path, ref)) for path in paths)
    return measured


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, default=Path(__file__).with_name("routes.json"))
    args = parser.parse_args(argv)

    spec = json.loads(args.manifest.read_text(encoding="utf-8"))
    routes = spec["routes"]
    baseline_ref = spec["baseline_ref"]
    expected = {name: route["baseline_bytes"] for name, route in routes.items()}
    baseline = measure(args.repo, routes, baseline_ref)
    current = measure(args.repo, routes, None)

    errors: list[str] = []
    if baseline != expected:
        errors.append(f"baseline mismatch: expected={expected!r}, observed={baseline!r}")
    for name in routes:
        delta = current[name] - baseline[name]
        print(f"{name}: {baseline[name]} -> {current[name]} ({delta:+d})")
        if delta >= 0:
            errors.append(f"{name}: closure did not shrink")
    baseline_total = sum(baseline.values())
    current_total = sum(current.values())
    print(f"total: {baseline_total} -> {current_total} ({current_total - baseline_total:+d})")
    if current_total >= baseline_total:
        errors.append("total: closure did not shrink")
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
