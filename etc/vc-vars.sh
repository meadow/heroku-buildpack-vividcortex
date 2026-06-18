if [[ -z "$VC_API_TOKEN" ]]; then
  echo "Looks like the VC_API_TOKEN is not set. Run: heroku config:add VC_API_TOKEN=<your API token>."
  exit 1
fi

if [[ -z "$DATABASE_URL" ]]; then
  echo "Looks like the DATABASE_URL is not set. Run: heroku config:add DATABASE_URL=<your database url>."
  exit 1
fi

# Ubicloud signs its Postgres server certs with its own CA, so the agent needs the
# CA cert on disk to verify the connection. Write the PEM (stored in a Heroku config
# var) to a file and point the agent at it via the sslca param in the host URI below.
printf '%s\n' "$DATABASE_PRIMARY_CERT" > /tmp/server-ca.crt

export VC_007="https://download.vividcortex.com/linux/x86_64/current/vc-agent-007"
export VC_HOME=$HOME/.vc
export VC_PID_DIR=$VC_HOME
export VC_RUN_DIR=$VC_HOME
export VC_LOG_DIR=$VC_HOME/logs
export VC_LOCK_DIR=$VC_HOME/lock
export VC_AGENT_INSTALL_DIR=$VC_HOME/bin
export VC_DRV_MANUAL_HOST_URI="$DATABASE_URL?sslenabled=true&sslmode=verify-full&sslca=/tmp/server-ca.crt"
export VC_HOSTNAME="$DYNO"

PATH=$PATH:$VC_AGENT_INSTALL_DIR

echo "Downloading agent 007"
curl $VC_007 > $VC_HOME/bin/vc-agent-007
chmod 755 $VC_HOME/bin/vc-agent-007
$VC_HOME/bin/vc-agent-007 --version
