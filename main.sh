#!/bin/bash
# File: main.sh                                                                #
# Description:
#     This script contains exercise00 in "Introduction to Bioinformatics" lecture
#     Do not edit this script
################################################################################

echo "--------------------------------------------------"
# Execute commands
for command in ./command/*.sh
do
    echo "executing command: $command"
    bash $command
echo "--------------------------------------------------"
done

################################################################################
