IMAGE=${1:-d9410b46515a}
PARAMS="$PARAMS -v /arm:/arm"
PARAMS="$PARAMS -v /data:/data"

docker run ${PARAMS} --user ${USER}:${USER} -t -i ${IMAGE} 
