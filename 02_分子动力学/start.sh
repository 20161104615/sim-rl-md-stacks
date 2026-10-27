#!/bin/bash
# 应用启动命令（autodl.art 填: bash /root/start_moldyn.sh）
# 必须非阻塞、保持实例常驻。打印速查卡 + 开 tmux 会话 + 可选 Jupyter(6006)
LOG=/root/startup_moldyn.log
source /root/install_lib.sh

{
echo "===== 分子动力学与科学计算（按需选装） ====="
echo "可用栈: gromacs(基础镜像预装) lammps(按需)"
echo "安装:   bash /root/install_moldyn.sh <栈名...>  或  --all  或 交互"
echo "论文复现: bash /root/install_paper.sh <env名> <requirements.txt|environment.yml>"
echo "已装环境: $(conda env list 2>/dev/null | tr '\n' ' ')"
} | tee "$LOG"

tmux kill-session -t moldyn 2>/dev/null || true
tmux new-session -d -s moldyn "bash /root/install_moldyn.sh --menu; exec bash" 2>/dev/null || true

if [ -z "$NO_JUPYTER" ]; then
  if (command -v ss >/dev/null 2>&1 && ss -ltn 2>/dev/null | grep -q ':6006') || \
     (command -v lsof >/dev/null 2>&1 && lsof -i:6006 >/dev/null 2>&1); then
    echo "6006 已被占用（基础镜像 jupyter 已在运行），跳过重复启动。" | tee -a "$LOG"
  else
    nohup "$JUPYTER_BIN" lab --ip=0.0.0.0 --port=6006 --no-browser --allow-root \
      --NotebookApp.token='' >>/root/jupyter.log 2>&1 &
    echo "Jupyter 已在 6006 启动（见 /root/jupyter.log）。" | tee -a "$LOG"
  fi
fi
exit 0
