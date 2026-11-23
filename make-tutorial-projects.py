#!/usr/bin/env python3
"""Assemble the downloadable starter and complete projects for the step-by-step tutorial.

  Starter  = TutorialProjects/Starter + the nine USDZ models
  Complete = Starter + the last code the reader types into each file (from the DocC steps)

The USDZ files are copied from the main project's RealityKitContent package, so
the repository never stores a second copy. Output goes to .tutorial-projects-build/
(ignored by git) as two folders and two ZIP files ready for a GitHub Release.

  python3 make-tutorial-projects.py           # assemble and zip
  python3 make-tutorial-projects.py --build   # also build both for the visionOS simulator
"""

import argparse
import shutil
import subprocess

from tutorial_steps import (
    ASSET_FOLDER, RESOURCES, RKASSETS, ROOT, STARTER, USDZ_NAMES, final_files, starter_sources,
)

OUTPUT = ROOT / ".tutorial-projects-build"
PROJECTS = {
    "Starter": "SolarSystemAtlas-Starter",
    "Complete": "SolarSystemAtlas-Complete",
}


def assemble(kind):
    folder = OUTPUT / PROJECTS[kind]
    if folder.exists():
        shutil.rmtree(folder)
    shutil.copytree(STARTER, folder, ignore=shutil.ignore_patterns(".DS_Store", "xcuserdata"))
    for name in USDZ_NAMES:
        shutil.copy2(ASSET_FOLDER / f"{name}.usdz", folder / RKASSETS / f"{name}.usdz")
    if kind == "Complete":
        paths = starter_sources()
        for name, resource in final_files().items():
            shutil.copy2(RESOURCES / resource, folder / paths[name])
    return folder


def build(folder):
    derived = OUTPUT / "DerivedData" / folder.name
    subprocess.run([
        "xcodebuild", "-project", str(folder / "SolarSystemAtlas.xcodeproj"),
        "-scheme", "SolarSystemAtlas",
        "-destination", "generic/platform=visionOS Simulator",
        "-derivedDataPath", str(derived), "-quiet",
        # Keep products here even when Xcode is set to a custom build location.
        f"SYMROOT={derived / 'Build/Products'}",
        "CODE_SIGNING_ALLOWED=NO", "build",
    ], check=True)
    print(f"BUILD OK: {folder.name}")


def zip_folder(folder):
    archive = folder.with_suffix(".zip")
    archive.unlink(missing_ok=True)
    subprocess.run([
        "ditto", "-c", "-k", "--norsrc", "--keepParent", str(folder), str(archive),
    ], check=True)
    size = archive.stat().st_size / 1_000_000
    print(f"ZIP: {archive} ({size:.1f} MB)")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--build", action="store_true", help="build both projects for the visionOS simulator")
    arguments = parser.parse_args()
    OUTPUT.mkdir(exist_ok=True)
    for kind in PROJECTS:
        folder = assemble(kind)
        if arguments.build:
            build(folder)
        zip_folder(folder)


if __name__ == "__main__":
    main()
