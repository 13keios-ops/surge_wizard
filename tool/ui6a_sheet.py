# -*- coding: utf-8 -*-
"""6-A 시안 시트 만들기 — 템플릿에 원화·폰트를 data URI 로 끼워 넣는다.

원화와 픽셀 폰트를 실제로 넣어야 「같은 게임처럼 보이나」를 판단할 수 있다.
폰트는 2.5 MB 짜리라 그대로 넣으면 안 되고, 시트에 실제로 쓰인 글자만
남기는 서브셋으로 줄인다 (보통 30 KB 아래로 떨어진다).

    python tool/ui6a_sheet.py
"""
import base64
import io
import re
from pathlib import Path

from PIL import Image
from fontTools import subset

ROOT = Path(__file__).resolve().parent.parent
SHEETS = [
    ("reports/img/ui6a/mockups.template.html", "reports/img/ui6a/mockups.html"),
    ("reports/img/ui6a/sizes.template.html", "reports/img/ui6a/sizes.html"),
    ("reports/img/ui6a/bg.template.html", "reports/img/ui6a/bg.html"),
]


def uri(data: bytes, mime: str) -> str:
    return f"data:{mime};base64,{base64.b64encode(data).decode()}"


def shrink(path: Path, width: int) -> str:
    """원화를 줄인다. 픽셀 격자가 흐려지지 않게 NEAREST 로 줄인다."""
    img = Image.open(path).convert("RGBA")
    if img.width > width:
        h = round(img.height * width / img.width)
        img = img.resize((width, h), Image.NEAREST)
    buf = io.BytesIO()
    img.save(buf, "WEBP", quality=82, method=6)
    return uri(buf.getvalue(), "image/webp")


def subset_font(path: Path, text: str) -> str:
    """시트에 실제로 쓰인 글자만 남긴다."""
    font = subset.load_font(str(path), subset.Options(layout_features=["*"]))
    opts = subset.Options(layout_features=["*"], notdef_outline=True)
    subsetter = subset.Subsetter(options=opts)
    subsetter.populate(text=text)
    subsetter.subset(font)
    buf = io.BytesIO()
    font.save(buf)
    font.close()
    return uri(buf.getvalue(), "font/ttf")


def build(tpl_rel: str, out_rel: str) -> None:
    tpl, out = ROOT / tpl_rel, ROOT / out_rel
    html = tpl.read_text(encoding="utf-8")

    # 템플릿에 등장하는 글자 전부 + 숫자·영문 (동적으로 만드는 문자열도 덮이게)
    chars = set(html) | set("0123456789/·−%dp")

    repl = {
        "{{BG}}": shrink(ROOT / "assets/art/bg/forest.webp", 512),
        "{{WIZ}}": shrink(ROOT / "assets/art/wizard/body_back.webp", 320),
        "{{FOE}}": shrink(ROOT / "assets/art/enemy/goblin_scout.webp", 320),
        "{{FONT11}}": subset_font(ROOT / "assets/fonts/Galmuri11.ttf", "".join(chars)),
        "{{FONT11B}}": subset_font(
            ROOT / "assets/fonts/Galmuri11-Bold.ttf", "".join(chars)),
        "{{FONT9}}": subset_font(ROOT / "assets/fonts/Galmuri9.ttf", "".join(chars)),
    }
    for key, val in repl.items():
        html = html.replace(key, val)

    left = re.findall(r"\{\{[A-Z0-9]+\}\}", html)
    if left:
        raise SystemExit(f"안 채운 자리가 남았다: {sorted(set(left))}")

    out.write_text(html, encoding="utf-8")
    print(f"{out.relative_to(ROOT)}  {out.stat().st_size / 1024:.0f} KB")


def main() -> None:
    for tpl_rel, out_rel in SHEETS:
        build(tpl_rel, out_rel)


if __name__ == "__main__":
    main()
