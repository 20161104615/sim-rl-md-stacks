# 发布 SOP 与 autodl.art 提交表单（照抄即可）

> 本文件是「上架所需一切」的汇总：先构建保存镜像，再把下面两个应用的表单内容原样贴进 autodl.art。
> 两个应用**共用同一份基座镜像**（镜像存储只算一份）。

---

## 阶段一：构建并保存共享基座镜像（在你的 4090 实例上做）

1. AutoDL 控制台开一台 **RTX 4090 48G** 实例（建议先开**无卡模式**跑构建，省算力），基础镜像选 **Gromacs 框架 → 2023.2**（Ubuntu 22.04 / Python 3.10 / CUDA 11.8，已含 miniconda + 预装 Gromacs 2023.2）。⚠️ 不要选 Gromacs 2022.2（Python 3.8 / Ubuntu 18.04 / CUDA 11.4，不兼容 ROS2 Humble 与 Isaac Lab）。
   ⚠️ **也不要选 PyTorch 2.8.0 / Python 3.12 / CUDA 12.1 那档**——虽然底座更新，但框架镜像是二选一的：选了它就没有预装 Gromacs，而 conda 版 Gromacs 是 CPU 构建，GPU 版得源码编译 20 分钟起，应用②的体验会明显变差。RL 各栈都在自己的 conda env 里自带 cu121 torch 运行时，CUDA 11.8 底座不影响它们（4090 驱动本身支持 CUDA 12）。
2. 把本仓库克隆/上传到实例，执行：
   ```bash
   bash 00_公共基座/build_base.sh
   ```
3. 核对系统盘（基础镜像本身含多个框架，本方案只增量加 tools env + 安装器，确认没有意外大文件/缓存残留即可）：
   ```bash
   du -sh /root/* | sort -h
   ```
4. 确认镜像内已含入口：
   ```bash
   ls /root/install_robot_rl.sh /root/install_moldyn.sh /root/install_paper.sh /root/start_robot_rl.sh /root/start_moldyn.sh
   ```
5. **关机** → 实例「更多」→「保存镜像」，起名 `sim-rl-md-base`。
6. 登录 **autodl.art**（与 AutoDL 同账号）→ 页头「+」→ **先发布镜像** `sim-rl-md-base`（填说明、传 logo、GitHub 地址可选）。

> 镜像说明建议：极简共享基座（CUDA 11.8 + Gromacs 2023.2 预装 + conda），开机后按需选装仿真/RL/分子动力学栈，支持论文复现独立环境。

---

## 阶段二：发布应用①（机器人仿真与强化学习）

在 autodl.art 页头「+」→ **发布应用**，按下表填写：

| 字段 | 内容 |
|---|---|
| 应用名称 | 机器人仿真与强化学习环境（Isaac Lab/CARLA/MuJoCo/PyBullet/ROS2/SMAC） |
| 分类 | 仿真 / 机器人（或 强化学习） |
| 选用镜像 | `sim-rl-md-base`（阶段一保存的那份） |
| 启动命令 | `bash /root/start_robot_rl.sh` |
| 对外端口 | 6006（Jupyter Lab，AutoDL 唯一对外端口） |
| 一句话简介 | RTX4090 极简基座，开机按需选装 Isaac Lab/CARLA/MuJoCo/PyBullet/ROS2/SMAC/PettingZoo，支持论文复现独立环境。 |
| 详细说明 | 见 `01_机器人仿真与RL/README_app.md`（直接整段粘贴） |
| logo | 1:1 方图，建议 512×512，几百 KB（我可代为生成，见文末） |

应用默认审核通过即上架，且**默认参加创作激励 0.1 元/小时**。

---

## 阶段三：发布应用②（分子动力学与科学计算）

同样「+」→ **发布应用**：

| 字段 | 内容 |
|---|---|
| 应用名称 | 分子动力学与科学计算环境（Gromacs/LAMMPS） |
| 分类 | 科学计算 / 分子动力学 |
| 选用镜像 | `sim-rl-md-base`（**同一份**，不另存） |
| 启动命令 | `bash /root/start_moldyn.sh` |
| 对外端口 | 6006（Jupyter Lab） |
| 一句话简介 | RTX4090 极简基座（CUDA 11.8 + Gromacs 2023.2 预装），开机按需选装 LAMMPS 2024.08.29，支持论文复现独立环境。 |
| 详细说明 | 见 `02_分子动力学/README_app.md`（直接整段粘贴） |
| logo | 1:1 方图，与①风格统一 |

---

## 阶段四：上架后（收益与维护）

- **收益**：别人从你的应用开实例跑的时长 × **0.1 元/小时**；满 **100 元**可提现（支付宝/银行卡）。详见 `README_总览.md` 与对话中确认的激励规则。
- **维护**：超过 **6 个月不更新**会被移出激励活动，记得持续迭代（哪怕改一句说明）。
- **禁止**：自己发自己用套现 —— 一旦发现取消资格且不给已得奖励。

---

## 提交前最终核对清单

- [ ] 阶段一：`build_base.sh` 在 4090 实例跑通，系统盘增量可控、无意外大文件残留
- [ ] 阶段一：`/root/install_*.sh`、`/root/start_*.sh`、`/root/install_paper.sh` 均在镜像内
- [ ] 阶段一：镜像 `sim-rl-md-base` 已保存并已在 autodl.art 发布
- [ ] 应用①启动命令 = `bash /root/start_robot_rl.sh`，说明贴 `01_*/README_app.md`
- [ ] 应用②启动命令 = `bash /root/start_moldyn.sh`，说明贴 `02_*/README_app.md`
- [ ] 两个应用都选用同一份 `sim-rl-md-base`
- [ ] 两个应用 logo 已传（1:1 方图）
- [ ] 版本号与论文复现需求核对（`versions.md`）

---

## 关于 logo

autodl.art 应用需要 1:1 方图 logo。如果你要，我可以**直接生成两张风格统一的 logo**（一张「机器人/仿真」主题、一张「分子动力学」主题，均 512×512），你下载后上传即可。告诉我就行。
