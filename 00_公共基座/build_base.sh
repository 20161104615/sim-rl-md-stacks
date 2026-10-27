#!/bin/bash
# ============================================================================
# 共享基座镜像构建脚本（所有专注应用共用同一份镜像）
# 目标卡: RTX 4090 48G (non-Blackwell, 选用 Gromacs 2023.2 基础镜像: Ubuntu 22.04 / Python 3.10 / CUDA 11.8)
# 形态: 极简基座（CUDA + conda + 基础工具 + 安装器脚本）
#       —— 重栈（Isaac Lab / CARLA / ROS2 / Gromacs 等）由用户开机后「按需选装」
# 用法: 在 AutoDL 4090 实例（建议无卡模式先跑）克隆本仓库后执行：
#       bash 00_公共基座/build_base.sh
#
# ⚠️ 关键:
#   1. 本脚本只装「基座 + 把安装器脚本拷进镜像」，不装任何重栈；系统盘增量可控（基础镜像本身含多框架）。
#   2. 构建完用 `du -sh /root/*` 核对系统盘，确认没有大文件残留。
#   3. 关机 → 保存镜像 → 该镜像同时供两个应用条目复用。
# ============================================================================
set -e
export DEBIAN_FRONTEND=noninteractive
LOG=/root/build_base.log
exec > >(tee -a "$LOG") 2>&1

# 探测已存在的基础镜像 conda（官方基础镜像通常已带 miniconda）
if [ -x /root/miniconda3/bin/conda ]; then CONDA_HOME=/root/miniconda3
elif [ -x /opt/conda/bin/conda ]; then CONDA_HOME=/opt/conda
else CONDA_HOME=/root/miniconda3; fi
DATA=/root/autodl-tmp
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "===== [1/5] 安装系统基础工具（精简，不带 GUI 重依赖） ====="
apt-get update
apt-get install -y --no-install-recommends \
  build-essential cmake git curl wget ca-certificates vim tmux htop \
  patchelf libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 libosmesa6 \
  libopenmpi-dev openmpi-bin
apt-get clean && rm -rf /var/lib/apt/lists/*

echo "===== [2/5] 安装 Miniconda 到系统盘（体积小） ====="
if [ ! -d "$CONDA_HOME" ]; then
  wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
  bash /tmp/miniconda.sh -b -p "$CONDA_HOME"
  rm -f /tmp/miniconda.sh
fi
source "$CONDA_HOME/etc/profile.d/conda.sh"
conda init bash
conda config --set auto_activate_base false
conda config --set channel_priority flexible
conda config --add channels conda-forge
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

echo "===== [3/5] 数据盘工作区（Jupyter 复用基础镜像 base 环境，不再单独建 tools env，避免 2GB 限额 OOM） ====="
mkdir -p "$DATA/workspaces"
ln -sfn "$DATA/workspaces" /root/workspaces
# 基础镜像的 base 环境已自带 jupyter（AutoDL 默认 6006 服务），start.sh 直接调用 $CONDA/bin/jupyter
"$CONDA_HOME/bin/jupyter" --version 2>/dev/null && echo "base 环境 jupyter 可用" || echo "WARN: base 环境无 jupyter，start.sh 将尝试启动"

echo "===== [4/5] 把按需安装器拷进镜像（开机后用户调用） ====="
cp -r "$SRC/01_机器人仿真与RL" /root/app_robot_rl
cp -r "$SRC/02_分子动力学"     /root/app_moldyn
cp "$SRC/install_lib.sh"   /root/install_lib.sh
cp "$SRC/install_paper.sh" /root/install_paper.sh
# 顶层入口（应用启动命令与文档里引用的就是这两个）
cp "$SRC/01_机器人仿真与RL/install_stacks.sh" /root/install_robot_rl.sh
cp "$SRC/02_分子动力学/install_stacks.sh"     /root/install_moldyn.sh
cp "$SRC/01_机器人仿真与RL/start.sh" /root/start_robot_rl.sh
cp "$SRC/02_分子动力学/start.sh"     /root/start_moldyn.sh

echo "===== [5/5] 清理缓存，控制镜像体积 ====="
conda clean -ay
pip cache purge
rm -rf ~/.cache/pip ~/.cache/huggingface /tmp/*

echo "======================================================"
echo "基座构建完成。系统盘占用（基础镜像本身含 pytorch/tensorflow/jax 等框架，"
echo "本方案只增量加安装器，jupyter 复用基础镜像 base 环境，请确认无意外大文件/缓存残留）:"
du -sh /root/* 2>/dev/null | sort -h
echo "镜像内已含: /root/install_robot_rl.sh  /root/install_moldyn.sh  /root/install_paper.sh"
echo "Gromacs 由基础镜像预装，开箱即用；LAMMPS 等重栈用户开机后按需安装。"
echo "用户开机后: bash /root/install_robot_rl.sh --all   (或交互选装)"
echo "======================================================"
