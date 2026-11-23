"""Shared description of the step-by-step tutorial's code steps and starter project.

Used by validate-step-by-step-tutorial.py, make-tutorial-projects.py and
capture-step-previews.py so that all three follow the same reader path:
start from TutorialProjects/Starter, then apply each @Code step in DocC order.
"""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent
CATALOG = ROOT / "SolarSystemAtlasStepByStep.docc"
RESOURCES = CATALOG / "Tutorials/Resources"
STARTER = ROOT / "TutorialProjects/Starter"
APP_FOLDER = "SolarSystemAtlas"
ASSET_FOLDER = ROOT / "Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets"
RKASSETS = "Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets"
CHAPTERS = [
    "01-SpatialLayoutBasics",
    "02-PlanetRotation",
    "03-PlanetInfoOverlay",
    "04-RealityKitIntegration",
]
# The nine models the tutorial uses. Moon and Pluto in the main project are not needed.
USDZ_NAMES = ["Sun", "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]
# Starter files that DocC shows as the "before" side of a diff.
STARTER_SNAPSHOTS = {
    "SolarSystemAtlasApp.swift": "00-app-starter.swift",
    "ContentView.swift": "00-content-starter.swift",
}

CODE = re.compile(r"@Code\(([^\n]+)\)")
ATTRIBUTE = re.compile(r'(\w+): "([^"]+)"')


class CodeStep:
    def __init__(self, chapter, line, name, file, previous):
        self.chapter, self.line, self.name, self.file, self.previous = chapter, line, name, file, previous

    @property
    def label(self):
        return f"{self.chapter}:{self.line} — {self.file}"


def starter_sources():
    """Swift file name → path relative to the starter project root."""
    return {
        path.name: path.relative_to(STARTER).as_posix()
        for path in sorted((STARTER / APP_FOLDER).rglob("*.swift"))
    }


def code_steps():
    for chapter in CHAPTERS:
        text = (CATALOG / "Tutorials" / f"{chapter}.tutorial").read_text()
        for match in CODE.finditer(text):
            attrs = dict(ATTRIBUTE.findall(match[1]))
            line = text[:match.start()].count("\n") + 1
            yield CodeStep(chapter, line, attrs["name"], attrs["file"], attrs.get("previousFile"))


def final_files():
    """File name → the last resource file the reader typed into it."""
    latest = dict(STARTER_SNAPSHOTS)
    for step in code_steps():
        latest[step.name] = step.file
    return latest
