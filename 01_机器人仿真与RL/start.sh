#!/bin/bash
# 应用启动命令（autodl.art 填: bash /root/start_robot_rl.sh）
# 必须非阻塞、保持实例常驻。打印速查卡 + 开 tmux 会话 + 可选 Jupyter(6006)
LOG=/root/startup_robot_rl.log
source /root/install_lib.sh

{
echo "===== 机器人仿真与强化学习（按需选装） ====="
echo "可用栈: isaaclab carla mujoco pybullet ros2 smac pettingzoo"
echo "安装:   bash /root/install_robot_rl.sh <栈名...>  或  --all  或 交互"
echo "论文复现: bash /root/install_paper.sh <env名> <requirements.txt|environment.yml>"
echo "已装环境: $(conda env list 2>/dev/null | tr '\n' ' ')"
} | tee "$LOG"

# 开一个 tmux 会话，随时进来选装/操作
tmux kill-session -t robot_rl 2>/dev/null || true
tmux new-session -d -s robot_rl "bash /root/install_robot_rl.sh --menu; exec bash" 2>/dev/null || true

# 可选：起 Jupyter 在 6006（AutoDL 唯一对外端口），NO_JUPYTER=1 可关
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
