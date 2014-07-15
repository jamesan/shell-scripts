#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# export PATH=$PATH
export TERM=xterm-256color

sources=(
    /etc/profile.d/vte.sh                       # vt3 package
   ~/.byobu/prompt                              # byobu prompt
   ~/.bashrc.all                                # custom settings
    /etc/udisks_functions/udisks_functions	# udisks2 cli wrapper
)

# User-specific sourcing
for source in ${sources[@]}; do
    [ -r $source ] && . $source
done

unset source
unset sources

mountpoint -q /media/passport && ! mountpoint -q /var/cache/pacman/pkg  && ~/mount.sh

export GNOME_KEYRING_CONTROL=$XDG_RUNTIME_DIR/keyring
export GPG_AGENT_INFO=$XDG_RUNTIME_DIR/keyring/gpg:0:1
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/keyring/ssh
