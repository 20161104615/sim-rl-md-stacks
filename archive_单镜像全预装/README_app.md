# 仿真·RL·分子动力学全家桶 (AutoDL.Art 应用说明)

## 一句话简介
面向机器人仿真、强化学习、多智能体与分子动力学研究的**开箱即用环境镜像**。基于 RTX 4090 48G（Ubuntu 22.04 + CUDA 12.x），预装 Isaac Lab、CARLA、MuJoCo、PyBullet、ROS2 Humble、SMACv2/PettingZoo 以及 Gromacs/LAMMPS，并用独立 conda 环境锁死各栈版本，避免环境污染。

## 应用分类
仿真 / 强化学习 / 科学计算

## 启动与重启
1. 在应用广场点「部署应用」→ 选 RTX 4090（或同区可运行卡）→ 创建并开机。
2. 开机后打开 **JupyterLab**（或 SSH），新建/打开终端。
3. 读速查卡：`cat /root/ENV_GUIDE.txt`。
4. 激活需要的环境：`conda activate env-sim`（见下）。
5. 无 Web 服务端口（非 ComfyUI 类应用），环境通过终端直接使用。

> 本应用无 6006 Web 服务，不需要开「自定义服务」。若需 CARLA 可视化服务端，按速查卡手动启动。

## 各环境激活与用途
| 环境 | 激活命令 | 含什么 |
|---|---|---|
| env-sim | `conda activate env-sim` | MuJoMo 3.2、PyBullet 3.2、Gymnasium、Stable-Baselines3 |
| env-marl | `conda activate env-marl` | PettingZoo、SMACv2、SuperSuit、MAPPO 基座 |
| env-isaac | `conda activate env-isaac` | Isaac Lab 2.x（headless EGL，4090 直跑） |
| env-md | `conda activate env-md` | Gromacs 2024.3、LAMMPS 2024 |
| ROS2 | `source /opt/ros/humble/setup.bash` | ROS2 Humble 桌面版（系统级） |

## 模型与数据
- **CARLA 服务端**已置于数据盘 `/root/autodl-tmp/carla/CARLA_0.9.15`（约 30GB，不占系统盘）。
- 你自己的论文代码、数据集请放在数据盘 `/root/autodl-tmp`，关机不丢、且不会撑大镜像。
- 系统盘已含全部预装环境，请勿把大文件写进 `/root` 以外的系统目录。

## 首次使用提示
- 首次 `conda activate env-isaac` 跑 Isaac Lab demo 会联网拉取资产，请稍等。
- 多栈**不要混用同一环境**，版本已为你隔离好。
- 论文复现：建议在每个 env 内再 `conda env export > paper_env.yaml` 锁死你的特定依赖组合。

## 已知限制
- 镜像较大，首次开机会比纯净镜像慢一些（仅首开，之后秒级）。
- CARLA 同时跑服务端 + Isaac Lab 渲染会比较吃显存，4090 48G 建议**分两个实例**或错峰。
- 系统盘按日计费（无论开关机），不用请及时「释放实例」或「缩容系统盘」。

## 版本矩阵
详见同目录 `versions.md`。
