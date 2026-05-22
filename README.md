# 📷 XSHOT

> A Termux tool to automatically beautify screenshots using ImageMagick.

---

## Installation

```bash
git clone https://github.com/X14OC14/XSHOT
cd XSHOT
bash install.sh
```

Automatically installs: `imagemagick`, `inotify-tools`, `bc`, and JetBrains Mono Nerd Font. Also copies `topo.png` to `/sdcard/topo.png` for use with the `-t` flag.

---

## Fix PATH

After installation, the `xshot` command may not be recognized. Run this once to fix it permanently:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Adjust Screenshot Path

The default path in `xshot.sh` is `/sdcard/Pictures/Screenshot`. This varies by device — update it to match yours:

```bash
screenshots_path="/sdcard/Pictures/Screenshot"   # adjust as needed
screenshots_backup="${screenshots_path}/backup"
```

To verify the correct path and event, test with:

```bash
inotifywait -m -e moved_to /sdcard/Pictures/Screenshot
```

Take a screenshot — if a filename appears in the output, the path and event are correct. Use `moved_to` instead of `create`, as Android writes to a `.pending-` temp file before renaming it to the final filename.

---

## Usage

```bash
xshot [mode] [theme] [optional]
```

| Mode | Description |
|------|-------------|
| `-a` | Autoshot — watches screenshot folder for new files |
| `-m` | Manual — process a specific file by name |
| `-wm` | Timestamp — adds time watermark to camera photos |
| `-h` | Show help |
| `-i` | Show version info |

| Theme | Description |
|-------|-------------|
| `-l` | Light theme |
| `-d` | Dark theme |
| `-g` | Gradient theme — diagonal two-color background |

| Optional | Description |
|----------|-------------|
| `-!` | Skip footer watermark |
| `-t` | Overlay topo pattern on background |

**Examples:**

```bash
xshot -a -d          # autoshot, dark theme
xshot -a -l          # autoshot, light theme
xshot -a -g          # autoshot, gradient theme
xshot -a -d -!       # autoshot, dark, no watermark
xshot -a -d -t       # autoshot, dark + topo overlay
xshot -a -g -t       # autoshot, gradient + topo overlay
xshot -m -d          # manual mode, dark theme
xshot -wm            # timestamp mode (camera photos)
```

---

## Customization

All configuration is at the top of `xshot.sh` under the `CONFIG` section.

### Watermark Text

```bash
footer_text=" Shot by Mafy | xiaocia.my.id"   # footer in autoshot/manual
owner_info=" @re.xiaocia"                       # name in timestamp mode (-wm)
```

### Font Size

```bash
footer_size=30            # footer text size
footer_size_time=30       # date/time text size
footer_size_timeStamp=55  # clock size in -wm mode
```

### Text Position

Offset format: `+X+Y`

```bash
footer_xy="+0+15"              # footer text position
footer_xy_time="+0+20"         # date/time position
footer_xy_timeStamp="+50+200"  # clock position in -wm
footer_xy_timeStamp2="+50+50"  # date position in -wm
```

### Colors

Footer color is set per theme — dark uses white, light uses black. To override, edit the `light()` and `dark()` functions in `xshot.sh`.

Image-level colors are defined in the `hex_color` array:

```bash
hex_color=(
  "#3d465c"  # [0] dark border
  "#1E222B"  # [1] titlebar background
  "#F8F9FA"  # [2] light border
  "#000000"  # [3] shadow color
  "#ffffff"  # [4] white
  "#59d6ff"  # [5] clock color in -wm
  "#e6e6e6"  # [6] date color in -wm
  "#38d13e"  # [7] green
)
```

### Gradient

Colors for the gradient theme (`-g`). Top-left to bottom-right:

```bash
grad_start="#5a1a1a"  # top-left color
grad_end="#050505"    # bottom-right color
grad_blur="0x20"      # blur intensity (higher = softer)
```

### Border & Shadow

```bash
border_size=50              # border thickness around image
shadow_size="85x10+0+10"   # format: blur x sigma + offsetX + offsetY
```

### Font

Replace the `.ttf` file in the `fonts/` folder, then update the font name in `xshot.sh`:

```bash
-font JetBrains-Mono-Medium-Nerd-Font-Complete
```

### Screenshot Paths

```bash
screenshots_path="/sdcard/Pictures/Screenshot"
camera_path="/sdcard/DCIM/Camera"
```

---

## After Editing

Every time you modify `xshot.sh`, copy it to `~/.local/bin/` to apply changes:

```bash
cp /path/to/xshot.sh ~/.local/bin/xshot
```
