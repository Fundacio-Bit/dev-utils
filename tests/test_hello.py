from pathlib import Path
import subprocess
import sys


def test_hello_script_prints_expected_message():
    script = Path(__file__).resolve().parents[1] / "scripts" / "hello.py"
    result = subprocess.run(
        [sys.executable, str(script)],
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 0
    assert result.stdout.strip() == "Hello from pinbal-template!"
