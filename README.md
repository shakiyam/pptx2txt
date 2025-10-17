pptx2txt
========

pptx2txt is a tool that converts PowerPoint `.pptx` format to text.

Requirements
------------

pptx2txt require python-pptx.

Windows:

```console
py -m pip install python-pptx
```

Linux/macOS:

```console
python3 -m pip install python-pptx
```

Usage
-----

To convert a `.pptx` files to text, run the following command:

Windows:

```console
py pptx2txt.py [files ...]
```

Linux/macOS:

```console
python3 pptx2txt.py [files ...]
```

Tips
----

If you are using Windows, you may find it useful to add a shortcut to SendTo by doing the following

```console
py -m pip install pywin32
py create_sendto_shortcut.py
```

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](https://opensource.org/licenses/mit)
