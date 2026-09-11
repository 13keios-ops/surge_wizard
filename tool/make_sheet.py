"""캡처 여러 장을 가로로 붙여 비교 시트 한 장을 만든다.

토큰 절약 규칙(CLAUDE.md) — 대화에서 여는 그림은 **가로 480px 한 장뿐**이다.

    python tool/make_sheet.py <결과png> <가로폭> <라벨=파일png> ...
"""

import sys
from PIL import Image, ImageDraw

BAR = 16  # 라벨 띠 높이


def main(out, total_w, items):
    n = len(items)
    w = total_w // n
    tiles = []
    for label, path in items:
        im = Image.open(path).convert('RGB')
        h = round(im.height * w / im.width)
        tiles.append((label, im.resize((w, h), Image.LANCZOS)))
    h = max(t.height for _, t in tiles)
    sheet = Image.new('RGB', (w * n, h + BAR), (20, 18, 26))
    d = ImageDraw.Draw(sheet)
    for i, (label, t) in enumerate(tiles):
        sheet.paste(t, (i * w, BAR))
        d.text((i * w + 4, 4), label, fill=(230, 226, 240))
    sheet.save(out)
    print(f'{out}: {sheet.size[0]}x{sheet.size[1]}')


if __name__ == '__main__':
    main(sys.argv[1], int(sys.argv[2]),
         [a.split('=', 1) for a in sys.argv[3:]])
