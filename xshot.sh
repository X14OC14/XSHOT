#!/usr/bin/env bash
# ─────────────────────────────────────────
#  xshot — screenshot beautifier for Termux
#  coded by Mafy | v1.2.1 | 22/05/2026
# ─────────────────────────────────────────

# ═════════════════════════════════════════
#  CONFIG
# ═════════════════════════════════════════

# ── Colors ────────────────────────────────
hex_color=(
  "#3d465c"  # [0] dark border
  "#1E222B"  # [1] titlebar / dark bg
  "#F8F9FA"  # [2] light border
  "#000000"  # [3] black / shadow
  "#ffffff"  # [4] white
  "#59d6ff"  # [5] blue (timestamp clock)
  "#e6e6e6"  # [6] gray (timestamp date)
  "#38d13e"  # [7] green
)

# ── Gradient ──────────────────────────────
grad_start="#5a1a1a"  # top-left color
grad_end="#050505"    # bottom-right color
grad_blur="0x20"      # blur intensity

# ── Border ────────────────────────────────
border_size=50
border_c_dark="${hex_color[0]}"
border_c_light="${hex_color[2]}"

# ── Shadow ────────────────────────────────
shadow_size="85x10+0+10"
shadow_color="${hex_color[3]}"

# ── Titlebar ──────────────────────────────
width_img=500
height_img=1000

# ── Footer / Watermark ────────────────────
footer_text=" Shot by Mafy | xiaocia.my.id"
footer_xy="+0+15"
footer_size=30
footer_xy_time="+0+20"
footer_size_time=30

# ── Timestamp Watermark ───────────────────
owner_info=" @re.xiaocia"
footer_xy_timeStamp="+50+200"
footer_xy_timeStamp2="+50+50"
footer_size_timeStamp=55
footer_color_timeStamp="${hex_color[5]}"
footer_color_timeStamp2="${hex_color[6]}"

# ── Paths ─────────────────────────────────
camera_path="/sdcard/DCIM/Camera"
camera_backup="${camera_path}/backup"
screenshots_path="/sdcard/Pictures/Screenshot"
screenshots_backup="${screenshots_path}/backup"
manual_backup="/sdcard/DCIM/backup"
topo_svg="/sdcard/topo.svg"
topo_png="/sdcard/topo.png"

# ═════════════════════════════════════════
#  TERMINAL COLORS  (jangan diubah)
# ═════════════════════════════════════════
o='\033[0m'
bl='\033[38;5;111m'   # soft blue
pk='\033[38;5;183m'   # soft pink-violet
wh='\033[38;5;253m'   # soft white
dm='\033[38;5;240m'   # dim gray
g='\033[38;5;114m'    # soft green (done)
r='\033[38;5;210m'    # soft red (failed)
y='\033[38;5;222m'    # soft yellow

# ─────────────────────────────────────────
#  Init
# ─────────────────────────────────────────

count=1
backup="yes"

check_format=(
  "${g}Done"
  "${r}Failed"
  "${g}Done"
  "${r}Failed"
)

if [[ ${type} = "MANUAL SHOT" ]]; then
  check_s=${check_format[2]}
  check_f=${check_format[3]}
else
  check_s=${check_format[0]}
  check_f=${check_format[1]}
fi

# create backup dirs if not exist
[[ ! -d ${screenshots_backup} ]] && mkdir -p "${screenshots_backup}"
[[ ! -d ${camera_backup} ]]      && mkdir -p "${camera_backup}"
[[ ! -d ${manual_backup} ]]      && mkdir -p "${manual_backup}"

# ─────────────────────────────────────────
#  Theme Functions
# ─────────────────────────────────────────

light() {
  color="LIGHT"
  titlebar_color=${hex_color[1]}
  border_color=${border_c_light}
  footer_color="${hex_color[3]}"  # hitam
  theme_mode="solid"
}

dark() {
  color="DARK"
  titlebar_color=${hex_color[1]}
  border_color=${border_c_dark}
  footer_color="${hex_color[4]}"  # putih
  theme_mode="solid"
}

gradient() {
  color="GRADIENT"
  titlebar_color=${hex_color[1]}
  footer_color="${hex_color[4]}"  # putih
  theme_mode="gradient"
}

# ─────────────────────────────────────────
#  Utility Functions
# ─────────────────────────────────────────

log() {
  echo -e "${dm}[${wh}$(date +'%H:%M:%S')${dm}]${o} $@"
}

prompt() {
  echo -e "$(log)${b}Please input file : ${y}"
}

check() {
  if [[ $? -eq 0 && ${PIPESTATUS[0]} -eq 0 ]]; then
    echo -e "   $(log)${check_s}"
  else
    echo -e "   $(log)${check_f}"
    exit 1
  fi
}

backup() {
  renamed=$(echo $file_name | sed "s/.jpg/_backup.jpg/g")
  chmod +x "${file}"
  cp "${file}" "${path_backup}/${renamed}"
}

next_count() {
  count=$(( ${count} + 1 ))
  echo -e "   ${r}[${y}${count}${r}]"
  echo -e "   $(log)${b}Waiting new file"
}

# ─────────────────────────────────────────
#  UI
# ─────────────────────────────────────────

print_ascii() {
  # smooth gradient: pink-violet → lavender → biru muda
  local colors=(148 149 150 151 152 153)
  local lines=(
    "██╗░░██╗░██████╗██╗░░██╗░█████╗░████████╗"
    "╚██╗██╔╝██╔════╝██║░░██║██╔══██╗╚══██╔══╝"
    "░╚███╔╝░╚█████╗░███████║██║░░██║░░░██║░░░"
    "░██╔██╗░░╚═══██╗██╔══██║██║░░██║░░░██║░░░"
    "██╔╝╚██╗██████╔╝██║░░██║╚█████╔╝░░░██║░░░"
    "╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░"
  )
  echo ""
  for (( i=0; i<${#lines[@]}; i++ )); do
    echo -e "\033[38;5;${colors[$i]}m${lines[$i]}\033[0m"
  done
}

header() {
  clear
  print_ascii
  echo -e "
\033[38;5;253m  ────────────────────────────────────────\033[0m
  \033[38;5;240mscreenshot beautifier for Termux\033[0m
\033[38;5;253m  ────────────────────────────────────────\033[0m

  \033[38;5;240mtype   \033[38;5;253m│\033[0m \033[38;5;111m${type}\033[0m
  \033[38;5;240mtheme  \033[38;5;253m│\033[0m \033[38;5;183m${color}\033[0m

\033[38;5;253m  ────────────────────────────────────────\033[0m
  \033[38;5;240mpress ctrl+c to stop\033[0m
"
}

help() {
  echo -e "
${wh}  ────────────────────────────────────────${o}
  ${bl}XSHOT${wh} — usage${o}
${wh}  ────────────────────────────────────────${o}

  ${dm}mode${o}
  ${wh}│${o} ${bl}-a${o}   autoshot (watch screenshot folder)
  ${wh}│${o} ${bl}-m${o}   manual input file
  ${wh}│${o} ${bl}-wm${o}  timestamp watermark for camera photos
  ${wh}│${o} ${bl}-h${o}   show this help
  ${wh}│${o} ${bl}-i${o}   show version info

  ${dm}theme${o}
  ${wh}│${o} ${pk}-l${o}   light
  ${wh}│${o} ${pk}-d${o}   dark
  ${wh}│${o} ${pk}-g${o}   gradient

  ${dm}optional${o}
  ${wh}│${o} ${dm}-!${o}   no watermark
  ${wh}│${o} ${dm}-t${o}   overlay topo pattern

  ${dm}examples${o}
  ${wh}│${o} xshot ${bl}-a ${pk}-d${o}
  ${wh}│${o} xshot ${bl}-a ${pk}-l ${dm}-!${o}
  ${wh}│${o} xshot ${bl}-a ${pk}-g${o}
  ${wh}│${o} xshot ${bl}-a ${pk}-g ${dm}-t${o}
  ${wh}│${o} xshot ${bl}-a ${pk}-d ${dm}-t${o}
${wh}  ────────────────────────────────────────${o}
"
}

program_info() {
  clear
  print_ascii
  echo -e "
\033[38;5;253m  ────────────────────────────────────────\033[0m
  \033[38;5;240mowner      \033[38;5;253m│\033[0m \033[38;5;111mMafy\033[0m
  \033[38;5;240mversion    \033[38;5;253m│\033[0m \033[38;5;183mv1.2.1\033[0m
  \033[38;5;240mbuilt      \033[38;5;253m│\033[0m 22/05/2026
  \033[38;5;240mplatform   \033[38;5;253m│\033[0m Termux + ImageMagick
\033[38;5;253m  ────────────────────────────────────────\033[0m
"
}

# ─────────────────────────────────────────
#  Core Functions
# ─────────────────────────────────────────

titlebar() {
  # macOS-style titlebar dots
  # original logic by arman
  gr="#27C93F"  # green dot
  yl="#FFBD2E"  # yellow dot
  rd="#FF5F56"  # red dot
  bl="#282C34"  # background

  rad=$( echo "0.0025 * ${width_img} * ${height_img} / 100" | bc )
  br=$( echo "${rad} * 5" | bc )
  x0=$( echo "${rad} * 3" | bc )
  y0=$( echo "${br} * 0.5" | bc )
  x1=$( echo "${x0} + ${rad}" | bc )

  declare -A arr=()
  for i in {0..2}; do
    arr[$i,0]=$x0
    arr[$i,1]=$y0
    arr[$i,2]=$x1
    arr[$i,3]=$y0
    x0=$( echo "${x0} + ${rad} * 3" | bc )
    x1=$( echo "${x0} + ${rad}" | bc )
  done

  if [[ "${add_on_img}" == "yes" ]]; then
    magick "$file" -fill $bl \
      -background ${titlebar_color} \
      -gravity north \
      -chop 0x$br \
      -splice 0x$br \
      -draw "fill ${rd} circle ${arr[0,0]},${arr[0,1]} ${arr[0,2]},${arr[0,3]}
             fill ${yl} circle ${arr[1,0]},${arr[1,1]} ${arr[1,2]},${arr[1,3]}
             fill ${gr} circle ${arr[2,0]},${arr[2,1]} ${arr[2,2]},${arr[2,3]}" \
      $file
  else
    magick $file -fill $bl \
      -background ${titlebar_color} \
      -gravity north -splice 0x$br \
      -draw "fill ${rd} circle ${arr[0,0]},${arr[0,1]} ${arr[0,2]},${arr[0,3]}
             fill ${yl} circle ${arr[1,0]},${arr[1,1]} ${arr[1,2]},${arr[1,3]}
             fill ${gr} circle ${arr[2,0]},${arr[2,1]} ${arr[2,2]},${arr[2,3]}" \
      $file
  fi
}

ss() {
  footer_time=" $(date +'%a %d.%h.%Y')  $(date +'%H:%M')"

  # apply rounded corners, shadow, and border/background frame
  if [[ "${theme_mode}" == "gradient" ]]; then
    tmp_img="${file%.*}_xshot_tmp.png"

    # screenshot + shadow as transparent layer
    magick "$file" \
      -alpha set -virtual-pixel transparent \
      -channel A -blur 0x5 -threshold 50% +channel \
      \( +clone -background "${shadow_color}" -shadow ${shadow_size} \) \
      +swap -background none -layers merge +repage \
      "$tmp_img"

    img_w=$(magick identify -format "%w" "$tmp_img")
    img_h=$(magick identify -format "%h" "$tmp_img")
    bg_w=$(( img_w + border_size * 2 ))
    bg_h=$(( img_h + border_size * 2 ))

    if [[ "$use_topo" == true ]]; then
      magick -size ${bg_w}x${bg_h} \
        -define gradient:angle=225 \
        gradient:"${grad_start}-${grad_end}" \
        -blur ${grad_blur} \
        \( -size ${bg_w}x${bg_h} tile:"${topo_png}" \) \
        -compose over -composite \
        "$tmp_img" -gravity center -compose over -composite \
        "$file"
    else
      magick -size ${bg_w}x${bg_h} \
        -define gradient:angle=225 \
        gradient:"${grad_start}-${grad_end}" \
        -blur ${grad_blur} \
        "$tmp_img" -gravity center -compose over -composite \
        "$file"
    fi

    rm -f "$tmp_img"
  else
    tmp_img="${file%.*}_xshot_tmp.png"

    # screenshot + shadow tanpa border dulu
    magick "$file" \
      -alpha set -virtual-pixel transparent \
      -channel A -blur 0x5 -threshold 50% +channel \
      \( +clone -background "${shadow_color}" -shadow ${shadow_size} \) \
      +swap -background none -layers merge +repage \
      "$tmp_img"

    img_w=$(magick identify -format "%w" "$tmp_img")
    img_h=$(magick identify -format "%h" "$tmp_img")
    bg_w=$(( img_w + border_size * 2 ))
    bg_h=$(( img_h + border_size * 2 ))

    if [[ "$use_topo" == true ]]; then
      # canvas border_color + topo, screenshot di tengah
      magick -size ${bg_w}x${bg_h} xc:"${border_color}" \
        \( -size ${bg_w}x${bg_h} tile:"${topo_png}" \) \
        -compose over -composite \
        "$tmp_img" -gravity center -compose over -composite \
        "$file"
    else
      magick -size ${bg_w}x${bg_h} xc:"${border_color}" \
        "$tmp_img" -gravity center -compose over -composite \
        "$file"
    fi

    rm -f "$tmp_img"
  fi

  if [[ ${wm} = "no" ]]; then
    check
    if [[ $type = "MANUAL SHOT" ]]; then
      echo -e "   $(log)${g}${file}${r}"
    else
      echo -e "   ${r}[ ${g}${file}${r} ]"
      next_count
    fi
  else
    # apply footer watermark
    magick "$file" \
      -gravity South -background none \
      -font JetBrains-Mono-Medium-Nerd-Font-Complete \
      -pointsize ${footer_size} \
      -fill ${footer_color} \
      -annotate ${footer_xy} "${footer_text}" \
      -gravity North -background none \
      -pointsize ${footer_size_time} \
      -annotate ${footer_xy_time} "${footer_time}" \
      "$file"
    check
    if [[ $type = "MANUAL SHOT" ]]; then
      echo -e "   $(log)${g}${file}${r}"
    else
      echo -e "   ${r}[ ${g}${file}${r} ]"
      next_count
    fi
  fi
}

timeStamp() {
  owner_info2=" $(date +'%H:%M')
 $(date +'%a %d.%h.%Y')"

  magick "${file}" \
    -gravity SouthWest -background black \
    -font JetBrains-Mono-Medium-Nerd-Font-Complete \
    -pointsize $footer_size_timeStamp \
    -fill $footer_color_timeStamp \
    -annotate $footer_xy_timeStamp "${owner_info}" \
    -fill $footer_color_timeStamp2 \
    -annotate $footer_xy_timeStamp2 "${owner_info2}" \
    "${file}"
  check
  echo -e "   ${r}[ ${g}${file}${r} ]"
  next_count
}

# ─────────────────────────────────────────
#  Mode Handlers
# ─────────────────────────────────────────

autoshot() {
  clear
  header
  echo -e "   ${r}[${y}${count}${r}]"
  echo -e "   $(log)${b}Waiting new file"
  inotifywait -m -e moved_to $path 2> /dev/null | \
    while read filename; do
      main
    done
}

manual() {
  clear
  header
  read -p "   $(prompt)" file_name

  # Manual mode is safe-output only:
  # raw input stays untouched, xshot result is written to *_xshot.*
  if [[ "$file_name" == /* ]]; then
    input_file="$file_name"
  else
    echo -e "   $(log)${b}find file ${y}${file_name}${b} in path ${y}/sdcard"
    cd /sdcard || {
      echo -e "   $(log)${r}permission denied, please run ${y}termux-setup-storage"
      exit 1
    }
    result=$(find -name "${file_name}" | sed 's .\{2\}  ' | head -n 1)
    if [[ -z "$result" ]]; then
      echo -e "   $(log)${r}file not found, please check again!"
      exit 1
    fi
    input_file="/sdcard/${result}"
  fi

  if [[ ! -f "$input_file" ]]; then
    echo -e "   $(log)${r}file not found: ${y}${input_file}"
    exit 1
  fi

  if [[ "$input_file" == *_xshot.* ]]; then
    echo -e "   $(log)${r}this looks like an xshot result already, use the raw file instead"
    exit 1
  fi

  base="${input_file%.*}"
  ext="${input_file##*.}"
  out_file="${base}_xshot.${ext}"
  n=1
  while [[ -e "$out_file" ]]; do
    out_file="${base}_xshot_${n}.${ext}"
    n=$((n + 1))
  done

  echo -e "   $(log)${b}found file in ${y}${input_file}"
  echo -e "   $(log)${b}output file ${y}${out_file}"

  cp "$input_file" "$out_file"
  file="$out_file"

  echo -e "   $(log)${b}converting file ..."
  titlebar
  ss
}

main() {
  file_name=$(echo -e "${filename}" | awk '{print $3}')

  # skip android temporary files
  [[ "$file_name" == .pending* ]] && return

  file=${path}/${file_name}
  echo -e "   $(log)${b}Found file ${y}${file_name}"

  if [[ ${run} = "auto" ]]; then
    [[ $backup = "yes" ]] && { echo -e "   $(log)${b}Backup file"; backup; }
    echo -e "   $(log)${b}Converting"
    titlebar
    ss
  elif [[ ${run} = "wm" ]]; then
    echo -e "   $(log)${b}Converting"
    timeStamp
  fi
}

# ─────────────────────────────────────────
#  Argument Parser
# ─────────────────────────────────────────

[[ $3 = "-!" ]] && wm="no"

case "$1" in
  -a)
    type="AUTOSHOT"
    space1="${r}    ║         ║ "
    path=${screenshots_path}
    path_backup=${screenshots_backup}
    run="auto"
    [[ "$3" == "-t" ]] && use_topo=true
    case "$2" in
      -l) space2="${r}      ║"; light; autoshot ;;
      -d) space2="${r}       ║"; dark;  autoshot ;;
      -g) space2="${r}   ║"; gradient; autoshot ;;
      *)  help ;;
    esac
    ;;

  -m)
    type="MANUAL SHOT"
    path=${FILE}
    space1="${r} ║         ║ "
    run="manual"
    [[ "$3" == "-t" ]] && use_topo=true
    case "$2" in
      -l) light; space2="${r}      ║"; manual ;;
      -d) dark;  space2="${r}       ║"; manual ;;
      -g) gradient; space2="${r}   ║"; manual ;;
      *)  help ;;
    esac
    ;;

  -wm)
    type="TIME STAMP"
    path=${camera_path}
    path_backup=${camera_backup}
    space1="${r}  ║         ║ "
    color="none"
    space2="${r}       ║"
    run="wm"
    autoshot
    ;;

  -i) program_info ;;
  *)  help ;;
esac
