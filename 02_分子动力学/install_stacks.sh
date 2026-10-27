#!/bin/bash
# ============================================================================
# 分子动力学与科学计算 —— 按需选装（每个栈独立 conda env）
# 交互:  bash /root/install_moldyn.sh
# 指定:  bash /root/install_moldyn.sh gromacs lammps
# 全装:  bash /root/install_moldyn.sh --all
# 说明: Gromacs 由基础镜像预装（开箱即用）；LAMMPS 等按需 conda 安装，避免源码编译与 MPI 冲突
# ============================================================================
source /root/install_lib.sh
STACKS=(gromacs lammps)

install_gromacs(){
  if command -v gmx >/dev/null 2>&1 || command -v grompp >/dev/null 2>&1; then
    local ver; ver="$(gmx --version 2>/dev/null | head -n 3)"
    log "Gromacs 已预装在基础镜像中，开箱即用，无需安装："
    log "${ver:-（版本未知，执行 gmx --version 查看）}"
    log "使用：直接 gmx / gmx mdrun（无需 conda activate）。特定论文版本请用 install_paper.sh 另建 env。"
    return 0
  fi
  log "未检测到预装 Gromacs，回退安装独立 env..."
  env_create gromacs 3.11; env_run gromacs
  conda install -y -c bioconda -c conda-forge "gromacs==2024.3"
  log "Gromacs 2024.3 装好（env: gromacs）。"
}

install_lammps(){
  env_create lammps 3.11; env_run lammps
  conda install -y -c conda-forge "lammps==20240829=*mpich*"
  log "LAMMPS 2024.08.29(mpich) 装好（env: lammps）。"
}

run_menu(){
  echo "=== 分子动力学 按需选装 ==="
  echo "输入序号空格分隔多选；0=全装；q=退出"
  local i=1; for s in "${STACKS[@]}"; do echo "  $i) $s"; i=$((i+1)); done
  echo "  0) ALL"
  while true; do
    read -rp "选择> " input
    [ "$input" = "q" ] && break
    if [ "$input" = "0" ]; then for x in "${STACKS[@]}"; do install_$x; done; break; fi
    for n in $input; do
      s="${STACKS[$((n-1))]}"
      [ -n "$s" ] && install_$s
    done
  done
}

main(){
  if [ "$1" = "--all" ]; then for x in "${STACKS[@]}"; do install_$x; done; return; fi
  if [ "$1" = "--menu" ] || [ $# -eq 0 ]; then run_menu; return; fi
  for a in "$@"; do
    if [[ " ${STACKS[*]} " == *" $a "* ]]; then install_$a; else log "未知栈: $a"; fi
  done
}
main "$@"
