#!/usr/bin/env bash

if ! command -v clamdscan >/dev/null 2>&1 && ! command -v clamscan >/dev/null 2>&1; then
    kdialog --title "ClamAV not installed!" --sorry "<b>ClamAV not installed.</b><br>Please consider installing it to use this functionality."
    exit 1
fi

if ! command -v kdialog >/dev/null 2>&1 ; then
    if ! command -v notify-send >/dev/null 2>&1; then
        printf "'kdialog' and 'notify-send' Not installed.\nPlease consider installing it to use this functionality.\n"
        exit 2
    else
        notify_util="notify-send"
    fi
else
    notify_util="kdialog"
fi

function msg_ok() {
    if [ "$notify_util" == "kdialog" ]; then
        kdialog --title "ClamAV Scan Results" --msgbox "<b>No virus found :)</b>"
    else
        notify-send -a "ClamAV Scan Results" -u normal -t 5000 -i "dialog-information" "ClamAV Scan Results" "<b>No virus found :)</b>"
    fi
}

function msg_found() {
    if [ "$notify_util" == "kdialog" ]; then
        kdialog --title "ClamAV Scan Results: Virus(es) Found!" --detailederror "<b>Virus(es) Found</b>" "$1"
    else
        notify-send -a "ClamAV Scan Results" -u normal -t 10000 -a -i "dialog-warning" "ClamAV Scan Results" "<b>Virus(es) Found</b>"
    fi
}

function msg_error() {
    if [ "$notify_util" == "kdialog" ]; then
        kdialog --title "ClamAV Scan Results: Error(s) Occurred!" --detailederror "<b>Some error(s) occurred!</b>" "$1"
    else
        notify-send -a "ClamAV Scan Results" -u normal -t 7500 -i "dialog-error" "ClamAV Scan Results" "<b>Some error(s) occurred!</b>"
    fi
}

# 0: no virus found
# 1: Virus(es) found
# 2: Some error(s) occurred
if pgrep clamd >/dev/null 2>&1; then
    summary=$(clamdscan --fdpass -imz "$@")
    r=$?
else
    # this mush slower than using clamdscan
    summary=$(clamscan -irz "$@")
    r=$?
fi

if [ $r -eq 0 ]; then
    msg_ok
elif [ $r -eq 1 ]; then
    msg_found "$summary"
else
    msg_error "$summary"
fi
