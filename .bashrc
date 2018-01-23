# Guard against non-interactive shells.
[[ $- == *i* ]] || return 0


# Set shell options.
shopt -s checkwinsize
shopt -s cmdhist
shopt -s dotglob  # Globs match hidden files.
shopt -s extglob  # Enable extended globbing, e.g. !(*.html|*.css).
shopt -s lithist
shopt -s no_empty_cmd_completion
shopt -s nullglob  # Don’t take non-matching globs literally.
shopt -s globstar  # ** expands to any number of directories.
shopt -s histappend

set -o pipefail


# List boring files.
gumpf='*.7z|*.jar|*.rar|*.zip|*.gz|*.bzip|*.bz2|*.xz|*.lzma|*.cab|*.iso|*.tar|'
gumpf+='*.dmg|*.xpi|*.gem|*.egg|*.deb|*.rpm|*.msi|*.msm|*.msp|secring.*|*.m~|'
gumpf+='*.mex*|slprj|.hg|.hgignore|.hgsigs|.hgsub|.hgsubstate|.hgtags|*.tmp|'
gumpf+='~$*.doc*|~$*.xls*|*.xlk|~$*.ppt*|.DS_Store|.AppleDouble|.LSOverride|'
gumpf+='Icon\r\r|._*|.DocumentRevisions-V100|.fseventsd|.Spotlight-V100|'
gumpf+='.TemporaryItems|.Trashes|.VolumeIcon.icns|.AppleDB|.AppleDesktop|'
gumpf+='Network Trash Folder|Temporary Items|.apdisk|[._]*.s[a-w][a-z]|'
gumpf+='[._]s[a-w][a-z]|Session.vim|.netrwhist|*~|tags|DerivedData|*.pbxuser|'
gumpf+='*.mode1v3|*.mode2v3|*.perspectivev3|xcuserdata|*.moved-aside|'
gumpf+='*.xccheckout|*.xcscmblueprint|.git|node_modules|typings|__pycache__|'
gumpf+='coverage_report'


# Set aliases.
alias ag='ag -s'  # Case-sensitive by default.
alias ascii="ag '[^ -~\\n]'"  # Highlight non-ASCII characters in a file.
alias aq='ag -Q'  # Match literals instead of regexen.
alias b=brew
alias c=clear
alias chdom=chmod  # Common typo.
alias chrome='open -a /Applications/Google\ Chrome.app/'
alias dr=docker
alias dc=docker-compose
alias e=nvim
alias get="curl -sSi -X GET -H 'Accept: application/json'"
alias grep='grep --color=auto --exclude-dir=.git'
alias l='ls --color=auto'
alias la='l -A'
alias ll=$'l -AhFl --time-style=\'+%Y-%m-%d %H:%M\n%a %d %b %H:%M\''
alias m=man
alias mdl='mdl --style ~/.mdstyle'
alias n=npm
alias o=open
alias post="curl -sSi -X POST -H 'Content-type: application/json' -d"
alias printenv="printenv | sort | grep -Pe '^[A-Z][A-Z0-9_]*(?==)'"
alias put="curl -sSi -X PUT -H 'Content-type: application/json' -d"
alias py='clear && bpython'
alias sudoa='sudo '  # An alias of sudo that expands aliases.
alias q=logout
alias t="tree -I \"$gumpf\""
alias vi=nvim
alias vim=nvim
alias vimdiff='nvim -d'
alias vd=vimdiff


# Function to make a new directory and change into it.
mkcd() {
    mkdir "$@" && cd "$_"
}


# Function to make a new directory with a memorable name.
temp() {
    SRC="$HOME/resources"
    if [[ -f $SRC/adjectives && -f $SRC/animals ]]; then
        iAdj=$RANDOM
        nAdj=$(grep -c "." $SRC/adjectives)
        (( iAdj %= nAdj ))
        iAml=$RANDOM
        nAml=$(grep -c "." $SRC/animals)
        (( iAml %= nAml ))
        (( iAdj++, iAml++ ))
        NAME=$(sed -n "$iAdj p" $SRC/adjectives)
        NAME=${NAME}-$(sed -n "$iAml p" $SRC/animals)
        mkdir -vm 700 $NAME
    else
        mktemp -dp . temp-XXXX
    fi
}


# Run login items.
binsync > /dev/null


# Other things that need loading.
if which rbenv &> /dev/null; then eval "$(rbenv init -)"; fi
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"
[[ -f $HOME/.git-completion.bash ]] && source "$HOME/.git-completion.bash"
[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
[[ -f $HOME/.bowman.bash ]] && source "$HOME/.bowman.bash"
if which fasd &> /dev/null; then eval "$(fasd --init auto)"; fi
if which pyenv &> /dev/null; then eval "$(pyenv init -)"; fi
if which pyenv-virtualenv &> /dev/null; then eval "$(pyenv virtualenv-init -)"; fi


# Customise command prompt.
[[ -f $HOME/.git-prompt.sh ]] && source "$HOME/.git-prompt.sh"
PROMPT_COMMAND='custom_prompt;history -a'
custom_prompt() {
    local raw_status=$? # Must come first!
    local raw_pyenv="$(pyenv version-name)"
    local raw_host='\u@\h'
    local raw_path=$(pwd | sed -e "s|^${HOME}|~|" -re 's|([^/]{0,2})[^/]*/|\1/|g')
    local raw_branch=$(__git_ps1 '%s')

    if [[ "$raw_pyenv" == "$(pyenv global)" ]]; then
        raw_pyenv=
    fi

    local ARROW=$'\ue0b0'
    local BG='48;5;'
    local FG='38;5;'
    local RESET="\[\e[0m\]"
    local RESET_BG="\[\e[48;5;235m\]" # 49 is buggy on Terminal.app

    # Text colours.
    local STATUS_FG=223 # gruvbox fg
    local PYENV_FG=223  # gruvbox fg
    local HOST_FG=248   # gruvbox fg3
    local PATH_FG=246   # gruvbox gray
    local BRANCH_FG=246 # gruvbox gray

    # Background colours.
    local STATUS_BG=166 # gruvbox orange
    local PYENV_BG=66   # gruvbox blue
    local HOST_BG=241   # gruvbox bg3
    local PATH_BG=239   # gruvbox bg2
    local BRANCH_BG=237 # gruvbox bg1

    local pretty_status="\[\e[$FG$STATUS_FG;$BG${STATUS_BG}m\] $raw_status "
    local pretty_pyenv="\[\e[$FG$PYENV_FG;$BG${PYENV_BG}m\] $raw_pyenv "
    local pretty_host="\[\e[$FG$HOST_FG;$BG${HOST_BG}m\] $raw_host "
    local pretty_path="\[\e[$FG$PATH_FG;$BG${PATH_BG}m\] $raw_path "
    local pretty_branch="\[\e[$FG$BRANCH_FG;$BG${BRANCH_BG}m\] $raw_branch "

    if [[ -n $raw_pyenv ]]; then
        local status_arrow_bg=$PYENV_BG
    else
        local status_arrow_bg=$HOST_BG
    fi

    if [[ -n $raw_branch ]]; then
        local branch_arrow_fg=$BRANCH_BG
    else
        local branch_arrow_fg=$PATH_BG
    fi

    local status_arrow="\[\e[$FG$STATUS_BG;$BG${status_arrow_bg}m\]$ARROW"
    local pyenv_arrow="\[\e[$FG$PYENV_BG;$BG${HOST_BG}m\]$ARROW"
    local host_arrow="\[\e[$FG$HOST_BG;$BG${PATH_BG}m\]$ARROW"
    local path_arrow="\[\e[$FG$PATH_BG;$BG${BRANCH_BG}m\]$ARROW"
    local branch_arrow="\[\e[$FG${branch_arrow_fg}m\]$RESET_BG$ARROW"

    if [[ -z $raw_pyenv ]]; then
        pretty_pyenv=
        pyenv_arrow=
    fi

    if [[ $raw_status -eq 0 ]]; then
        pretty_status=
        status_arrow=
    fi

    if [[ -z $raw_branch ]]; then
        pretty_branch=
        path_arrow=
    fi

    PS1="$pretty_status$status_arrow$pretty_pyenv$pyenv_arrow$pretty_host"
    PS1="$PS1$host_arrow$pretty_path$path_arrow$pretty_branch$branch_arrow$RESET "

    PS2="\[\e[38;5;246;48;5;237m\]...\[\e[38;5;237m\]$RESET_BG$ARROW$RESET "
    PS3="\[\e[38;5;223;48;5;66m\] ${PS3:=Enter a number: }\[\e[38;5;66m\]$RESET_BG$ARROW$RESET "
    PS4="\[\e[38;5;223;48;5;66m\] $0:$LINENO \e[38;5;66m\]$RESET_BG$ARROW$RESET "

    # Set the window title.
    echo -n -e "\033]0;$raw_path\007"
}


# Load colour profile for ls.
if which dircolors &> /dev/null; then
    if [[ -r ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi


# Gimmicks.
if which fortune sed par &> /dev/null; then
    echo
    fortune | sed 's/^/  > /' | par 76
    echo
fi


# Exit cleanly.
true
