#!/bin/bash

# Only for debugging script
#set -ex
#trap read debug

set -e
DEBUG=""
ENVFILE=""
USAGE="USAGE: $0 <path_to_env> [--debug|--verbose]"

if [ "$#" -lt "1" ]; then
    echo "Missing env path. Exiting..."
    echo $USAGE
    exit 1
fi

if [ -f $1 ]; then
    ENVFILE=$1
    source $ENVFILE
    shift
else
    echo "Env file not reachable.Exiting..."
    exit 1
fi

while (( "$#" )); do
    if [ $1 = "--debug" ] || [ $1 = "--verbose" ]; then
        DEBUG=$1
    fi
    shift
done

# Check some parameters
if [ -z "$MOODLE_RG_LOCATION" ] \
    || [ -z "$MOODLE_RG_NAME" ] \
    || [ -z "$SCRIPTS_RG_NAME" ] \
    || [ -z "$MOODLE_AZURE_WORKSPACE" ] \
    || [ -z "$MOODLE_DEPLOY_JSON" ] \
    || [ -z "$MOODLE_SSH_KEY_FILENAME" ] \
    || [ -z "$MOODLE_DEPLOYMENT_NAME" ]; then
    echo "Missing parameters. Exiting..."
fi

# Check if logged in
echo -n "Checking if logged in..."
if ! az account list $DEBUG >/dev/null; then
    echo "ERROR: Not logged in. Exiting."
    exit 1
fi
echo "DONE"

# Create azure group for scripts
if [ -z "$MOODLE_ARTIFACTS_LOCATION" ]; then

    # Create group if it does not exist
    echo -n "Checking if $SCRIPTS_RG_NAME resource-group exists..."
    if ! az group show $DEBUG --name $SCRIPTS_RG_NAME &> /dev/null; then
        echo "DONE"
        echo -n "Group $SCRIPTS_RG_NAME does not exist. Creating..."
        az group create $DEBUG \
            --name $SCRIPTS_RG_NAME \
            --location $MOODLE_RG_LOCATION \
            > /dev/null
        if [ $? -gt 0 ]; then
            echo "Error. Exiting..."
            exit $?
        fi
    fi
    echo "DONE"

    # Create storage account if it does not exist
    echo -n "Checking if $SCRIPTS_RG_NAME storage account exists..."
    if ! az storage account show $DEBUG --name $SCRIPTS_RG_NAME &> /dev/null; then
        echo "DONE"
        echo -n "Storage $SCRIPTS_RG_NAME does not exist. Creating..."
        az storage account create $DEBUG \
            --name $SCRIPTS_RG_NAME \
            --resource-group $SCRIPTS_RG_NAME \
            --location $MOODLE_RG_LOCATION \
            --sku Standard_LRS \
            > /dev/null
        if [ $? -gt 0 ]; then
            echo "Error. Exiting..."
            exit $?
        fi
    fi
    echo "DONE"

    echo -n "Getting storage keys..."
    STORAGEKEY=$(az storage account keys list $DEBUG \
        --resource-group $SCRIPTS_RG_NAME \
        --account-name $SCRIPTS_RG_NAME \
        --query "[0].value" | tr -d '"')
    echo "DONE"

    echo -n "Checking if storage share exists..."
    STORAGESHAREEXISTS=$( echo $(az storage share exists $DEBUG --name scripts --account-name $SCRIPTS_RG_NAME --account-key $STORAGEKEY) | jq -r .exists)
    if [ "$STORAGESHAREEXISTS" = "false" ]; then
        echo "DONE"
        echo -n "Share does not exist. Creating share..."
        az storage share create $DEBUG \
            --account-name $SCRIPTS_RG_NAME \
            --account-key $STORAGEKEY \
            --name scripts \
            --quota 1 \
            > /dev/null
        if [ $? -gt 0 ]; then
            echo "Error. Exiting..."
            exit $?
        fi
    fi
    echo "DONE"

    # Generate SAS
    echo -n "Retrieving artifacts location..."
    MOODLE_ARTIFACTS_LOCATION=$(az storage share url $DEBUG \
        --name scripts \
        --account-name $SCRIPTS_RG_NAME \
        --account-key $STORAGEKEY)
    MOODLE_ARTIFACTS_LOCATION="${MOODLE_ARTIFACTS_LOCATION%\"}/\""
    echo "DONE"

    echo -n "Retrieving SAS key..."
    MOODLE_ARTIFACTS_SAS=$(az storage account generate-sas $DEBUG \
        --expiry "2039-12-31T00:00Z" \
        --permissions rlp \
        --resource-types sco \
        --services f \
        --account-name $SCRIPTS_RG_NAME)
    MOODLE_ARTIFACTS_SAS="\"?${MOODLE_ARTIFACTS_SAS#\"}"
    echo "DONE"

    # Modify env variables file
    sed -i '' "s|MOODLE_ARTIFACTS_LOCATION=*|MOODLE_ARTIFACTS_LOCATION=${MOODLE_ARTIFACTS_LOCATION}|" $ENVFILE
    sed -i '' "s|MOODLE_ARTIFACTS_SAS=*|MOODLE_ARTIFACTS_SAS=${MOODLE_ARTIFACTS_SAS//&/\\&}|" $ENVFILE

    # Modify deploy.json
    sed -i '' "s|\"_artifactsLocation\":.*|\"_artifactsLocation\":           { \"value\" : ${MOODLE_ARTIFACTS_LOCATION} },|" $MOODLE_AZURE_WORKSPACE/$MOODLE_DEPLOY_JSON
    sed -i '' "s|\"_artifactsLocationSasToken\":.*|\"_artifactsLocationSasToken\":   { \"value\" : ${MOODLE_ARTIFACTS_SAS//&/\\&} },|" $MOODLE_AZURE_WORKSPACE/$MOODLE_DEPLOY_JSON
    sed -i '' "s|\"sshPublicKey\":.*|\"sshPublicKey\":                 { \"value\" : \"$(cat ${MOODLE_SSH_KEY_FILENAME})\" },|" $MOODLE_AZURE_WORKSPACE/$MOODLE_DEPLOY_JSON
fi

if [ -z "$STORAGEKEY" ]; then
    echo -n "Getting storage keys..."
    STORAGEKEY=$(az storage account keys list $DEBUG \
        --resource-group $SCRIPTS_RG_NAME \
        --account-name $SCRIPTS_RG_NAME \
        --query "[0].value" | tr -d '"')
    echo "DONE"
fi

echo -n "Checking if scripts are already loaded..."
SCRIPTEXIST=$(echo $(az storage file exists $DEBUG --share-name scripts --path $MOODLE_DEPLOY_JSON --account-name $SCRIPTS_RG_NAME --account-key $STORAGEKEY) | jq -r .exists)
echo "DONE"

if [ "$SCRIPTEXIST" = "false" ]; then
    # Copy files (azure does not currently support regexp)
    echo "Scripts are not loaded. Uploading scripts..."
    az storage directory create $DEBUG \
        --name nested \
        --share-name scripts \
        --account-name $SCRIPTS_RG_NAME \
        --account-key $STORAGEKEY
    az storage file upload-batch $DEBUG \
        -d scripts/nested \
        -s $MOODLE_AZURE_WORKSPACE/nested \
        --account-name $SCRIPTS_RG_NAME \
        --account-key $STORAGEKEY
    az storage directory create $DEBUG \
        --name scripts \
        --share-name scripts \
        --account-name $SCRIPTS_RG_NAME \
        --account-key $STORAGEKEY
    az storage file upload-batch $DEBUG \
        -d scripts/scripts \
        -s $MOODLE_AZURE_WORKSPACE/scripts \
        --account-name $SCRIPTS_RG_NAME \
        --account-key $STORAGEKEY
    az storage file upload $DEBUG \
        --source azuredeploy.json \
        --share-name scripts \
        --account-name $SCRIPTS_RG_NAME \
        --account-key $STORAGEKEY
    az storage file upload $DEBUG \
        --source $MOODLE_AZURE_WORKSPACE/$MOODLE_DEPLOY_JSON \
        --share-name scripts \
        --account-name $SCRIPTS_RG_NAME \
        --account-key $STORAGEKEY
fi

source $ENVFILE
if [ ! -z "$MOODLE_ARTIFACTS_LOCATION" ] && [ ! -z "$MOODLE_ARTIFACTS_SAS" ]; then
    # Create azure group
    echo -n "Checking if $MOODLE_RG_NAME group exists..."
    if ! az group show $DEBUG --name $MOODLE_RG_NAME &> /dev/null; then
        echo "DONE"
        echo -n "Group $MOODLE_RG_NAME does not exist. Creating..."
        az group create $DEBUG \
            --name $MOODLE_RG_NAME \
            --location $MOODLE_RG_LOCATION \
            > /dev/null
        if [ $? -gt 0 ]; then
            echo "Error. Exiting..."
            exit $?
        fi
    fi
    echo "DONE"

    #Create deployment
    read -p "Environment is ready. Do you want to deploy? (y/n) " CONFIRMDEPLOY

    if [ $CONFIRMDEPLOY = "y" ]; then
        echo "Deploying..."
        az group deployment create $DEBUG \
            --name $MOODLE_DEPLOYMENT_NAME \
            --resource-group $MOODLE_RG_NAME \
            --template-uri ${MOODLE_ARTIFACTS_LOCATION}azuredeploy.json${MOODLE_ARTIFACTS_SAS} \
            --parameters ${MOODLE_ARTIFACTS_LOCATION}${MOODLE_DEPLOY_JSON}${MOODLE_ARTIFACTS_SAS}
        echo "DONE"

        echo -n "Retrieving outputs..."
        az group deployment show $DEBUG \
            --resource-group $MOODLE_RG_NAME \
            --name $MOODLE_DEPLOYMENT_NAME \
            --out json \
            --query *.outputs \
            > outputs.txt
        echo "DONE"
    else
        echo "Deployment cancelled. Exiting..."
        exit 1
    fi
fi
