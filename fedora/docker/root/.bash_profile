# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

export PATH
if [ -e /root/.nix-profile/etc/profile.d/nix.sh ]; then . /root/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Since this can be invoked as an interactive container, setup bash.
export PS1="[$PCP_CONTAINER_IMAGE] "
PATH=/usr/bin:$PATH
