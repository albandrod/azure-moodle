#!/bin/bash

# Group info for scripts
SCRIPTS_RG_NAME=rgmoodlescripts

# Group info for moodle
MOODLE_RG_LOCATION=westeurope
MOODLE_RG_NAME=rgmoodleucvpre
MOODLE_DEPLOYMENT_NAME=moodleucvpre
MOODLE_AZURE_WORKSPACE=~/workspace/sls/ucv/azure_moodle

# Deploy json
MOODLE_DEPLOY_JSON=azuredeploy-PRE.json

# Parameters
MOODLE_SSH_KEY_FILENAME=~/.ssh/SSHPrePublicKey.pub
MOODLE_ARTIFACTS_LOCATION="https://rgmoodlescripts.file.core.windows.net/scripts/"
MOODLE_ARTIFACTS_SAS="?se=2039-12-31T00%3A00Z&sp=rlp&sv=2018-03-28&ss=f&srt=sco&sig=U1uHWqsks5nVSmMz/UQHh7v5euCYodsBqDeQ1OcbSKo%3D"
