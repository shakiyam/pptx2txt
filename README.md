pptx2txt
========

pptx2txt is a tool that converts PowerPoint `.pptx` format to text.

Requirements
------------

pptx2txt requires python-pptx. Install it using [uv](https://github.com/astral-sh/uv), a fast Python package manager:

```console
# System-wide installation (recommended)
uv pip install --system python-pptx

# For development with virtual environment:
uv venv
# Windows: .venv\Scripts\activate
# Linux/macOS: source .venv/bin/activate
uv pip install python-pptx
```

**Note**: System-wide installation may require administrator privileges.

Usage
-----

To convert a `.pptx` files to text, run the following command:

```console
# Windows
py pptx2txt.py [files ...]

# Linux/macOS
python3 pptx2txt.py [files ...]
```

Tips
----

If you are using Windows, you can make a shortcut to the "SendTo" menu by running the following command:

```console
uv pip install --system pywin32
py create_sendto_shortcut.py
```

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](https://opensource.org/licenses/mit)
