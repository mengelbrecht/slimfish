# User Host Settings
set -q SLIMFISH_DISPLAY_USER_HOST_INFO;      or set -g SLIMFISH_DISPLAY_USER_HOST_INFO      1
set -q SLIMFISH_USER_COLOR;                  or set -g SLIMFISH_USER_COLOR                  'green'
set -q SLIMFISH_USER_ROOT_COLOR;             or set -g SLIMFISH_USER_ROOT_COLOR             'red'
set -q SLIMFISH_HOST_COLOR;                  or set -g SLIMFISH_HOST_COLOR                  'yellow'

# AWS Info Settings
set -q SLIMFISH_DISPLAY_AWS_INFO;            or set -g SLIMFISH_DISPLAY_AWS_INFO            0
set -q SLIMFISH_AWS_COLOR;                   or set -g SLIMFISH_AWS_COLOR                   'blue'

# CWD Settings
set -q SLIMFISH_CWD_COLOR;                   or set -g SLIMFISH_CWD_COLOR                   'cyan'
set -q SLIMFISH_CWD_ROOT_COLOR;              or set -g SLIMFISH_CWD_ROOT_COLOR              'red'

# Prompt Symbol Settings
set -q SLIMFISH_PROMPT_SYMBOL;               or set -g SLIMFISH_PROMPT_SYMBOL               '∙'
set -q SLIMFISH_PROMPT_SYMBOL_COLOR_READY;   or set -g SLIMFISH_PROMPT_SYMBOL_COLOR_READY   'white'
set -q SLIMFISH_PROMPT_SYMBOL_COLOR_WORKING; or set -g SLIMFISH_PROMPT_SYMBOL_COLOR_WORKING 'red'

# Exec Time Settings
set -q SLIMFISH_DISPLAY_EXEC_TIME;           or set -g SLIMFISH_DISPLAY_EXEC_TIME           1
set -q SLIMFISH_MAX_EXEC_TIME;               or set -g SLIMFISH_MAX_EXEC_TIME               5
set -q SLIMFISH_EXEC_TIME_COLOR;             or set -g SLIMFISH_EXEC_TIME_COLOR             'yellow'

# Exit Status Settings
set -q SLIMFISH_DISPLAY_EXIT_STATUS;         or set -g SLIMFISH_DISPLAY_EXIT_STATUS         1
set -q SLIMFISH_EXIT_STATUS_SYMBOL;          or set -g SLIMFISH_EXIT_STATUS_SYMBOL          '↵'
set -q SLIMFISH_EXIT_STATUS_COLOR;           or set -g SLIMFISH_EXIT_STATUS_COLOR           'red'

# Git Settings
set -q SLIMFISH_ENABLE_GIT;                  or set -g SLIMFISH_ENABLE_GIT                  1

# Async Settings
set -q SLIMFISH_ENABLE_ASYNC;                or set -g SLIMFISH_ENABLE_ASYNC                1


function slimfish_gitline_async_handler --on-signal USR1
    set -l mypid %self
    set -l value (eval echo "\$prompt_slimfish_gitline_$mypid")
    set -e prompt_slimfish_gitline_$mypid
    set -g _slimfish_gitline_output (echo "$value")
    set -e _slimfish_gitline_async_running
    set -g _slimfish_prompt_refresh
    commandline -f repaint
end

function slimfish_user_host -d "Show user and host info"
    if test $SLIMFISH_DISPLAY_USER_HOST_INFO -eq 0
        return
    end
    if test -z "$SSH_CLIENT" -a "$USER" != "$default_user"
        return
    end

    set -l host (hostname -s)
    set -l reset (set_color normal)
    set -l color_host (set_color $SLIMFISH_HOST_COLOR)
    set -l color_user
    if test (id -u "$USER") -eq 0
        set color_user (set_color $SLIMFISH_USER_ROOT_COLOR)
    else
        set color_user (set_color $SLIMFISH_USER_COLOR)
    end

    echo -sn "$color_user$USER$reset@$color_host$host$reset"
end

function slimfish_aws_profile
    if not test $SLIMFISH_DISPLAY_AWS_INFO
        return
    end
    if test -n "$AWS_PROFILE"
        set -l color (set_color SLIMFISH_AWS_COLOR)
        echo -sn "$color$AWS_PROFILE"(set_color normal)
    end
end

function slimfish_cwd
    set -l cwd (prompt_pwd)
    set -l color
    if test "$cwd" = "/"
        set color (set_color $SLIMFISH_CWD_ROOT_COLOR)
    else
        set color (set_color $SLIMFISH_CWD_COLOR)
    end

    echo -sn "$color$cwd"(set_color normal)
end

function slimfish_gitline
    if test $SLIMFISH_ENABLE_GIT -eq 0
        return
    end
    if test $SLIMFISH_ENABLE_ASYNC -eq 0
        set -l dir (dirname (status --current-filename))
        echo -sn (python $dir/gitline.py)
        return
    end
    if set -q _slimfish_prompt_refresh
        echo -sn $_slimfish_gitline_output
        return
    end
    if not set -q _slimfish_gitline_async_running
        set -l dir (dirname (status --current-filename))
        set -g _slimfish_gitline_async_running
        command /usr/bin/env fish $dir/fish_prompt_async.fish %self &
        # command (fish ~/.config/fish/functions/fish_prompt_async.fish %self &
    end
end

function slimfish_prompt_symbol
    set -l color
    if not set -q _slimfish_gitline_async_running
        set color (set_color $SLIMFISH_PROMPT_SYMBOL_COLOR_READY)
    else
        set color (set_color $SLIMFISH_PROMPT_SYMBOL_COLOR_WORKING)
    end
    echo -sn "$color$SLIMFISH_PROMPT_SYMBOL"(set_color normal)
end

function fish_prompt
    # Start gitline early so it can finish more quickly and
    # the prompt symbol color can be correctly adjusted.
    set -g _slimfish_gitline_display (slimfish_gitline)

    set -l user_host (slimfish_user_host)
    set -l cwd (slimfish_cwd)
    set -l aws_profile (slimfish_aws_profile)
    set -l prompt_symbol (slimfish_prompt_symbol)
    echo $user_host $cwd $aws_profile $prompt_symbol ''
end

