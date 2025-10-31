import sys
from pathlib import Path
from typing import Any

if sys.platform != "win32":
    print("Error: This script only works on Windows", file=sys.stderr)
    sys.exit(1)

from win32com.client import Dispatch

shell: Any = Dispatch("WScript.Shell")
sendto_dir: str = shell.SpecialFolders("SendTo")
shortcut_path = Path(sendto_dir) / "pptx2txt.lnk"
shortcut: Any = shell.CreateShortCut(str(shortcut_path))
shortcut.TargetPath = sys.executable
script_path = Path(__file__).parent / "pptx2txt.py"
shortcut.Arguments = f"-Xutf8 {script_path}"
shortcut.Save()
