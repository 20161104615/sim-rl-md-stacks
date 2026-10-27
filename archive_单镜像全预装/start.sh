#!/bin/bash
# ============================================================================
# AutoDL 应用开机启动脚本（应用「启动命令」栏填: bash /root/start.sh）
# 作用: 生成环境速查卡 + 预建 tmux 会话，保持实例运行。
# 说明: 本应用是「环境型应用」，没有单一 Web 服务。
#       请用 JupyterLab / SSH 进入，按下方命令激活对应环境。
# ============================================================================
source /root/miniconda3/etc/profile.d/conda.sh

# 生成速查卡
cat >/root/ENV_GUIDE.txt <<'EOF'
===== 仿真·RL·分子动力学全家桶 =====
激活环境:
  conda activate env-sim      # MuJoCo / PyBullet / SB3
  conda activate env-marl     # SMACv2 / PettingZoo / MAPPO
  conda activate env-isaac    # Isaac Lab (headless, EGL)
  conda activate env-md       # Gromacs / LAMMPS
ROS2: source /opt/ros/humble/setup.bash

CARLA 服务端启动:
  cd /root/autodl-tmp/carla/CARLA_0.9.15 && ./CarlaUE4.sh -opengl -carla-rpc-port=2000

Isaac Lab 示例:
  conda activate env-isaac && python -m isaaclab.scripts.demo

数据盘: /root/autodl-tmp  (CARLA 就在这里)
系统盘已含全部预装环境，开箱即用。
EOF

# 预建 tmux 会话，方便直接 attach
for s in sim marl isaac md; do
  tmux has-session -t "$s" 2>/dev/null || tmux new-session -d -s "$s"
done

echo "环境就绪。速查卡见 /root/ENV_GUIDE.txt"
# 保持实例运行（AutoDL 应用需要启动命令不退出）
exec sleep infinity
