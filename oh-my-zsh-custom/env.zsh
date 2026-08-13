# Custom environment variables
[ -z "$SSH_AUTH_SOCK" ] && eval $(ssh-agent) >/dev/null 2>&1
