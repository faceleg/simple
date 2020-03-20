# Simple
# https://github.com/sotayamashita/simple
#
# MIT © Sota Yamashita

function __git_upstream_configured
    git rev-parse --abbrev-ref @"{u}" > /dev/null 2>&1
end

function __git_current_remote
   set -l current_branch (git_branch_name)
   set -l remote (git config --get-regexp "branch\.$current_branch\.remote" | sed -e "s/^.* //")
   set -l remote_branch (git config --get-regexp "branch\.$current_branch\.merge" | \
     sed "s/^.*refs\/heads\///")

   printf "$current_branch -> "
   if test -n "$remote"
     if [ "$current_branch" = "$remote_branch" ]
       printf "$remote"
     else
       printf "$remote/$remote_branch"
     end
   else
     printf "not pushed"
   end
end

function __print_color
    set -l color  $argv[1]
    set -l string $argv[2]

    set_color $color
    printf $string
    set_color normal
end

function fish_prompt -d "Simple Fish Prompt"
    set -l last_command_status $status

    set -l colour_green 5DAE8B
    set -l colour_white FFFFFF
    set -l colour_blue 6597ca
    set -l colour_red FF7676
    set -l colour_yellow F6F49D

    echo -e ""

    if test "$fish_key_bindings" = "fish_vi_key_bindings"
        or test "$fish_key_bindings" = "fish_hybrid_key_bindings"
        switch "$fish_bind_mode"
            case default
            __print_color $colour_green "N "
            case insert
            __print_color $colour_blue "I "
            case replace_one
            __print_color $colour_red "R "
            case visual
            __print_color $colour_yellow "V "
        end
    end

    # User
    #
    set -l user (id -un $USER)
    __print_color $colour_red "$user"


    # Host
    #
    set -l host_name (hostname -s)
    set -l host_glyph " at "

    __print_color $colour_white "$host_glyph"
    __print_color $colour_yellow "$host_name"


    # Current working directory
    #
    set -l pwd_glyph " in "
    set -l pwd_string (prompt_pwd | sed 's|^'$HOME'\(.*\)$|~\1|')

    __print_color $colour_white "$pwd_glyph"
    __print_color $colour_green "$pwd_string"


    # Git
    #
    if git_is_repo
        set -l current_remote (__git_current_remote)
        set -l git_glyph " on "
        set -l git_branch_glyph

        __print_color $colour_white "$git_glyph"
        __print_color $colour_blue "$current_remote"

        if git_is_touched
            if git_is_staged
                if git_is_dirty
                    set git_branch_glyph " [±]"
                else
                    set git_branch_glyph " [+]"
                end
            else
                set git_branch_glyph " [?]"
            end
        end

        __print_color $colour_blue "$git_branch_glyph"

        if __git_upstream_configured
             set -l git_ahead (command git rev-list --left-right --count HEAD...@"{u}" ^ /dev/null | awk '
                $1 > 0 { printf("⇡") } # can push
                $2 > 0 { printf("⇣") } # can pull
             ')

             if test ! -z "$git_ahead"
                __print_color $colour_green " $git_ahead"
            end
        end
    end

    __print_color $colour_white "\e[K\n"
    if test $last_command_status -ne 0
      __print_color $colour_white "["
      __print_color $colour_red "$last_command_status"
      __print_color $colour_white "] "
      __print_color $colour_red "❯ "
    else
      __print_color $colour_red "❯ "
    end
end
