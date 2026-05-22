#!/bin/bash
# ─────────────────────────────────────────
#  xshot — installer
#  coded by Mafy | v1.2.1 | 22/05/2026
# ─────────────────────────────────────────

# ═════════════════════════════════════════
#  TERMINAL COLORS  (jangan diubah)
# ═════════════════════════════════════════
o='\033[0m'
bl='\033[38;5;111m'   # soft blue
pk='\033[38;5;183m'   # soft pink-violet
wh='\033[38;5;253m'   # soft white
dm='\033[38;5;240m'   # dim gray
g='\033[38;5;114m'    # soft green
r='\033[38;5;210m'    # soft red
y='\033[38;5;222m'    # soft yellow

# ═════════════════════════════════════════
#  CONFIG
# ═════════════════════════════════════════

# ── Paths ─────────────────────────────────
font_dir="/data/data/com.termux/files/home/.fonts"
local_dir="/data/data/com.termux/files/home/.local"
bin="${local_dir}/bin"
sdcard="/data/data/com.termux/files/home/storage"
dir_package="/data/data/com.termux/files/usr/bin"
topo_dest="/sdcard/topo.png"

# ── Packages ──────────────────────────────
package=(
  "magick"
  "inotifywait"
  "bc"
)

# ─────────────────────────────────────────
#  Utility Functions
# ─────────────────────────────────────────

log() {
  echo -e "${dm}[${wh}$(date +'%H:%M:%S')${dm}]${o} $@"
}

check() {
  if [[ $? -eq 0 && ${PIPESTATUS[0]} -eq 0 ]]; then
    echo -e "   $(log)${g}Done${o}"
  else
    echo -e "   $(log)${r}Error${o}"
    exit 1
  fi
}

already() {
  echo -e "   $(log)${dm}already installed${o}"
}

# ─────────────────────────────────────────
#  UI
# ─────────────────────────────────────────

print_ascii() {
  local colors=(148 149 150 151 152 153)
  local lines=(
    "██╗███╗░░██╗░██████╗████████╗░█████╗░██╗░░░░░██╗░░░░░"
    "██║████╗░██║██╔════╝╚══██╔══╝██╔══██╗██║░░░░░██║░░░░░"
    "██║██╔██╗██║╚█████╗░░░░██║░░░███████║██║░░░░░██║░░░░░"
    "██║██║╚████║░╚═══██╗░░░██║░░░██╔══██║██║░░░░░██║░░░░░"
    "██║██║░╚███║██████╔╝░░░██║░░░██║░░██║███████╗███████╗"
    "╚═╝╚═╝░░╚══╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚══════╝╚══════╝"
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
  \033[38;5;240mscreenshot beautifier for Termux  v1.2.1\033[0m
\033[38;5;253m  ────────────────────────────────────────\033[0m
"
}

# ─────────────────────────────────────────
#  Installer
# ─────────────────────────────────────────

header
read -p "$(echo -e "  ${dm}press enter to continue...${o} ")" _

echo -e "\n$(log)${bl}Installing packages${o}"

echo -e "  ${wh}│${o} ${dm}imagemagick${o}"
if [[ ! -f "${dir_package}/${package[0]}" ]]; then
  pkg install imagemagick -y
  check
else
  already
fi

echo -e "  ${wh}│${o} ${dm}inotify-tools${o}"
if [[ ! -f "${dir_package}/${package[1]}" ]]; then
  pkg install inotify-tools -y
  check
else
  already
fi

echo -e "  ${wh}│${o} ${dm}bc${o}"
if [[ ! -f "${dir_package}/${package[2]}" ]]; then
  pkg install bc -y
  check
else
  already
fi

echo -e "\n$(log)${bl}Installing fonts${o}"
cp -rf "$(pwd)/fonts" ~/.fonts
check

if [[ ! -d ${sdcard} ]]; then
  echo -e "\n$(log)${bl}Setting up storage access${o}"
  termux-setup-storage
  sleep 3s
fi

echo -e "\n$(log)${bl}Copying topo.png to /sdcard${o}"
if [[ -f "$(pwd)/topo.png" ]]; then
  cp "$(pwd)/topo.png" "${topo_dest}"
  check
else
  echo -e "   $(log)${y}topo.png not found in repo, skipping${o}"
fi

echo -e "\n$(log)${bl}Setting up ~/.local/bin${o}"
sleep 1s
if [[ ! -d ${local_dir} ]]; then
  echo -e "  ${wh}│${o} ${dm}creating directory${o}"
  mkdir -p "${bin}"
  check
else
  echo -e "  ${wh}│${o} ${dm}directory already exists${o}"
fi

echo -e "  ${wh}│${o} ${dm}copying xshot${o}"
sleep 1s
cp xshot.sh "${bin}/xshot"
check
chmod +x "${bin}/xshot"
check

echo -e "\n$(log)${g}installation complete${o}"
echo -e "
${wh}  ────────────────────────────────────────${o}
  ${dm}run with command${o} ${bl}xshot${o}
${wh}  ────────────────────────────────────────${o}
"
