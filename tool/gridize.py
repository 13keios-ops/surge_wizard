"""원화를 **정확히 N칸 격자** 위로 다시 찍는다. (`reports/32_원화v3_검수.md` 3절)

생성기는 두 번 요청해도 「칸 수」를 못 맞췄다 (마법사 56칸 → 56칸). 그런데
받은 그림은 **필요한 것보다 잘게** 그려져 있으므로, **굵게 다시 찍는 것은
이쪽에서 할 수 있다.** 색·자세·구도는 그대로 남는다.

하는 것은 둘뿐이다.

1. **면적 평균으로 N칸까지 줄인다** (`Image.BOX`). 알파를 곱해서 줄여야
   투명한 자리의 색이 가장자리로 번지지 않는다
2. **정수배로 최근접 확대한다** (`Image.NEAREST`) → 블록 안이 완전한 단색이 되고
   `tool/measure_grid.py` 의 표준편차가 **정확히 0** 이 된다

⛔ **팔레트 근사·포스터라이즈·외곽선 추가·알파 이진화는 하지 않는다.**
`tool/bake_art.py` 의 「크기를 건드리지 않는다」는 **이미 격자가 옳은 원화**에
대한 규칙이다. 격자가 없는 그림에는 이 단계가 먼저 온다.

쓰는 법:
    python tool/gridize.py <원본png> <결과png> <칸수> <한칸px> <캔버스> [w]
    (마지막 `w` 를 붙이면 칸수를 **가로**로 센다 — 넓고 낮은 보스용)
"""

import sys
import numpy as np
from PIL import Image

sys.stdout.reconfigure(encoding='utf-8')

ALPHA = 16
FOOT = 477 / 512      # 캔버스 크기와 무관한 발바닥 비율 (`art_sprite.dart`)


def gridize(src, dst, cells, cell_px, canvas, by='h'):
    im = Image.open(src).convert('RGBA')
    a = np.array(im)
    ys, xs = np.where(a[:, :, 3] >= ALPHA)
    im = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    w, h = im.size
    unit = (h if by == 'h' else w) / cells        # 원본 몇 px 이 한 칸인가
    cols, rows = max(1, round(w / unit)), max(1, round(h / unit))
    cols, rows = (cols, cells) if by == 'h' else (cells, rows)

    small = _box_down(im, cols, rows)
    tile = small.resize((cols * cell_px, rows * cell_px), Image.NEAREST)

    out = Image.new('RGBA', (canvas, canvas), (0, 0, 0, 0))
    top = round(canvas * FOOT) - tile.height
    out.paste(tile, ((canvas - tile.width) // 2, top))
    out.save(dst)
    print(f'{dst}: {canvas}x{canvas} · {cols}x{rows}칸 · 한 칸 {cell_px}px '
          f'· 발바닥 y {round(canvas * FOOT) - 1} · 머리 위 여백 {top}px')


def _box_down(im, cols, rows):
    """알파를 곱해서 줄인 뒤 되돌린다 — 투명한 자리의 색이 안 번지게."""
    f = np.array(im).astype(np.float64)
    al = f[:, :, 3:4] / 255.0
    pm = np.concatenate([f[:, :, :3] * al, f[:, :, 3:4]], axis=2)
    s = np.array(Image.fromarray(pm.astype(np.uint8), 'RGBA')
                 .resize((cols, rows), Image.BOX)).astype(np.float64)
    s[:, :, :3] = np.clip(s[:, :, :3] / np.clip(s[:, :, 3:4] / 255.0, 1e-6, None),
                          0, 255)
    return Image.fromarray(s.astype(np.uint8), 'RGBA')


def gridize_bg(src, dst, cols, cell_px):
    """배경은 잘라낼 것도 세울 것도 없다. 가로 칸 수만 맞춘다."""
    im = Image.open(src).convert('RGB')
    rows = round(im.size[1] / (im.size[0] / cols))
    out = im.resize((cols, rows), Image.BOX) \
            .resize((cols * cell_px, rows * cell_px), Image.NEAREST)
    out.save(dst)
    print(f'{dst}: {out.size[0]}x{out.size[1]} · {cols}x{rows}칸 · 한 칸 {cell_px}px')


if __name__ == '__main__':
    src, dst, cells, cell_px, canvas = sys.argv[1:6]
    by = 'w' if len(sys.argv) > 6 and sys.argv[6] == 'w' else 'h'
    if canvas == 'bg':
        gridize_bg(src, dst, int(cells), int(cell_px))
    else:
        gridize(src, dst, int(cells), int(cell_px), int(canvas), by)
