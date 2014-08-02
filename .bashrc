#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set persistent environment variables
export LESS="-RCQaix2"  # Raw control chars, clear screen, totally quiet, search skip screen, ignore case, tab stop = 4
export EDITOR=/usr/bin/nano     # CLI editor
export VISUAL=/usr/bin/mousepad # GUI editor

# Keyring daemon
if [ -v XDG_RUNTIME_DIR ]; then
    export GNOME_KEYRING_CONTROL=$XDG_RUNTIME_DIR/keyring
    export GPG_AGENT_INFO=$XDG_RUNTIME_DIR/keyring/gpg:0:1
    export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/keyring/ssh
fi

# Shell behaviour tweaks
shopt -s autocd         # Change to directory if command is the path to a directory.
shopt -s checkwinsize   # Monitors the window size and updates $LINES and $COLUMNS accordingly.
shopt -s cmdhist        # Saves all lines of a multi-line command together in a single history entry.
shopt -s dotglob        # Include '.'-prefixed files in the results of pathname expansion.
shopt -s extglob        # Enable extended pattern matching in all expansion.

## Multi-session history settings ## {{{

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

#export PROMPT_COMMAND=_bash_history_sync;history -a;echo -en "\e]2;";history 1|sed "s/^[ \t]*[0-9]\{1,\}  //g";echo -en "\e\\"
export PS1="\[\e[31m\]\\[\e[00;32m\]\u\[\e[00m\]@\[\e[00;31m\]\h\[\e[00m\]:\[\e[00;36m\]\w\[\e[00m\] "
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

## }}}

# Per-session console logging
if [[ $(ps -p $PPID -o comm=) = "tmux" ]]; then
    logfile="$(date -Isecond).$TERM.log"
    logdir=$HOME/.logs
    mkdir $logdir 2> /dev/null
    script -q $logdir/$logfile
    exit
fi

# Error trapping
EC() { echo -e '\e[1;33m'code $?'\e[m\n'; }
trap EC ERR

## Safety features ## {{{
alias cp='cp -i'                    # Prompt before overwrite
alias mv='mv -i'                    # Prompt before overwrite
alias rm='timeout 3 rm -Ivd --one-file-system' # Prompt before removal and halt longlasting remove commands
alias ln='ln -i'                    # Prompt before removal
alias chown='chown --preserve-root' # Fail on recursive operation over root
alias chmod='chmod --preserve-root' # Fail on recursive operation over root
alias chgrp='chgrp --preserve-root' # Fail on recursive operation over root
alias cls=' echo -ne "\033c"'       # clear screen for real (it does not work in Terminology)
# }}}

## One-letter shortcuts ## {{{
alias c='clear'
alias h='history'
alias j='jobs -l'
# }}}

## New commands ## {{{

alias nowtime=n'date +"%T %Z"'
alias nowdate='date +"%Y-%m-%d %a W%W"'
alias now='date +"%Y-%m-%d %a W%W, %T %Z"'
alias nowdatetime='now'

alias path='echo -e ${PATH//:/\\n}'
alias lsmount='mount | column -t'

alias md5='openssl md5'
alias sha1='openssl sha1'
alias sha256='openssl sha256'

alias ports='ss --all --numeric --processes --ipv4 --ipv6'
alias psc='ps xawf -eo pid,user,cgroup,args'
alias fastping='ping -c 15 -i 0.2'

alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
alias cpuinfo='lscpu'
alias gpumeminfo='grep -i --color memory /var/log/Xorg.0.log'

# }}}

## Default options ## {{{
alias bc='bc -l'            # Auto-include math library
alias cd="cd -P"            # Handle '..' physically as symbolic link components shall be resolved first
alias df='df -H'            # Format sizes in human-readable units
alias du='du -ch'           # Format sizes in human-readable units and append grand total
alias mkdir='mkdir -pv'     # Create parent dirs as needed
alias nano='nano -w'        # Disable word wrap
alias ping='ping -c 5'      # Default ping to 5 attempts
alias wget='wget -c'        # Auto-resume downloads
## }}}

# Replace existing commands
alias diff='colordiff'
alias more='less'
alias pgrep='psc|grep'
alias su='sudo -i'

# Colourise commands
for cmd in \
        ls grep egrep fgrep pacman ; do
    alias "${cmd}=${cmd} --color=always"
done

# Abbreviations
alias xci='xclip -selection clipboard -i'
alias xco='xclip -selection clipboard -o'
alias du1='du --max-depth=1'
alias du2='du --max-depth=2'
alias du3='du --max-depth=3'

# Error tolerance
alias :q=' exit'
alias :Q=' exit'
alias :x=' exit'

## ls ## {{{
alias lh='ls -hF'
alias l1='lh -1'                    # listing
alias lr='lh -R'                    # recursive ls
alias ll='lh -l'                    # long listing
alias la='ll -A'
alias lx='ll -BX'                   # sort by ext
alias lz='ll -rS'                   # sort by size
alias lt='ll -rt'                   # sort by date
alias l.='ll -d .*'                 # list hidden files
alias lm='l. | more'                # paginate with hidden files
# }}}

## cd ## {{{
alias  cd..='cd ..'
alias    ..='cd ..'
alias   ...='cd ../../../'
alias  ....='cd ../../../../'
alias .....='cd ../../../../'
alias    .3='cd ../../../'
alias    .4='cd ../../../../'
alias    .5='cd ../../../../..'
# }}}


## Auto-sudo privileged commands ## {{{
if [ $UID -ne 0 ]; then
    alias sudo='sudo '
    alias suedit='ex sudo -e'
    for cmd in \
            chroot fdisk gdisk cgdisk sgdisk mount umount losetup partprobe blkid dd \
            foremost \
            chown chmod chgrp \
            lsblk lsof lslogins lspci lsusb lsusb.py \
            rmmod modprobe usermod dkms modinfo lsmod \
            auditctl systemctl \
            pkill kill ps htop \
            pacman updatedb powerpill pacman-optimize \
            wifi-menu netctl netctl-auto rfkill \
            hdparm sdparm ; do
        alias $cmd="sudo $cmd"
    done
fi
## }}}

## Systemd system and service manager ## {{{

# System service manager
alias sys='systemctl'
alias syss='sys start'
alias syst='sys stop'
alias syse='sys enable'
alias sysd='sys disable'
alias sysr='sys reload-or-try-restart'
alias sysR='sys try-restart'
alias sysS='sys status'
alias sysF='sys --failed'
alias sysA='sys --all'

# User service manager
alias sysu='\systemctl --user'
alias sysus='sysu start'
alias sysut='sysu stop'
alias sysue='sysu enable'
alias sysud='sysu disable'
alias sysur='sysu reload-or-try-restart'
alias sysuR='sysu try-restart'
alias sysuS='sysu status'
alias sysuF='sysu --failed'
alias sysuA='sysu --all'

# Power commands.
alias hibernate='sys hibernate'
alias hybrid-sleep='sys hybrid-sleep'
alias reboot='sys reboot'
alias poweroff='sys poweroff'
alias suspend='sys suspend'

## }}}

## Arch Linux package management ## {{{

alias pac='yaourt'
alias pack='package-query'
alias pacsyu='pac -Syu'             # Synchronize local and ABS with repositories and then upgrade local packages that are out of date
alias pacsy='pac -Sy'               # Update and refresh the package list against repositories
alias pacsc='pac -Sc'               #
alias pacs='pac -S'                 # Install specific package(s) from the repositories
alias pacu='pac -U'                 # Install specific package not from the repositories but from a file
alias pacsd='pac -S --asdeps'       # Install given package(s) as dependencies of another package
alias pacr='pac -R'                 # Remove the specified package(s), retaining its configuration(s) and required dependencies
alias pacrns='pac -Rns'             # Remove the specified package(s), its configuration(s) and unneeded dependencies
alias pacsi='pac -Si'               # Display information about a given package in the repositories
alias pacas='pack -As --sort w'     # Search for package(s) in the repositories
alias pacss='pack -Ss --sort n'     # Search for package(s) in the repositories
alias pacsl='pac -Sl'               # Search for package(s) in the repositories
alias pacqi='pac -Qi'               # Display information about a given package in the local database
alias pacqs='pack -Qs --sort n'     # Search for package(s) in the local database
alias pacql='pac -Ql'               # Search for package(s) in the local database
alias pacqo='pac -Qo'               # Search for package(s) that own the specified file(s)

# '[r]emove [o]rphans' - recursively remove ALL orphaned packages
alias pacro="/usr/bin/pacman -Qtdq > /dev/null && sudo /usr/bin/pacman -Rns \$(/usr/bin/pacman -Qtdq | sed -e ':a;N;$!ba;s/\n/ /g')"

alias pacman-disowned-dirs="comm -23 <(sudo find / \( -path '/dev' -o -path '/sys' -o -path '/run' -o -path '/tmp' -o -path '/mnt' -o -path '/srv' -o -path '/proc' -o -path '/boot' -o -path '/home' -o -path '/root' -o -path '/media' -o -path '/var/lib/pacman' -o -path '/var/cache/pacman' \) -prune -o -type d -print | sed 's/\([^/]\)$/\1\//' | sort -u) <(pacman -Qlq | sort -u)"
alias pacman-disowned-files="comm -23 <(sudo find / \( -path '/dev' -o -path '/sys' -o -path '/run' -o -path '/tmp' -o -path '/mnt' -o -path '/srv' -o -path '/proc' -o -path '/boot' -o -path '/home' -o -path '/root' -o -path '/media' -o -path '/var/lib/pacman' -o -path '/var/cache/pacman' \) -prune -o -type f -print | sort -u) <(pacman -Qlq | sort -u)"

## }}}

# Execute command in a subshell
function ex() {
    exec "$@" &> /dev/null &
}

# Edit arguments as files with default editor in subshell
function edit() {
    if [ $UID -ne 0 ]; then
        SUDO='sudo'
    else
        SUDO=
    fi

    if [ -n "${VISUAL}" -a -x "${VISUAL}" ]; then
        ex "${SUDO}" "${VISUAL}" "$@"
    elif [ -n "${EDITOR}" -a -x "${EDITOR}" ]; then
        ex "${SUDO}" "${VISUAL}" "$@"
    else
        "${SUDO}" less "$@"
    fi
}

# Swap two files
function swap()
{
    if [ $# -ne 2 ]; then
        echo "Usage: swap file1 file2"
    else
        local TMPFILE=$(mktemp)
        mv "$2" "$1"
        mv $TMPFILE "$2"
    fi
}

# Multi-format archie extractor
# extract [file1] [file2] [file3] ...
extract() {
    local c e i

    (($#)) || return

    for i; do
        c=''
        e=1

        if [[ ! -r $i ]]; then
            echo "$0: file is unreadable: \`$i'" >&2
            continue
        fi

        case $i in
            *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz)))))
                   c=(bsdtar xvf);;
            *.7z)  c=(7z x);;

            *.Z)   c=(uncompress);;
            *.bz2) c=(bunzip2);;
            *.exe) c=(cabextract);;
            *.gz)  c=(gunzip);;
            *.rar) c=(unrar x);;
            *.xz)  c=(unxz);;
            *.zip) c=(unzip);;
            *)     echo "$0: unrecognized file extension: \`$i'" >&2
                   continue;;
        esac

        command "${c[@]}" "$i"
        ((e = e || $?))
    done
    return "$e"
}

# List loaded kernel modules and their properties
function aa_mod_parameters() {
    N=/dev/null;
    C=`tput op` O=$(echo -en "\n`tput setaf 2`>>> `tput op`");
    for mod in $(cat /proc/modules|cut -d" " -f1);
    do
        md=/sys/module/$mod/parameters;
        [[ ! -d $md ]] && continue;
        m=$mod;
        d=`modinfo -d $m 2>$N | tr "\n" "\t"`;
        echo -en "$O$m$C";
        [[ ${#d} -gt 0 ]] && echo -n " - $d";
        echo;
        for mc in $(cd $md; echo *);
        do
            de=`modinfo -p $mod 2>$N | grep ^$mc 2>$N|sed "s/^$mc=//" 2>$N`;
            echo -en "\t$mc=`cat $md/$mc 2>$N`";
            [[ ${#de} -gt 1 ]] && echo -en " - $de";
            echo;
        done;
    done
}
function show_mod_parameter_info() {
    if tty -s <&1
    then
        green="\e[1;32m"
        yellow="\e[1;33m"
        cyan="\e[1;36m"
        reset="\e[0m"
    else
        green=
        yellow=
        cyan=
        reset=
    fi
    newline=$'\n'

    while read mod
    do
        md=/sys/module/$mod/parameters
        [[ ! -d $md ]] && continue
        d="$(modinfo -d $mod 2>/dev/null | tr "\n" "\t")"
        echo -en "$green$mod$reset"
        [[ ${#d} -gt 0 ]] && echo -n " - $d"
        echo
        pnames=()
        pdescs=()
        pvals=()
        pdesc=
        add_desc=false
        while IFS="$newline" read p
        do
            if [[ $p =~ ^[[:space:]] ]]
            then
                pdesc+="$newline    $p"
            else
                $add_desc && pdescs+=("$pdesc")
                pname="${p%%:*}"
                pnames+=("$pname")
                pdesc=("    ${p#*:}")
                pvals+=("$(cat $md/$pname 2>/dev/null)")
            fi
            add_desc=true
        done < <(modinfo -p $mod 2>/dev/null)
        $add_desc && pdescs+=("$pdesc")
        for ((i=0; i<${#pnames[@]}; i++))
        do
            printf "  $cyan%s$reset = $yellow%s$reset\n%s\n" \
                ${pnames[i]} \
                "${pvals[i]}" \
                "${pdescs[i]}"
        done
        echo

    done < <(cut -d' ' -f1 /proc/modules | sort)
}
