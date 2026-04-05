if status is-interactive
    # 1. Matikan greeting bawaan di sini
    set -g fish_greeting ""

    fastfetch

    # 2. Logika Prompt dengan baris baru yang cerdas
    function fish_prompt
        set -l last_status $status
        
        # Munculkan baris kosong hanya setelah command pertama selesai
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