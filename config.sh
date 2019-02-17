#!/bin/bash

config-system() {
  rm -rf /bin/sh
  ln -s /bin/bash /bin/sh
  # 剪裁系统缺失开发套件和 man page，这里还原完整版
  unminimize
  # 中文环境
  locale-gen zh_CN.UTF-8
}

config-dir() {
  mkdir -p ~/{github,gitlab,downloads,config,test,.ssh}
}

config-ssh() {
  # fix: 转义问题
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

  # git
  git config --global user.name $name
  git config --global user.email $email
  for (( i = 0; i < ${#GIT_CONFIG[*]}; i++ )); do
    eval "git config --global ${GIT_CONFIG[$i]}"
  done
}

install-nodejs() {
  local NPM=(node-gyp)
  curl -L https://git.io/n-install | bash -s -- -q && source ~/.bashrc
  npm install ${NPM[*]}
}

install-ruby() {
  local GEM=(bundler pry)

  wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
  tar -xzvf ruby-install-0.7.0.tar.gz
  cd ruby-install-0.7.0
  make install
  cd -
  ruby-install --system ruby
  gem install ${GEM[*]}
}

install-rust() {
  curl https://sh.rustup.rs -sSf | bash -s -- -y
  echo -en "\nsource ~/.cargo/env;" >> ~/.bashrc
  unset CARGO_HOME
  unset RUSTUP_HOME
}

install-operation-tools() {
  pip install ansible
  pip install shadowsocks
}

install-dependencies() {
  export DEBIAN_FRONTEND=noninteractive
  apt update -yq; apt dist-upgrade -yq
  # TODO: 换源
  apt install -yq --reinstall ca-certificates
  apt install -yq net-tools iproute2 iputils-* lsof git git-core gcc g++ make gyp automake bison openssl autoconf libssl-dev libtool build-essential zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev  libc6-dev ncurses-dev libcurl4-openssl-dev libapr1-dev libaprutil1-dev libx11-dev libffi-dev tcl-dev tk-dev libcap2-bin libcairo2-dev libjpeg8-dev libpango1.0-dev libgif-dev build-essential libpixman-1-dev dump curl traceroute sshfs cifs-utils hostapd ssh openssh-server htop iptables iptstate ufw python-pip vim psmisc privoxy autossh manpages-zh
  unset DEBIAN_FRONTEND
}

main() {
  install-dependencies
  # # install-operation-tools
  # install-rust
  # install-nodejs
  # install-ruby

  config-system
  config-git
  config-ssh
  config-dir
}

main