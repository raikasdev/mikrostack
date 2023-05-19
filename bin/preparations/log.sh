warn()
{
    printf '\e[1;31m%-6s\n\e[m' "$1"
}

log()
{
    printf '\e[1;33m%-6s\n\e[m' "$1"
}

success()
{
    printf '\e[1;32m%-6s\n\e[m' "$1"
}

cyan()
{
    printf '\e[1;36m%-6s\n\e[m' "$1"
}