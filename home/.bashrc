# ~/.bashrc
#
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source utility-library

PATHDIRS=(
    #~ /usr/bin/vendor_perl
    #~ /usr/bin/core_perl
    #~ /usr/bin/site_perl
    $(cope_path)
)
for PATHDIR in "${PATHDIRS[@]}" ; do
    [ -d "$(realpath $PATHDIR)" -a ! "$(echo $PATH | grep -q $PATHDIR)" ] && PATH=$PATHDIR:$PATH
done

# Per-session console logging
TERM_BIN=$(ps -p $PPID -o comm=)
TERM_BINS=(screen tmux)
if [[ " ${TERM_BINS[*]} " =~ " $TERM_BIN " ]]; then
    logfile="$(date -Isecond).$TERM"
    logdir=$HOME/.log/$TERM_BIN
    mkdir -p $logdir 2> /dev/null
    script -qaf $logdir/$logfile.log
    exit
fi

msg SSH/GPG Key Agent
$(gnome-keyring-daemon | sed 's/^/export /')

msg Multi-session history settings ## {{{

        HISTSIZE=9000
        HISTFILESIZE=$HISTSIZE
export  HISTCONTROL=ignoreboth
export  HISTIGNORE='history*'

_bash_history_sync() {
  builtin history -a         #1
  HISTFILESIZE=$HISTSIZE     #2
  builtin history -c         #3
  builtin history -r         #4
}

history() {
  _bash_history_sync
  builtin history "$@"
}

export PROMPT_COMMAND=_bash_history_sync;history -a;echo -en "\e]2;";history 1|sed "s/^[ \t]*[0-9]\{1,\}  //g";echo -en "\e\\"
export PS1="\[\e[31m\]\\[\e[01;32m\]\u\[\e[00m\]@\[\e[01;31m\]\h\[\e[00m\] \[\e[01;36m\]\w\[\e[00m\]\$(__drush_ps1) "
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

## }}}

msg Set DISPLAY variable
test ! -v DISPLAY -a $(systemctl is-active display-manager.service) = active && \
    export DISPLAY=:$(ls -1 /tmp/.X11-unix | tail -c +2)
export VDPAU_DRIVER=va_gl

# Error trapping
# trap 'echo -e "\e[1;33m"code $?. line $LINENO"\e[m"' ERR

ulimit -S -c 0      # Don't want coredumps.
set -o notify
set -o noclobber
set -o ignoreeof

# Shell behaviour tweaks
shopt -s autocd         # Change to directory if command is the path to a directory.
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize   # Monitors the window size and updates $LINES and $COLUMNS accordingly.
shopt -s cmdhist        # Saves all lines of a multi-line command together in a single history entry.
shopt -s extglob        # Enable extended pattern matching in all expansion.
shopt -s histappend histreedit histverify
shopt -s no_empty_cmd_completion
shopt -s sourcepath
shopt -u mailwarn
unset MAILCHECK        # Don't want my shell to warn me of incoming mail.

export LESSOPEN="| /usr/bin/source-highlight-esc.sh %s"
export LESS="-RCQaix2"  # Raw control chars, clear screen, totally quiet, search skip screen, ignore case, tab stop = 4
export LESS_TERMCAP_me=$(printf '\e[0m')
export LESS_TERMCAP_se=$(printf '\e[0m')
export LESS_TERMCAP_ue=$(printf '\e[0m')
export LESS_TERMCAP_mb=$(printf '\e[1;32m')
export LESS_TERMCAP_md=$(printf '\e[1;34m')
export LESS_TERMCAP_us=$(printf '\e[1;32m')
export LESS_TERMCAP_so=$(printf '\e[1;44;1m')
export EDITOR=/usr/bin/nano
export VISUAL=/usr/bin/mousepad

# User specific aliases and functions

msg Safety features ## {{{
alias cp='cp -i'                    # Prompt before overwrite
alias mv='mv -iv'                   # Prompt before overwrite
alias rm='timeout 3 rm -Iv   --one-file-system' # Prompt before removal and halt longlasting remove commands
alias ln='ln -i'                    # Prompt before removal
alias mkdir='mkdir -pv'
alias chown='chown --preserve-root' # Fail on recursive operation over root
alias chmod='chmod --preserve-root' # Fail on recursive operation over root
alias chgrp='chgrp --preserve-root' # Fail on recursive operation over root
alias cls=' echo -ne "\033c"'       # clear screen for real (it does not work in Terminology)
# }}}

alias df='df -h'                    # Format sizes in human-readable units
alias du='du -c -h'                 # Format sizes in human-readable units and append grand total
alias mkdir='mkdir -p -v'           # Create parent dirs as needed
alias ddd='\dd '                    # Create an alternative to overloaded word, dd
alias cd="cd -P"                    # Handle '..' physically as symbolic link components shall be resolved first

# Colourize command outputs
alias diff='colordiff'
alias grep='grep --color=always'

alias xargs='xargs '                # Allow aliases in xargs statements
alias free='free -hlt'
alias nano='nano -w'                # Disable word wrap
function ping() {
  if [ $# -eq 0 ]; then
    ping -c5 8.8.8.8                # Default ping to 5 attempts to Google's primary DNS
  else
    ping -c5 "$@"                   # Default ping to 5 attempts
  fi
}
alias xclip='xclip -selection clipboard -i'
alias inbin='sudo install -Dm755 -t /usr/local/bin '
alias trr='transmission-remote'
alias rm-chrome-crash-dumps='sudo \rm -rf ~/.config/google-chrome-unstable-backup-crashrecovery-*'
alias spt='speedtest'
alias btc='bluetoothctl'

alias boinccmd='command boinccmd --passwd $(sudo cat /var/lib/boinc/gui_rpc_auth.cfg) '
alias boinc-on='boinccmd --set_run_mode always '
alias boinc-auto='boinccmd --set_run_mode auto '
alias boinc-off='boinccmd --set_run_mode never '
alias boinc-project-status='boinccmd --get_project_status '
alias boinc-client-status='boinccmd --get_cc_status '
alias boinc-simple-status='boinccmd --get_simple_gui_info '
alias boinc-state='boinccmd --get_state '
alias boinc-host-info='boinccmd --get_host_info '
alias boinc-transfer-history='boinccmd --get_daily_xfer_history '
alias boinc-disk-usage='boinccmd --get_disk_usage '
alias boinc-network-on='boinccmd --set_network_mode always; boinccmd --network_available '
alias boinc-count-messages='boinccmd --get_message_count'
alias boinc-get-message='boinccmd --get_messages '
alias boinc-get-notice='boinccmd --get_notices '
alias boinc-get-tasks='boinccmd --get_tasks '
alias boinc-quit='boinccmd --quit '
alias boinc-benchmarks='boinccmd --run_benchmarks '

# Development aliases
alias bin-install='sudo install -m755 -t /usr/local/bin'
alias brc-edit='geany ~/.bashrc'
alias brc='source ~/.bashrc'
alias debug="set -o nounset; set -o xtrace; true"
function geany() {
  case $(ps -o stat= -p $$) in
    *+*) command geany "$@" & ;;
    *) command geany "$@" ;;
  esac
}

msg VCS commands ## {{{
export BITDIR=~/Documents/VCS/bitbucket.org
export HUBDIR=~/Documents/VCS/github.org
export LABDIR=~/Documents/VCS/gitlab.org

export AURDIR=~/Documents/VCS/github.org/aur-pkgs
export NESDIR=~/Documents/VCS/github.org/aur-pkgs
NESPREFIX=nestle-ca-

bit-cd() {
    test $# -gt 2 && exit 1
    git-cd "${1:-nestle-ca}" "${2:-onemethod}" 'bitbucket.org'
}
hub-cd() {
    test $# -gt 3 && exit 1
    set -- "${1:-aur-pkgs}" "${2:-jamesan}" "${3:-github.com}"
    repo="$1"
    user="$2"
    domain="$3"
    path=~/Documents/VCS/$domain/$name
    addr="git@$domain:$user/$repo.git"
    if [ -d "$path" ]; then
        git -C $path pull
    else
        if [ "$domain" != 'local' ]; then
            git clone $addr $path
        else
            git -C $path init
        fi
    fi
    pushd "$path"
}
lab-cd() {
    test $# -gt 2 && exit 1
    git-cd "${1:-drupal-ec2-scripts}" "${2:-jamesan}" 'gitlab.com'
}


function nes-cd() {
    test $# -gt 0 || 1=frontend
    REPO_NAME="nestle-ca-$1"; shift
    bit-cd $REPO_NAME "$*"
}

nes-cd() {
    test $# -gt 1 && exit 1
    if [ $# -eq 0 ]; then
        bit-cd 'nestle-ca'
    else
        bit-cd "nestle-ca-$1"
    fi
}
# Aliases that silently ignore parameters
alias aurploader='aurploader -akvn -c ~/.config/aurploader.cookie -l ~/.config/aurploader *.src.tar.gz'
alias aur-log='git -C $AURDIR log; true '
alias aur-push='git -C $AURDIR pull; true '
alias aur-pull='git -C $AURDIR push; true '
alias aur-sync='aur-push && aur-pull && true'
function aur-clean() {
    find $AURDIR -type f -iname '*.pkg.tar*' -exec rm -f {} +
    find $AURDIR -type f -iname '*.src.tar*' -exec rm -f {} +
}

# Aliases that accept optionally parameters
alias aur-status='git -C $AURDIR status '
function aur-cd() {
    if [ $# -gt 0 -a ! -d "$AURDIR/$*" ]; then
        aur-dl "$*"
    fi
    pushd "$AURDIR/$*"
}
function aur-add() {
    if [ $# -eq 0 ]; then
        git -C $AURDIR add '.'
    else
        git -C $AURDIR add "$@"
    fi
}
function aur-commit() {
    if [ $# -eq 0 ]; then
        git -C $AURDIR commit
    else
        git -C $AURDIR commit -m "$*"
    fi
    aur-sync
}

# Aliases that must be passed parameters
function aur-dl() {
    [ $# -gt 0 ] || exit 1
    pushd $AURDIR
    yaourt -G "$@"
    popd
    for PKG in "$@"; do
        aur-add $PKG
        aur-commit "Added $PKG from the AUR."
    done
    aur-sync
    aur-status
}
function aur-makepkg() {
    [ $# -gt 0 ] || exit 1
    aur-clean
    aur-sync
    for PKG in "$@"; do
        if [ -d $AURDIR/$PKG ]; then
            pushd $AURDIR/$PKG
            makepkg -s
            popd
        fi
    done
    aur-clean
    aur-status
}
function aur-up() {
    if [ $# -eq 0 ]; then
        aur-up $(basename $(pwd))
    fi
    aur-clean
    aur-sync
    for PKG in "$@"; do
        if [ -d $AURDIR/$PKG ]; then
            pushd $AURDIR/$PKG
            mkaurball
            aurploader -aknvc ~/.config/aurploader.cookie -l ~/.config/aurploader
            popd
        fi
    done
    aur-clean
    aur-status
}

## }}}

alias hist='history'
alias more='less'
alias du0='du --max-depth=0'
alias du1='du --max-depth=1'

alias ports='ss -rlps46x'
alias psc='ps xawf -eo pid,user,cgroup,args'
alias pgrep='psc|grep'           # requires an argument

# Error tolerance
alias :q=' exit'
alias :Q=' exit'
alias :x=' exit'
alias cd..='cd ..'
alias   ..='cd ..'
alias ecit='exit'
alias eit='exit'
alias exut='exit'

alias edit='[ -v "${VISUAL}" ] && echo "$VISUAL" || ( [ -n "${EDITOR}" ] && echo "$EDITOR" || echo ''less'' )'

# Auto-sudo privileged commands
if [ $UID -ne 0 ]; then
    alias sudo='sudo '
    alias suedit='sudo -e'
    for cmd in \
            chroot fdisk gdisk cgdisk sgdisk mount umount losetup partprobe dd \
            partclone.{btrfs,chkimg,dd,ext2,ext3,ext4,ext4dev,extfs,fat,fat12,fat16,fat32,hfs+,hfsp,hfsplus,imager,info,ntfs,ntfsfixboot,ntfsreloc,reiserfs,restore,vfat} \
            syslinux-install_update gummiboot mkinitcpio \
            foremost \
            lspci lsusb lsusb.py iotop \
            rmmod modprobe usermod dkms modinfo lsmod \
            auditctl systemctl \
            pkill kill ps htop \
            chown chmod chgrp \
            pacman updatedb powerpill pacman-optimize localepurge \
            pkgfile arch-chroot \
            arch-nspawn makechrootpkg mkarchroot \
            ccm ccm32 ccm64 clean-chroot-manager32 clean-chroot-manager64 \
            wifi-menu netctl netctl-auto rfkill \
            hdparm sdparm ; do
        alias $cmd="sudo $cmd"
    done
fi

# Auto-execute commands in subshell
#for cmd in \
#        suedit edit ; do
#    alias $cmd="ex $cmd"
#done

# Power commands.
alias hibernate='sys hibernate'
alias hybrid-sleep='sys hybrid-sleep'
alias reboot='sys reboot'
alias poweroff='sys poweroff'
alias suspend='sys suspend'

# System service manager
alias sys='systemctl'
alias syst='sys start'
alias sysp='sys stop'
alias syse='sys enable'
alias sysd='sys disable'
alias sysr='sys reload-or-try-restart'
alias sysR='sys try-restart'
alias sysS='sys status'
alias sysD='sys daemon-reload'
alias sysI='sys isolate'
alias sysf='sys reset-failed'
alias sysF='sys --failed'
alias sysA='sys --all'

# User service manager
alias sysu='\systemctl --user'
alias sysut='sysu start'
alias sysup='sysu stop'
alias sysue='sysu enable'
alias sysud='sysu disable'
alias sysur='sysu reload-or-try-restart'
alias sysuR='sysu try-restart'
alias sysuS='sysu status'
alias sysuD='sysu daemon-reload'
alias sysuI='sysu isolate'
alias sysuf='sysu reset-failed'
alias sysuF='sysu --failed'
alias sysuA='sysu --all'

# Specific service manager commands
alias syscli='sysI multi-user.target'
alias sysgui='sysI graphical.target'

function syss() {
    syst "$@"
    sysS "$@"
}

function sysus() {
    sysut "$@"
    sysuS "$@"
}

# Package manager
alias pac='yaourt'
alias pack='package-query'

# Cache management
alias pacsy='pac -Sy'
alias pacsc='pac -Sc'
alias pacsyy='pac -Syy'
alias pacscc='pac -Scc'

# Package (un)installation
alias pacsyu='pac -Syu'
alias pacsyau='pac -Syau'
alias pacsau='pac -Sau'
alias pacs='pac -S'
alias pacu='pac -U'
alias pacsd='pac -S --asdeps'
alias pacud='pac -U --asdeps'
alias pacr='pac -R'
alias pacrns='pac -Rns'

# Package installation - no interaction
alias pacsyu!='pac -Syu --noconfirm'
alias pacsyau!='pac -Syau --noconfirm'
alias pacsau!='pac -Sau --noconfirm'
alias pacs!='pac -S --noconfirm'
alias pacu!='pac -U --noconfirm'
alias pacsd!='pac -S --asdeps --noconfirm'
alias pacud!='pac -U --asdeps --noconfirm'
alias pacr!='pac -R --noconfirm'
alias pacrns!='pac -Rns --noconfirm'

# Remote queries
alias pacsi='pac -Si'               # Display information about a given package in the repositories
alias pacsl='pac -Sl'               # Search for package(s) in the repositories
alias pacss='pack -Ss --sort n'
function pacas(){
    pack -Ss --sort n "$@"          # Search for package(s) in the repositories
    pack -As --sort w "$@"          # Search for package(s) in the AUR
}

# Local queries
alias pacqi='pac -Qi'               # Display information about a given package in the local database
alias pacqs='pack -Qs --sort n'     # Search for package(s) in the local database
alias pacql='pac -Ql'               # Search for package(s) in the local database
function pacqo() {                  # Search for package(s) that own the specified file(s)
  [ $# -eq 0 ] && return
  files=()
  for file in "$@"; do
    [ -a $file ] || file=$(which "$file")
    [ $? -eq 0 ] && files+=("$file")
  done
  [ ${#files[@]} -gt 0 ] && pac -Qo "${files[@]}"
}

# Database changes
alias pacddep='pac -D --asdeps'
alias pacdexp='pac -D --asexplicit'

# Paacman lock changes
alias pacunlock="sudo rm /var/lib/pacman/db.lck"   # Delete the lock file /var/lib/pacman/db.lck
alias paclock="sudo touch /var/lib/pacman/db.lck"  # Create the lock file /var/lib/pacman/db.lck

# '[r]emove [o]rphans' - recursively remove ALL orphaned packages
alias pacro="/usr/bin/pacman -Qtdq > /dev/null && sudo /usr/bin/pacman -Rns \$(/usr/bin/pacman -Qtdq | sed -e ':a;N;$!ba;s/\n/ /g')"

alias pacman-disowned-dirs="comm -23 <(sudo find / \( -path '/dev' -o -path '/sys' -o -path '/run' -o -path '/tmp' -o -path '/mnt' -o -path '/srv' -o -path '/proc' -o -path '/boot' -o -path '/home' -o -path '/root' -o -path '/media' -o -path '/var/lib/pacman' -o -path '/var/cache/pacman' \) -prune -o -type d -print | sed 's/\([^/]\)$/\1\//' | sort -u) <(pacman -Qlq | sort -u)"
alias pacman-disowned-files="comm -23 <(sudo find / \( -path '/dev' -o -path '/sys' -o -path '/run' -o -path '/tmp' -o -path '/mnt' -o -path '/srv' -o -path '/proc' -o -path '/boot' -o -path '/home' -o -path '/root' -o -path '/media' -o -path '/var/lib/pacman' -o -path '/var/cache/pacman' \) -prune -o -type f -print | sort -u) <(pacman -Qlq | sort -u)"

## ls ## {{{
eval $(dircolors -b)
alias ls='ls -hF --color=auto'
alias lr='ls -R'                    # recursive ls
alias ll='ls -l'
alias lld='ll -d'
alias la='ll -A'
alias lx='ll -BX'                   # sort by extension
alias lz='ll -rS'                   # sort by size
alias lt='ll -rt'                   # sort by date
alias lm='la | more'
# }}}

## drush ##
alias drush='drush '
alias drhm='drush @hm '
alias drn='drush @nestle.lacolhost.com '
alias sua='sudo -Hu aegir '
alias drs='sua drush @staging.lacolhost.com '
alias pv='provision-verify '
drush site-set -

reset-aegir() {
    sudo systemctl stop aegir.target aegir.service mysqld.service nginx.service php-fpm.service
    sudo pacman -Rns --noconfirm aegir aegir-hostmaster aegir-provision
    getent passwd aegir && sudo userdel -r aegir
    getent group aegir && sudo groupdel aegir

    sudo rm -rf /var/lib/aegir
    sudo rm -rf /var/lib/mysql
    sudo install -dm700 -o mysql -g mysql /var/lib/mysql
    sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    sudo systemctl daemon-reload
    sudo systemctl start mysqld.service nginx.service php-fpm.service
    echo -ne "\ny\nroot\nroot\n\n\n\n\n" | mysql_secure_installation

    aur-cd aegir-provision && makepkg -si --noconfirm
    aur-cd aegir-hostmaster && makepkg -si --noconfirm
    aur-cd aegir && makepkg -si --noconfirm
    sudo systemctl daemon-reload
}

#~## EC2 tools for personal account ##
#~function ec2-ja() {
    #~export AWS_ACCESS_KEY="AKIAJPJH2VZ57GJRTMDQ"
    #~export AWS_SECRET_KEY="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"
    #~export EC2_URL="https://ec2.us-east-1.amazonaws.com"
#~}
#~## EC2 tools for OneMethod ##
#~function ec2-om() {
    #~export AWS_ACCESS_KEY="AKIAJGYQ7GZYJ5Y64ZWQ"
    #~export AWS_SECRET_KEY="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"
    #~export EC2_URL="https://ec2.us-east-1.amazonaws.com"
#~}
#~ec2-ja

# Execute command in a subshell
function ex() {
    exec "$@" &> /dev/null &
}

# Swap two files
function swap() {
    if [ $# -ne 2 ]; then
        echo "Usage: swap file1 file2"
    else
        local TMPFILE=$(mktemp)
        mv "$2" "$1"
        mv $TMPFILE "$2"
    fi
}

# Delect default date format if none specified
function date() {
    if [ $# -eq 0 ]; then
        command date "+%a, %b %d, %Y [%T]"
    else
        command date "$@"
    fi
}

# Include aliases and functions in which command
function which() {
    (alias; declare -f) | env PATH="$(pwd)":$PATH $(/usr/bin/which which) --tty-only --read-alias --read-functions --show-tilde --show-dot $@
}

function varpush() {
    for VAR in "$@"; do
        declare -ga ${VAR}___STACK
        eval "${VAR}___STACK+=(\$$VAR)"
        export ${VAR}___STACK
        unset $VAR
    done
}

function varpop() {
    for VAR in "$@"; do
        unset $VAR
        if [ $(eval "echo \${#${VAR}___STACK[@]}") -gt 0 ]; then
            eval "let NUM=\${#${VAR}___STACK[@]}-1 1"
            eval "$VAR=\${${VAR}___STACK[$NUM]}"
            eval "${VAR}___STACK=(\${${VAR}___STACK[@]:0:$NUM})"
            if [ $NUM -eq 0 ]; then
                unset ${VAR}___STACK
            fi
        fi
    done
}
