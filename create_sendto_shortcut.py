import os.path
import sys
from typing import Any

if sys.platform != "win32":
    print("Error: This script only works on Windows", file=sys.stderr)
    sys.exit(1)

from win32com.client import Dispatch

shell: Any = Dispatch("WScript.Shell")
sendto_dir: str = shell.SpecialFolders("SendTo")
shortcut: Any = shell.CreateShortCut(os.path.join(sendto_dir, "pptx2txt.lnk"))
shortcut.TargetPath = sys.executable
shortcut.Arguments = os.path.join(os.path.dirname(__file__), "pptx2txt.py")
shortcut.Save()
