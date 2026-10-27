# 版本矩阵 · 机器人仿真与RL（RTX 4090 48G / Ubuntu 22.04 / 基座 CUDA 11.8，Isaac Lab env 自带 CUDA 12.x）

| 栈 | conda env | 关键版本 | 安装方式 | 备注 |
|---|---|---|---|---|
| 基座 | (base) | AutoDL Gromacs 2023.2 基础镜像: Python 3.10 / Ubuntu 22.04 / CUDA 11.8 + 预装 Gromacs | 直接选用 | 系统盘增量可控（基础镜像本身含多框架） |
| Isaac Lab | isaaclab | Isaac Lab 2.0.0 / torch 2.4.1 / torchvision 0.19.1 | pip (含 Isaac Sim) | headless EGL |
| CARLA | carla | CARLA 0.9.15 服务端 + 客户端 0.9.15 | 数据盘 tar + pip client | 服务端 ~30GB 放数据盘 |
| MuJoCo | mujoco | MuJoCo 3.2.5 / dm-control 1.0.9 | pip | 连续控制 |
| PyBullet | pybullet | PyBullet 3.2.7 / SB3 2.4.0 / Gymnasium 0.29.1 | pip | 快速原型 |
| ROS2 | system | ROS2 Humble (ros-base) | apt (Ubuntu 22.04) | 系统级，不进 conda |
| SMAC | smac | SMACv2 0.1.6 / PettingZoo 1.24.3 / SuperSuit 3.9.1 / torch 2.4.1 | pip | 多智能体 |
| PettingZoo | pettingzoo | PettingZoo 1.24.3 / SuperSuit 3.9.1 | pip | MARL 环境库 |

## 为什么要分 env
Isaac Lab 绑死 torch/CUDA 组合；ROS2 Humble 走 apt 且 Python ≤3.10；三者放同一 Python 环境必冲突。本应用用独立 conda env 隔离，同时满足「特定论文复现」的纯净度。

> 注：基座 CUDA 为 11.8（Gromacs 2023.2 基础镜像）。Isaac Lab 在独立 env 内用 torch 2.4.1(cu121) 自带 CUDA12 运行时，4090 驱动兼容，无需升级系统 CUDA；其余栈（MuJoCo/PyBullet/ROS2/SMAC/PettingZoo）在 11.8 下原生可用。

## 发布前自检
- [ ] 基座系统盘增量可控（`du -sh /root/*` 核对、无意外大文件残留，CARLA/Isaac Sim 未进系统盘）
- [ ] `/root/install_robot_rl.sh`、`/root/start_robot_rl.sh`、`/root/install_paper.sh` 均在镜像内
- [ ] `bash /root/start_robot_rl.sh` 手动跑过一次，无报错、Jupyter 6006 起得来
- [ ] 版本号与论文复现需求核对（按需微调 isaaclab==2.0.0 等）
- [ ] autodl.art 应用说明已贴 README_app.md，启动命令填 `bash /root/start_robot_rl.sh`
