<div align="center">

<img src="assets/xshot.png" alt="XSHOT" width="900">

<br>

**screenshot beautifier for Termux**  
`v1.2.2` · `ImageMagick` · `inotify-tools` · `Android`

</div>

---

## Install

```bash
git clone https://github.com/X14OC14/XSHOT
bash XSHOT/install.sh
```

Installs dependencies, copies fonts to `~/.fonts/`, and sets up `/sdcard/xshot/pattern/` with the included pattern files.

### Fix PATH

If `xshot` isn't recognized after install:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

---

## Usage

```
xshot [mode] [theme] [optional]
```

### Mode

| Flag | Description |
|------|-------------|
| `-a` | Autoshot — watches screenshot folder, processes on arrival |
| `-m` | Manual — input a filename, process it once |
| `-wm` | Timestamp — stamps date/time onto camera photos |
| `-h` | Help |
| `-i` | Version info |

### Theme

| Flag | Description |
|------|-------------|
| `-l` | Light — white border, dark footer |
| `-d` | Dark — dark border, white footer |
| `-g` | Gradient — diagonal two-color background, no solid border |

### Optional

| Flag | Description |
|------|-------------|
| `-!` | Skip footer watermark |
| `-p` | Overlay pattern on background |

### Examples

```bash
xshot -a -d           # autoshot, dark
xshot -a -g           # autoshot, gradient
xshot -a -g -p        # autoshot, gradient + pattern overlay
xshot -a -d -p        # autoshot, dark + pattern overlay
xshot -a -d -!        # autoshot, dark, no watermark
xshot -m -g           # manual, gradient
xshot -wm             # timestamp camera photos
```

> **Note — Manual mode** outputs to a new file `filename_xshot.ext` and never overwrites the original.

---

## Configuration

Everything lives at the top of `xshot.sh` under `# CONFIG`.

### Colors

```bash
hex_color=(
  "#3d465c"  # [0] dark border
  "#1E222B"  # [1] titlebar bg
  "#F8F9FA"  # [2] light border
  "#000000"  # [3] shadow
  "#ffffff"  # [4] white
  "#59d6ff"  # [5] clock color (-wm)
  "#e6e6e6"  # [6] date color (-wm)
  "#38d13e"  # [7] green
)
```

### Gradient

```bash
grad_start="#5a1a1a"  # top-left
grad_end="#050505"    # bottom-right
grad_blur="0x20"      # softness — higher = more blurred
```

### Border & Shadow

```bash
border_size=50              # thickness in px
shadow_size="85x10+0+10"   # blur x sigma + offsetX + offsetY
```

### Pattern

```bash
pattern_png="/sdcard/xshot/pattern/yourfile.png"
```

Drop any PNG into `/sdcard/xshot/pattern/` and point `pattern_png` to it. The folder ships with a `.nomedia` file so nothing bleeds into the gallery.

### Watermark

```bash
footer_text=" Shot by Mafy | xiaocia.my.id"  # autoshot / manual
owner_info=" @re.xiaocia"                      # timestamp mode
footer_size=30
footer_xy="+0+15"
```

### Font

Drop a `.ttf` into `/sdcard/xshot/fonts/` (or `~/.fonts/`), then update the font name in `xshot.sh`:

```bash
-font JetBrains-Mono-Medium-Nerd-Font-Complete
```

### Screenshot Path

Default is `/sdcard/Pictures/Screenshot` — varies by device. Update if needed:

```bash
screenshots_path="/sdcard/Pictures/Screenshot"
```

To verify your path and event type:

```bash
inotifywait -m -e moved_to /sdcard/Pictures/Screenshot
```

Take a screenshot — if the filename appears, you're good. Android uses `moved_to` because it writes to a `.pending-` temp file before renaming.

---

## After Editing

```bash
cp /path/to/xshot.sh ~/.local/bin/xshot
```

---

## Repository Structure

```
XSHOT/
├── fonts/          # JetBrains Mono Nerd Font
├── pattern/        # PNG/SVG pattern files
├── xshot.sh        # main script
├── install.sh      # installer
└── README.md
```

---

<div align="center">
<sub>coded by Mafy · xiaocia.my.id</sub>
</div>
