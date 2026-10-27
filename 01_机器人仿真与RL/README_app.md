# 机器人仿真与强化学习全家桶（AutoDL 一键应用）

基于 RTX 4090 48G 的**极简共享基座**镜像，开机后**按需选装**你需要的仿真 / RL 栈，不预装臃肿环境、不互相污染版本。

## 包含哪些栈（任选安装）
- **Isaac Lab 2.0.0**（含 Isaac Sim，headless EGL，机器人学/模仿学习）
- **CARLA 0.9.15**（自动驾驶仿真，~30GB 服务端自动放数据盘）
- **MuJoCo 3.2.5** + dm-control（连续控制）
- **PyBullet 3.2.7** + Stable-Baselines3（快速原型）
- **ROS2 Humble**（ros-base，机器人中间件）
- **SMACv2 0.1.6** + PettingZoo 1.24.3 + SuperSuit（多智能体 RL）
- **论文复现**：任意 `requirements.txt / environment.yml` 一键建独立 env

## 怎么用
1. 部署应用后，终端或 Jupyter(6006) 里执行：
   ```bash
   bash /root/install_robot_rl.sh --all          # 全装
   bash /root/install_robot_rl.sh isaaclab mujoco # 只装指定栈
   bash /root/install_robot_rl.sh                # 交互菜单选装
   ```
2. 论文复现（固定版本组合，隔离纯净）：
   ```bash
   bash /root/install_paper.sh ppo_atari requirements.txt 3.10
   ```
3. 激活环境：`conda activate isaaclab` / `carla` / `mujoco` / `pybullet` / `smac` / `pettingzoo`
   ROS2：`source /opt/ros/humble/setup.bash`
   CARLA 启动：`$DATA/carla/CARLA_0.9.15/CarlaUE4.sh -opengl`

## 数据盘与模型
- 工作区软链：`/root/workspaces` → `/root/autodl-tmp/workspaces`
- 大文件（数据集、CARLA、StarCraft II）请放 `/root/autodl-tmp`，**不要写进系统盘**，否则关机保存会爆炸、开机变慢。

## 已知限制
- 首次选装需联网下载，CARLA/Isaac Sim 体积大，请留足实例运行时间。
- ROS2 为系统级安装；Isaac Lab 与 ROS2 不在同一 Python 环境，按官方方式分别调用。
- 版本号见应用内 `versions.md`，如需特定论文版本请用 `install_paper.sh` 锁定。
- 基座为 CUDA 11.8（Gromacs 2023.2 基础镜像）；Isaac Lab 在其独立 env 内用 torch 2.4.1(cu121) 自带 CUDA12 运行时，4090 驱动兼容，无需升级系统 CUDA。
