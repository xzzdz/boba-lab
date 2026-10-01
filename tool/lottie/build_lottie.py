#!/usr/bin/env python3
"""Builds Boba Lab's Lottie animations from code.

The LottieFiles MCP servers were not connected while the app was built, so
every animation here is assembled from shape layers using the Soft Clay
palette and motion tokens (signature ease-out-back, gravity for falling
things, sine for loops). Swap any file for a LottieFiles-made one later; the
app only depends on the file names.

    python tool/lottie/build_lottie.py
"""

import json
import math
import random
from pathlib import Path

OUT = Path(__file__).resolve().parents[2] / "assets" / "lottie"
FR = 60


def rgba(hex_color, alpha=1.0):
    h = hex_color.lstrip("#")
    return [round(int(h[i:i + 2], 16) / 255, 4) for i in (0, 2, 4)] + [alpha]


C = {
    "primary": rgba("#7C3AED"),
    "deep": rgba("#6D28D9"),
    "ink": rgba("#5B21B6"),
    "text": rgba("#332F3A"),
    "lavender": rgba("#C4B5FD"),
    "rim": rgba("#A78BFA"),
    "tint": rgba("#F3E8FF"),
    "pink": rgba("#DB2777"),
    "straw": rgba("#F9A8D4"),
    "milk": rgba("#C99A6E"),
    "pearl": rgba("#2A1A12"),
    "foam": rgba("#FFF3DA"),
    "white": rgba("#FFFFFF"),
    "green": rgba("#10B981"),
    "mint": rgba("#34D399"),
    "yellow": rgba("#F6C453"),
    "orange": rgba("#F59E0B"),
    "sky": rgba("#60A5FA"),
}

# Bezier easing (x1, y1, x2, y2), the same curves as lib/core/motion/motion.dart.
EASE = {
    "sig": (0.34, 1.56, 0.64, 1.0),
    "out": (0.2, 0.0, 0.0, 1.0),
    "in": (0.4, 0.0, 1.0, 1.0),
    "inout": (0.45, 0.0, 0.55, 1.0),
    "sine": (0.37, 0.0, 0.63, 1.0),
    "gravity": (0.55, 0.0, 1.0, 0.45),
    "lin": (0.0, 0.0, 1.0, 1.0),
}


# ---------------------------------------------------------------- properties

def static(value):
    return {"a": 0, "k": value}


def anim(*frames):
    """Keyframes from (t, value, ease) tuples; ease shapes the segment that
    starts at that key. A later key at the same time replaces the earlier one."""
    cleaned = []
    for frame in frames:
        if cleaned and cleaned[-1][0] == frame[0]:
            cleaned[-1] = frame
        else:
            cleaned.append(frame)
    keys = []
    for i, frame in enumerate(cleaned):
        t, value = int(frame[0]), frame[1]
        ease = frame[2] if len(frame) > 2 else "inout"
        key = {"t": t, "s": list(value) if isinstance(value, (list, tuple)) else [value]}
        if i < len(cleaned) - 1:
            if ease == "hold":
                key["h"] = 1
            else:
                x1, y1, x2, y2 = EASE[ease]
                key["o"] = {"x": [x1], "y": [y1]}
                key["i"] = {"x": [x2], "y": [y2]}
        keys.append(key)
    return {"a": 1, "k": keys}


def prop(value):
    if isinstance(value, dict):
        return value
    return static(list(value) if isinstance(value, tuple) else value)


def vec3(value, z):
    """Layer transforms are 3D; pad 2D values with z."""
    if isinstance(value, dict):
        for key in value["k"]:
            if len(key["s"]) == 2:
                key["s"].append(z)
        return value
    return static([value[0], value[1], z])


# -------------------------------------------------------------------- shapes

def ellipse(size, pos=(0, 0)):
    return {"ty": "el", "nm": "Ellipse", "d": 1, "p": prop(pos), "s": prop(size)}


def rect(size, pos=(0, 0), r=0):
    return {"ty": "rc", "nm": "Rect", "d": 1, "p": prop(pos), "s": prop(size), "r": prop(r)}


def path(vertices, ins=None, outs=None, closed=True):
    n = len(vertices)
    return {
        "ty": "sh",
        "nm": "Path",
        "d": 1,
        "ks": static({"c": closed, "v": vertices, "i": ins or [[0, 0]] * n, "o": outs or [[0, 0]] * n}),
    }


def line(a, b):
    return path([list(a), list(b)], closed=False)


def fill(color, opacity=100):
    return {"ty": "fl", "nm": "Fill", "c": static(color), "o": prop(opacity), "r": 1, "bm": 0}


def stroke(color, width, opacity=100):
    return {"ty": "st", "nm": "Stroke", "c": static(color), "o": prop(opacity), "w": prop(width), "lc": 2, "lj": 2, "ml": 4, "bm": 0}


def trim(end, start=0):
    return {"ty": "tm", "nm": "Trim", "s": prop(start), "e": prop(end), "o": static(0), "m": 1}


def group(name, items, p=(0, 0), a=(0, 0), s=(100, 100), r=0, o=100):
    transform = {
        "ty": "tr",
        "nm": "Transform",
        "p": prop(p),
        "a": prop(a),
        "s": prop(s),
        "r": prop(r),
        "o": prop(o),
        "sk": static(0),
        "sa": static(0),
    }
    return {"ty": "gr", "nm": name, "it": items + [transform], "np": len(items), "cix": 2, "bm": 0}


def _sub(a, b):
    return [a[0] - b[0], a[1] - b[1]]


def _add(a, b):
    return [a[0] + b[0], a[1] + b[1]]


def _mul(a, k):
    return [a[0] * k, a[1] * k]


def _len(a):
    return math.hypot(a[0], a[1])


def rounded(points, radii):
    """Closed polygon with rounded corners (cubic approximation)."""
    vs, ins, outs = [], [], []
    n = len(points)
    for k, p in enumerate(points):
        r = radii[k] if isinstance(radii, (list, tuple)) else radii
        if r <= 0:
            vs.append(list(p))
            ins.append([0, 0])
            outs.append([0, 0])
            continue
        a, b = points[k - 1], points[(k + 1) % n]
        da, db = _sub(a, p), _sub(b, p)
        la, lb = min(r, _len(da) / 2), min(r, _len(db) / 2)
        p1 = _add(p, _mul(da, la / _len(da)))
        p2 = _add(p, _mul(db, lb / _len(db)))
        vs += [p1, p2]
        ins += [[0, 0], _mul(_sub(p, p2), 0.55)]
        outs += [_mul(_sub(p, p1), 0.55), [0, 0]]
    return path(vs, ins, outs)


def star4(r_out, r_in):
    pts = []
    for k in range(8):
        angle = math.pi / 4 * k - math.pi / 2
        r = r_out if k % 2 == 0 else r_in
        pts.append([r * math.cos(angle), r * math.sin(angle)])
    return rounded(pts, [1.2 if k % 2 == 0 else 0 for k in range(8)])


# ------------------------------------------------------------------- the cup
# Same cup as lib/features/cup/cup_painter.dart, with the origin at the
# bottom centre so scaling grows it from its base.

CUP = [(-58, -158), (58, -158), (46, 0), (-46, 0)]
CUP_R = [2, 2, 9, 9]
LIQUID = [(-54.5, -136), (54.5, -136), (43.5, -3), (-43.5, -3)]
LIQUID_R = [0, 0, 7, 7]


def straw_group():
    return group("straw", [line((22, -188), (6, -42)), stroke(C["straw"], 11)])


def lid_group():
    return group("lid", [rect((124, 8), (0, -160), 4), fill(C["lavender"])])


def front_groups():
    return [
        group("shine", [line((-46, -144), (-37.5, -24)), stroke(C["white"], 5, 60)]),
        group("rim", [rounded(CUP, CUP_R), stroke(C["rim"], 3.5), fill(C["white"], 30)]),
    ]


def back_group():
    return group("back", [rounded(CUP, CUP_R), fill(C["white"], 55)])


def liquid_group(color=None, s=(100, 100)):
    return group("liquid", [rounded(LIQUID, LIQUID_R), fill(color or C["milk"])], s=s)


def pearl_items(r=7, center=(0, 0)):
    """A pearl whose bottom sits on `center`, so scaling squashes it down."""
    cx, cy = center
    return [
        group("shine", [ellipse((r * 0.5, r * 0.5), (cx - r * 0.3, cy - r * 1.35)), fill(C["white"], 45)]),
        ellipse((r * 2, r * 2), (cx, cy - r)),
        fill(C["pearl"]),
    ]


def cup_glyph(color, width):
    """Small outlined cup for stamps and badges."""
    return group(
        "cup glyph",
        [
            line((-14, -15), (14, -15)),
            line((4, -15), (9, -25)),
            rounded([(-12, -15), (12, -15), (9, 13), (-9, 13)], [0, 0, 3, 3]),
            stroke(color, width),
        ],
    )


def check_mark(size, color, width, end=100):
    """One polyline, so a trim draws it stroke by stroke."""
    k = size / 34
    tick = path([[-17 * k, 1 * k], [-4 * k, 14 * k], [17 * k, -11 * k]], closed=False)
    return group("check", [tick, trim(end), stroke(color, width)])


def check_badge(d):
    return [check_mark(d * 0.5, C["white"], d * 0.13), group("disc", [ellipse((d, d)), fill(C["green"])])]


# --------------------------------------------------------------------- comps

class Comp:
    def __init__(self, name, w, h, frames):
        self.name, self.w, self.h, self.op = name, w, h, frames
        self.layers = []

    def add(self, name, shapes, p=(0, 0), a=(0, 0), s=(100, 100), r=0, o=100):
        """Adds a layer below the ones already added (first added = on top)."""
        self.layers.append({
            "ddd": 0,
            "ind": len(self.layers) + 1,
            "ty": 4,
            "nm": name,
            "sr": 1,
            "ks": {"o": prop(o), "r": prop(r), "p": vec3(p, 0), "a": vec3(a, 0), "s": vec3(s, 100)},
            "ao": 0,
            "shapes": shapes,
            "ip": 0,
            "op": self.op,
            "st": 0,
            "bm": 0,
        })

    def shadow(self, center, width, scale=None):
        self.add("shadow", [group("shadow", [ellipse((width, width * 0.15)), fill(C["primary"], 14)])], p=center, s=scale or (100, 100))

    def save(self):
        doc = {
            "v": "5.7.4",
            "fr": FR,
            "ip": 0,
            "op": self.op,
            "w": self.w,
            "h": self.h,
            "nm": self.name,
            "ddd": 0,
            "assets": [],
            "layers": self.layers,
        }
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / f"{self.name}.json").write_text(json.dumps(doc, separators=(",", ":")), encoding="utf-8")
        return self.name


def sampled(fn, start, end, step):
    """Linear keyframes sampled from fn(t) — for loops that must wrap cleanly."""
    frames = [(t, fn(t), "lin") for t in range(start, end, step)]
    frames.append((end, fn(end)))
    return anim(*frames)


# ------------------------------------------------------------- animations

def splash_logo():
    c = Comp("splash_logo", 240, 240, 110)
    base = (120, 205)
    c.add("straw", [straw_group()], p=anim((0, (120, 135), "hold"), (34, (120, 135), "sig"), (52, base)),
          o=anim((0, 0, "hold"), (34, 0, "lin"), (38, 100)))
    c.add("lid", [lid_group()], p=anim((0, (120, 175), "hold"), (24, (120, 175), "sig"), (40, base)),
          o=anim((0, 0, "hold"), (24, 0, "lin"), (28, 100)))
    grow = anim((0, (0, 0), "sig"), (20, (100, 100)))
    c.add("front", front_groups(), p=base, s=grow)
    for k, (x, rest) in enumerate([(102, 200), (121, 202), (139, 201)]):
        t0 = 44 + 7 * k
        c.add(
            f"pearl {k}",
            [group("pearl", pearl_items())],
            p=anim((0, (x, 55), "hold"), (t0, (x, 55), "gravity"), (t0 + 16, (x, rest))),
            s=anim((0, (90, 112), "hold"), (t0 + 15, (90, 112), "lin"), (t0 + 17, (124, 80), "sig"), (t0 + 30, (100, 100))),
            o=anim((0, 0, "hold"), (t0, 0, "lin"), (t0 + 3, 100)),
        )
    c.add("liquid", [liquid_group()], p=base, s=anim((0, (100, 0), "hold"), (12, (100, 0), "out"), (40, (100, 100))))
    c.add("back", [back_group()], p=base, s=anim((0, (0, 0), "sig"), (20, (100, 100))))
    return c.save()


def loading_pearls():
    c = Comp("loading_pearls", 120, 48, 60)
    for k, x in enumerate([36, 60, 84]):
        d = 8 * k
        c.add(
            f"pearl {k}",
            [group("pearl", pearl_items())],
            p=anim((0, (x, 42), "hold"), (d, (x, 42), "out"), (d + 14, (x, 22), "in"), (d + 28, (x, 42), "hold"), (60, (x, 42))),
            s=anim((0, (100, 100), "hold"), (d + 27, (100, 100), "lin"), (d + 29, (120, 82), "out"), (d + 38, (100, 100), "hold"), (60, (100, 100))),
        )
    return c.save()


def success_check():
    c = Comp("success_check", 200, 200, 72)
    center = (100, 100)
    c.add("check", [check_mark(44, C["white"], 13, end=anim((0, 0, "hold"), (14, 0, "out"), (32, 100)))], p=center)
    c.add("disc", [group("disc", [ellipse((100, 100)), fill(C["green"])])], p=center, s=anim((0, (0, 0), "sig"), (20, (100, 100))))
    c.add(
        "ring",
        [group("ring", [
            ellipse(anim((0, (96, 96), "hold"), (8, (96, 96), "out"), (32, (178, 178)))),
            stroke(C["green"], 4, anim((0, 0, "hold"), (8, 70, "out"), (32, 0))),
        ])],
        p=center,
    )
    colors = [C["pink"], C["primary"], C["yellow"], C["mint"]]
    for k in range(8):
        angle = math.pi / 4 * k - math.pi / 2
        near = (100 + 44 * math.cos(angle), 100 + 44 * math.sin(angle))
        far = (100 + 90 * math.cos(angle), 100 + 90 * math.sin(angle))
        c.add(
            f"dot {k}",
            [group("dot", [ellipse((10, 10)), fill(colors[k % 4])])],
            p=anim((0, near, "hold"), (10, near, "out"), (30, far)),
            s=anim((0, (0, 0), "hold"), (10, (100, 100), "lin"), (22, (100, 100), "in"), (34, (0, 0))),
        )
    return c.save()


def confetti():
    c = Comp("confetti", 390, 640, 150)
    rnd = random.Random(7)
    palette = [C["primary"], C["pink"], C["lavender"], C["yellow"], C["mint"], C["orange"], C["sky"], C["straw"]]

    def piece(k):
        kind = rnd.choice(["rect", "rect", "dot", "pearl"])
        if kind == "rect":
            return group("piece", [rect((12, 6), r=1.5), fill(rnd.choice(palette))])
        if kind == "dot":
            return group("piece", [ellipse((8, 8)), fill(rnd.choice(palette))])
        return group("piece", pearl_items(r=4.5, center=(0, 4.5)))

    def tumble(t0, t_end):
        frames, t, wide = [], t0, True
        while t < t_end:
            frames.append((t, (100, 100 if wide else 25), "sine"))
            t += 20
            wide = not wide
        frames.append((t_end, (100, 100)))
        return anim(*frames)

    for k in range(24):  # burst from the middle, then fall
        t0 = rnd.randint(1, 6)  # frame 0 stays empty: it is the still frame for reduced motion
        start = (195 + rnd.uniform(-12, 12), 250)
        apex = (195 + rnd.uniform(-175, 175), 250 - rnd.uniform(90, 230))
        t_apex = t0 + rnd.randint(16, 22)
        t_end = min(150, t_apex + rnd.randint(80, 115))
        end = (apex[0] + rnd.uniform(-40, 40), 690)
        rot = rnd.uniform(0, 360)
        c.add(
            f"burst {k}",
            [piece(k)],
            p=anim((0, start, "hold"), (t0, start, "out"), (t_apex, apex, "gravity"), (t_end, end)),
            r=anim((t0, rot, "lin"), (t_end, rot + rnd.choice([-1, 1]) * rnd.uniform(360, 900))),
            s=tumble(t0, t_end),
            o=anim((0, 0, "hold"), (t0, 100, "hold"), (t_end - 12, 100, "lin"), (t_end, 0)),
        )
    for k in range(12):  # light rain from the top
        t0 = rnd.randint(4, 40)
        t_end = min(150, t0 + rnd.randint(100, 140))
        x = rnd.uniform(10, 380)
        sway = rnd.uniform(14, 28)
        frames = [(0, (x, -20), "hold")]
        t = t0
        while t < t_end:
            progress = (t - t0) / (t_end - t0)
            frames.append((t, (x + sway * math.sin(progress * 6), -20 + 710 * progress), "lin"))
            t += 15
        frames.append((t_end, (x, 690)))
        c.add(
            f"rain {k}",
            [piece(k)],
            p=anim(*frames),
            r=anim((t0, rnd.uniform(0, 360), "lin"), (t_end, rnd.uniform(400, 800))),
            s=tumble(t0, t_end),
            o=anim((0, 0, "hold"), (t0, 100, "hold"), (t_end - 10, 100, "lin"), (t_end, 0)),
        )
    return c.save()


def empty_cup():
    c = Comp("empty_cup", 200, 200, 120)
    roll = group("pearl", pearl_items(r=9), p=anim((0, (14, -4), "sine"), (60, (-14, -4), "sine"), (120, (14, -4))))
    c.add(
        "cup",
        [straw_group(), lid_group(), *front_groups(), roll, back_group()],
        p=(100, 180),
        s=(62, 62),
        r=anim((0, -5, "sine"), (60, 5, "sine"), (120, -5)),
    )
    c.shadow((100, 184), 120, scale=anim((0, (100, 100), "sine"), (60, (90, 100), "sine"), (120, (100, 100))))
    return c.save()


def stamp():
    c = Comp("stamp", 120, 120, 40)
    center = (60, 60)
    c.add(
        "stamp",
        [
            cup_glyph(C["white"], 3.5),
            group("inner ring", [ellipse((60, 60)), stroke(C["white"], 2, 60)]),
            group("disc", [ellipse((76, 76)), fill(C["pink"])]),
        ],
        p=center,
        s=anim((0, (170, 170), "in"), (9, (92, 92), "out"), (17, (105, 105), "inout"), (26, (100, 100))),
        r=anim((0, -20, "in"), (9, 0)),
        o=anim((0, 0, "lin"), (4, 100)),
    )
    c.add(
        "ink ring",
        [group("ring", [
            ellipse(anim((0, (72, 72), "hold"), (9, (72, 72), "out"), (28, (120, 120)))),
            stroke(C["pink"], 3, anim((0, 0, "hold"), (9, 60, "out"), (28, 0))),
        ])],
        p=center,
    )
    for k in range(6):
        angle = math.pi / 3 * k + math.pi / 6
        near = (60 + 36 * math.cos(angle), 60 + 36 * math.sin(angle))
        far = (60 + 56 * math.cos(angle), 60 + 56 * math.sin(angle))
        c.add(
            f"dot {k}",
            [group("dot", [ellipse((7, 7)), fill(C["pink"] if k % 2 else C["primary"])])],
            p=anim((0, near, "hold"), (9, near, "out"), (24, far)),
            s=anim((0, (0, 0), "hold"), (9, (100, 100), "lin"), (18, (100, 100), "in"), (28, (0, 0))),
        )
    return c.save()


def float_y(x, y, amount, op):
    return anim((0, (x, y), "sine"), (op // 2, (x, y - amount), "sine"), (op, (x, y)))


def status_received():
    c = Comp("status_received", 160, 160, 120)
    c.add("badge", [group("badge", check_badge(36))], p=(110, 108),
          s=anim((0, (100, 100), "sine"), (60, (110, 110), "sine"), (120, (100, 100))))
    bars = [group(f"bar {k}", [rect((w, 7), (-20 + w / 2, y), 3.5), fill(C["lavender"])]) for k, (w, y) in enumerate([(40, -20), (32, -6), (22, 8)])]
    c.add("paper", [*bars, group("paper", [rect((70, 88), r=12), stroke(C["rim"], 3), fill(C["white"])])], p=float_y(76, 80, 6, 120))
    c.shadow((78, 138), 76, scale=anim((0, (100, 100), "sine"), (60, (88, 100), "sine"), (120, (100, 100))))
    return c.save()


def status_brewing():
    c = Comp("status_brewing", 160, 160, 120)
    for k, x0 in enumerate([68, 88, 76, 94]):
        def state(t, k=k, x0=x0):
            local = (t - 30 * k) % 120
            if local > 60:
                return None
            return local / 60

        def pos(t, x0=x0, state=state):
            p = state(t)
            p = 0 if p is None else p
            return (x0 + 6 * math.sin(p * 2 * math.pi), 60 - 50 * p ** 0.85)

        def opacity(t, state=state):
            p = state(t)
            if p is None:
                return 0
            if p < 0.15:
                return p / 0.15 * 100
            if p > 0.7:
                return max(0, (1 - p) / 0.3 * 100)
            return 100

        def scale(t, state=state):
            p = state(t)
            p = 0 if p is None else p
            return (60 + 40 * p, 60 + 40 * p)

        d = [10, 7, 12, 8][k]
        c.add(
            f"bubble {k}",
            [group("bubble", [ellipse((d, d)), stroke(C["rim"], 1.5), fill(C["white"], 90)])],
            p=sampled(pos, 0, 120, 6),
            o=sampled(opacity, 0, 120, 6),
            s=sampled(scale, 0, 120, 6),
        )
    c.add(
        "cup",
        [straw_group(), lid_group(), *front_groups(),
         liquid_group(s=anim((0, (100, 96), "sine"), (60, (100, 100), "sine"), (120, (100, 96)))), back_group()],
        p=(80, 146),
        s=(55, 55),
    )
    c.shadow((80, 148), 70)
    return c.save()


def status_ready():
    c = Comp("status_ready", 160, 160, 120)
    for k, ((x, y), color, t0) in enumerate([((38, 54), C["yellow"], 8), ((124, 44), C["pink"], 44), ((130, 98), C["primary"], 80)]):
        c.add(
            f"sparkle {k}",
            [group("sparkle", [star4(11, 3), fill(color)])],
            p=(x, y),
            s=anim((0, (0, 0), "hold"), (t0, (0, 0), "sig"), (t0 + 14, (100, 100), "in"), (t0 + 34, (0, 0), "hold"), (120, (0, 0))),
            r=anim((t0, 0, "lin"), (t0 + 34, 90)),
        )
    pearls = [group(f"pearl {k}", pearl_items(r=7, center=(x, -4))) for k, x in enumerate([-28, -14, 0, 14, 28])]
    c.add(
        "cup",
        [straw_group(), lid_group(), *front_groups(), *pearls, liquid_group(), back_group()],
        p=anim((0, (80, 146), "out"), (10, (80, 136), "in"), (20, (80, 146), "hold"), (120, (80, 146))),
        s=anim((0, (55, 55), "hold"), (19, (55, 55), "lin"), (21, (61, 49), "sig"), (34, (55, 55), "hold"), (120, (55, 55))),
    )
    c.shadow((80, 148), 70, scale=anim((0, (100, 100), "out"), (10, (84, 100), "in"), (20, (100, 100), "hold"), (120, (100, 100))))
    return c.save()


def status_done():
    c = Comp("status_done", 160, 160, 90)
    c.add("badge", [group("badge", check_badge(38))], p=(112, 98),
          s=anim((0, (0, 0), "hold"), (16, (0, 0), "sig"), (30, (100, 100))))
    handle = path([[-16, -72], [0, -90], [16, -72]], ins=[[0, 0], [-10, 0], [0, -10]], outs=[[0, -10], [10, 0], [0, 0]], closed=False)
    c.add(
        "bag",
        [
            group("handle", [handle, stroke(C["rim"], 4)]),
            group("logo", [cup_glyph(C["primary"], 3)], p=(0, -34), s=(70, 70)),
            group("bag", [rect((72, 76), (0, -38), 12), stroke(C["rim"], 3.5), fill(C["tint"])]),
        ],
        p=anim((0, (76, 142), "out"), (10, (76, 132), "in"), (20, (76, 142))),
        s=anim((0, (100, 100), "hold"), (19, (100, 100), "lin"), (21, (108, 92), "sig"), (32, (100, 100))),
    )
    c.shadow((78, 144), 80)
    return c.save()


def onboard_build():
    c = Comp("onboard_build", 280, 280, 200)
    base = (140, 262)
    fade = ((170, 100, "lin"), (184, 0, "hold"), (200, 0))
    c.add("front", [straw_group(), lid_group(), *front_groups()], p=base)
    c.add(
        "foam",
        [group("foam", [rect((106, 24), (0, -138), 10), fill(C["foam"])], a=(0, -150), p=(0, -150),
               s=anim((0, (100, 0), "hold"), (96, (100, 0), "sig"), (116, (100, 100), "hold"), (170, (100, 100), "in"), (184, (100, 0), "hold"), (200, (100, 0))))],
        p=base,
    )
    for k, (dx, ice_rot) in enumerate([(-26, -12), (2, 9), (26, -5)]):
        t0 = 66 + 8 * k
        land = (140 + dx, 262 - 118 + (k % 2) * 8)
        c.add(
            f"ice {k}",
            [group("ice", [rect((24, 24), r=6), stroke(C["white"], 1.5, 90), fill(C["white"], 55)], r=ice_rot)],
            p=anim((0, (land[0], land[1] - 34), "hold"), (t0, (land[0], land[1] - 34), "sig"), (t0 + 22, land)),
            o=anim((0, 0, "hold"), (t0, 0, "lin"), (t0 + 5, 100, "hold"), *fade),
        )
    for k, dx in enumerate([-26, -12, 2, 16, -5]):
        t0 = 12 + 9 * k
        land_y = 258 if k < 4 else 245
        start = (140 + dx, 120)
        c.add(
            f"pearl {k}",
            [group("pearl", pearl_items(r=8))],
            p=anim((0, start, "hold"), (t0, start, "gravity"), (t0 + 18, (start[0], land_y))),
            s=anim((0, (90, 112), "hold"), (t0 + 17, (90, 112), "lin"), (t0 + 19, (124, 80), "sig"), (t0 + 32, (100, 100))),
            o=anim((0, 0, "hold"), (t0, 0, "lin"), (t0 + 3, 100, "hold"), *fade),
        )
    c.add("liquid", [liquid_group()], p=base)
    c.add("back", [back_group()], p=base)
    return c.save()


def onboard_order():
    c = Comp("onboard_order", 280, 280, 180)
    c.add("done", [group("badge", check_badge(40))], p=(196, 66),
          s=anim((0, (0, 0), "hold"), (76, (0, 0), "sig"), (92, (100, 100), "hold"), (150, (100, 100), "in"), (162, (0, 0), "hold"), (180, (0, 0))))
    c.add(
        "clock",
        [
            group("minute", [line((0, 0), (0, -14)), stroke(C["ink"], 3)], r=anim((0, 0, "lin"), (180, 360))),
            group("hour", [line((0, 0), (9, 0)), stroke(C["ink"], 3.5)]),
            group("face", [ellipse((46, 46)), stroke(C["rim"], 3), fill(C["white"])]),
        ],
        p=(78, 206),
    )
    c.add(
        "tap",
        [group("ripple", [
            ellipse(anim((0, (0, 0), "hold"), (40, (0, 0), "out"), (70, (96, 96)))),
            stroke(C["white"], 3, anim((0, 0, "hold"), (40, 90, "out"), (70, 0))),
        ])],
        p=(146, 196),
    )
    mini_cup = group("mini cup", [rounded([(-20, -26), (20, -26), (15, 22), (-15, 22)], [1, 1, 5, 5]), stroke(C["rim"], 3), fill(C["milk"])])
    c.add(
        "phone",
        [
            group("button", [rect((84, 28), (0, 56), 14), fill(C["primary"])]),
            group("cup", [mini_cup, group("lid", [rect((48, 6), (0, -29), 3), fill(C["lavender"])])], p=(0, -14)),
            group("notch", [rect((34, 7), (0, -84), 3.5), fill(C["text"], 18)]),
            group("body", [rect((128, 200), r=26), stroke(C["deep"], 4), fill(C["white"])]),
        ],
        p=float_y(146, 140, 5, 180),
    )
    c.shadow((146, 248), 120)
    return c.save()


def onboard_stamps():
    c = Comp("onboard_stamps", 280, 280, 200)
    out = ((172, (100, 100), "in"), (186, (0, 0), "hold"), (200, (0, 0)))
    c.add("free", [group("glyph", [cup_glyph(C["white"], 3.5)], s=(80, 80)), group("disc", [ellipse((48, 48)), fill(C["yellow"])])],
          p=(220, 84), s=anim((0, (0, 0), "hold"), (112, (0, 0), "sig"), (130, (100, 100), "hold"), *out),
          r=anim((0, -30, "hold"), (112, -30, "sig"), (130, 0)))
    slots = [(140 - 80 + 40 * (k % 5), 124 + 40 * (k // 5)) for k in range(10)]
    for k, (x, y) in enumerate(slots):
        t0 = 10 + 9 * k
        c.add(
            f"stamp {k}",
            [group("glyph", [cup_glyph(C["white"], 4)], s=(52, 52)), group("disc", [ellipse((30, 30)), fill(C["pink"])])],
            p=(x, y),
            s=anim((0, (0, 0), "hold"), (t0, (170, 170), "in"), (t0 + 7, (90, 90), "out"), (t0 + 13, (104, 104), "inout"), (t0 + 19, (100, 100), "hold"), *out),
        )
    c.add("slots", [group(f"slot {k}", [ellipse((30, 30), (x - 140, y - 144)), fill(C["white"], 28)]) for k, (x, y) in enumerate(slots)], p=(140, 144))
    c.add(
        "card",
        [
            group("title", [rect((74, 8), (-70, -44), 4), fill(C["white"], 55)]),
            group("card", [rect((236, 132), r=26), fill(C["primary"])]),
        ],
        p=(140, 144),
    )
    c.shadow((140, 222), 200)
    return c.save()


BUILDERS = [
    splash_logo, loading_pearls, success_check, confetti, empty_cup, stamp,
    status_received, status_brewing, status_ready, status_done,
    onboard_build, onboard_order, onboard_stamps,
]

if __name__ == "__main__":
    for build in BUILDERS:
        name = build()
        size = (OUT / f"{name}.json").stat().st_size
        print(f"{name:18} {size / 1024:6.1f} KB")
