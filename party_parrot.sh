#!/usr/bin/env bash

# Party Parrot - terminal animation script
# Based on the classic Party Parrot meme (cultofthepartyparrot.com)

DELAY=0.1

hide_cursor() { printf '\033[?25l'; }
show_cursor() { printf '\033[?25h'; }
clear_frame() { printf '\033[H'; }

trap 'show_cursor; printf "\n"; exit 0' INT TERM

# ANSI colors
R='\033[0;31m'  # red
O='\033[0;33m'  # orange (dark yellow)
Y='\033[1;33m'  # yellow
G='\033[0;32m'  # green
C='\033[0;36m'  # cyan
B='\033[0;34m'  # blue
M='\033[0;35m'  # magenta
P='\033[1;35m'  # pink (bright magenta)
W='\033[1;37m'  # white
K='\033[0;30m'  # black
N='\033[0m'     # reset

# Each frame is an array of lines with color codes embedded
declare -a FRAMES

# Frame 1
FRAMES[0]=$(printf "${G}    ___   \n${G}  /     \\ \n${G} | ${Y}o${G} ${Y}o${G} | \n${G}  \\  v  / \n${G}  /|   |\\ \n${G} / |   | \\ \n${G}   |   |  \n${N}")

# Frame 2
FRAMES[1]=$(printf "${C}    ___   \n${C}  /     \\ \n${C} | ${Y}o${C} ${Y}o${C} | \n${C}  \\  ^  / \n${C}   |   | \n${C}  /|   |\\ \n${C}   |   |  \n${N}")

# Frame 3
FRAMES[2]=$(printf "${B}    ___   \n${B}  /     \\ \n${B} | ${W}o${B} ${W}o${B} | \n${B}  \\  v  / \n${B}   |   | \n${B} / |   | \\\n${B}   |   |  \n${N}")

# Frame 4
FRAMES[3]=$(printf "${M}    ___   \n${M}  /     \\ \n${M} | ${W}o${M} ${W}o${M} | \n${M}  \\  ^  / \n${M}  /|   | \n${M} / |   | \\\n${M}   |   |  \n${N}")

# Frame 5
FRAMES[4]=$(printf "${R}    ___   \n${R}  /     \\ \n${R} | ${Y}o${R} ${Y}o${R} | \n${R}  \\  v  / \n${R}  /|   |\\ \n${R}   |   | \\\n${R}   |   |  \n${N}")

# Frame 6
FRAMES[5]=$(printf "${O}    ___   \n${O}  /     \\ \n${O} | ${W}o${O} ${W}o${O} | \n${O}  \\  ^  / \n${O}   |   |\\ \n${O}  /|   |  \n${O}   |   |  \n${N}")

# Frame 7
FRAMES[6]=$(printf "${Y}    ___   \n${Y}  /     \\ \n${Y} | ${R}o${Y} ${R}o${Y} | \n${Y}  \\  v  / \n${Y}  /|   |  \n${Y} / |   |\\ \n${Y}   |   |  \n${N}")

# Frame 8
FRAMES[7]=$(printf "${P}    ___   \n${P}  /     \\ \n${P} | ${W}o${P} ${W}o${P} | \n${P}  \\  ^  / \n${P}  /|   |\\ \n${P}   |   |/ \n${P}   |   |  \n${N}")

NUM_FRAMES=${#FRAMES[@]}

clear
hide_cursor

echo ""
printf "${W}  🎉 PARTY PARROT 🎉${N}\n"
echo ""

while true; do
    for ((i = 0; i < NUM_FRAMES; i++)); do
        clear_frame
        echo ""
        printf "${W}  🎉 PARTY PARROT 🎉${N}\n"
        echo ""
        printf '%b\n' "${FRAMES[$i]}"
        printf "  ${C}Press Ctrl+C to stop${N}\n"
        sleep "$DELAY"
    done
done
