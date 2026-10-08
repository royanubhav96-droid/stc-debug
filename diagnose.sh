#!/bin/bash
# STC VM Diagnostics — run as root
OUT="output_$(hostname)_$(date +%Y%m%d_%H%M%S).txt"

{
echo "===== DATE / HOST ====="
date; hostname; whoami

echo ""
echo "===== DISK USAGE ====="
df -h

echo ""
echo "===== MEMORY ====="
free -h

echo ""
echo "===== GPU (if any) ====="
nvidia-smi 2>/dev/null || echo "No nvidia-smi"

echo ""
echo "===== RUNNING PYTHON PROCESSES ====="
ps aux | grep python | grep -v grep

echo ""
echo "===== SCREEN SESSIONS ====="
screen -ls 2>/dev/null || echo "no screen"

echo ""
echo "===== TMUX SESSIONS ====="
tmux ls 2>/dev/null || echo "no tmux"

echo ""
echo "===== FIND LOG FILES (last modified 7 days) ====="
find /opt /home /root /tmp -name "*.log" -mtime -7 2>/dev/null | head -30

echo ""
echo "===== TAIL RECENT LOGS (last 30 lines each) ====="
for f in $(find /opt /home /root /tmp -name "*.log" -mtime -7 2>/dev/null | head -5); do
  echo "--- $f ---"
  tail -30 "$f" 2>/dev/null
done

echo ""
echo "===== INSTALLED PYTHON PACKAGES (pip) ====="
pip list 2>/dev/null || pip3 list 2>/dev/null

echo ""
echo "===== /OPT CONTENTS ====="
ls -lh /opt/ 2>/dev/null

echo ""
echo "===== TEABOY / CLEANLINESS DIRS ====="
find /opt /home /root -maxdepth 4 -type d \( -iname "*tea*" -o -iname "*clean*" -o -iname "*stc*" -o -iname "*detect*" \) 2>/dev/null

echo ""
echo "===== CPU LOAD ====="
top -bn1 | head -20

echo ""
echo "===== NETWORK PORTS LISTENING ====="
ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null

} 2>&1 | tee "$OUT"

echo ""
echo "Output saved to: $OUT"
echo "Now run:"
echo "  git add $OUT && git commit -m 'diag output' && git push"
