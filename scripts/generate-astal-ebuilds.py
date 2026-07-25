#!/usr/bin/env python3
# generate gui-libs/astal-* for the Astal monorepo
# - the latest gitrev and its author date (not current date)
#   are read from GitHub unless both are supplied by cli
# - see render_ebuild() for the hotpath
# - hardcoded maintainer name :)

from __future__ import annotations

import argparse
import dataclasses
import datetime as dt
import json
import pathlib
import sys
import urllib.request


REPOSITORY = "Aylur/astal"
ROOT = pathlib.Path(__file__).resolve().parents[1]
MAINTAINER = """  <maintainer type="person">
    <email>swomf@proton.me</email>
    <name>swomf</name>
  </maintainer>"""


@dataclasses.dataclass(frozen=True)
class Package:
    name: str
    source: str
    description: str
    rdepend: tuple[str, ...] = ("dev-libs/glib:2",)
    bdepend: tuple[str, ...] = ()
    python: bool = True
    vala: bool = True
    iuse: str = ""
    required_use: str = ""
    gnome2_schemas: bool = False  # i.e. notifd
    patches: tuple[str, ...] = ()


PACKAGES = (
    Package(
        "astal-io",
        "lib/astal/io",
        "Core I/O library for Astal",
    ),
    Package(
        "astal-gtk3",
        "lib/astal/gtk3",
        "GTK 3 building blocks for desktop shells",
        (
            "dev-libs/glib:2",
            "dev-libs/wayland",
            "gui-libs/astal-io",
            "gui-libs/gtk-layer-shell[vala]",
            "x11-libs/gdk-pixbuf:2",
            "x11-libs/gtk+:3",
        ),
        ("dev-libs/wayland-protocols",),
    ),
    Package(
        "astal-gtk4",
        "lib/astal/gtk4",
        "GTK 4 building blocks for desktop shells",
        (
            "dev-libs/glib:2",
            "dev-libs/wayland",
            "gui-libs/astal-io",
            "gui-libs/gtk4-layer-shell[vala]",
            "gui-libs/gtk:4",
        ),
    ),
    Package(
        "astal-apps",
        "lib/apps",
        "Library and command-line tool for querying applications",
        ("dev-libs/glib:2", "dev-libs/json-glib"),
    ),
    Package(
        "astal-auth",
        "lib/auth",
        "Authentication library for Astal",
        ("dev-libs/glib:2", "sys-libs/pam"),
    ),
    Package(
        "astal-battery",
        "lib/battery",
        "UPower D-Bus proxy library for Astal",
        ("dev-libs/glib:2", "dev-libs/json-glib"),
    ),
    Package(
        "astal-bluetooth",
        "lib/bluetooth",
        "BlueZ D-Bus wrapper library for Astal",
    ),
    Package(
        "astal-brightness",
        "lib/brightness",
        "Library and command-line tool for controlling display brightness",
        (
            "dev-libs/glib:2",
            "dev-libs/json-glib",
            "gui-libs/astal-quarrel",
        ),
    ),
    Package(
        "astal-cava",
        "lib/cava",
        "Audio visualization library using CAVA",
        ("dev-libs/glib:2", ">=media-sound/libcava-1.0.0"),
    ),
    Package(
        "astal-greetd",
        "lib/greet",
        "Greetd IPC client library for Astal",
        (
            "dev-libs/glib:2",
            "dev-libs/json-glib",
            "gui-libs/astal-quarrel",
        ),
    ),
    Package(
        "astal-hyprland",
        "lib/hyprland",
        "Library and command-line tool for Hyprland IPC sockets",
        ("dev-libs/glib:2", "dev-libs/json-glib"),
        # NOTE: https://github.com/Aylur/astal/pull/446 wants to merge
        #       support for the new hyprland v0.55 dispatchers, but the mr
        #       breaks astal back-compat and hasnt been accepted.
        #       to prevent hyprland v0.55+ users from being totally SOL,
        #       our ebuild simply trusts that the user is on Hyprland v0.55+.
        # WARNING: This may need removing if upstream gets around to merging
        patches=("hyprwm-v0.55-lua.patch",),
    ),
    Package(
        "astal-mpris",
        "lib/mpris",
        "Library and command-line tool for controlling media players",
        (
            "dev-libs/glib:2",
            "dev-libs/json-glib",
            "gui-libs/astal-quarrel",
            "net-libs/libsoup:3.0",
            "x11-libs/gdk-pixbuf:2",
        ),
    ),
    Package(
        "astal-network",
        "lib/network",
        "NetworkManager wrapper library for Astal",
        ("dev-libs/glib:2", "net-misc/networkmanager"),
    ),
    Package(
        "astal-notifd",
        "lib/notifd",
        "Notification daemon library and command-line tool",
        (
            "dev-libs/glib:2",
            "dev-libs/json-glib",
            "gui-libs/astal-quarrel",
            "x11-libs/gdk-pixbuf:2",
        ),
        gnome2_schemas=True,
    ),
    Package(
        "astal-powerprofiles",
        "lib/powerprofiles",
        "Power-profiles-daemon D-Bus wrapper library for Astal",
        ("dev-libs/glib:2", "dev-libs/json-glib"),
    ),
    Package(
        "astal-quarrel",
        "lib/quarrel",
        "Command-line argument parsing library",
    ),
    Package(
        "astal-wl",
        "lib/wl",
        "Wayland connection manager library for Astal",
        ("dev-libs/glib:2", "dev-libs/wayland"),
        ("dev-libs/wayland-protocols", "dev-util/wl-vapi-gen"),
    ),
    Package(
        "astal-river",
        "lib/river",
        "Status library for the River Wayland compositor",
        (
            "dev-libs/glib:2",
            "dev-libs/wayland",
            "gui-libs/astal-wl",
        ),
        ("dev-libs/wayland-protocols", "dev-util/wl-vapi-gen"),
    ),
    Package(
        "astal-tray",
        "lib/tray",
        "System tray library and command-line tool for Astal",
        (
            "dev-libs/glib:2",
            "dev-libs/json-glib",
            "gui-libs/appmenu-glib-translator",
            "x11-libs/gdk-pixbuf:2",
        ),
    ),
    Package(
        "astal-wireplumber",
        "lib/wireplumber",
        "WirePlumber audio control library for Astal",
        ("dev-libs/glib:2", "media-video/wireplumber:0="),
    ),
    Package(
        "astal-gjs",
        "lang/gjs",
        "GJS bindings for Astal",
        (
            "dev-libs/gjs",
            "gui-libs/astal-io",
            "gtk3? ( gui-libs/astal-gtk3 )",
            "gtk4? ( gui-libs/astal-gtk4 )",
        ),
        (),
        False,
        False,
        "+gtk3 gtk4",
        "|| ( gtk3 gtk4 )",
    ),
)

META_FLAGS = {
    "apps": ("library and command-line tool for querying applications", "astal-apps"),
    "auth": ("authentication library", "astal-auth"),
    "battery": ("UPower D-Bus proxy library", "astal-battery"),
    "bluetooth": ("BlueZ D-Bus wrapper library", "astal-bluetooth"),
    "brightness": ("display brightness control library", "astal-brightness"),
    "cava": ("audio visualization library", "astal-cava"),
    "gjs": ("GJS bindings", "astal-gjs"),
    "greetd": ("Greetd IPC client library", "astal-greetd"),
    "gtk3": ("GTK 3 shell library", "astal-gtk3"),
    "gtk4": ("GTK 4 shell library", "astal-gtk4"),
    "hyprland": ("Hyprland IPC library", "astal-hyprland"),
    "mpris": ("MPRIS media player library", "astal-mpris"),
    "network": ("NetworkManager wrapper library", "astal-network"),
    "notifd": ("notification daemon library", "astal-notifd"),
    "powerprofiles": ("power profiles library", "astal-powerprofiles"),
    "river": ("River compositor status library", "astal-river"),
    "tray": ("system tray library", "astal-tray"),
    "wireplumber": ("WirePlumber audio library", "astal-wireplumber"),
}


def latest_revision() -> tuple[str, str]:
    "return revision, date"
    request = urllib.request.Request(
        f"https://api.github.com/repos/{REPOSITORY}/commits?per_page=1",
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "overlay-funroll-astal-generator",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            commit = json.load(response)[0]
    except (OSError, KeyError, IndexError, json.JSONDecodeError) as error:
        raise SystemExit(
            f"failed to query the latest Astal git revision: {error}"
        ) from error
    revision = commit["sha"]
    date = dt.datetime.fromisoformat(
        commit["commit"]["author"]["date"].replace("Z", "+00:00")
    ).strftime("%Y%m%d")
    return revision, date


def dependency_block(name: str, values: tuple[str, ...]) -> str:
    "a = (\n\tb\n\tc\n\td)"
    if not values:
        return f'{name}=""\n'
    body = "\n".join(f"\t{value}" for value in values)
    return f'{name}="\n{body}\n"\n'


def render_ebuild(package: Package, revision: str) -> str:
    "this is likely to change"
    inherits = ["meson"]
    if package.python:
        inherits.append("python-any-r1")
    if package.vala:
        inherits.append("vala")
    if package.gnome2_schemas:
        inherits.append("gnome2-utils")
    python = "PYTHON_COMPAT=( python3_{11..15} )\n" if package.python else ""
    vala = 'VALA_USE_DEPEND="valadoc vapigen"\n' if package.vala else ""
    bdepend = (("${PYTHON_DEPS}",) if package.python else ()) + ("dev-build/meson",)
    if package.vala:
        bdepend += ("$(vala_depend)", "dev-libs/gobject-introspection")
    bdepend += package.bdepend
    optional = f'IUSE="{package.iuse}"\n' if package.iuse else ""
    required = (
        f'REQUIRED_USE="{package.required_use}"\n' if package.required_use else ""
    )
    patches = (
        "PATCHES=( {} )\n".format(
            " ".join(f'"${{FILESDIR}}/{patch}"' for patch in package.patches)
        )
        if package.patches
        else ""
    )
    # they all point at the same-named tarball -- for caching
    ebuild = f"""# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# This package was autogenerated by scripts/generate-astal-ebuilds.py.
# Do not edit directly.

EAPI=8

{python}{vala}inherit {" ".join(inherits)}

DESCRIPTION="{package.description}"
HOMEPAGE="https://github.com/{REPOSITORY}"
REVISION="{revision}"
SRC_URI="https://github.com/{REPOSITORY}/archive/${{REVISION}}.tar.gz -> astal-${{REVISION}}.tar.gz"
S="${{WORKDIR}}/astal-${{REVISION}}"
EMESON_SOURCE="${{S}}/{package.source}"
{patches}
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
{optional}{required}
{dependency_block("RDEPEND", package.rdepend)}DEPEND="${{RDEPEND}}"
{dependency_block("BDEPEND", bdepend)}"""
    if package.vala:
        ebuild += """src_configure() {
	vala_setup
	meson_src_configure
}
"""
    if package.gnome2_schemas:
        ebuild += """
pkg_postinst() {
	gnome2_schemas_update
}

pkg_postrm() {
	gnome2_schemas_update
}
"""
    return ebuild


def render_meta_ebuild() -> str:
    "this is less likely to change"
    flags = " ".join(f"+{flag}" if flag in {"gtk3"} else flag for flag in META_FLAGS)
    deps = ["gui-libs/astal-io"]
    for flag, (_, package) in META_FLAGS.items():
        use_deps = "[gtk3=,gtk4=]" if flag == "gjs" else ""
        deps.append(f"{flag}? ( gui-libs/{package}{use_deps} )")
    return f"""# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# This package was autogenerated by scripts/generate-astal-ebuilds.py.
# Prefer to edit scripts/generate-astal-ebuilds.py over this ebuild directly.

EAPI=8

DESCRIPTION="Meta package for the Astal library collection"
HOMEPAGE="https://github.com/{REPOSITORY}"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64"
IUSE="{flags}"
REQUIRED_USE="gjs? ( || ( gtk3 gtk4 ) )"

{dependency_block("RDEPEND", tuple(deps))}
"""


def render_metadata(package: Package | None = None) -> str:
    use = ""
    if package and package.iuse:
        descriptions = {
            "gtk3": "Install bindings for <pkg>gui-libs/astal-gtk3</pkg>",
            "gtk4": "Install bindings for <pkg>gui-libs/astal-gtk4</pkg>",
        }
        flags = "\n".join(
            f'    <flag name="{flag.lstrip("+")}">'
            f'{descriptions[flag.lstrip("+")]}</flag>'
            for flag in package.iuse.split()
        )
        use = f"\n  <use>\n{flags}\n  </use>"
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE pkgmetadata SYSTEM "https://www.gentoo.org/dtd/metadata.dtd">
<pkgmetadata>
{MAINTAINER}{use}
  <upstream>
    <bugs-to>https://github.com/{REPOSITORY}/issues</bugs-to>
    <remote-id type="github">{REPOSITORY}</remote-id>
  </upstream>
</pkgmetadata>
"""


def render_meta_metadata() -> str:
    flags = "\n".join(
        f'    <flag name="{flag}">Install the {description}</flag>'
        for flag, (description, _) in META_FLAGS.items()
    )
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE pkgmetadata SYSTEM "https://www.gentoo.org/dtd/metadata.dtd">
<pkgmetadata>
{MAINTAINER}
  <use>
{flags}
  </use>
  <upstream>
    <bugs-to>https://github.com/{REPOSITORY}/issues</bugs-to>
    <remote-id type="github">{REPOSITORY}</remote-id>
  </upstream>
</pkgmetadata>
"""


def write_package(package: Package, revision: str, version: str) -> pathlib.Path:
    directory = ROOT / "gui-libs" / package.name
    directory.mkdir(parents=True, exist_ok=True)
    ebuild = directory / f"{package.name}-{version}.ebuild"
    ebuild.write_text(render_ebuild(package, revision).rstrip() + "\n")
    metadata = directory / "metadata.xml"
    metadata.write_text(render_metadata(package))
    return ebuild


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--revision", help="40-character Astal Git revision")
    parser.add_argument("--date", help="revision date in YYYYMMDD format")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if bool(args.revision) != bool(args.date):
        raise SystemExit("--revision and --date must be supplied together")
    if args.revision:
        revision, date = args.revision, args.date
    else:
        revision, date = latest_revision()
    if len(revision) != 40 or any(char not in "0123456789abcdef" for char in revision):
        raise SystemExit("--revision must be a lowercase 40-character hexadecimal SHA")
    try:
        dt.datetime.strptime(date, "%Y%m%d")
    except ValueError as error:
        raise SystemExit("--date must use YYYYMMDD format") from error

    version = f"0_pre{date}"
    written = [write_package(package, revision, version) for package in PACKAGES]

    meta = ROOT / "gui-libs" / "astal-meta"
    meta.mkdir(parents=True, exist_ok=True)
    meta_ebuild = meta / f"astal-meta-{version}.ebuild"
    meta_ebuild.write_text(render_meta_ebuild().rstrip() + "\n")
    (meta / "metadata.xml").write_text(render_meta_metadata())
    written.append(meta_ebuild)

    for path in written:
        print(path.relative_to(ROOT))

    print("dont forget to run")
    print("    pkgdev manifest gui-libs/astal-*")
    print("(possibly with -d to a temp dir)")

    return 0


if __name__ == "__main__":
    sys.exit(main())
