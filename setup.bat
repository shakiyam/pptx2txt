@echo off
rem One chained command instead of goto labels, because cmd can miss labels in batch files with LF line endings
rem Continued lines start with a space, because cmd takes the first character after a trailing ^ literally
py -m pip install -r "%~dp0requirements.txt" ^
  && py -m pip install --upgrade pywin32 ^
  && py "%~dp0create_sendto_shortcut.py" ^
  && echo Setup completed. ^
  || echo Setup failed.
pause
