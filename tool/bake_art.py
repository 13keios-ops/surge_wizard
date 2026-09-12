"""원화 PNG → 게임용 WebP 굽기.

근거: `WORK_ORDER_ART_PHASE1_5.md` 2-A절 · `docs/art/RUNTIME_ASSET_SPEC.md`

하는 것은 셋이다 — **알파 250↑ → 255 스냅**, **선택적 축소**, **무손실 WebP 굽기**.

> ## 🔴 2026-09-13 — **캐릭터 격자화를 뺐다** (검토 41 승인)
> 옛 주석은 「크기를 건드리지 않는다 — 격자가 깨진다」였다. **그 격자를 없앴다.**
>
> 참고 게임 실측에서 **지배적인 블록 크기가 없었고**(같은 색이 1px씩 53%),
> 우리는 228 물리픽셀 자리에 37칸만 내보내 **6.2배 거칠었다.**
> 원화가 모자란 것이 아니라 격자화가 버리고 있었다.
>
> 이제 캐릭터는 **`gridize` 를 거치지 않고 여기서 바로 줄인다.**
> 줄이는 것은 LANCZOS 이고, 런타임 보간도 `none` 이 아니라 부드러운 것을 쓴다.
> **배경은 예전 그대로다** (2px 블록을 유지한다).

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


FOOT = 477 / 512      # 발바닥이 놓이는 세로 비율 (art_sprite.dart kArtFootLine)
FILL = 0.86           # 실루엣의 긴 변이 캔버스에서 차지하는 비율


def normalize(im, size):
    """실루엣을 잘라내 [size] 정사각 캔버스에 **발바닥 기준으로** 다시 앉힌다.

    격자화(`gridize.py`)가 하던 두 가지 중 **자리 잡기만 남기고 양자화는 뺐다**
    (검토 41 승인). 양자화가 세부를 6배 깎고 있었다.

    긴 변을 기준으로 줄이므로 **넓고 낮은 몬스터**(슬라임·두꺼비)도 넘치지 않는다.
    """
    box = im.split()[3].point(lambda v: 255 if v >= ALPHA_CROP else 0).getbbox()
    if box is None:
        return im.resize((size, size), Image.LANCZOS)
    im = im.crop(box)
    r = size * FILL / max(im.size)
    im = im.resize((max(1, round(im.width * r)), max(1, round(im.height * r))),
                   Image.LANCZOS)
    out = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    out.paste(im, ((size - im.width) // 2, round(size * FOOT) - im.height))
    return out


def bake(src_path, dst_path, size=None):
    """[size]를 주면 그 정사각 캔버스에 **발바닥을 맞춰** 앉히고 줄여 굽는다.

    화면에 나가는 물리 픽셀보다 **두 배쯤 크게** 두면 충분하다 —
    일반 적 76dp × 3배 화면 = 228px 이므로 512 면 2.2배 여유다.
    """
    im = Image.open(src_path).convert('RGBA')
    if size is not None:
        im = normalize(im, size)
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
        size = int(sys.argv[3]) if len(sys.argv) > 3 else None
        bake(sys.argv[1], sys.argv[2], size)
        report(sys.argv[2])
