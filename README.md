dockerq
=======

Short, consistent docker query commands for common tasks.

Docker has some inconsistent command names and the format and query paths are less-than-memorable.

This tool allows using much shorter and consistent commands, as well as storing long-winded format strings and JSON query strings in a disk file.

Examples
========

Show the names of containers, images, volumes and networks respectively (you can also use the long names `containers`, `images`, `volumes` and `networks`)

    dockerq c -n
    dockerq i -n
    dockerq v -n
    dockerq n -n

See the names and port mappings for containers (from `dockerq-queries.conf` example file)

    dockerq c -f ports

Use the stored `ipf` string (from `dockerq-queries.conf` example file) to print the IP address fo the container

    dockerq inspect mycontainer ipf

Use the stored `ipf` string, on all containers whose names contain `app` (note the use of `ins` is equivalent to spelling out `inspect`)

    dockerq ins app ipf -a -t container

Usage
=====

    dockerq ASSETTYPE [OPTIONS]

OPTIONS
-------

-a, --all
    List all ; only useful for containers

-n, --name
    List only the names

-i, --id
    List only the IDs

-f, --format
    Specify a stored format string name
    You can store format strings in dockerq-queries.conf
    in ./ , ~/.config/dockerq/ or /etc/dockerq/
    as key-value pairs

    e.g.
      ports={{.Names}}t{{.Ports}}


-n, -i and -f are mutually exclusive



ASSETTYPE
---------

i, image
    list basic image info

c, container
    list basic container info

v, volume
    list basic volume info

n, network
    list basic network info


dockerq {inspect|ins} ASSETNAME FILTERNAME [OPTIONS]
=======

`dockerq ins ...` and `dockerq inspect ...` are equivalent.

OPTIONS
-------

-t, --type
    Specify an asset type for inspection; useful if two asset types share a name



ASSETNAME
---------

If the `-a` or `--all` global option was passed, `ASSETNAME` serves as a filter to apply to all asset names of a given type.

The special name `--list` will list all available saved filters.


FILTERNAME
----------

Use a saved filter name. You can add these to a dockerq-queries.conf file in your local directory, or in $HOME/.config/dockerq/ or /etc/dockerq/

Example
-------

Given this entry in the config file

    ipf=.[0].NetworkSettings.Networks[].IPAddress

You can call like this

    dockerq inspect mycontainer ipf

To get the IP of the specified container, or

    dockerq inspect somename ipf -t container

To apply `somename` as a matching filter to all `container` names to run the inspect query against

