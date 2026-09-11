"""원화 PNG → 게임용 WebP 굽기.

근거: `WORK_ORDER_ART_PHASE1_5.md` 2-A절 · `docs/art/RUNTIME_ASSET_SPEC.md`

하는 것은 둘뿐이다 — **알파 250↑ → 255 스냅**, **무손실 WebP 굽기**.

⛔ **크기를 건드리지 않는다.** 원화는 7px(캐릭터)·2px(배경) 정사각 블록으로
그려져 있어 정수배가 아닌 배율로 리샘플하면 그 격자가 깨진다. 화면에
맞추는 축소는 런타임이 `FilterQuality.none` 으로 한다.
(앞 지시서의 「크롭 + 몸 높이 정규화」는 폐기됐다 — 격자가 깨졌다)

⛔ 팔레트 근사 · 포스터라이즈 · 색 수 제한 · 외곽선 추가 · 알파 이진화도 안 한다.

쓰는 법:
    python tool/bake_art.py <원본png> <결과webp>
    python tool/bake_art.py --check <webp...>      # 굽지 않고 규격만 잰다
"""

import sys
from collections import Counter
from PIL import Image

# 콘솔이 cp949 라도 한글이 깨지지 않게 (Windows)
sys.stdout.reconfigure(encoding='utf-8')

ALPHA_CROP = 16       # 실루엣 문턱값
ALPHA_SNAP = 250      # 이 값 이상은 255로


def bake(src_path, dst_path):
    im = Image.open(src_path).convert('RGBA')
    r, g, b, a = im.split()
    # 원화 알파 최대가 253~254라 그대로 두면 배경이 비친다
    a = a.point(lambda v: 255 if v >= ALPHA_SNAP else v)
    Image.merge('RGBA', (r, g, b, a)).save(
        dst_path, 'WEBP', lossless=True, method=6)


def run_mode(im):
    """가로 방향으로 같은 화소가 몇 칸씩 이어지는지 재 최빈값을 낸다.

    원화가 N px 정사각 블록으로 그려졌으면 최빈값이 N 이고 모든 런이 N 의
    배수다. 어딘가에서 리샘플하면 이 값이 무너진다 (지시서 3절 검산 2).
    """
    px = im.load()
    w, h = im.size
    lens = Counter()
    for y in range(h):
        run, prev = 0, None
        for x in range(w):
            c = px[x, y]
            if c == prev:
                run += 1
            else:
                if prev is not None and prev[3] >= ALPHA_CROP:
                    lens[run] += 1
                run, prev = 1, c
        if prev is not None and prev[3] >= ALPHA_CROP:
            lens[run] += 1
    mode = lens.most_common(1)[0][0]
    total = sum(lens.values())
    ok = sum(n for L, n in lens.items() if L % mode == 0)
    return mode, ok / total


def report(path):
    """구운 결과를 다시 열어 규격을 잰다 (지시서 3절 검산 1~4)."""
    im = Image.open(path).convert('RGBA')
    a = im.split()[3]
    box = a.point(lambda v: 255 if v >= ALPHA_CROP else 0).getbbox()
    hist = a.histogram()
    mode, ratio = run_mode(im)
    print(f'{path}: {im.size[0]}x{im.size[1]}')
    if box:
        x0, y0, x1, y1 = box
        print(f'  실루엣 {x1 - x0}x{y1 - y0} · 중심 x {(x0 + x1 - 1) / 2} '
              f'· 발바닥 y {y1 - 1}')
    print(f'  런 최빈값 {mode}px — 배수 비율 {ratio:.1%}')
    print(f'  알파 1~249 화소 {sum(hist[1:250])} · a=255 {hist[255]}')
    print(f'  고유색 {len(im.getcolors(maxcolors=1 << 24))}')


if __name__ == '__main__':
    if sys.argv[1] == '--check':
        for p in sys.argv[2:]:
            report(p)
    else:
        bake(sys.argv[1], sys.argv[2])
        report(sys.argv[2])
