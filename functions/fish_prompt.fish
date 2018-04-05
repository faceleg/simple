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
    echo -e ""

    if test "$fish_key_bindings" = "fish_vi_key_bindings"
        or test "$fish_key_bindings" = "fish_hybrid_key_bindings"
        switch "$fish_bind_mode"
            case default
            __print_color 5DAE8B "N "
            case insert
            __print_color 6597ca "I "
            case replace_one
            __print_color FF7676 "R "
            case visual
            __print_color F6F49D "V "
        end
    end

    # User
    #
    set -l user (id -un $USER)
    __print_color FF7676 "$user"


    # Host
    #
    set -l host_name (hostname -s)
    set -l host_glyph " at "

    __print_color ffffff "$host_glyph"
    __print_color F6F49D "$host_name"


    # Current working directory
    #
    set -l pwd_glyph " in "
    set -l pwd_string (prompt_pwd | sed 's|^'$HOME'\(.*\)$|~\1|')

    __print_color ffffff "$pwd_glyph"
    __print_color 5DAE8B "$pwd_string"


    # Git
    #
    if git_is_repo
        set -l current_remote (__git_current_remote)
        set -l git_glyph " on "
        set -l git_branch_glyph

        __print_color ffffff "$git_glyph"
        __print_color 6597ca "$current_remote"

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

        __print_color 6597ca "$git_branch_glyph"

        if __git_upstream_configured
             set -l git_ahead (command git rev-list --left-right --count HEAD...@"{u}" ^ /dev/null | awk '
                $1 > 0 { printf("⇡") } # can push
                $2 > 0 { printf("⇣") } # can pull
             ')

             if test ! -z "$git_ahead"
                __print_color 5DAE8B " $git_ahead"
            end
        end
    end

    __print_color FF7676 "\e[K\n❯ "
end
