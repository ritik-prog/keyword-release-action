#!/bin/bash
set -e

if [ -n "$GITHUB_EVENT_PATH" ];
then
    EVENT_PATH=$GITHUB_EVENT_PATH
elif [ -f ./sample_push_event.json ];
then
    EVENT_PATH='./sample_push_event.json'
    LOCAL_TEST=true
else
    echo "No JSON data to process! :("
    exit 1
fi

env
jq . < $EVENT_PATH

# if keyword is found
if jq '.commits[].message, .head_commit.message' < $EVENT_PATH | grep -i -q "$*";
then
    # do something
    VERSION=$(date +%F.%s)

    DATA="$(printf '{"tag_name":"v%s",' $VERSION)"
    DATA="${DATA} $(printf '"target_commitish":"master",')"
    DATA="${DATA} $(printf '"name":"v%s",' $VERSION)"
    DATA="${DATA} $(printf '"body":"Automated release based on keyword: %s",' "$*")"
    DATA="${DATA} $(printf '"draft":false, "prerelease":false}')"

    RELEASE_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/"

    AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
    ACCEPT_HEADER="Accept: application/vnd.github+json"
    API_VERSION_HEADER="X-GitHub-Api-Version: 2022-11-28"

    if [[ "${LOCAL_TEST}" == *"true"* ]];
    then
        echo "## [TESTING] Keyword was found but no release was created."
    else
        RELEASE_RESPONSE=$(echo $DATA | http POST $RELEASE_URL $AUTH_HEADER $ACCEPT_HEADER $API_VERSION_HEADER --ignore-stdin | jq .)
        UPLOAD_URL=$(echo $RELEASE_RESPONSE | jq -r .upload_url | sed 's/{?name,label}//')

        # Upload the asset
        ASSET_URL="${UPLOAD_URL}?name=${RELEASE_FILENAME}"
        http --check-status --ignore-stdin --form POST $ASSET_URL $AUTH_HEADER $ACCEPT_HEADER $API_VERSION_HEADER < $RELEASE_FILENAME
    fi
# otherwise
else
    # exit gracefully
    echo "Nothing to process."
fi
