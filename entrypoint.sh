#!/bin/bash
set -e

export PATH=$PATH:/ghcli/bin

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

    if [[ "${LOCAL_TEST}" == *"true"* ]];
    then
        echo "## [TESTING] Keyword was found but no release was created."
    else
        git config --global --add safe.directory /github/workspace
        gh release create $VERSION -F - <<< "$DATA"
    fi
# otherwise
else
    # exit gracefully
    echo "Nothing to process."
fi
