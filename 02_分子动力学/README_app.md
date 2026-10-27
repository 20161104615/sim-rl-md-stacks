# 分子动力学与科学计算（AutoDL 一键应用）

基于 RTX 4090 48G 的**极简共享基座**镜像，开机后**按需选装**分子动力学栈，版本严格锁死、互不污染。

## 包含哪些栈（任选安装）
- **Gromacs 2023.2（基础镜像已预装，开箱即用）**：直接 `gmx` 调用，无需安装；如需特定论文版本用 `install_paper.sh` 另建独立 env
- **LAMMPS 2024.08.29**（mpich 并行，材料/软物质模拟）
- **论文复现**：任意 `requirements.txt / environment.yml` 一键建独立 env

## 怎么用
1. 部署应用后，终端或 Jupyter(6006) 里执行：
   ```bash
   bash /root/install_moldyn.sh --all            # 全装
   bash /root/install_moldyn.sh gromacs          # 只装 Gromacs
   bash /root/install_moldyn.sh                  # 交互菜单选装
   ```
2. 论文复现（固定版本组合，隔离纯净）：
   ```bash
   bash /root/install_paper.sh gmx_paper environment.yml 3.11
   ```
3. 激活环境：Gromacs 免激活直接用 `gmx`；LAMMPS 用 `conda activate lammps`
   运行：`gmx mdrun ...` / `lmp -in in.lammps`

## 数据盘与输入
- 工作区软链：`/root/workspaces` → `/root/autodl-tmp/workspaces`
- 拓扑/力场/轨迹等大文件请放 `/root/autodl-tmp`，**不要写进系统盘**。

## 已知限制
- 首次选装需联网；LAMMPS 经 conda 安装，依赖较多，请留足实例运行时间；Gromacs 由基础镜像预装，无需安装。
- 并行（MPI）默认随 conda 装好的 mpich；如需 OpenMPI 或其他编译器，用 `install_paper.sh` 自建 env。
- 版本号见应用内 `versions.md`，特定论文版本请用 `install_paper.sh` 锁定。
