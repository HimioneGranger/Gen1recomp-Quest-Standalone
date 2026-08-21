"""Source-only contract for the external Cloud C2 Quest handoff."""

from __future__ import annotations

from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parents[2]
HANDOFF = ROOT / "docs/project-coordination/cloud-c2-quest-compatibility-handoff-20260821.md"
CHECKLIST = ROOT / "docs/quest-release-checklist.md"


def require(text: str, values: tuple[str, ...], label: str) -> None:
    normalized = " ".join(text.split())
    missing = [value for value in values
               if " ".join(value.split()) not in normalized]
    assert not missing, f"{label} is missing: {missing}"


def tracked_runtime_files() -> list[Path]:
    result = subprocess.run(
        ["git", "ls-files", "-z", "--", "src", "mobile/android"],
        cwd=ROOT,
        check=True,
        capture_output=True,
    )
    paths = result.stdout.decode("utf-8").split("\0")
    return [ROOT / path for path in paths if path]


def main() -> None:
    handoff = HANDOFF.read_text(encoding="utf-8")
    checklist = CHECKLIST.read_text(encoding="utf-8")

    require(handoff, (
        "`skyCloudModel` | `linear-scalar-directional-volume-b1`, `none`",
        "`skyCloudResource` | `untried`, `ready`, `failed`",
        "`skyCloudFilter` | `untried`, `linear`",
        "`skyCloudWrap` | `untried`, `repeat`",
        "`skyCloudFailure` | `none`, `allocation`, `setPixel`, `filter`, `wrap`",
        "C2 to `4`, C1 to `1`, and C0 to `0`",
        "Quest cloud resource failed at",
    ), "QRENDER interface")

    require(handoff, (
        "c82c3e64b826e1c84ec9a3770e2183e3fd6a17de",
        "cloud-c2-advanced",
        "Schema: `46`",
        "2.0.0-quest.cloud-c2-advanced-test",
        "6535FC650A93C3C90B38BFA73D471FA827038A3EEF13622EB8FDAAF29D5AB7E6",
        "D48D82DC541A6E20AA93628DA62C2FE0C346257EA1E968948742FDE011DADFED",
        "113/113",
    ), "external dependency identity")

    require(handoff, (
        "DRAMALESS is an external paired dependency",
        "Do not copy DRAMALESS source into app history",
        "continuous video and timestamp-aligned, unfiltered logs",
        "No host result can infer a device result",
        "resource setup only",
        "never proves shader link, headset pixels, performance, or acceptance",
        "12 resolution-by-Water cells",
        "CPU time, GPU time, median, p90, p99, missed frames, stale frames,",
        "and reprojected frames",
    ), "acceptance boundary")

    require(checklist, (
        "Cloud C2 paired-headset gate",
        "cloud-c2-quest-compatibility-handoff-20260821.md",
        "continuous video and timestamp-aligned unfiltered logs",
    ), "release checklist propagation")

    forbidden = ("QRENDER", "skyCloudModel", "skyCloudResource",
                 "skyCloudFilter", "skyCloudWrap", "skyCloudFailure",
                 "skyCloudLevel", "skyCloudFetches")
    violations: list[str] = []
    for path in tracked_runtime_files():
        try:
            source = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        for token in forbidden:
            if token in source:
                violations.append(f"{path.relative_to(ROOT)}: {token}")
    assert not violations, (
        "pass-through app must not add a cloud/QRENDER parser or runtime copy: "
        + ", ".join(violations)
    )

    print("PASS: Quest Cloud C2 compatibility contract")


if __name__ == "__main__":
    main()
