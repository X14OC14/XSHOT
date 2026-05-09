#!/usr/bin/env bash
# ─────────────────────────────────────────
#  xshot — screenshot beautifier for Termux
#  coded by Mafy | v1.0.0 | 08/05/2026
# ─────────────────────────────────────────

# ── Terminal Colors ───────────────────────
o='\033[0m'
bl='\033[38;5;111m'   # soft blue
pk='\033[38;5;183m'   # soft pink-violet
wh='\033[38;5;253m'   # soft white
dm='\033[38;5;240m'   # dim gray
g='\033[38;5;114m'    # soft green (done)
r='\033[38;5;210m'    # soft red (failed)
y='\033[38;5;222m'    # soft yellow

# ── Hex Colors ────────────────────────────
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

# ── Paths ─────────────────────────────────
camera_path="/sdcard/DCIM/Camera"
camera_backup="${camera_path}/backup"
screenshots_path="/sdcard/Pictures/Screenshot"
screenshots_backup="${screenshots_path}/backup"
manual_backup="/sdcard/DCIM/backup"

# ── Titlebar ──────────────────────────────
convert_titlebar="yes"
add_on_img=""
width_img=500
height_img=1000

# ── Border ────────────────────────────────
border_size=50
border_radius=0 #defaut 10
border_c_dark="${hex_color[0]}"
border_c_light="${hex_color[2]}"

# ── Shadow ────────────────────────────────
shadow_size="85x10+0+10"
shadow_color="${hex_color[3]}"

# ── Footer / Watermark ────────────────────
owner_info=" @re.xiaocia"
footer_text=" Shot by Mafy | xiaocia.my.id"

footer_xy="+0+15"
footer_xy_time="+0+20"
footer_size=30
footer_size_time=30
# footer_color handled per theme

# ── Timestamp Mode ────────────────────────
footer_xy_timeStamp="+50+200"
footer_xy_timeStamp2="+50+50"
footer_size_timeStamp=55
footer_color_timeStamp="${hex_color[5]}"
footer_color_timeStamp2="${hex_color[6]}"

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
}

dark() {
  color="DARK"
  titlebar_color=${hex_color[1]}
  border_color=${border_c_dark}
  footer_color="${hex_color[4]}"  # putih
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

header() {
  echo -e "
${pk}██╗░░██╗░██████╗██╗░░██╗░█████╗░████████╗
╚██╗██╔╝██╔════╝██║░░██║██╔══██╗╚══██╔══╝
░╚███╔╝░╚█████╗░███████║██║░░██║░░░██║░░░
░██╔██╗░░╚═══██╗██╔══██║██║░░██║░░░██║░░░
██╔╝╚██╗██████╔╝██║░░██║╚█████╔╝░░░██║░░░
╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░${o}

${wh}  ────────────────────────────────────────${o}
  ${dm}screenshot beautifier for Termux${o}
${wh}  ────────────────────────────────────────${o}

  ${dm}type   ${wh}│${o} ${bl}${type}${o}
  ${dm}theme  ${wh}│${o} ${pk}${color}${o}

${wh}  ────────────────────────────────────────${o}
  ${dm}press ctrl+c to stop${o}
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

  ${dm}optional${o}
  ${wh}│${o} ${dm}-!${o}   no watermark

  ${dm}examples${o}
  ${wh}│${o} xshot ${bl}-a ${pk}-d${o}
  ${wh}│${o} xshot ${bl}-a ${pk}-l ${dm}-!${o}
${wh}  ────────────────────────────────────────${o}
"
}

program_info() {
  echo -e "
${pk}██╗░░██╗░██████╗██╗░░██╗░█████╗░████████╗
╚██╗██╔╝██╔════╝██║░░██║██╔══██╗╚══██╔══╝
░╚███╔╝░╚█████╗░███████║██║░░██║░░░██║░░░
░██╔██╗░░╚═══██╗██╔══██║██║░░██║░░░██║░░░
██╔╝╚██╗██████╔╝██║░░██║╚█████╔╝░░░██║░░░
╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░${o}

${wh}  ────────────────────────────────────────${o}
  ${dm}owner      ${wh}│${o} ${bl}Mafy${o}
  ${dm}version    ${wh}│${o} ${pk}v1.0.0${o}
  ${dm}built      ${wh}│${o} 08/05/2026
  ${dm}platform   ${wh}│${o} Termux + ImageMagick
${wh}  ────────────────────────────────────────${o}
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

  # apply rounded corners, shadow, and border
  magick "$file" \
    -alpha set -virtual-pixel transparent \
    -channel A -blur 0x5 -threshold 50% +channel \
    \( +clone -background "${shadow_color}" -shadow ${shadow_size} \) \
    +swap -background none -layers merge +repage \
    -bordercolor "${border_color}" -border ${border_size} \
    "$file"

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
  echo -e "   $(log)${b}find file ${y}${file_name}${b} in path ${y}/sdcard"
  cd /sdcard
  if [[ $? -eq 0 ]]; then
    result=$(find -name "${file_name}" | sed 's .\{2\}  ')
    if [[ ${result} = "" ]]; then
      echo -e "   $(log)${r}file not found, please check again!"
      exit 1
    fi
    echo -e "   $(log)${b}found file in ${y}/sdcard/${result}"
    file="/sdcard/${result}"
    echo -e "   $(log)${b}converting file ..."
    titlebar
    ss
  else
    echo -e "   $(log)${r}permission denied, please run ${y}termux-setup-storage"
  fi
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
    case "$2" in
      -l) space2="${r}      ║"; light; autoshot ;;
      -d) space2="${r}       ║"; dark;  autoshot ;;
      *)  help ;;
    esac
    ;;

  -m)
    type="MANUAL SHOT"
    path=${FILE}
    space1="${r} ║         ║ "
    run="manual"
    case "$2" in
      -l) light; space2="${r}      ║"; manual ;;
      -d) dark;  space2="${r}       ║"; manual ;;
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
