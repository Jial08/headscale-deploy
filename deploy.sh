#!/bin/bash
source config/tput_color_echo.sh

# set -e，脚本只要发生错误，就终止执行。
set -o errexit
# set -u，遇到不存在的变量就会报错，并停止执行
set -o nounset
# set -e 有一个例外情况，就是不适用于管道命令。所谓管道命令，就是多个子命令通过管道运算符（|）组合成为一个大的命令。Bash 会把最后一个子命令的返回值，作为整个命令的返回值。也就是说，只要最后一个子命令不失败，管道命令总是会执行成功，因此它后面命令依然会执行，set -e就失效了。
# set -o pipefail用来解决这种情况，只要一个子命令失败，整个管道命令就失败，脚本就会终止执行。
set -o pipefail
# 在脚本中设置 -x 参数，让命令执行时打印其命令本身和参数，+x 关闭
#set -x

function change_apt_sources() {
  green '换源'
  set -x
  cp /etc/apt/sources.list /etc/apt/sources.list.bak
  cp config/sources2004.list /etc/apt/sources.list
  apt update
}

function install_docker() {
  green 'docker 换源'
  set -x
  mkdir -p /etc/docker
  cp config/daemon.json /etc/docker
  set +x
  green '安装 docker'
  set -x
  apt-get remove docker docker-engine docker.io containerd runc
  apt-get update
  apt-get install \
    ca-certificates \
    curl \
    gnupg
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    tee /etc/apt/sources.list.d/docker.list >/dev/null
  apt-get update
  apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  docker version
}

function install_docker_compose() {
  green '安装 docker-compose'
  set -x
  curl -SL https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  docker-compose version
}

function nginx_init() {
  green '初始化 nginx 配置'
  read -rp "输入服务器IP：" ip
  green '服务器IP：' "$ip"
  set -x
  mkdir -p /opt/nginx/{conf,html,cert}
  cp config/nginx/192.168.10.60.crt /opt/nginx/cert/"$ip".crt
  cp config/nginx/192.168.10.60.key /opt/nginx/cert/"$ip".key
  cp config/nginx/server.conf /opt/nginx/conf/server.conf
  sed -i "s/192.168.10.60/$ip/g" /opt/nginx/conf/server.conf
  cp config/nginx/derp.json /opt/nginx/html/derp.json
  sed -i "s/192.168.10.60/$ip/g" /opt/nginx/html/derp.json
}

function headscale_init() {
  green '初始化 headscale'
  read -rp "输入服务器IP：" ip
  green '服务器IP：' "$ip"
  set -x
  mkdir -p /etc/headscale
  mkdir -p /var/lib/headscale
  touch /var/lib/headscale/db.sqlite
  cp config/config.yaml /etc/headscale
  sed -i "s/192.168.10.60/$ip/g" /etc/headscale/config.yaml
}

function run_docker_compose() {
  green '运行 nginx、ip_derper、headscale、headscale-webui'
  set -x
  mkdir -p /opt/headscale
  cp config/docker-compose.yml /opt/headscale
  cd /opt/headscale
  docker-compose up -d
  docker ps
}

green "请选择服务类型"
green "1) 更新源"
green "2) 安装 docker"
green "3) 安装 docker-compose"
green "4) 初始化 nginx 配置"
green "5) 初始化 headscale 配置"
green "6) 运行容器"
green "7) 按顺序执行123456"
green "8) 退出"
read -r number
case $number in
1)
  change_apt_sources
  ;;
2)
  install_docker
  ;;
3)
  install_docker_compose
  ;;
4)
  nginx_init
  ;;
5)
  headscale_init
  ;;
6)
  run_docker_compose
  ;;
7)
  change_apt_sources
  install_docker
  install_docker_compose
  nginx_init
  headscale_init
  run_docker_compose
  ;;
8)
  exit
  ;;
esac
