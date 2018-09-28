#
# This shell prompt config file was created by promptline.vim
#
function __promptline_battery {
  local percent_sign="%"
  local battery_symbol=""
  local threshold="30"

  # escape percent "%" in zsh
  [[ -n ${ZSH_VERSION-} ]] && percent_sign="${percent_sign//\%/%%}"

  # osx
  if hash ioreg 2>/dev/null; then
    local ioreg_output
    if ioreg_output=$(ioreg -rc AppleSmartBattery 2>/dev/null); then
      local battery_capacity=${ioreg_output#*MaxCapacity\"\ \=}
      battery_capacity=${battery_capacity%%\ \"*}

      local current_capacity=${ioreg_output#*CurrentCapacity\"\ \=}
      current_capacity=${current_capacity%%\ \"*}

      local battery_level=$(($current_capacity * 100 / $battery_capacity))
      [[ $battery_level -gt $threshold ]] && return 1

      printf "%s" "${battery_symbol}${battery_level}${percent_sign}"
      return
    fi
  fi

  # linux
  for possible_battery_dir in /sys/class/power_supply/BAT*; do
    if [[ -d $possible_battery_dir && -f "$possible_battery_dir/energy_full" && -f "$possible_battery_dir/energy_now" ]]; then
      current_capacity=$( <"$possible_battery_dir/energy_now" )
      battery_capacity=$( <"$possible_battery_dir/energy_full" )
      local battery_level=$(($current_capacity * 100 / $battery_capacity))
      [[ $battery_level -gt $threshold ]] && return 1

      printf "%s" "${battery_symbol}${battery_level}${percent_sign}"
      return
    fi
  done

return 1
}
function __promptline_ps1 {
  local slice_prefix slice_empty_prefix slice_joiner slice_suffix is_prompt_empty=1

  # section "c" header
  slice_prefix="${c_bg}${sep}${c_fg}${c_bg}${space}" slice_suffix="$space${c_sep_fg}" slice_joiner="${c_fg}${c_bg}${alt_sep}${space}" slice_empty_prefix="${c_fg}${c_bg}${space}"
  [ $is_prompt_empty -eq 1 ] && slice_prefix="$slice_empty_prefix"
  # section "c" slices
  __promptline_wrapper "$(if [[ -n ${ZSH_VERSION-} ]]; then print %n; elif [[ -n ${FISH_VERSION-} ]]; then printf "%s" "$USER"; else printf "%s" \\u; fi )" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; is_prompt_empty=0; }
  __promptline_wrapper "$(__promptline_battery)" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; is_prompt_empty=0; }

  # section "b" header
  slice_prefix="${b_bg}${sep}${b_fg}${b_bg}${space}" slice_suffix="$space${b_sep_fg}" slice_joiner="${b_fg}${b_bg}${alt_sep}${space}" slice_empty_prefix="${b_fg}${b_bg}${space}"
  [ $is_prompt_empty -eq 1 ] && slice_prefix="$slice_empty_prefix"
  # section "b" slices
  __promptline_wrapper "${VIRTUAL_ENV##*/}" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; is_prompt_empty=0; }

  # section "a" header
  slice_prefix="${a_bg}${sep}${a_fg}${a_bg}${space}" slice_suffix="$space${a_sep_fg}" slice_joiner="${a_fg}${a_bg}${alt_sep}${space}" slice_empty_prefix="${a_fg}${a_bg}${space}"
  [ $is_prompt_empty -eq 1 ] && slice_prefix="$slice_empty_prefix"
  # section "a" slices
  __promptline_wrapper "$(__promptline_cwd)" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; is_prompt_empty=0; }

  # section "y" header
  slice_prefix="${y_bg}${sep}${y_fg}${y_bg}${space}" slice_suffix="$space${y_sep_fg}" slice_joiner="${y_fg}${y_bg}${alt_sep}${space}" slice_empty_prefix="${y_fg}${y_bg}${space}"
  [ $is_prompt_empty -eq 1 ] && slice_prefix="$slice_empty_prefix"
  # section "y" slices
  __promptline_wrapper "$(__promptline_vcs_branch)" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; is_prompt_empty=0; }

  # section "warn" header
  slice_prefix="${warn_bg}${sep}${warn_fg}${warn_bg}${space}" slice_suffix="$space${warn_sep_fg}" slice_joiner="${warn_fg}${warn_bg}${alt_sep}${space}" slice_empty_prefix="${warn_fg}${warn_bg}${space}"
  [ $is_prompt_empty -eq 1 ] && slice_prefix="$slice_empty_prefix"
  # section "warn" slices
  __promptline_wrapper "$(__promptline_last_exit_code)" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; is_prompt_empty=0; }

  # close sections
  printf "%s" "${reset_bg}${sep}$reset$space"
}
function __promptline_vcs_branch {
  local branch
  local branch_symbol=" "

  # git
  if hash git 2>/dev/null; then
    if branch=$( { git symbolic-ref --quiet HEAD || git rev-parse --short HEAD; } 2>/dev/null ); then
      branch=${branch##*/}
      printf "%s" "${branch_symbol}${branch:-unknown}"
      return
    fi
  fi
  return 1
}
function __promptline_cwd {
  local dir_limit="2"
  local truncation="⋯"
  local first_char
  local part_count=0
  local formatted_cwd=""
  local dir_sep="  "
  local tilde="~"

  local cwd="${PWD/#$HOME/$tilde}"

  # get first char of the path, i.e. tilde or slash
  [[ -n ${ZSH_VERSION-} ]] && first_char=$cwd[1,1] || first_char=${cwd::1}

  # remove leading tilde
  cwd="${cwd#\~}"

  while [[ "$cwd" == */* && "$cwd" != "/" ]]; do
    # pop off last part of cwd
    local part="${cwd##*/}"
    cwd="${cwd%/*}"

    formatted_cwd="$dir_sep$part$formatted_cwd"
    part_count=$((part_count+1))

    [[ $part_count -eq $dir_limit ]] && first_char="$truncation" && break
  done

  printf "%s" "$first_char$formatted_cwd"
}
function __promptline_left_prompt {
  local slice_prefix slice_empty_prefix slice_joiner slice_suffix is_prompt_empty=1

  # section "a" header
  slice_prefix="${a_bg}${sep}${a_fg}${a_bg}${space}" slice_suffix="$space${a_sep_fg}" slice_joiner="${a_fg}${a_bg}${alt_sep}${space}" slice_empty_prefix="${a_fg}${a_bg}${space}"
  [ $is_prompt_empty -eq 1 ] && slice_prefix="$slice_empty_prefix"
  # section "a" slices
  __promptline_wrapper "$(__promptline_cwd)" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; is_prompt_empty=0; }

  # section "b" header
  slice_prefix="${b_bg}${sep}${b_fg}${b_bg}${space}" slice_suffix="$space${b_sep_fg}" slice_joiner="${b_fg}${b_bg}${alt_sep}${space}" slice_empty_prefix="${b_fg}${b_bg}${space}"
  [ $is_prompt_empty -eq 1 ] && slice_prefix="$slice_empty_prefix"
  # section "b" slices
  __promptline_wrapper "${VIRTUAL_ENV##*/}" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; is_prompt_empty=0; }

  # section "c" header
  slice_prefix="${c_bg}${sep}${c_fg}${c_bg}${space}" slice_suffix="$space${c_sep_fg}" slice_joiner="${c_fg}${c_bg}${alt_sep}${space}" slice_empty_prefix="${c_fg}${c_bg}${space}"
  [ $is_prompt_empty -eq 1 ] && slice_prefix="$slice_empty_prefix"
  # section "c" slices
  __promptline_wrapper "$(if [[ -n ${ZSH_VERSION-} ]]; then print %n; elif [[ -n ${FISH_VERSION-} ]]; then printf "%s" "$USER"; else printf "%s" \\u; fi )" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; is_prompt_empty=0; }
  __promptline_wrapper "$(__promptline_battery)" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; is_prompt_empty=0; }

  # close sections
  printf "%s" "${reset_bg}${sep}$reset$space"
}
function __promptline_wrapper {
  # wrap the text in $1 with $2 and $3, only if $1 is not empty
  # $2 and $3 typically contain non-content-text, like color escape codes and separators

  [[ -n "$1" ]] || return 1
  printf "%s" "${2}${1}${3}"
}

function __promptline_last_exit_code {

  [[ $last_exit_code -gt 0 ]] || return 1;

  printf "%s" "$last_exit_code"
}
function __promptline_right_prompt {
  local slice_prefix slice_empty_prefix slice_joiner slice_suffix

  # section "warn" header
  slice_prefix="${warn_sep_fg}${rsep}${warn_fg}${warn_bg}${space}" slice_suffix="$space${warn_sep_fg}" slice_joiner="${warn_fg}${warn_bg}${alt_rsep}${space}" slice_empty_prefix=""
  # section "warn" slices
  __promptline_wrapper "$(__promptline_last_exit_code)" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; }

  # section "y" header
  slice_prefix="${y_sep_fg}${rsep}${y_fg}${y_bg}${space}" slice_suffix="$space${y_sep_fg}" slice_joiner="${y_fg}${y_bg}${alt_rsep}${space}" slice_empty_prefix=""
  # section "y" slices
  __promptline_wrapper "$(__promptline_vcs_branch)" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; }

  # close sections
  printf "%s" "$reset"
}
function __promptline {
  local last_exit_code="${PROMPTLINE_LAST_EXIT_CODE:-$?}"

  local esc=$'[' end_esc=m
  if [[ -n ${ZSH_VERSION-} ]]; then
    local noprint='%{' end_noprint='%}'
  elif [[ -n ${FISH_VERSION-} ]]; then
    local noprint='' end_noprint=''
  else
    local noprint='\[' end_noprint='\]'
  fi
  local wrap="$noprint$esc" end_wrap="$end_esc$end_noprint"
  local space=" "
  local sep=""
  local rsep=""
  local alt_sep=""
  local alt_rsep=""
  local reset="${wrap}0${end_wrap}"
  local reset_bg="${wrap}49${end_wrap}"
  local a_fg="${wrap}38;5;8${end_wrap}"
  local a_bg="${wrap}48;5;249${end_wrap}"
  local a_sep_fg="${wrap}38;5;249${end_wrap}"
  local b_fg="${wrap}38;5;252${end_wrap}"
  local b_bg="${wrap}48;5;31${end_wrap}"
  local b_sep_fg="${wrap}38;5;31${end_wrap}"
  local c_fg="${wrap}38;5;253${end_wrap}"
  local c_bg="${wrap}48;5;24${end_wrap}"
  local c_sep_fg="${wrap}38;5;24${end_wrap}"
  local warn_fg="${wrap}38;5;232${end_wrap}"
  local warn_bg="${wrap}48;5;166${end_wrap}"
  local warn_sep_fg="${wrap}38;5;166${end_wrap}"
  local y_fg="${wrap}38;5;252${end_wrap}"
  local y_bg="${wrap}48;5;31${end_wrap}"
  local y_sep_fg="${wrap}38;5;31${end_wrap}"
  if [[ -n ${ZSH_VERSION-} ]]; then
    PROMPT="$(__promptline_left_prompt)"
    RPROMPT="$(__promptline_right_prompt)"
  elif [[ -n ${FISH_VERSION-} ]]; then
    if [[ -n "$1" ]]; then
      [[ "$1" = "left" ]] && __promptline_left_prompt || __promptline_right_prompt
    else
      __promptline_ps1
    fi
  else
    PS1="$(__promptline_ps1)"
  fi
}

if [[ -n ${ZSH_VERSION-} ]]; then
  if [[ ! ${precmd_functions[(r)__promptline]} == __promptline ]]; then
    precmd_functions+=(__promptline)
  fi
elif [[ -n ${FISH_VERSION-} ]]; then
  __promptline "$1"
else
  if [[ ! "$PROMPT_COMMAND" == *__promptline* ]]; then
    PROMPT_COMMAND='__promptline;'$'\n'"$PROMPT_COMMAND"
  fi
fi