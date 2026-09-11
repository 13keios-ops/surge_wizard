"""원화의 「칸 크기」를 격자 적합으로 잰다. (`reports/32_원화v3_검수.md` 2-1절)

**런 최빈값으로 재지 마라.** 안티에일리어싱이 조금만 있어도 1px 런이 82~96%가
돼 아무것도 못 말한다. 엣지 자기상관은 **없는 격자를 있다고 한다** (보스가 그랬다).

여기서 하는 것은 하나뿐이다 — 후보 칸 크기 p 마다 **블록 안쪽 색의 표준편차**를
재고 극소점을 찾는다. 격자가 완벽하면 블록 안이 단색이라 **정확히 0** 이 나온다
(Phase 1.5 합격 원화는 p=7 에서 0.00). **극소점이 없으면 격자가 없는 것이다.**

쓰는 법:
    python tool/measure_grid.py <png...>

numpy 가 필요하다 (`pip install numpy`). 앱은 안 쓰고 검수 때만 쓴다.
"""

import sys
import numpy as np
from PIL import Image

sys.stdout.reconfigure(encoding='utf-8')

ALPHA = 16      # 실루엣 문턱값
PMAX = 30       # 여기까지 후보로 본다


def grid_fit(path):
    im = Image.open(path).convert('RGBA')
    a = np.array(im).astype(float)
    ys, xs = np.where(a[:, :, 3] >= ALPHA)
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    rgb = a[y0:y1, x0:x1, :3]
    on = a[y0:y1, x0:x1, 3] >= ALPHA
    h, w, _ = rgb.shape
    print(f'== {path}  캔버스 {im.size[0]}x{im.size[1]} · 실루엣 {w}x{h} '
          f'· 중심x {(x0 + x1 - 1) / 2:.1f} · 발바닥y {y1 - 1}')

    out = []
    for p in range(4, PMAX):
        # 위상(offset)을 바꿔 가며 제일 잘 맞는 자리의 값을 그 p 의 점수로 삼는다
        best = min(_phase_std(rgb, on, p, off) for off in range(p))
        out.append((p, best))
    # 값은 p 가 커질수록 자연히 는다. 그러니 「제일 작은 곳」이 아니라
    # **양옆보다 낮게 파인 곳(극소점)**만 격자로 인정한다
    dips = [(p, v) for i, (p, v) in enumerate(out)
            if 0 < i < len(out) - 1 and v < out[i - 1][1] and v < out[i + 1][1]]
    for p, v in out:
        print(f'   p={p:>2}  블록내 표준편차 {v:6.2f}'
              f'{"  ← 극소점" if (p, v) in dips else ""}')
    # 극소점은 여럿 나온다 — 칸 크기의 **약수와 배수**도 격자에 얼추 맞기 때문이다.
    # 진짜 주기는 **양옆보다 가장 깊게 파인 곳**이다 (약수·배수는 얕게 파인다).
    if dips:
        idx = {p: i for i, (p, _) in enumerate(out)}
        depth = {p: (out[idx[p] - 1][1] + out[idx[p] + 1][1]) / 2 - v
                 for p, v in dips}
        p = max(depth, key=depth.get)
        v = dict(dips)[p]
        print(f'   → 칸 크기 {p}px (표준편차 {v:.2f}. 0 에 가까울수록 또렷하다)'
              f'{"" if v < 1.0 else "  ⚠ 경계가 번져 있다"}')
    else:
        print('   → 🔴 극소점이 없다 = 칸 격자가 없다 (부드럽게 칠한 그림이다)')
    return out


def _phase_std(rgb, on, p, off):
    """칸 크기 p · 위상 off 로 잘랐을 때 블록 안쪽 색이 얼마나 흔들리나."""
    tot, n = 0.0, 0
    for x in range(off, rgb.shape[1] - p + 1, p):
        sel = on[:, x:x + p].all(axis=1)
        if not sel.any():
            continue
        blk = rgb[:, x:x + p, :][sel]
        tot += blk.std(axis=1).sum()
        n += blk.shape[0] * 3
    return tot / max(n, 1)


if __name__ == '__main__':
    for path in sys.argv[1:]:
        grid_fit(path)
