#!/bin/bash
source config/tput_color_echo.sh

function change_apt_sources() {
  green '换源'
  cp /etc/apt/sources.list /etc/apt/sources.list.bak
  cp config/sources2004.list /etc/apt/sources.list
  apt update
}

function install_docker() {
  green 'docker 换源'
  mkdir -p /etc/docker
  cp config/daemon.json /etc/docker
  green '安装 docker'
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
  curl -SL https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  docker-compose version
}

function nginx_init() {
  green '初始化 nginx 配置'
  read -rp "输入服务器IP：" ip
  green '服务器IP：' "$ip"
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
  mkdir -p /etc/headscale
  mkdir -p /var/lib/headscale
  touch /var/lib/headscale/db.sqlite
  cp config/config.yaml /etc/headscale
  sed -i "s/192.168.10.60/$ip/g" /etc/headscale/config.yaml
}

function run_docker_compose() {
  green '运行 nginx、ip_derper、headscale、headscale-webui'
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
6)
  change_apt_sources
  install_docker
  install_docker_compose
  nginx_init
  headscale_init
  run_docker_compose
  ;;
7)
  exit
  ;;
esac
