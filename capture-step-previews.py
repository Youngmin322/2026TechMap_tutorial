#!/usr/bin/env python3
"""Capture a visionOS Simulator preview for each tutorial code step with a visible result.

The script follows the reader: it starts from TutorialProjects/Starter with the
nine USDZ models, applies the DocC @Code steps in order, and at each step listed
in CAPTURES builds the app, runs it in the Apple Vision Pro simulator and saves
a screenshot to SolarSystemAtlasStepByStep.docc/Resources/.

The empty room is captured first; each app screenshot is compared with it and
cropped to the region the app changed, so the volume fills the preview.

Two capture-only adjustments never reach the tutorial code:
  top      shrinks the scene and tilts it around x so it is seen from above,
           which shows z differences from the fixed simulator camera.
  select   starts with one planet selected, because the script cannot tap.

  python3 capture-step-previews.py                 # all captures
  python3 capture-step-previews.py 01-content-earth # only matching captures
"""

import shutil
import subprocess
import sys
import time

from PIL import Image, ImageChops, ImageFilter

from tutorial_steps import (
    ASSET_FOLDER, CATALOG, RESOURCES, RKASSETS, ROOT, STARTER, STARTER_SNAPSHOTS,
    USDZ_NAMES, code_steps, starter_sources,
)

WORK = ROOT / ".tutorial-captures-build"
PROJECT = WORK / "SolarSystemAtlas"
DERIVED = WORK / "DerivedData"
APP = DERIVED / "Build/Products/Debug-xrsimulator/SolarSystemAtlas.app"
BUNDLE_ID = "com.example.SolarSystemAtlas"
DEVICE_NAME = "Apple Vision Pro"
OUTPUT = CATALOG / "Resources"

# Resource file of the step → captures to save after that step.
CAPTURES = {
    "01-content-start.swift": [dict(name="preview-01-content-start")],
    "01-content-earth.swift": [dict(name="preview-01-content-earth")],
    "01-content-scene.swift": [dict(name="preview-01-content-scene")],
    "01-layout-aligned.swift": [dict(name="preview-01-layout-aligned-top", top=-70)],
    "01-layout-depth-offset.swift": [
        dict(name="preview-01-layout-depth-offset"),
        dict(name="preview-01-layout-depth-offset-top", top=-70),
    ],
    "02-scene-timeline.swift": [dict(name="preview-02-scene-timeline", wait=14)],
    "03-spatial-overlay.swift": [dict(name="preview-03-spatial-overlay", select="Earth")],
    "03-card-glass.swift": [dict(name="preview-03-card-glass", select="Earth")],
    "04-content-scene.swift": [dict(name="preview-04-content-scene")],
    "04-scene-planets.swift": [dict(name="preview-04-scene-planets")],
    "04-scene-update.swift": [dict(name="preview-04-scene-update", wait=14)],
    "04-attachment-labels.swift": [dict(name="preview-04-attachment-labels", wait=14)],
    "04-tap-selection.swift": [dict(name="preview-04-tap-selection", select="Earth", wait=14)],
}


def run(*arguments, check=True):
    return subprocess.run(arguments, text=True, capture_output=True, check=check).stdout


def device_id():
    for line in run("xcrun", "simctl", "list", "devices", "available").splitlines():
        if line.strip().startswith(DEVICE_NAME + " ("):
            return line.split("(")[1].split(")")[0]
    raise SystemExit(f"No {DEVICE_NAME} simulator is installed.")


def prepare_project():
    if PROJECT.exists():
        shutil.rmtree(PROJECT)
    shutil.copytree(STARTER, PROJECT, ignore=shutil.ignore_patterns(".DS_Store", "xcuserdata"))
    for name in USDZ_NAMES:
        shutil.copy2(ASSET_FOLDER / f"{name}.usdz", PROJECT / RKASSETS / f"{name}.usdz")


EMPTY_CONTENT = "import SwiftUI\n\nstruct ContentView: View {\n    var body: some View { Color.clear }\n}\n"


def write_sources(latest, capture):
    paths = starter_sources()
    for name, resource in latest.items():
        text = (RESOURCES / resource).read_text()
        if capture.get("empty") and name == "ContentView.swift":
            text = EMPTY_CONTENT
        if capture.get("top") and name == "SolarSystemAtlasApp.swift":
            text = text.replace(
                "ContentView()",
                "ContentView()\n"
                "                .scaleEffect(x: 0.6, y: 0.6, z: 0.6)\n"
                f"                .rotation3DEffect(.degrees({capture['top']}), axis: .x)",
                1,
            )
        if capture.get("select"):
            text = text.replace(
                "@State private var selectedPlanet: Planet?",
                "@State private var selectedPlanet: Planet? = "
                f'Planet.starter.first {{ $0.id == "{capture["select"]}" }}',
            )
        (PROJECT / paths[name]).write_text(text)


def build():
    result = subprocess.run([
        "xcodebuild", "-project", str(PROJECT / "SolarSystemAtlas.xcodeproj"),
        "-scheme", "SolarSystemAtlas", "-destination", "generic/platform=visionOS Simulator",
        "-derivedDataPath", str(DERIVED), "-quiet",
        f"SYMROOT={DERIVED / 'Build/Products'}", "CODE_SIGNING_ALLOWED=NO", "build",
    ], text=True, capture_output=True)
    if result.returncode:
        raise SystemExit(result.stdout[-4000:] + result.stderr[-4000:])


def screenshot(device, path):
    run("xcrun", "simctl", "io", device, "screenshot", str(path))
    return Image.open(path).convert("RGB")


def crop_to_app(empty, shot, margin=0.35, aspect=16 / 10):
    """Crop around what the step's code draws, compared with an empty volume of the same size."""
    difference = ImageChops.difference(empty, shot).convert("L")
    mask = difference.point(lambda value: 255 if value > 24 else 0).filter(ImageFilter.MinFilter(5))
    box = mask.getbbox()
    if not box:
        raise SystemExit("The app did not change the screen; nothing to crop.")
    left, top, right, bottom = box
    width, height = right - left, bottom - top
    width, height = width * (1 + 2 * margin), height * (1 + 2 * margin)
    if width / height < aspect:
        width = height * aspect
    else:
        height = width / aspect
    width, height = max(width, 720), max(height, 450)
    center_x, center_y = (left + right) / 2, (top + bottom) / 2
    left = min(max(0, center_x - width / 2), shot.width - width)
    top = min(max(0, center_y - height / 2), shot.height - height)
    cropped = shot.crop((int(left), int(top), int(left + width), int(top + height)))
    if cropped.width > 1600:
        cropped = cropped.resize((1600, round(1600 * cropped.height / cropped.width)), Image.LANCZOS)
    return cropped


def main():
    only = sys.argv[1:]
    device = device_id()
    run("xcrun", "simctl", "boot", device, check=False)
    run("xcrun", "simctl", "bootstatus", device, "-b")
    WORK.mkdir(exist_ok=True)
    prepare_project()

    def shoot(latest, capture, name):
        write_sources(latest, capture)
        build()
        run("xcrun", "simctl", "uninstall", device, BUNDLE_ID, check=False)
        run("xcrun", "simctl", "install", device, str(APP))
        run("xcrun", "simctl", "launch", device, BUNDLE_ID)
        time.sleep(capture.get("wait", 10))
        shot = screenshot(device, WORK / f"{name}-full.png")
        run("xcrun", "simctl", "terminate", device, BUNDLE_ID, check=False)
        time.sleep(2)
        return shot

    # One empty volume per window configuration (the App file decides its size).
    empty_volumes = {}
    latest = dict(STARTER_SNAPSHOTS)
    for step in list(code_steps()):
        latest[step.name] = step.file
        for capture in CAPTURES.get(step.file, []):
            if only and not any(token in capture["name"] for token in only):
                continue
            app_file = latest["SolarSystemAtlasApp.swift"]
            if app_file not in empty_volumes:
                print(f"Capturing empty volume for {app_file}", flush=True)
                empty_volumes[app_file] = shoot(latest, dict(empty=True), f"empty-{app_file}")
            print(f"Capturing {capture['name']} after {step.label}", flush=True)
            shot = shoot(latest, capture, capture["name"])
            crop_to_app(empty_volumes[app_file], shot).save(OUTPUT / f"{capture['name']}.png", optimize=True)
    print(f"Saved previews to {OUTPUT}")


if __name__ == "__main__":
    main()
