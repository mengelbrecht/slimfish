function slimfish_exec_time -d 'Show command execution time'
    if test $SLIMFISH_DISPLAY_EXEC_TIME -eq 0
        return
    end
    set -l max_exec_time (math "$SLIMFISH_MAX_EXEC_TIME * 1000")
    if test $CMD_DURATION -lt $max_exec_time
        return
    end

    set -l exec_time (echo $CMD_DURATION | humanize_duration)
    echo -sn (set_color $SLIMFISH_EXEC_TIME_COLOR)"$exec_time"(set_color normal)
end

function slimfish_exit_status
    set -l retval $argv[1]
    if test $SLIMFISH_DISPLAY_EXIT_STATUS -eq 0
        return
    end
    if test $retval -ne 0
        set_color $SLIMFISH_EXIT_STATUS_COLOR
        echo -sn "$retval $SLIMFISH_EXIT_STATUS_SYMBOL"
    end
end

function fish_right_prompt
    set -l exit_status (slimfish_exit_status $status)
    set -l exec_time (slimfish_exec_time)
    echo $exec_time $exit_status $_slimfish_gitline_display

    set -e _slimfish_prompt_refresh
    set -e _slimfish_gitline_display
    set -e _slimfish_gitline_output
end

