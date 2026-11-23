#!/usr/bin/env python3
"""Type-check the cumulative Swift files in Chapters 1–4 in DocC step order.

The reader starts from TutorialProjects/Starter, so the check starts from the
starter's Swift files too. Every @Code step must name a file that already
exists in the starter, and the starter files DocC compares against must match
the starter byte for byte.

Requires Xcode with the visionOS 26+ SDK. A temporary RealityKitContent
module supplies the package's real public declaration with a check-only
Bundle.module accessor. This does not validate USDZ loading or runtime UI.
"""

from pathlib import Path
import subprocess
import tempfile

from tutorial_steps import (
    RESOURCES, ROOT, STARTER, STARTER_SNAPSHOTS, code_steps, starter_sources,
)


def run(arguments):
    result = subprocess.run(arguments, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)
    return result.stdout.strip()


def check_starter():
    files = starter_sources()
    for name, snapshot in STARTER_SNAPSHOTS.items():
        if (STARTER / files[name]).read_text() != (RESOURCES / snapshot).read_text():
            raise RuntimeError(f"{snapshot} differs from the starter's {files[name]}")
    for step in code_steps():
        if step.name not in files:
            raise RuntimeError(f"{step.label}: {step.name} is not in the starter project")
    return files


def validate(work):
    starter_files = check_starter()
    sdk = run(["xcrun", "--sdk", "xrsimulator", "--show-sdk-path"])
    flags = [
        "-sdk", sdk,
        "-target", "arm64-apple-xros26.0-simulator",
        "-swift-version", "5",
        "-default-isolation", "MainActor",
        "-module-cache-path", str(work / "module-cache"),
    ]
    package_source = (
        ROOT / "Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.swift"
    )
    accessor = work / "BundleAccessor.swift"
    accessor.write_text(
        "import Foundation\n"
        "extension Bundle { static var module: Bundle { Bundle.main } }\n"
    )
    run([
        "xcrun", "swiftc", *flags, "-emit-module",
        "-module-name", "RealityKitContent",
        str(package_source), str(accessor),
        "-emit-module-path", str(work / "RealityKitContent.swiftmodule"),
    ])

    sources = work / "Sources"
    sources.mkdir()
    for name, relative in starter_files.items():
        (sources / name).write_text((STARTER / relative).read_text())

    def typecheck():
        run([
            "xcrun", "swiftc", *flags, "-I", str(work),
            "-typecheck", "-parse-as-library",
            "-module-name", "SolarSystemAtlasTutorial",
            *map(str, sorted(sources.glob("*.swift"))),
        ])

    print("Checking starter project", flush=True)
    typecheck()

    latest = dict(STARTER_SNAPSHOTS)
    count = 0
    for step in code_steps():
        if step.previous and latest.get(step.name) != step.previous:
            raise RuntimeError(
                f"{step.chapter}: {step.name} compares against {step.previous}, "
                f"but the reader's latest file is {latest.get(step.name)}"
            )
        (sources / step.name).write_text((RESOURCES / step.file).read_text())
        latest[step.name] = step.file
        print(f"Checking {step.label}", flush=True)
        typecheck()
        count += 1

    for filename in ["s2-core-feature.swift", "s3-complete.swift", "s4-complete.swift"]:
        print(f"Checking standalone checkpoint — {filename}", flush=True)
        run([
            "xcrun", "swiftc", *flags, "-I", str(work), "-typecheck",
            "-parse-as-library", "-module-name", "SolarSystemAtlasCheckpoint",
            str(RESOURCES / filename),
        ])
    print(f"PASS: starter, {count} cumulative code steps and 3 standalone checkpoints.")
    print("USDZ loading, selection, and card placement require simulator/device verification.")


if __name__ == "__main__":
    try:
        with tempfile.TemporaryDirectory(prefix="solarsystematlas-tutorial-") as directory:
            validate(Path(directory))
    except (RuntimeError, OSError) as error:
        raise SystemExit(str(error)) from error
