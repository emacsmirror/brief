#!/bin/bash
# Brief Emulator/Brief Mode Launcher with Emacs
# A support script associated with ELPA package "brief"
# Version    : 1.0
# Written by : Luke Lee since Brief mode 5.86

# Environment variables and default values
BRIEFVERSION=${BRIEFVERSION-"5.86"}
BRIEFPATH=${BRIEFPATH-"~/.emacs.d/elpa/brief-${BRIEFVERSION}"}
BRIEFQUICK=${BRIEFQUICK-"1"}
BRIEFTERMINAL=${BRIEFTERMINAL-"0"}
EMACS=${EMACS-"emacs"}

function help ()
{
  cat <<EOF
b : Brief Emulator/Brief Mode using Emacs
------------------------------------------
usage: b [-h] [-nq] [-nw] [<emacs-args>]

    -h               show short help message and exit
    -nq              no quick launch (no -q argument for Emacs)
    -nw              force run in terminal mode (-nw for Emacs)
    <emacs-args>     arguments for Emacs, -q or -Q overrides -nq

Environment variables:

    BRIEFVERSION     ELPA brief version, default "5.86"
    BRIEFPATH        default path to search brief.el[c]
    BRIEFQUICK       launch Emacs with -q, default=1
    BRIEFTERMINAL    launch Emacs in terminal mode with -nw, default=0
    EMACS            default Emacs binary to launch

Example: editing ~/.bashrc in the background

    b ~/.bashrc &
EOF

  if [ $HELP == 1 ]; then
    exit 3
  elif [ $HELP == 2 ]; then
    echo -e "\n\n$(basename ${EMACS}) : The Emacs Program"
    echo -e "---------------------------------"
  fi

  if [ "$1" == "notfound" ]; then
    echo "Error: brief.el[c] file(s) not found."
    exit 2
  fi
}

function find_brief ()
{
  if [ -f $1/brief.el ] || [ -f $1/brief.elc ]; then
    BRIEFPATH="$1"
    return `true`
  fi
  return `false`
}

# Try if $EMACS can be found and executed, if not, exit

function find_emacs ()
{
  if ! which ${EMACS} >/dev/null 2>&1; then
    if [ "${EMACS}" != "emacs" ]; then
      local PREVEMACS=${EMACS}
      if ! EMACS=`which emacs`; then
        echo "Error: neither '${PREVEMACS}' nor 'emacs' be found in PATH."
        echo "Please specify a valid emacs or install it."
        exit 1
      else
        echo "Warning: '${PREVEMACS}' can't be found; running defaut 'emacs' found in PATH."
      fi
    else
      echo "Error: 'emacs' cannot be found; please specify a valid one or install it."
      exit 1
    fi
  fi
}

find_emacs

# Search for brief.el or brief.elc through default path list

HELP=0

find_brief ${BRIEFPATH} \
  || find_brief ~/.emacs.d/elpa/brief-${BRIEFVERSION} \
  || find_brief ~/.emacs.d/elpa/brief \
  || find_brief ~/.emacs.d/brief \
  || find_brief ~/bin/elisp/brief \
  || help notfound

# Scan arguments

SHOWVERSION=0
EMACSARGS=()
j=0

while [ "$1" != "" ]; do

  case "$1" in
    -h)
      HELP=1
      ;;
    --help) # both b and emacs's help
      HELP=2
      ;;
    -nq)
      BRIEFQUICK=0
      shift
      continue
      ;;
    -nw|--no-window-system)
      BRIEFTERMINAL=0 # no duplicate
      ;;
    --version)
      SHOWVERSION=1
      ;;
    -Q|-q|--quick|--no-init-file)
      BRIEFQUICK=0 # no duplicate
      ;;
  esac

  ((j++))
  EMACSARGS[$j]="$1"
  shift

done

# Process extra arguments

[ "$HELP" != "0" ] && help
[ "$SHOWVERSION" == "1" ] && echo -e "Brief mode/emulator version ${BRIEFVERSION} for"
[ "$BRIEFTERMINAL" == "1" ] && EMACSARGS=("-nw" "${EMACSARGS[@]}")
[ "$BRIEFQUICK" == "1" ] && EMACSARGS=("-q" "${EMACSARGS[@]}")

# Launch Emacs with Brief mode default settings

exec ${EMACS} --load ${BRIEFPATH}/brief --eval \
"(progn \
  (setq-default truncate-lines t) \
  (setq scroll-step 1 \
        scroll-conservatively 101) \
  (setq hscroll-margin 1 \
        hscroll-step 1) \
  (scroll-bar-mode -1) \
  (brief-mode 1))" \
"${EMACSARGS[@]}"