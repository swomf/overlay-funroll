# funroll gentoo repository

for funrolling your loops

## what

This is a Gentoo [overlay](https://wiki.gentoo.org/wiki/Overlay)
for nigh-unpackaged software in Gentoo.

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

    This is what I use, but I'm biased because this just
    makes development easier.

## extra notes 

No `::funroll` package is live-ebuild only; everything either has a
version or is saved via date e.g. `anyrun-0_pre20250429`.
This is based on a
[no 9999 only convention](https://leo3418.github.io/2023/02/07/avoid-9999-only-gentoo-packages.html#if-upstream-does-not-make-releases)

Extra categories are added on by the rigorous precondition of:
if I feel like it.

There may be unresolvable dependencies, such as the Kirottu kidex
for anyrun (see anyrun's postinst).

Packages or edits may be removed if they're added to guru or gentoo.

Otherwise we are standard: packages are git-added with `pkgdev commit`,
`pkgcheck scan --commits --net`, and then `git commit --amend` to add a
`Signed-off-by` signature at the end of each commit message.
