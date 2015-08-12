#!/bin/bash

rsync -arv --delete --progress --exclude='zarya/New_Slices' --exclude='rassvet/slices' --exclude='old/not_sync' /media/snaiffer/snaifExHard/work /
