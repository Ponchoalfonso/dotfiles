#!/usr/bin/env python3

import argparse
import os
from pathlib import Path
from time import time


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Prune Pi session files older than the given number of days. Defaults to dry-run mode.",
    )
    parser.add_argument(
        "days",
        nargs="?",
        type=int,
        default=30,
        help="delete sessions older than this many days (default: 30)",
    )
    parser.add_argument(
        "--delete",
        "--apply",
        action="store_true",
        help="actually delete matching sessions",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="list matching sessions without deleting them (default)",
    )
    parser.add_argument(
        "--session-dir",
        default=os.environ.get(
            "PI_CODING_AGENT_SESSION_DIR",
            str(Path.home() / ".pi" / "agent" / "sessions"),
        ),
        help="Pi session directory (default: PI_CODING_AGENT_SESSION_DIR or ~/.pi/agent/sessions)",
    )
    return parser.parse_args()


def find_old_sessions(session_dir: Path, days: int) -> list[Path]:
    cutoff = time() - (days * 24 * 60 * 60)
    return sorted(
        path
        for path in session_dir.rglob("*.jsonl")
        if path.is_file() and path.stat().st_mtime < cutoff
    )


def main() -> int:
    args = parse_args()
    session_dir = Path(args.session_dir).expanduser()

    if not session_dir.is_dir():
        print(f"pi-prune: session directory does not exist: {session_dir}")
        return 0

    sessions = find_old_sessions(session_dir, args.days)

    if args.delete:
        print(f"pi-prune: deleting sessions older than {args.days} days under {session_dir}")
        for session in sessions:
            print(session)
            session.unlink()
    else:
        print(f"pi-prune: dry run; sessions older than {args.days} days under {session_dir}")
        print("pi-prune: rerun with --delete to remove them")
        for session in sessions:
            print(session)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
