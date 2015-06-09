#!/bin/sh

#
# ~/.xsession
#
# Executed by xdm/gdm/kdm at login
#

XKBOPTIONS="compose:caps"
/bin/bash --login -i ~/.xinitrc
