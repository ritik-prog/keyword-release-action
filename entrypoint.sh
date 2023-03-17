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

    DATA="--header 'Accept: application/vnd.github+json' \
          --header 'X-GitHub-Api-Version: 2022-11-28' \
          --input -"

    JSON="$(printf '{"tag_name":"v%s",' $VERSION)"
    JSON="${JSON} $(printf '"target_commitish":"master",')"
    JSON="${JSON} $(printf '"name":"v%s",' $VERSION)"
    JSON="${JSON} $(printf '"body":"Automated release based on keyword: %s",' "$*")"
    JSON="${JSON} $(printf '"draft":false, "prerelease":false}')"

    URL="/repos/${GITHUB_REPOSITORY}/releases"

    if [[ "${LOCAL_TEST}" == *"true"* ]];
    then
        echo "## [TESTING] Keyword was found but no release was created."
    else
        echo $JSON | gh api $URL $DATA
    fi
# otherwise
else
    # exit gracefully
    echo "Nothing to process."
fi
