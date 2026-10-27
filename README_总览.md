# AutoDL 应用总览：仿真 · 强化学习 · 分子动力学（拆分式 + 基座按需选装）

## 为什么这么拆
把 Isaac Lab / CARLA / MuJoCo / PyBullet / ROS2 / SMAC / PettingZoo / Gromacs / LAMMPS
全部塞进一个镜像会**体积爆系统盘、版本互相打架、维护灾难**。正确做法是：

- **共享一份基座镜像**（基于 AutoDL **Gromacs 2023.2** 基础镜像：Ubuntu 22.04 / Python 3.10 / CUDA 11.8，已含 miniconda + 预装 Gromacs；本方案只增量加 tools env 与按需安装器）。
- 上架 **2 个专注应用条目**，都引用这同一份基座镜像：
  1. **机器人仿真与强化学习全家桶**（`01_机器人仿真与RL/`）
  2. **分子动力学与科学计算**（`02_分子动力学/`）
- 用户开机后**按需选装**自己要的栈，重活进他自己的实例，基座始终精简。

> 想再细拆（把 RL 多智能体从机器人仿真里独立成第 3 个应用）也很容易：
> 复用同一份基座镜像，只是 autodl.art 再多建一个条目、启动命令换一个包装脚本即可。

## 目录结构
```
AutoDL应用_仿真RL_MD/
├── 00_公共基座/build_base.sh     # 在实例里一键产出共享基座镜像
├── install_lib.sh                # 共享安装库（conda/数据盘/日志/env 帮助）
├── install_paper.sh              # 论文复现：从 requirements/yml 建独立 env
├── 01_机器人仿真与RL/
│   ├── install_stacks.sh         # 按需选装：isaaclab/carla/mujoco/pybullet/ros2/smac/pettingzoo
│   ├── start.sh                  # 应用启动命令（开机运行，非阻塞）
│   ├── README_app.md             # 贴进 autodl.art 的应用说明
│   └── versions.md               # 版本矩阵 + 发布自检
├── 02_分子动力学/
│   ├── install_stacks.sh         # 按需选装：gromacs/lammps
│   ├── start.sh
│   ├── README_app.md
│   └── versions.md
└── archive_单镜像全预装/         # 早期「单镜像全预装」方案（已弃用，留档）
```

## 发布路线图
1. 开 4090 实例（建议**无卡模式**先跑构建，省算力）。
2. 克隆本仓库，`bash 00_公共基座/build_base.sh` → 产出共享基座。
3. `du -sh /root/*` 核对系统盘（基础镜像本身含多个框架，本方案只增量加 tools env，确认无意外大文件残留即可）。
4. 关机 → 控制台「更多」→「保存镜像」（起名如 `sim-rl-md-base`）。
5. 登录 **autodl.art** → 页头「+」→ **先发镜像**（填说明/logo）→ **再发应用**。
6. 两个应用条目都选这份镜像：
   - 应用①启动命令：`bash /root/start_robot_rl.sh`，分类「仿真/机器人」
   - 应用②启动命令：`bash /root/start_moldyn.sh`，分类「科学计算/分子动力学」
   - 说明文案分别贴 `01_*/README_app.md`、`02_*/README_app.md`。
7. 审核通过即上架，默认参加**创作激励（0.1 元/小时）**。

## 成本与硬约束（务必知晓）
- **系统盘不关机也按日计费**（基础 30GB 0.10 元/日 + 扩容费）。本方案只在官方基础镜像上增量加 tools env 与安装器，镜像体积增量很小，几乎只付基础费；重栈是用户开机后装进**他自己**的实例，不增加你的镜像存储。
- 镜像存储：社区免费额度约 30GB，超出 ~0.01 元/GB/日。基座极小，基本不占。
- **应用实例关机 60 天才释放**（普通实例 15 天），但系统盘一直计费，不用了记得释放或缩容。
- 跨区：镜像只在保存它的区可选。

## 「特定论文复现」为什么在这里最稳
用户最常遇到「Gromacs 有基础镜像，但某篇论文的固定版本组合还是得手配」——本方案用两个机制解决：
1. 每个栈都在**独立 conda env** 里锁版本，互不污染；
2. `install_paper.sh` 可从任意 `requirements.txt / environment.yml` 一键建独立 env，
   复现环境天然纯净，和你的基座、和其他用户的环境完全隔离。
