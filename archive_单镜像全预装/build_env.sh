#!/bin/bash
# ============================================================================
# AutoDL 应用「仿真·RL·分子动力学全家桶」镜像构建脚本
# 目标卡: RTX 4090 48G (non-Blackwell, CUDA 12.x, Ubuntu 22.04 基础镜像)
# 形态: 单镜像 + 多 conda env 隔离（每个栈一套锁版本环境）
# 用法: 在 AutoDL 实例里 bash build_env.sh   （建议无卡模式先跑，省算力）
#
# ⚠️ 注意:
#   1. 本脚本会下载大量文件，构建耗时 30~90 分钟，需联网。
#   2. CARLA 服务端约 30GB，写入数据盘 /root/autodl-tmp（不进系统盘）。
#   3. 版本号为构建时已知稳定值，正式发布前请先 dry-run 一段确认可装。
#   4. 系统盘最终占用请控制在 ~200GB 内；装完用 `du -sh /root/*` 核对。
# ============================================================================
set -e
export DEBIAN_FRONTEND=noninteractive
LOG=/root/build_env.log
exec > >(tee -a "$LOG") 2>&1

CONDA_HOME=/root/miniconda3
DATA=/root/autodl-tmp

echo "===== [0/7] 安装系统依赖 ====="
apt-get update
apt-get install -y --no-install-recommends \
  build-essential cmake git curl wget ca-certificates \
  libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
  libopenmpi-dev openmpi-bin libosmesa6-dev patchelf

echo "===== [1/7] 安装 Miniconda ====="
if [ ! -d "$CONDA_HOME" ]; then
  wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
  bash /tmp/miniconda.sh -b -p "$CONDA_HOME"
fi
source "$CONDA_HOME/etc/profile.d/conda.sh"
conda init bash
conda config --set auto_activate_base false

# ---------------------------------------------------------------------------
# env-sim: MuJoCo / PyBullet / 通用 RL 训练
# ---------------------------------------------------------------------------
echo "===== [2/7] env-sim (MuJoCo, PyBullet, SB3) ====="
conda create -y -n env-sim python=3.10
conda activate env-sim
pip install --no-cache-dir \
  "mujoco==3.2.5" \
  "dm-control==1.0.9" \
  "pybullet==3.2.7" \
  "gymnasium==0.29.1" \
  "stable-baselines3==2.4.0" \
  "tensorboard==2.17.0"
# MuJoCo 需要物理引擎许可文件（免费），首次运行会自动联网获取，无需手动。
conda deactivate

# ---------------------------------------------------------------------------
# env-marl: 多智能体 (SMACv2 / PettingZoo / MAPPO)
# ---------------------------------------------------------------------------
echo "===== [3/7] env-marl (SMACv2, PettingZoo, MAPPO) ====="
conda create -y -n env-marl python=3.10
conda activate env-marl
pip install --no-cache-dir \
  "pettingzoo==1.24.3" \
  "supersuit==3.9.1" \
  "smacv2==0.1.6" \
  "gymnasium==0.29.1" \
  "torch==2.4.1" \
  "numpy==1.26.4"
# MAPPO / EPyMARL 等训练框架按需再装（论文复现通常自带 requirements）
conda deactivate

# ---------------------------------------------------------------------------
# env-isaac: Isaac Lab (Isaac Sim 内置, headless EGL)
# ---------------------------------------------------------------------------
echo "===== [4/7] env-isaac (Isaac Lab) ====="
conda create -y -n env-isaac python=3.10
conda activate env-isaac
# Isaac Lab 自带 Isaac Sim 依赖（含 CUDA11.7/12.x 兼容 wheel），4090 走 headless
pip install --no-cache-dir \
  "torch==2.4.1" "torchvision==0.19.1"
pip install --no-cache-dir "isaaclab==2.0.0"   # 构建时确认最新 2.x
# 预拉取 Isaac Sim 资源（若网络受限，可注释掉，让用户首次运行时拉）
# python -m isaaclab.scripts.download_assets
conda deactivate

# ---------------------------------------------------------------------------
# env-md: Gromacs / LAMMPS (分子动力学)
#   用 conda/bioconda 装以避免源码编译与 MPI 冲突
# ---------------------------------------------------------------------------
echo "===== [5/7] env-md (Gromacs, LAMMPS) ====="
conda create -y -n env-md python=3.11 -c conda-forge
conda activate env-md
conda install -y -c bioconda -c conda-forge \
  "gromacs==2024.3" \
  "lammps==20240829=*mpich*" \
  "openmpi==5.0.3"
conda deactivate

# ---------------------------------------------------------------------------
# ROS2 Humble (系统级安装, 不放 conda; 4090 镜像基于 Ubuntu 22.04 兼容)
# ---------------------------------------------------------------------------
echo "===== [6/7] ROS2 Humble (system) ====="
if [ ! -f /opt/ros/humble/setup.bash ]; then
  curl -sSL https://raw.githubusercontent.com/ros/ros2/iron/ros2.repos >/dev/null 2>&1 || true
  apt-get update
  apt-get install -y software-properties-common
  add-apt-repository -y universe
  curl -sSL https://raw.githubusercontent.com/ros/ros2/beta/ros2.repos >/dev/null 2>&1 || true
  # 标准 Humble 二进制源
  echo "deb [arch=amd64] http://packages.ros.org/ros2/ubuntu jammy main" >/etc/apt/sources.list.d/ros2.list
  curl -sSL https://raw.githubusercontent.com/ros/ros2/rosdistro/master/ros.key | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg
  apt-get update
  apt-get install -y ros-humble-desktop
fi
echo 'source /opt/ros/humble/setup.bash' >>/root/.bashrc

# ---------------------------------------------------------------------------
# CARLA 服务端 (放数据盘, 不进系统盘)
# ---------------------------------------------------------------------------
echo "===== [7/7] CARLA 0.9.15 服务端 (数据盘) ====="
mkdir -p "$DATA/carla"
if [ ! -d "$DATA/carla/CARLA_0.9.15" ]; then
  wget -q https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/CARLA_0.9.15.tar.gz -O "$DATA/carla/carla.tar.gz"
  tar -xzf "$DATA/carla/carla.tar.gz -C $DATA/carla" || tar -xzf "$DATA/carla/carla.tar.gz -C $DATA/carla"
fi
# Python 客户端同时装进 env-sim 方便调用
conda activate env-sim
pip install --no-cache-dir "carla==0.9.15"
conda deactivate

echo "======================================================"
echo "构建完成。系统盘占用:"
du -sh /root/* 2>/dev/null | sort -h
echo "激活环境: conda activate env-sim | env-marl | env-isaac | env-md"
echo "ROS2: source /opt/ros/humble/setup.bash"
echo "CARLA 服务端: $DATA/carla/CARLA_0.9.15 (需手动启动 ./CarlaUE4.sh -opengl)"
echo "======================================================"
