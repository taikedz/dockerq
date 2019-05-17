### dockerq ASSETTYPE [OPTIONS] Usage:help
# Short, consistent docker commands for common tasks.
#
# OPTIONS
# -------
#
# -a, --all
#   List all ; only useful for containers
#
# -n, --name
#   List only the names
#
# -i, --id
#   List only the IDs
#
# -f, --format
#   Specify a stored format string name
#   You can store format strings in dockerctl-queries.conf
#   in ./ , ~/.config/dockerctl/ or /etc/dockerctl/
#   as key-value pairs
#
#   e.g.
#     ports={{.Names}}\t{{.Ports}}
#
#
# -n, -i and -f are mutually exclusive
#
#
#
# ASSETTYPE
# ---------
#
# i, image
#   list basic image info
#
# c, container
#   list basic container info
#
# v, volume
#   list basic volume info
#
# n, network
#   list basic network info
#
###/doc
