# funroll gentoo repository

for funrolling your loops

## what

This is a Gentoo [overlay](https://wiki.gentoo.org/wiki/Overlay) for nigh-unpackaged software in Gentoo.

And if I can get it working, perhaps new ways
to bootstrap compilers. (Rust from Ocaml when??)

## how to install

There are two options.

1. Git-sync directly from GitHub

    ```bash
    # /etc/portage/repos.conf/funroll.conf
    [funroll]
    location = /var/db/repos/funroll
    sync-type = git
    sync-uri = https://github.com/swomf/overlay-funroll
    ```

2. Git clone into your local user...

    ```bash
    $ git clone https://github.com/swomf/overlay-funroll
    ```

    then git-sync from said user.

    ```bash
    # /etc/portage/repos.conf/funroll.conf
    [funroll]
    location = /var/db/repos/funroll
    sync-type = git
    sync-uri = /home/user/blahblahwherever/overlay-funroll
    ```

    This is what I use, but I'm biased because this just makes development easier.
