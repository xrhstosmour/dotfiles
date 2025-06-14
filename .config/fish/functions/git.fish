# TODO: Replace `fzf` with `skim`.
# Function to stash changes with a default name.
# Usage:
#   git_stash "Stash message" or git_stash
function git_stash
    if test -n "$argv[1]"
        set name "$argv[1]"
    else
        set name (date +'%d_%m_%YT%H_%M_%S')
    end

    git stash push -u -m "$name"
end


# Function to get the deafult branch.
# Usage:
#   git_get_default_branch
function git_get_default_branch
    set default_branch ""

    # Attempt to get the default branch from the remote repository
    set default_branch (git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
    if test -n "$default_branch"
        set default_branch "origin/$default_branch"
    else
        log_error "Could not determine the default branch!"
        return 1
    end

    echo "$default_branch"
end

# Function to fetch and rebase the current branch onto default branch with autostash enabled by default.
# Usage:
#   git_fetch_and_rebase optional_branch/"" true/false
function git_fetch_and_rebase
    set branch_to_rebase_onto ""
    set autostash_enabled "true"

    # Parse arguments.
    if test -n "$argv[1]"
        set branch_to_rebase_onto "$argv[1]"
    end

    if test -n "$argv[2]"
        set autostash_enabled "$argv[2]"
    end

    # Determine branch to rebase onto.
    if test -z "$branch_to_rebase_onto"
        # Get the default branch.
        set branch_to_rebase_onto (git_get_default_branch)

        # Check if the `git_get_default_branch` function succeeded.
        if test $status -ne 0
            log_error "Failed to determine the default branch!"
            return 1
        end
    else
        # Fetch the specific branch if provided
        git fetch origin $branch_to_rebase_onto
        set branch_to_rebase_onto "origin/$branch_to_rebase_onto"
    end


    # Check for uncommitted changes if autostash is disabled.
    if test "$autostash_enabled" = "false"
        if not git diff-index --quiet HEAD --
            log_error "Commit or stash your uncommitted changes before rebasing!"
            return 1
        end
    end

    log_info "Fetching and rebasing onto `$branch_to_rebase_onto`..."

    # Perform fetch and rebase with or without autostash.
    if test "$autostash_enabled" = "true"
        git fetch && git rebase -i "$branch_to_rebase_onto" --autosquash --autostash
    else
        git fetch && git rebase -i "$branch_to_rebase_onto" --autosquash
    end
end

# Function to choose commit to fixup.
# Pressing:
#   - ENTER will fixup the commit
#   - TAB will show the commit changes
#   - ? will toggle the preview
# Usage:
#   git_auto_fix_up
function git_auto_fix_up
    # Get the name of the current branch.
    set current_branch (git rev-parse --abbrev-ref HEAD)

    # Get the default branch.
    set default_branch (git_get_default_branch)
    if test $status -ne 0
        return 1
    end

    # Get the log of the current branch excluding commits from the upstream branch.
    set -l commits_list (git log --oneline --pretty=format:'%h | %s' --no-merges $default_branch..$current_branch | string split '\n')

    # Check if the commits list is empty.
    if test -z "$commits_list"
        echo "No commits found!"
        return 1
    end

    # Loop through the array.
    for line in $commits_list
        # Get commit hash and message.
        set commit_hash (echo $line | awk '{print $1}')
        set commit_message (echo $line | cut -d' ' -f3-)

        # Exclude lines where commit message starts with fixup!
        if not string match -q 'fixup!*' "$commit_message"

            # Print the commit hash and message.
            echo -e "$BOLD_YELLOW$commit_hash$NO_COLOR $BOLD_GREEN|$NO_COLOR $commit_message"
        end
    end | fzf --multi --ansi --bind 'enter:execute(git commit --fixup {1} --no-verify)+abort,tab:execute(git diff {1}^!),?:toggle-preview' --preview '

        # Keep the commit hash and message.
        set commit_hash {1}
        set commit_message (echo {2..} | cut -d"|" -f2- | sed "s/^ //")

        # Get the author, date, and files paths for the commit.
        set author (git show -s --format="%an" $commit_hash)
        set date (git show -s --format="%ad" --date=format-local:"on %d/%m/%Y at %H:%M:%S" $commit_hash)
        set files (git diff-tree --no-commit-id --name-only -r $commit_hash)

        # Color constants are not working in the preview window so we use the hardcoded ANSI escape codes.
        # Add "- " in front of each file line with green color.
        set formatted_files ""
        for file in $files
            set formatted_files "$formatted_files\e[1;32m-\e[0m $file\n"
        end

        echo -e "\e[1;33mHash:\e[0m $commit_hash"
        echo -e "\e[1;33mMessage:\e[0m $commit_message\n"
        echo -e "\e[1;36mAuthor:\e[0m $author"
        echo -e "\e[1;36mDate:\e[0m $date\n"

        # Show "Files:" and the list of files only if there are any files.
        if test -n "$files"
            echo -e "\e[1;32mFiles:\e[0m"
            echo -e "$formatted_files"
        end
    ' --preview-window=right:50%:hidden:wrap

    # Return success status regardless of fzf's exit status
    return 0
end

# Function to show/list git stashes and interact with them using fzf.
# Pressing:
#   - ENTER will apply the stash
#   - DELETE will drop the stash
#   - TAB will show the file changes
#   - ? will toggle the preview
# Usage:
#   git_stash_list
function git_stash_list
    # Get the stash list as an array.
    set -l stash_list (git stash list -n 50 --pretty=format:'%h|%s' | string split '\n')

    # Check if the stash list is empty.
    if test -z "$stash_list"
        log_error "No stashes found!"
        return 1
    end

    # Loop through the array.
    for line in $stash_list
        # Extract the stash hash by splitting based on "|".
        set stash_hash (echo "$line" | cut -d'|' -f1 | xargs)

        # Extract the stash message and keep it clean, without the branch.
        set stash_message (echo "$line" | cut -d'|' -f2- | xargs)
        set stash_message (echo "$stash_message" | sed 's/^On [^:]*: //')

        # Print the branch related to the stash and its message.
        echo -e "$BOLD_YELLOW$stash_hash$NO_COLOR $BOLD_GREEN|$NO_COLOR $stash_message"
    end | fzf --ansi --bind 'enter:execute(git stash apply (git log -g stash --format="%h %gd" | grep -m 1 {1} | awk "{print \$2}"))+abort,delete:execute(git stash drop (git log -g stash --format="%h %gd" | grep -m 1 {1} | awk "{print \$2}"))+abort,tab:execute(git stash show -p {1}),?:toggle-preview' --preview '
        # Extract stash hash and message from the selection.
        set stash_hash {1}
        set stash_message (echo {2..} | cut -d"|" -f2- | sed "s/^ //")

        # Get the stash index in the stash@{index} format.
        set stash_index (git log -g stash --format="%h %gd" | grep -m 1 "$stash_hash" | awk "{print \$2}")

        # Get the branch from git stash list excluding the stash message.
        set branch (git stash list --pretty=format:"%s" | grep -m 1 "$stash_message" | sed "s/.*On \(.*\): $stash_message/\1/" | xargs)

        # Get the date of the stash.
        set date (git show -s --format="%ad" --date=format-local:"%d/%m/%Y at %H:%M:%S" $stash_hash)

        # Get the list of files affected by the stash.
        set files (git stash show -p $stash_hash --name-only)

        # Color constants are not working in the preview window so we use the hardcoded ANSI escape codes.
        # Add "- " in front of each file line with green color.
        set formatted_files ""
        for file in $files
            set formatted_files "$formatted_files\e[1;32m-\e[0m $file\n"
        end

        echo -e "\e[1;33mIndex:\e[0m $stash_index"
        echo -e "\e[1;33mHash:\e[0m $stash_hash"
        echo -e "\e[1;33mBranch:\e[0m $branch\n"
        echo -e "\e[1;36mMessage:\e[0m $stash_message"
        echo -e "\e[1;36mDate:\e[0m $date\n"

        # Show "Files:" and the list of files only if there are any files.
        if test -n "$files"
            echo -e "\e[1;32mFiles:\e[0m"
            echo -e "$formatted_files"
        end
    ' --preview-window=right:50%:hidden:wrap

    # Return success status regardless of `fzf`'s exit status.
    return 0
end

# Function to show git log for the current branch and interact with it using fzf.
# Pressing:
#   - ENTER will reset the current branch to the selected commit
#   - TAB will show the commit changes
#   - ? will toggle the preview
# Usage:
#   git_log_current_branch
function git_log_current_branch
    # Get the name of the current branch.
    set current_branch (git rev-parse --abbrev-ref HEAD)

    # Get the base branch.
    set default_branch (git_get_default_branch)
    if test $status -ne 0
        return 1
    end

    # Get the log of the current branch excluding commits from the upstream branch.
    set -l log_list (git log --oneline --pretty=format:'%h | %s' $default_branch..$current_branch | string split '\n')

    # Check if the log list is empty.
    if test -z "$log_list"
        echo "No commits found!"
        return 1
    end

    # Loop through the array.
    for line in $log_list
        # Extract the commit hash and message.
        set commit_hash (echo "$line" | awk '{print $1}')
        set commit_message (echo "$line" | cut -d' ' -f3-)

        # Print the commit hash and message.
        echo -e "$BOLD_YELLOW$commit_hash$NO_COLOR $BOLD_GREEN|$NO_COLOR $commit_message"
    end | fzf --ansi --bind 'enter:execute(git reset --hard {1})+abort,tab:execute(git diff {1}^!),?:toggle-preview' --preview '
        # Extract commit hash and message from the selection.
        set commit_hash {1}
        set commit_message (echo {2..} | cut -d"|" -f2- | sed "s/^ //")

        # Get the author, date, and files paths for the commit.
        set author (git show -s --format="%an" $commit_hash)
        set date (git show -s --format="%ad" --date=format-local:"%d/%m/%Y at %H:%M:%S" $commit_hash)
        set files (git diff-tree --no-commit-id --name-only -r $commit_hash)

        # Color constants are not working in the preview window so we use the hardcoded ANSI escape codes.
        # Add "- " in front of each file line with green color.
        set formatted_files ""
        for file in $files
            set formatted_files "$formatted_files\e[1;32m-\e[0m $file\n"
        end

        echo -e "\e[1;33mHash:\e[0m $commit_hash"
        echo -e "\e[1;33mMessage:\e[0m $commit_message\n"
        echo -e "\e[1;36mAuthor:\e[0m $author"
        echo -e "\e[1;36mDate:\e[0m $date\n"

        # Show "Files:" and the list of files only if there are any files.
        if test -n "$files"
            echo -e "\e[1;32mFiles:\e[0m"
            echo -e "$formatted_files"
        end
    ' --preview-window=right:50%:hidden:wrap

    # Return success status regardless of `fzf`'s exit status.
    return 0
end

# Function to show all branches not merged or deleted and interact with them using fzf.
# Pressing:
#   - ENTER will checkout to the selected branch
#   - DELETE will delete the selected branch
#   - TAB will show the diff of the selected branch
#   - ? will toggle the preview and show more details
# Usage:
#   git_list_branches
function git_list_branches
    # Get the default branch.
    set default_branch (git_get_default_branch)
    if test $status -ne 0
        return 1
    end

    # Get the current branch.
    set current_branch (git branch --show-current)

    # Get all local and remote branches as arrays.
    set -l all_branches (git branch -a --format='%(refname:short)')
    set -l merged_branches (git branch -a --merged $default_branch | sed 's/^[* ]*//')
    set -l local_branches (git branch --format='%(refname:short)')
    set -l not_pushed_local_branches (git for-each-ref --format="%(refname:short) %(push:track)" refs/heads | grep '\[gone\]' | awk '{print $1}')

    # Remove merged branches from all_branches.
    set -l branch_list
    for b in $all_branches
        set found 0
        for m in $merged_branches
            if test "$b" = "$m"
                set found 1
                break
            end
        end
        if test $found -eq 0
            set branch_list $branch_list $b
        end
    end

    # Remove remote branches that have a corresponding local branch.
    set -l branch_list2
    for b in $branch_list
        set skip 0
        for l in $local_branches
            if test "$b" = "origin/$l"
                set skip 1
                break
            end
        end
        if test $skip -eq 0
            set branch_list2 $branch_list2 $b
        end
    end

    # Exclude origin/HEAD.
    set -l branch_list3
    for b in $branch_list2
        if test "$b" != "origin/HEAD"
            set branch_list3 $branch_list3 $b
        end
    end

    # Add not pushed local branches.
    for b in $not_pushed_local_branches
        if not contains $b $branch_list3
            set branch_list3 $branch_list3 $b
        end
    end

    # Remove empty entries.
    set -l final_branches
    for b in $branch_list3
        if test -n "$b"
            set final_branches $final_branches $b
        end
    end

    if test (count $final_branches) -eq 0
        echo "No branches found!"
        return 1
    end

    for line in $final_branches
        if test "$line" = "$current_branch"
            echo -e "$BOLD_YELLOW$line$NO_COLOR"
        else
            echo -e "$BOLD_GREEN$line$NO_COLOR"
        end
    end | fzf --ansi --bind 'enter:execute(git checkout {1})+abort,delete:execute(git branch -d {1})+abort,tab:execute(git diff {1})+abort,?:toggle-preview' --preview '
        set branch_name {1}
        set author (git log -1 --pretty=format:"%an" $branch_name)
        set date (git log -1 --pretty=format:"%ad" --date=format-local:"%d/%m/%Y at %H:%M:%S" $branch_name)
        set files (git ls-tree -r $branch_name --name-only)
        set formatted_files ""
        for file in $files
            set formatted_files "$formatted_files\e[1;32m-\e[0m $file\n"
        end
        echo -e "\e[1;33mBranch:\e[0m $branch_name\n"
        echo -e "\e[1;36mAuthor:\e[0m $author"
        echo -e "\e[1;36mDate:\e[0m $date\n"
        if test -n "$files"
            echo -e "\e[1;32mFiles:\e[0m"
            echo -e "$formatted_files"
        end
    ' --preview-window=right:50%:hidden:wrap

    # Always return 0 so that escape/abort does not show as error.
    return 0
end

# Function to cherry-pick specific commits from different branches.
# Show a list of the branch | commit hash | commit message.
# Pressing:
#   - ENTER will cherry-pick the commit
#   - ? will toggle the preview and show more details
# Usage:
#   git_cherry_pick_commit
function git_cherry_pick_commit
    # Get the current branch.
    set current_branch (git branch --show-current)

    # Get the list of commits from all remote branches except the current one.
    set -l commits_list (git log --oneline --pretty=format:'%h | %s' --all --remotes | grep -v "origin/$current_branch" | string split '\n')

    # Check if the commit list is empty.
    if test -z "$commits_list"
        echo "No commits found!"
        return 1
    end

    # Loop through the array.
    for line in $commits_list
        # Get commit hash and message.
        set commit_hash (echo "$line" | awk '{print $1}')
        set commit_message (echo "$line" | cut -d' ' -f3-)

        # Print the commit hash and message.
        echo -e "$BOLD_YELLOW$commit_hash$NO_COLOR $BOLD_GREEN|$NO_COLOR $commit_message"
    end | fzf --ansi --bind 'enter:execute(git cherry-pick {1})+abort,?:toggle-preview' --preview '
        # Keep the commit hash and message.
        set commit_hash {1}
        set commit_message (echo {2..} | cut -d"|" -f2- | sed "s/^ //")

        # Get the branch, author, date, and files paths for the commit.
        set branch (git branch -a --contains $commit_hash | grep "remotes/origin/" | sed "s#remotes/##")

        set author (git show -s --format="%an" $commit_hash)
        set date (git show -s --format="%ad" --date=format-local:"%d/%m/%Y at %H:%M:%S" $commit_hash)
        set files (git diff-tree --no-commit-id --name-only -r $commit_hash)

        # Color constants are not working in the preview window so we use the hardcoded ANSI escape codes.
        # Add "- " in front of each file line with green color.
        set formatted_files ""
        for file in $files
            set formatted_files "$formatted_files\e[1;32m-\e[0m $file\n"
        end

        echo -e "\e[1;33mHash:\e[0m $commit_hash"
        echo -e "\e[1;33mBranch:\e[0m $branch"
        echo -e "\e[1;33mMessage:\e[0m $commit_message\n"
        echo -e "\e[1;36mAuthor:\e[0m $author"
        echo -e "\e[1;36mDate:\e[0m $date\n"

        # Show "Files:" and the list of files only if there are any files.
        if test -n "$files"
            echo -e "\e[1;32mFiles:\e[0m"
            echo -e "$formatted_files"
        end
    ' --preview-window=right:50%:hidden:wrap
end

# Function to merge the current branch to default branch.
# Usage:
#   git_merge_to_default_branch [branch_name] [pr_number]
function git_merge_to_default_branch
    set remote "origin"
    set current_branch ""
    set upstream_branch ""
    set default_branch ""
    set branch_to_be_merged ""
    set new_commits_count 0
    set no_ff_option ""
    set merge_commit_title ""
    set merge_commit_body ""

    # Safety check: Ensure no rebase is ongoing.
    if test -d (git rev-parse --git-dir)/rebase-merge -o -d (git rev-parse --git-dir)/rebase-apply
        log_error "Rebase in progress, operation stopped!"
        return 1
    end

    # Step 1: Checkout specified branch if provided.
    if test -n "$argv[1]"
        log_info "Checking out `$argv[1]` branch..."
        git checkout "$argv[1]"
    end

    set current_branch (git rev-parse --abbrev-ref HEAD)
    log_info "Currently on `$current_branch` branch."

    # Step 2: Resolve upstream branch.
    set upstream_branch (git rev-parse --abbrev-ref "@{upstream}" 2>/dev/null; or echo "$current_branch")
    if not git ls-remote --heads --exit-code "$remote" "$upstream_branch" >/dev/null 2>&1
        read -P "Please enter the branch name for fetch/push operations: " upstream_branch
    end
    log_info "Tracking the remote branch `$upstream_branch`..."

    # Fetch and rebase current branch onto master/main.
    git_fetch_and_rebase "" false
    if test $status -ne 0
        log_error "Rebase failed, resolve conflicts/errors before running the script again!"
        return 1
    end

    # Get the base branch using the `git_get_default_branch` function.
    set default_branch (git_get_default_branch)
    set branch_to_be_merged "$remote/$upstream_branch"
    set local_branch (string replace "origin/" "" "$default_branch")

    # Force push current branch.
    log_info "Force pushing `$current_branch` to `$remote/$upstream_branch`..."
    git push "$remote" "HEAD:$upstream_branch" --force-with-lease

    git checkout "$local_branch"
    git reset --hard "$default_branch"
    git fetch "$remote" "$upstream_branch"

    set new_commits_count (git rev-list --count "$default_branch..FETCH_HEAD")
    if test "$new_commits_count" -gt 1
        set no_ff_option "--no-ff"
        set merge_commit_title "Merge branch \`$upstream_branch\`"
        if test -n "$argv[2]"
            set merge_commit_body "Closes #$argv[2]"
        end
    end

    log_info "The following commits will be merged from `$upstream_branch` to `$default_branch`:"
    git --no-pager log --decorate --graph --oneline "$default_branch..FETCH_HEAD"

    log_warning "Do you want to merge and push these commits to `$default_branch`? (Y/N):"
    read user_confirm
    if test "$user_confirm" = "y" -o "$user_confirm" = "Y"
        if test -n "$merge_commit_title"
            if test -n "$merge_commit_body"
                git merge FETCH_HEAD $no_ff_option -m "$merge_commit_title" -m "$merge_commit_body"
            else
                git merge FETCH_HEAD $no_ff_option -m "$merge_commit_title"
            end
        else
            git merge FETCH_HEAD $no_ff_option
        end

        if test $status -ne 0
            log_error "Merge failed!"
            git checkout "$current_branch"
            return 1
        end

        git push "$remote" "$local_branch"
        if test $status -ne 0
            log_error "Push to `$default_branch` failed!"
            git reset --hard HEAD^
            git checkout "$current_branch"
            return 1
        end
        log_success "Push to `$default_branch` was successful."
    else
        log_info "Merge and push to `$default_branch` was aborted."
        git checkout "$current_branch"
    end
end

# Function to set upstream branch for current branch.
# Usage:
#   git_add_remote_branch
function git_add_remote_branch
    set current_branch (git rev-parse --abbrev-ref HEAD)
    set remote "origin"

    log_info "Setting upstream for `$current_branch` to `$remote/$current_branch`..."
    git branch --set-upstream-to="$remote/$current_branch" "$current_branch"

    if test $status -eq 0
        log_success "Successfully set upstream for `$current_branch` to `$remote/$current_branch`."
        return 0
    else
        log_error "Failed to set upstream for `$current_branch`!"
        return 1
    end
end
