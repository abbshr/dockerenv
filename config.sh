#!/bin/bash

cd /tmp

source b-log.sh

# log all level
LOG_LEVEL_ALL

config-system() {
  WARN "sh 链接到 bash"
  rm -rf /bin/sh
  ln -s /bin/bash /bin/sh

  # 剪裁系统缺失开发套件和 man page，这里还原完整版
  NOTICE "正在恢复镜像中被裁减的软件"
  yes | unminimize #&> /dev/null

  # 中文环境
  NOTICE "设置中文环境"
  locale-gen zh_CN.UTF-8
}

config-dir() {
  WARN "创建工作目录"
  mkdir -p ~/{github,gitlab,downloads,config,test,.ssh}
}

config-ssh() {
  cat <<'EOF-CONFIG-SSH' >> .bashrc
ps -aux | grep -v "grep" | grep ssh-agent &> /dev/null
if [[ $? != 0 ]]; then
  eval $(ssh-agent -s) &> /dev/null
  cat <<EOF > ~/.sshagentrc
export SSH_AGENT_PID=$SSH_AGENT_PID
export SSH_AUTH_SOCK=$SSH_AUTH_SOCK
EOF
else
  source ~/.sshagentrc
fi
EOF-CONFIG-SSH
}

config-shadowsocks() {
  local version=$(sslocal --version)
  if [[ "${version}" == "Shadowsocks 2.8.2" ]]; then
    sed -i "s/EVP_CIPHER_CTX_cleanup/EVP_CIPHER_CTX_reset/g" /usr/local/lib/python2.7/dist-packages/shadowsocks/crypto/openssl.py
  fi
}

config-git() {
  local name=ran
  local email=abbshrsoufii@gmail.com

  local GIT_CONFIG=(
    'alias.ac "!git add -A && git commit"'
    "alias.co checkout"
    "alias.st 'status -sb'"
    "alias.lg \"log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --\""
    "alias.branches 'branch -a'"
    "alias.remotes 'remote -v'"
    "color.ui 1"
  )

  NOTICE "配置 git alias"
  # git
  git config --global user.name $name
  git config --global user.email $email
  for (( i = 0; i < ${#GIT_CONFIG[*]}; i++ )); do
    eval "git config --global ${GIT_CONFIG[$i]}"
  done
}

install-nodejs() {
  INFO "安装 Node.js"
  local NPM=(node-gyp)
  curl -sS https://git.io/n-install | bash -s -- -q
  if [[ $? != 0 ]]; then
    ERROR "node.js 下载失败"
  else
    source ~/.bashrc
    if n lts; then
      npm install ${NPM[*]}
    else
      ERROR "node.js lts 安装失败"
    fi
  fi
}

install-ruby() {
  INFO "安装 Ruby"
  local GEM=(bundler pry)
  wget -qO - https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz | tar xzv
  if [[ $? != 0 ]]; then
    ERROR "Ruby 下载失败"
  else
    cd ruby-install-0.7.0
    make install
    cd -
    if ruby-install --system ruby; then
      gem install ${GEM[*]}
    else
      ERROR "Ruby 安装失败"
    fi
  fi
}

install-rust() {
  INFO "安装 Rust"
  curl -sS https://sh.rustup.rs | bash -s -- -y
  if [[ $? != 0 ]]; then
    ERROR "Rust 下载失败"
  else
    echo -en "\nsource ~/.cargo/env;" >> ~/.bashrc
  fi
}

install-operation-tools() {
  INFO "安装运维工具"
  pip install ansible
  pip install shadowsocks
}

install-dependencies() {
  NOTICE "软件更新"
  export DEBIAN_FRONTEND=noninteractive
  apt update -yq; apt dist-upgrade -yq #&> /dev/null
  # TODO: 换源
  apt install -yq --reinstall ca-certificates #&> /dev/null
  INFO "安装开发套件"
  apt install -yq git git-core gcc g++ make gyp automake bison openssl autoconf libssl-dev libtool build-essential zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev  libc6-dev ncurses-dev libcurl4-openssl-dev libapr1-dev libaprutil1-dev libx11-dev libffi-dev tcl-dev tk-dev libcap2-bin libcairo2-dev libjpeg8-dev libpango1.0-dev libgif-dev build-essential libpixman-1-dev dump curl traceroute sshfs cifs-utils hostapd openssh-server htop net-tools iptstate ufw python-pip psmisc privoxy autossh manpages-zh #&> /dev/null
  unset DEBIAN_FRONTEND
}

main() {
  config-system

  install-dependencies
  # # install-operation-tools

  config-git
  # config-ssh
  # config-shadowsocks
  config-dir

  # install-rust
  install-nodejs
  # install-ruby

  true
}

main