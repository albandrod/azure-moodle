#!/bin/bash

# Group info for scripts

# Scripts resource group name (eg: rgscriptsmoodle)
SCRIPTS_RG_NAME=

# Moodle resource group location (eg: westeurope)
MOODLE_RG_LOCATION=westeurope

# Moodle resource group name (eg: rgmoodleucvpre)
MOODLE_RG_NAME=

# Moodle deployment name (eg: moodleucvpre)
MOODLE_DEPLOYMENT_NAME=

# Moodle Azure ARM template path (where this is located, eg: ~/workspace/ucv/azureconf/arm_template)
MOODLE_AZURE_WORKSPACE=

# Moodle deploy json with parameters (eg: azuredeploy-PRE.json)
MOODLE_DEPLOY_JSON=

# SSH Public key path (eg: ~/SSHPREPublicKey.pub)
MOODLE_SSH_KEY_FILENAME=

# DON'T FILL: Moodle artifacts location, will be set by the script
MOODLE_ARTIFACTS_LOCATION=
# DON'T FILL: Moodle artifacts sas token, will be set by the script
MOODLE_ARTIFACTS_SAS=
