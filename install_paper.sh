#!/bin/bash
# ============================================================================
# 论文复现专用：从 requirements.txt / environment.yml 建一个独立 conda env
# 用法:
#   bash /root/install_paper.sh <env名> <requirements.txt|environment.yml> [python版本]
# 例:
#   bash /root/install_paper.sh ppo_atari requirements.txt 3.10
#   bash /root/install_paper.sh gmx_paper environment.yml 3.11
# 说明:
#   - 这是「特定版本组合 / 论文复现」的核心入口：不污染任何共享环境。
#   - yml 走 conda env update（可含 conda/pip 混合依赖），txt 走 pip install -r。
#   - 大二进制（数据集、预训练权重、StarCraft II 等）请放进 /root/autodl-tmp。
# ============================================================================
set -e
source /root/install_lib.sh

ENV="$1"; SPEC="$2"; PY="${3:-3.10}"
if [ -z "$ENV" ] || [ -z "$SPEC" ]; then
  echo "用法: bash /root/install_paper.sh <env名> <requirements.txt|environment.yml> [python版本]"
  exit 1
fi
if [ ! -f "$SPEC" ]; then
  echo "找不到依赖文件: $SPEC"; exit 1
fi

env_create "$ENV" "$PY"
source "$CONDA/etc/profile.d/conda.sh"; conda activate "$ENV"
if [[ "$SPEC" == *.yml || "$SPEC" == *.yaml ]]; then
  conda env update -n "$ENV" -f "$SPEC"
else
  pip install -r "$SPEC"
fi
log "论文环境 [$ENV] 建好：conda activate $ENV"
