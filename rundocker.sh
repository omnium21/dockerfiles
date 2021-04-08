IMAGE=${1:-"${USER}-ubuntu"}
PARAMS="$PARAMS -v /arm:/arm"
PARAMS="$PARAMS -v /data:/data"

docker run ${PARAMS} --user ${USER}:${USER} -t -i ${IMAGE} 
