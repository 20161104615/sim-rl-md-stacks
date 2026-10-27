#!/bin/bash
# ============================================================================
# 机器人仿真与强化学习 —— 按需选装（每个栈独立 conda env）
# 交互:  bash /root/install_robot_rl.sh
# 指定:  bash /root/install_robot_rl.sh isaaclab carla mujoco pybullet ros2 smac pettingzoo
# 全装:  bash /root/install_robot_rl.sh --all
# 原则: 重二进制（CARLA 服务端 ~30GB / StarCraft II）放数据盘 /root/autodl-tmp
# ============================================================================
source /root/install_lib.sh
STACKS=(isaaclab carla mujoco pybullet ros2 smac pettingzoo)

install_isaaclab(){
  # 基座为 CUDA 11.8，但 Isaac Lab 的 torch 2.4.1(cu121) 自带 CUDA12 运行时；
  # 4090 驱动支持 CUDA12，故在独立 env 内即可运行，无需升级系统 CUDA。
  env_create isaaclab 3.10; env_run isaaclab
  pip install --no-cache-dir torch==2.4.1 torchvision==0.19.1
  pip install --no-cache-dir isaaclab==2.0.0
  log "Isaac Lab 装好（env: isaaclab，自带 CUDA12 运行时，兼容 11.8 基座）。首次运行需联网拉 Isaac Sim 资源。"
}

install_carla(){
  env_create carla 3.9; env_run carla
  pip install --no-cache-dir carla==0.9.15
  mkdir -p "$DATA/carla"
  if [ ! -d "$DATA/carla/CARLA_0.9.15" ]; then
    log "下载 CARLA 0.9.15 服务端(~30GB) 到数据盘..."
    wget -q https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/CARLA_0.9.15.tar.gz -O "$DATA/carla/carla.tar.gz"
    tar -xzf "$DATA/carla/carla.tar.gz" -C "$DATA/carla"
  fi
  log "CARLA 服务端: $DATA/carla/CARLA_0.9.15，启动: ./CarlaUE4.sh -opengl"
}

install_mujoco(){
  env_create mujoco 3.10; env_run mujoco
  pip install --no-cache-dir mujoco==3.2.5 dm-control==1.0.9
  log "MuJoCo 装好（env: mujoco）。"
}

install_pybullet(){
  env_create pybullet 3.10; env_run pybullet
  pip install --no-cache-dir pybullet==3.2.7 gymnasium==0.29.1 stable-baselines3==2.4.0
  log "PyBullet + SB3 装好（env: pybullet）。"
}

install_ros2(){
  log "安装 ROS2 Humble (ros-base, 无 GUI)..."
  apt-get update
  apt-get install -y software-properties-common
  add-apt-repository -y universe
  curl -sSL https://raw.githubusercontent.com/ros/ros2/rosdistro/master/ros.key | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg
  echo "deb [arch=amd64] http://packages.ros.org/ros2/ubuntu jammy main" >/etc/apt/sources.list.d/ros2.list
  apt-get update
  apt-get install -y ros-humble-ros-base
  echo 'source /opt/ros/humble/setup.bash' >>/root/.bashrc
  log "ROS2 Humble 装好（系统级）。需要 Gazebo GUI 可另装 ros-humble-desktop。"
}

install_smac(){
  env_create smac 3.10; env_run smac
  pip install --no-cache-dir pettingzoo==1.24.3 supersuit==3.9.1 smacv2==0.1.6 gymnasium==0.29.1 torch==2.4.1 numpy==1.26.4
  mkdir -p "$DATA/smac"
  log "SMACv2 装好（env: smac）。StarCraft II 二进制需自行放入 $DATA/smac（论文常自带）。"
}

install_pettingzoo(){
  env_create pettingzoo 3.10; env_run pettingzoo
  pip install --no-cache-dir pettingzoo==1.24.3 supersuit==3.9.1
  log "PettingZoo 装好（env: pettingzoo）。"
}

run_menu(){
  echo "=== 机器人仿真与RL 按需选装 ==="
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
