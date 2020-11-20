source ~/.bashrc
source ~/git-completion.bash
source ~/dotfiles/ssh-completion.bash

#set -eE -o functrace

#failure() {
#  local lineno=$1
#  local msg=$2
#  echo "Failed at $lineno: $msg"
#}
#trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

c_reset='\e[0m'
c_git_clean='\e[0;36m'
c_git_dirty='\e[0;35m'

c_sep=""
c_sub=""
c_black=16
last_c=$c_black

fg() {
    echo "\e[38;5;$1m"
}

bg() {
    echo -ne "\e[48;5;$1m"
    last_c=$1
}

sep() {
    next=$1
    echo -ne "${c_reset}$(fg $last_c)$(bg $next)${c_sep}${c_reset}"
    bg $next
}

c_git='8'
c_git_mod='178'
c_git_untracked='125'
c_git_staged='34'
c_git_stashed='75'
c_user='39'
c_host='124'
c_dir='26'
c_prompt='220'
c_py='220'


# Function to assemble the Git part of our prompt.
in_git_dir() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        return 1
    fi
    return 0
}

in_venv() {
    if [ -z `basename "$VIRTUAL_ENV"` ]; then
        return 1
    fi
    return 0
}

py_prompt() {
  virtual_env=$(cd $VIRTUAL_ENV/.. && pwd)
  echo -ne "$(fg 233)py:`basename $virtual_env`"
}

git_prompt ()
{

    #git fetch 2> /dev/null

    git_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    if [ $? != 0 ]; then
      return
    fi

    if [ "$git_branch" == "HEAD" ]; then
        git_branch=$(git rev-parse --short HEAD)
    fi


    if git diff --quiet 2>/dev/null >&2; then
        git_color="$c_git_clean"
    else
        git_color="$c_git_dirty"
    fi


    if [ "$git_branch" ]; then
        echo -n " $git_branch"
    fi

    rev_list=$(git rev-list --left-right @...@{upstream} 2>/dev/null)

    git_ahead="$(echo "$rev_list" | grep -Ec "^<")"
    if [ "$git_ahead" -gt 0 ]; then
        echo -ne " ↑ $git_ahead"
    fi

    git_behind="$(echo "$rev_list" | grep -Ec "^>")"
    if [ "$git_behind" -gt 0 ]; then
        echo -ne " ↓ $git_behind"
    fi

    status=$(git status --short)

    git_staged=$(echo "$status" | grep -Ec "^(A|M|D|R)")
    if [ "$git_staged" -gt 0 ]; then
        sep $c_git_staged
        echo -ne "● $git_staged"
    fi

    git_modified=$(echo "$status" | grep -Ec "^.M")
    if [ $git_modified ] && [ "$git_modified" -gt 0 ]; then
        sep $c_git_mod
        echo -ne "✚ $git_modified"
    fi

    git_untracked=$(echo "$status" | grep -Ec "^\?\?")
    if [ "$git_untracked" -gt 0 ]; then
        sep $c_git_untracked
        echo -ne "… $git_untracked"
    fi

    git_stashed=$(git stash show --numstat 2>/dev/null | grep -c "")
    if [ $git_stashed ] && [ "$git_stashed" -gt 0 ]; then
        sep $c_git_stashed
        echo -ne "⚑ $git_stashed"
    fi
}


function _prompt {
    bg $c_dir
    echo -ne "${PWD}"
    if in_venv; then
        sep $c_py
        py_prompt
    fi
    if in_git_dir; then
        sep $c_git
        git_prompt
    fi
    sep $c_black
    echo -e ""
}

function prompt {
    PS1="\[\e[0m\]"
    echo "$(_prompt)"
    project_dir=$(pwd | sed -E 's#.*projects\/([a-zA-Z]+).*#🛠\1#')
    echo -n -e "\033]0;$project_dir\007"
}

PROMPT_COMMAND='prompt'
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
GOPATH=$HOME
PATH=$PATH:/Applications/Splunk/bin/:/usr/local/opt/go/libexec/bin:$GOPATH/go/bin:$HOME/bin
set -o vi

alias sshhosts="sed -n 's/^\s*Host\s+\(.*\)\s*/\1/ip' ~/.ssh/config"
alias projects="cd ~/projects"
alias pg_start="pg_ctl -D /usr/local/var/postgres stop -s -m fast"
alias pg_stop="pg_ctl -D /usr/local/var/postgres stop -s -m fast"
alias listening="lsof -P -iTCP -sTCP:LISTEN"
alias flushdns="sudo killall -HUP mDNSResponder"

pyvenv() {
  if [ -f "./venv/bin/activate" ]; then
    source ./venv/bin/activate
  else
    venvlocation=$(pipenv --venv)
    if [ $? ]; then
      source $(pipenv --venv)/bin/activate
    fi
  fi
}

docker_sh() {
  if [ -z $1 ]; then
    echo "Usage: docker_sh CONTAINER"
  fi
  docker exec -ti $1 /bin/bash
}


# AWS Profiles
aws_profile() {
    if [ -z $1 ]; then
        echo "Usage: aws_profile
        [dta|baseline|client0|hip|projectpurple|snapattack|none]"
        return 1
    fi
    PROFILE="default"
    case $1 in
        "none")
            unset AWS_PROFILE
            unset AWS_DEFAULT_PROFILE
            echo "Removed AWS Profile"
            return
            ;;
        *)
            echo "Profile not recognized, using $1 as-is"
            PROFILE=$1
            ;;
    esac

    export AWS_PROFILE="awsaml-$PROFILE-BAHSSO_Admin_Role"
    export AWS_DEFAULT_PROFILE="awsaml-$PROFILE-BAHSSO_Admin_Role"
    echo "Set AWS Profile to: $AWS_PROFILE"
}

export PATH="$HOME/.cargo/bin:$PATH"
