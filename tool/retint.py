"""적 원화를 **계열 색**으로 다시 칠한다. (`ENEMY_FAMILIES.md` 2절)

## 왜 필요한가

받은 38종을 재 보니 **계열끼리 색이 거의 같았다** — 큰야수↔석상 5.5,
거구↔용마족 7.3 (Lab 거리, 25 아래면 작은 화면에서 헷갈린다).
화면에서 몬스터를 가르는 단서는 **실루엣과 색 둘뿐**인데 그 하나가 죽어 있었다.

**다시 그리지 않고 다시 칠한다.** 실루엣은 멀쩡하므로 색만 고치면 된다.

## 어떻게

1. **밝기는 그대로 둔다.** 명암을 지워 버리면 납작해진다
2. 밝기를 계열 색의 **어두운 끝 → 밝은 끝**으로 펼친다
3. 🔴 **악센트는 지킨다** — 눈·불씨처럼 **작고 채도 높은** 곳은 안 건드린다.
   보스 실루엣 연출이 눈에 기대고 있다 (`GAME_DESIGN.md` 6.7절 ②)

**악센트를 채도만으로 가르면 안 된다.** 슬라임처럼 **몸 자체가 채도 높은** 경우
몸까지 지켜져 아무것도 안 바뀐다. 그래서 **면적**으로 가른다 — 색상 띠가
그림의 [ACCENT_AREA] 보다 좁게 차지하면 악센트로 본다.

쓰는 법:
    python tool/retint.py <원본png> <결과png> <색 #RRGGBB>
    python tool/retint.py --all <원본디렉터리> <결과디렉터리>   # 계열표대로 일괄
"""

import json
import sys

import numpy as np
from PIL import Image

sys.stdout.reconfigure(encoding='utf-8')

ACCENT_AREA = 0.06   # 이보다 좁은 색상 띠는 악센트로 보고 지킨다
ACCENT_SAT = 0.45    # 악센트로 보려면 이만큼은 선명해야 한다
HUE_BINS = 24        # 색상환을 몇 칸으로 나눠 면적을 세나


def _hsv(rgb):
    mx = rgb.max(2)
    mn = rgb.min(2)
    v = mx
    s = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)
    d = np.maximum(mx - mn, 1e-6)
    r, g, b = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    h = np.where(mx == r, (g - b) / d % 6,
                 np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4)) / 6
    return h % 1.0, s, v


def accent_mask(rgb, alpha):
    """**작고 선명한** 색만 True. 몸통처럼 넓은 면은 악센트가 아니다."""
    h, s, _ = _hsv(rgb)
    body = alpha >= 0.5
    total = max(int(body.sum()), 1)
    keep = np.zeros_like(body)
    bins = (h * HUE_BINS).astype(int) % HUE_BINS
    for b in range(HUE_BINS):
        sel = body & (bins == b) & (s >= ACCENT_SAT)
        if 0 < sel.sum() <= total * ACCENT_AREA:
            keep |= sel
    return keep


def retint(src, target_hex):
    t = target_hex.lstrip('#')
    tgt = np.array([int(t[i:i + 2], 16) / 255 for i in (0, 2, 4)])
    a = np.asarray(Image.open(src).convert('RGBA')).astype(float) / 255
    rgb, alpha = a[:, :, :3], a[:, :, 3]
    lum = (rgb * [0.299, 0.587, 0.114]).sum(2, keepdims=True)
    # 🔴 **곱하기**로 입힌다. 밝기에 따라 더하는 방식은 밝은 쪽에서 흰색으로
    # 빠져 계열끼리 색이 다시 붙는다 (실측: 계열 간 거리 중앙값 33 → 26).
    ramp = np.clip(tgt * (0.30 + 1.45 * lum), 0, 1)
    keep = accent_mask(rgb, alpha)[:, :, None]
    out = np.where(keep, rgb, ramp)
    return Image.fromarray(
        (np.concatenate([np.clip(out, 0, 1), a[:, :, 3:4]], 2) * 255)
        .astype(np.uint8), 'RGBA')


def main(argv):
    if argv[1] == '--all':
        import os
        colors = json.load(open('art_raw/_compare/family_colors.json',
                                encoding='utf-8'))
        member = json.load(open('art_raw/_compare/family_members.json',
                                encoding='utf-8'))
        os.makedirs(argv[3], exist_ok=True)
        for name, fam in member.items():
            src = os.path.join(argv[2], f'{name}.png')
            if not os.path.exists(src):
                print(f'  없음: {name}')
                continue
            retint(src, colors[fam]).save(os.path.join(argv[3], f'{name}.png'))
        print(f'{len(member)}종 다시 칠했다 → {argv[3]}')
    else:
        retint(argv[1], argv[3]).save(argv[2])
        print(f'{argv[2]}: {argv[3]} 로 다시 칠했다')


if __name__ == '__main__':
    main(sys.argv)
