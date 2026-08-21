"""Source-only contract for the external Cloud C2 Quest handoff."""

from __future__ import annotations

import ast
from pathlib import Path, PurePosixPath
import re
import shlex
import subprocess


ROOT = Path(__file__).resolve().parents[2]
BUILD_ANDROID = ROOT / "scripts/build_android.sh"
HANDOFF = ROOT / "docs/project-coordination/cloud-c2-quest-compatibility-handoff-20260821.md"
PLAN = ROOT / "docs/project-coordination/cloud-c2-headset-execution-plan-20260821.md"
CHECKLIST = ROOT / "docs/quest-release-checklist.md"

PACKAGED_RUNTIME_ROOTS = (
    "main.lua", "conf.lua", "src", "data", "assets", "tools/save-editor",
)
ANDROID_RUNTIME_ROOT = "mobile/android"
PACKAGER_METADATA_INPUTS = (
    "tools/rom_manifest.json",
    "tools/rom_manifest_blue.json",
    "tools/rom_manifest_yellow.json",
    "tools/rom_manifest_gold.json",
)
SCAN_ROOTS = PACKAGED_RUNTIME_ROOTS + (ANDROID_RUNTIME_ROOT,)

# Match the exact emitted record name and key/value field prefixes. These byte
# tokens catch a parser or duplicate emitter without matching ordinary vendor
# prose that only names a field.
FORBIDDEN_RUNTIME_TOKENS = (
    b"QRENDER scene-timing",
    b"skyCloudModel=",
    b"skyCloudResource=",
    b"skyCloudFilter=",
    b"skyCloudWrap=",
    b"skyCloudFailure=",
    b"skyCloudLevel=",
    b"skyCloudFetches=",
)


def require(text: str, values: tuple[str, ...], label: str) -> None:
    normalized = " ".join(text.split())
    missing = [value for value in values
               if " ".join(value.split()) not in normalized]
    assert not missing, f"{label} is missing: {missing}"


def packager_targets() -> tuple[str, ...]:
    """Read both packager target declarations and compare them to this test."""
    source = BUILD_ANDROID.read_text(encoding="utf-8")
    match = re.search(r"^targets = (\[.*?^\])$", source, re.MULTILINE | re.DOTALL)
    assert match, "scripts/build_android.sh has no readable fallback target list"
    targets = ast.literal_eval(match.group(1))
    assert isinstance(targets, list) and all(isinstance(item, str) for item in targets)

    expected = PACKAGED_RUNTIME_ROOTS + PACKAGER_METADATA_INPUTS
    assert tuple(targets) == expected, (
        f"contract roots are not aligned with fallback packager: {targets!r}"
    )

    shell_match = re.search(
        r'zip -q -X -9 -r "\$LOVE_FILE"\s+\\\s*\n(.*?)\n\s+-x ',
        source,
        re.DOTALL,
    )
    assert shell_match, "scripts/build_android.sh has no readable zip target list"
    shell_targets = tuple(shlex.split(shell_match.group(1).replace("\\", " ")))
    assert shell_targets == expected, (
        f"contract roots are not aligned with shell packager: {shell_targets!r}"
    )
    return tuple(targets)


def tracked_runtime_files() -> list[tuple[str, bytes]]:
    result = subprocess.run(
        ["git", "ls-files", "-z", "--", *SCAN_ROOTS],
        cwd=ROOT,
        check=True,
        capture_output=True,
    )
    try:
        names = result.stdout.decode("utf-8").split("\0")
    except UnicodeDecodeError as exc:
        raise AssertionError("git returned a non-UTF-8 tracked path") from exc

    files: list[tuple[str, bytes]] = []
    for name in names:
        if not name:
            continue
        path = ROOT / PurePosixPath(name)
        try:
            files.append((name, path.read_bytes()))
        except OSError as exc:
            raise AssertionError(f"tracked runtime file is unreadable: {name}") from exc
    return files


def find_forbidden_tokens(files: list[tuple[str, bytes]]) -> list[str]:
    violations: list[str] = []
    for name, data in files:
        for token in FORBIDDEN_RUNTIME_TOKENS:
            if token in data:
                violations.append(f"{name}: {token.decode('ascii')}")
    return violations


def negative_coverage_self_check() -> None:
    """Prove every logical root detects a forbidden token, without fixtures."""
    token = FORBIDDEN_RUNTIME_TOKENS[0]
    for root in SCAN_ROOTS:
        name = root if PurePosixPath(root).suffix else f"{root}/negative.bin"
        hits = find_forbidden_tokens([(name, b"prefix\xff" + token + b"\x00suffix")])
        assert hits == [f"{name}: {token.decode('ascii')}"], (
            f"negative coverage self-check failed for {root}"
        )


def main() -> None:
    handoff = HANDOFF.read_text(encoding="utf-8")
    plan = PLAN.read_text(encoding="utf-8")
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
        "cloud-c2-headset-execution-plan-20260821.md",
        "sole authoritative device procedure",
    ), "acceptance boundary")

    preservation_boundary = (
        "All Q43, Q44, Q45, post-Q44, post-parity, paired-launcher, failed "
        "Cloud C2 `-001`, and other prior pair/evidence directories remain "
        "preserved. The new `-002` pair supersedes them only as the candidate "
        "for this Cloud C2 test. It does not accept or replace their historical "
        "results for any other lane."
    )
    require(handoff, (preservation_boundary,), "handoff preservation boundary")
    require(plan, (preservation_boundary,), "plan preservation boundary")

    require(plan, (
        "warm each cell for 10 seconds",
        "capture and measure each cell continuously for 60 seconds, not 30",
        "configured target refresh",
        "12 resolution-by-Water cells",
        "separate 60-second C2 visual sequence",
        "Capture a lower/under-cloud view that looks up at the same cloud and makes its underside and darker lower mass unambiguous.",
        "PAIRED_HEADSET_GATE_PLAN.md",
        "superseded for physical execution",
    ), "authoritative headset procedure")

    require(checklist, (
        "Cloud C2 paired-headset gate",
        "cloud-c2-headset-execution-plan-20260821.md",
        "sole authoritative device procedure",
        "continuous video and timestamp-aligned unfiltered logs",
    ), "release checklist propagation")

    packager_targets()
    negative_coverage_self_check()
    violations = find_forbidden_tokens(tracked_runtime_files())
    assert not violations, (
        "pass-through app must not add a cloud/QRENDER parser or runtime copy: "
        + ", ".join(violations)
    )

    print("PASS: Quest Cloud C2 compatibility contract")


if __name__ == "__main__":
    main()
