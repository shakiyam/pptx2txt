import os.path
import sys

from win32com.client import Dispatch

shell = Dispatch('WScript.Shell')
sendto_dir = shell.SpecialFolders('SendTo')
shortcut = shell.CreateShortCut(os.path.join(sendto_dir, 'pptx2txt.lnk'))
shortcut.Targetpath = sys.executable
shortcut.Arguments = os.path.join(os.path.dirname(__file__), 'pptx2txt.py')
shortcut.save()
