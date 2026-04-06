if status is-interactive

    set -g fish_greeting ""

    fastfetch

    function fish_prompt
        set -l last_status $status
        
        if set -q NEW_LINE_BEFORE_PROMPT
            echo ""
        end
        set -g NEW_LINE_BEFORE_PROMPT true

        # Folder saat ini
        echo -n (set_color yellow)"󰉖 "(basename (prompt_pwd))" "

        # Info Git
        set -l git_branch (fish_git_prompt)
        if test -n "$git_branch"
            echo -n (set_color magenta)"󰊢"$git_branch" "
        end

        # Simbol input 2-baris
        if test $last_status -eq 0
            echo -e "\n"(set_color white)"❯ "
        else
            echo -e "\n"(set_color red)"❯ "
        end
    end
end
