#!/bin/bash
set -e

# Define how much we need puzzles.
TOTAL_GENERATION=500

# Command options:
# QQwing:
#   https://qqwing.com/instructions.html
# SukakuExplainer/serate:
#   https://github.com/SudokuMonster/SukakuExplainer/wiki/Batch-mode-command-line-parameters
QQWING="qqwing --one-line"
SERATE="serate --format="%g%t%r""

# Difficulty argument parsing (Default: simple).
DIFFICULTY="simple"
case "$1" in
    1|Simple|simple)
        DIFFICULTY="simple"
        ;;
    2|Easy|easy)
        DIFFICULTY="easy"
        ;;
    3|Intermediate|intermediate)
        DIFFICULTY="intermediate"
        ;;
    4|Expert|expert)
        DIFFICULTY="expert"
        ;;
    *)
        ;;
esac

# Timer stuffs
TIME_START=0
timer_start() {
    TIME_START=$(date +%s%3N)
}
timer_end() {
    TIME_END=$(date +%s%3N)
    printf '%s: elapsed time: %sms\n' "$1" "$((TIME_END - TIME_START))"
}

# Show information before processing
echo
printf 'date: %s\n' "$(date)"
printf 'diff: %s\n' "$DIFFICULTY"

timer_start

# Phase 1: Raw puzzle generation using QQwing.
${QQWING} --difficulty $DIFFICULTY --generate $TOTAL_GENERATION > /tmp/raw_puzzles_1
sed -i 's/\./0/g' /tmp/raw_puzzles_1 # Replace all dots with zero.

timer_end "Phase 1"
timer_start

# Phase 2: Ranking difficulty using SukakuExplainer/serate.
${SERATE} --input=/tmp/raw_puzzles_1 --output=/tmp/raw_puzzles_2
sed -i 's/\t/  /g' /tmp/raw_puzzles_2 # Replace all tabs with spaces.

timer_end "Phase 2"
timer_start

# Phase 3: Sorting difficulty and calculate sha1 by each lines using awk, sort and sha1sum.
awk '{print $0}' /tmp/raw_puzzles_2 | sort -k2,2n > /tmp/raw_puzzles_3
awk '{
    cmd = "echo -n " $1 " | sha1sum | cut -c 1-24"; 
    cmd | getline sha; 
    close(cmd); 
    split(sha, arr, " "); 
    print arr[1] " " $0 
}' /tmp/raw_puzzles_3 > /tmp/nice_puzzles
rm /tmp/raw_puzzles_*

timer_end "Phase 3"

# Final: Save nice_puzzles file into current directory.
mv /tmp/nice_puzzles $(pwd)/"$DIFFICULTY".txt
