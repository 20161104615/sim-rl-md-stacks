# 版本矩阵 (RTX 4090 48G / Ubuntu 22.04 / CUDA 12.x)

| 栈 | conda env | 关键版本 | 安装方式 | 备注 |
|---|---|---|---|---|
| 基础 | (base) | Miniconda latest, Python 3.10 | sh 安装 | 全局基础 |
| 仿真通用 | env-sim | MuJoCo 3.2.5 / PyBullet 3.2.7 / SB3 2.4.0 / Gymnasium 0.29.1 | pip | 单智能体 RL |
| 多智能体 | env-marl | PettingZoo 1.24.3 / SMACv2 0.1.6 / SuperSuit 3.9.1 / torch 2.4.1 | pip | MAPPO 等 |
| 机器人 | env-isaac | Isaac Lab 2.x / torch 2.4.1 / torchvision 0.19.1 | pip (含 Isaac Sim) | headless EGL |
| 分子动力学 | env-md | Gromacs 2024.3 / LAMMPS 2024.08.29 (mpich) / OpenMPI 5.0.3 / Python 3.11 | conda bioconda | MPI 隔离 |
| ROS2 | system | ROS2 Humble 桌面版 | apt (Ubuntu 22.04) | 系统级，不进 conda |
| CARLA | env-sim + 数据盘 | CARLA 0.9.15 服务端 + Python 客户端 0.9.15 | 数据盘 tar + pip client | 服务端~30GB 放数据盘 |

## 版本互斥说明（为什么要分 env）
- Isaac Lab 要求固定 torch/CUDA 组合；ROS2 Humble 要求 Python ≤3.10 且走 apt；Gromacs/LAMMPS 对编译器与 MPI 敏感。三者放进同一 Python 环境必冲突。
- 因此采用「一镜像 + 多 conda env」方案，每个环境锁死一套版本，同时满足「特定论文代码复现」的纯净度需求。

## 构建与发布步骤
1. AutoDL 控制台开一台 4090 实例（建议无卡模式先跑构建），选 Ubuntu 22.04 + CUDA 12.x 基础镜像。
2. `bash build_env.sh` 完成全部预装；用 `du -sh /root/*` 核对系统盘 ≤ ~200GB。
3. 关机 →「更多」→「保存镜像」。
4. 登录 autodl.art → 页头「+」→ 发布镜像（填 GitHub 项目地址、说明、logo）。
5. 在同一「+」里发布应用：选刚保存的镜像，启动命令填 `bash /root/start.sh`，分类选「仿真/强化学习」，说明贴 README_app.md。
6. 审核通过即上架，默认参加创作激励（0.1 元/小时）。

## 发布前自检
- [ ] 系统盘占用 ≤ 200GB（CARLA 未进系统盘）
- [ ] 四个 conda env + ROS2 均可正常 `conda activate`
- [ ] 速查卡 `/root/ENV_GUIDE.txt` 存在
- [ ] `start.sh` 在实例内手动跑过一次，无报错
- [ ] 版本号与论文复现需求核对（按需微调）
