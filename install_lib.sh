#!/bin/bash
# 共享安装库：被 install_robot_rl.sh / install_moldyn.sh / install_paper.sh 引用
# 统一 conda 路径、数据盘、日志与 env 帮助函数
# 运行时自动探测 conda 位置（不同基础镜像可能在 /root/miniconda3 或 /opt/conda）
if [ -x /root/miniconda3/bin/conda ]; then CONDA=/root/miniconda3
elif [ -x /opt/conda/bin/conda ]; then CONDA=/opt/conda
elif [ -x "$HOME/miniconda3/bin/conda" ]; then CONDA=$HOME/miniconda3
else CONDA=/root/miniconda3; fi
export PATH=$CONDA/bin:$PATH
# Jupyter 直接使用基础镜像 base 环境自带的（AutoDL 已在 6006 跑着），避免额外建 env 在 2GB 限额下 OOM
JUPYTER_BIN=$CONDA/bin/jupyter
DATA=/root/autodl-tmp
WORK=$DATA/workspaces
LOG=/root/install.log
mkdir -p "$WORK"

log(){ echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"; }

# 创建独立 conda env（每个栈一套，互不污染，满足论文复现纯净度）
env_create(){
  source "$CONDA/etc/profile.d/conda.sh"
  conda create -y -n "$1" python="$2"
}
# 激活 env 并让后续 pip/conda 在该 env 内执行
env_run(){
  source "$CONDA/etc/profile.d/conda.sh"
  conda activate "$1"
}
