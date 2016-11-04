set -o pipefail

echo Checking for other nodes
IP=""
if [[ -n "${KUBERNETES_SERVICE_HOST}" ]]; then

	POD_NAMESPACE=${POD_NAMESPACE:-default}
	MYHOST=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
	echo My host: ${MYHOST}

	URL="https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}/api/v1/namespaces/${POD_NAMESPACE}/endpoints/rethinkdb-driver"
	echo "Endpont url: ${URL}"
	echo "Looking for IPs..."
	token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
	# try to pick up first different ip from endpoints
	IP=$(curl -s ${URL} --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt --header "Authorization: Bearer ${token}" \
		| jq -s -r --arg h "${MYHOST}" '.[0].subsets | .[].addresses | [ .[].ip ] | map(select(. != $h)) | .[0]') || exit 1
	[[ "${IP}" == null ]] && IP=""
fi

if [[ -n "${IP}" ]]; then
	ENDPOINT="${IP}:29015"
	echo "Join to ${ENDPOINT}"
	exec rethinkdb --bind all  --join ${ENDPOINT}
else
	echo "Start single instance"
	exec rethinkdb --bind all
fi
