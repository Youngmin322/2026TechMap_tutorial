#!/usr/bin/env python3
"""Type-check the cumulative Swift files in Chapters 1–4 in DocC step order.

Requires Xcode with the visionOS 26+ SDK. A temporary RealityKitContent
module supplies the package's real public declaration with a check-only
Bundle.module accessor. This does not validate USDZ loading or runtime UI.
"""

from pathlib import Path
import re
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parent
CATALOG = ROOT / "SolarSystemAtlasStepByStep.docc"
RESOURCES = CATALOG / "Tutorials/Resources"
CODE = re.compile(r"@Code\(([^\n]+)\)")
ATTRIBUTE = re.compile(r'(\w+): "([^"]+)"')


def run(arguments):
    result = subprocess.run(arguments, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)
    return result.stdout.strip()


def validate(work):
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
    # ContentView exists in the Xcode App template before the first code step.
    (sources / "ContentView.swift").write_text(
        'import SwiftUI\nstruct ContentView: View {\n'
        '    var body: some View { Text("Hello, world!") }\n}\n'
    )
    latest = {}
    count = 0
    for chapter in ["01-SpatialLayoutBasics", "02-PlanetRotation", "03-PlanetInfoOverlay", "04-RealityKitIntegration"]:
        tutorial = CATALOG / "Tutorials" / f"{chapter}.tutorial"
        for match in CODE.finditer(tutorial.read_text()):
            attrs = dict(ATTRIBUTE.findall(match[1]))
            name, filename = attrs["name"], attrs["file"]
            previous = attrs.get("previousFile")
            if previous and latest.get(name) != previous:
                raise RuntimeError(
                    f"{chapter}: {name} compares against {previous}, "
                    f"but the reader's latest file is {latest.get(name)}"
                )
            (sources / name).write_text((RESOURCES / filename).read_text())
            latest[name] = filename
            line = tutorial.read_text()[:match.start()].count("\n") + 1
            print(f"Checking {chapter}:{line} — {filename}", flush=True)
            run([
                "xcrun", "swiftc", *flags, "-I", str(work),
                "-typecheck", "-parse-as-library",
                "-module-name", "SolarSystemAtlasTutorial",
                *map(str, sorted(sources.glob("*.swift"))),
            ])
            count += 1

    for filename in ["s2-core-feature.swift", "s3-complete.swift", "s4-complete.swift"]:
        print(f"Checking standalone checkpoint — {filename}", flush=True)
        run([
            "xcrun", "swiftc", *flags, "-I", str(work), "-typecheck",
            "-parse-as-library", "-module-name", "SolarSystemAtlasCheckpoint",
            str(RESOURCES / filename),
        ])
    print(f"PASS: {count} cumulative code steps and 3 standalone checkpoints.")
    print("USDZ loading, selection, and card placement require simulator/device verification.")


if __name__ == "__main__":
    try:
        with tempfile.TemporaryDirectory(prefix="solarsystematlas-tutorial-") as directory:
            validate(Path(directory))
    except (RuntimeError, OSError) as error:
        raise SystemExit(str(error)) from error
