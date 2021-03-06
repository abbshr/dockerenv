# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

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

export LANG="zh_CN.UTF-8"
export LANGUAGE="zh_CN:zh"
export LC_ALL="zh_CN.UTF-8"

export EDITOR="/usr/bin/vim"

export MACOS_PATH="/Users/xxx/mnt-linux"

code() {
    local SPEC_DIR=$(realpath ${1})
    local SUB_SPEC_DIR=${SPEC_DIR/\/root}
    ssh mac "code ${MACOS_PATH}${SUB_SPEC_DIR}"
}
