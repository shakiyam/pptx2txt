import codecs
import os.path
import sys
from datetime import datetime

from pptx import Presentation
from pptx.exc import PackageNotFoundError
from pptx.shapes.autoshape import Shape
from pptx.shapes.base import BaseShape
from pptx.shapes.graphfrm import GraphicFrame
from pptx.shapes.group import GroupShape

version = '2025-07-23'


def log(message: str) -> None:
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f'{timestamp} {message}', file=sys.stderr)


def shape2txt(shape: BaseShape) -> list[str]:
    lines = []
    if isinstance(shape, Shape):
        for paragraph in shape.text_frame.paragraphs:
            stripped = paragraph.text.strip()
            if stripped:
                lines.append(stripped)
    elif isinstance(shape, GraphicFrame) and shape.has_table:
        for row in shape.table.rows:
            for cell in row.cells:
                stripped = cell.text.strip()
                if stripped:
                    lines.append(stripped)
    elif isinstance(shape, GroupShape):
        for item in shape.shapes:
            lines += shape2txt(item)
    return lines


log(f'pptx2txt - version {version} by Shinichi Akiyama')

if len(sys.argv) < 2:
    log('ERROR: No input files specified')
    log('Usage: pptx2txt <file1.pptx> [file2.pptx] ...')
    sys.exit(1)

for file in sys.argv[1:]:
    # Check if file exists
    if not os.path.exists(file):
        log(f'ERROR: File not found: {file}')
        sys.exit(1)

    base, ext = os.path.splitext(file)
    textfile = f'{base}.txt'

    try:
        presentation = Presentation(file)
        log(f'{file} was opened.')
    except PackageNotFoundError:
        log(f'ERROR: Invalid PPTX file: {file}')
        sys.exit(1)
    except Exception as e:
        log(f'ERROR: Failed to open {file}: {str(e)}')
        sys.exit(1)

    lines = []
    for i, slide in enumerate(presentation.slides):
        lines.append(f'--- Slide {i + 1} ---')
        for shape in slide.shapes:
            lines += shape2txt(shape)

    try:
        with codecs.open(textfile, 'w', 'utf-8') as f:
            for line in lines:
                print(line, file=f)
        log(f'{textfile} was saved.')
    except (IOError, OSError) as e:
        log(f'ERROR: Cannot write to {textfile}: {str(e)}')
        sys.exit(1)

log('All files were processed.')
