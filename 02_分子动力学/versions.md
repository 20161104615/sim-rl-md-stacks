# 版本矩阵 · 分子动力学（RTX 4090 48G / Ubuntu 22.04 / CUDA 11.8）

| 栈 | conda env | 关键版本 | 安装方式 | 备注 |
|---|---|---|---|---|
| 基座 | AutoDL Gromacs 2023.2 基础镜像 | Ubuntu 22.04 / Python 3.10 / CUDA 11.8，预装 Gromacs 2023.2 + miniconda | 直接选用 | 系统盘占用由基础镜像决定，本方案只增量加 tools env + 安装器 |
| Gromacs | (基础镜像预装) | Gromacs 2023.2（开箱即用） | 预装 | 特定论文版本（如 2024.3）用 install_paper.sh 另建 env |
| LAMMPS | lammps | LAMMPS 2024.08.29 (mpich) (Python 3.11) | conda conda-forge | MPI 隔离 |

## 版本互斥说明
Gromacs/LAMMPS 对编译器与 MPI 实现敏感；用独立 conda env + bioconda/conda-forge 锁版本，避免与系统或其他栈冲突，同时满足「特定论文复现」的纯净度。

## 发布前自检
- [ ] 首次开机执行 `gmx --version`，确认输出里有 **GPU support: CUDA**（预装 Gromacs 应为 GPU 构建）；若显示 CPU-only，告诉我改回 conda/源码编译路线
- [ ] 基座系统盘增量可控（基础镜像本身含多框架，确认无意外大文件/缓存残留即可）
- [ ] `/root/install_moldyn.sh`、`/root/start_moldyn.sh`、`/root/install_paper.sh` 均在镜像内
- [ ] `bash /root/start_moldyn.sh` 手动跑过一次，无报错、Jupyter 6006 起得来
- [ ] 版本号与论文复现需求核对（默认 Gromacs 2023.2 预装；如需 2024.3 等特定版本用 install_paper.sh 另建 env）
- [ ] autodl.art 应用说明已贴 README_app.md，启动命令填 `bash /root/start_moldyn.sh`
