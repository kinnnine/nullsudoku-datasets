#!/bin/bash

export DEBIAN_FRONTEND="noninteractive"

cd /tmp

# Install QQWing
curl -o qqwing.deb https://qqwing.com/qqwing_1.3.4-1_amd64.deb
sudo dpkg -i qqwing.deb && rm qqwing.deb

# Obtain SukakuExplainer and create launcher into home user's directory .local/bin
curl -LO https://github.com/SudokuMonster/SukakuExplainer/releases/download/v1.18.1/SukakuExplainer.jar
cat << 'EOF' > $HOME/.local/bin/serate
SE_BINARY="/tmp/SukakuExplainer.jar"
java -cp "$SE_BINARY" diuf.sudoku.test.serate $@
EOF
chmod +x $HOME/.local/bin/serate