# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=(lua5-{1..4})
inherit meson lua-single optfeature

DESCRIPTION="Libraries for Aylur's GTK Shell"
HOMEPAGE="https://github.com/Aylur/astal"
LICENSE="LGPL-2.1-only"
SLOT="0"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Aylur/astal.git"
else
	GIT_COMMIT="4820a3e37cc8eb81db6ed991528fb23472a8e4de"
	SRC_URI="https://github.com/Aylur/astal/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${GIT_COMMIT}"
	KEYWORDS="~amd64"
fi

IUSE="
	introspection
	hyprland
	wireplumber
	network
	powerprofiles
	bluetooth
	river
	mpris
	battery
	tray
	notifd
	apps
	auth
	+io
	greetd
	gjs
	cava
	gtk3
	gtk4
	lua
"

REQUIRED_USE="
	${LUA_REQUIRED_USE}
	gjs? ( io )
	gtk3? ( io )
	gtk4? ( io )
"

# Deps calculated from
#   https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libastal- * -git
#   except for gtk3, which is just base libastal-git.
# Missing: 1. vala-panel-appmenu[translator] (it's a subproject)
#             https://aur.archlinux.org/packages/appmenu-glib-translator-git
# TODO: should battery require sys-power/upower?
#       should bluetooth require net-wireless/bluez?
#
# NOTE: 1st empty space is bluetooth (excluded since it has no extra rdepends)
#       2nd empty space is io        (excluded since it has no extra rdepends)
#       I set [+gtk3] because its aur package naming implies it is the default
RDEPEND="
	sys-libs/glibc
	dev-libs/glib:2
	hyprland? ( dev-libs/json-glib )
	wireplumber? ( media-video/wireplumber )
	network? ( net-libs/libnma[vala] )
	powerprofiles? ( dev-libs/json-glib )

	river? ( dev-libs/json-glib dev-libs/wayland )
	mpris? ( dev-libs/json-glib )
	battery? ( dev-libs/json-glib )
	tray? ( dev-libs/json-glib x11-libs/gtk+:3 x11-libs/gdk-pixbuf:2 gui-libs/appmenu-glib-translator )
	notifd? ( dev-libs/json-glib x11-libs/gdk-pixbuf:2 )
	apps? ( dev-libs/json-glib )
	auth? ( sys-libs/pam )

	greetd? ( dev-libs/json-glib )
	gjs? ( dev-libs/gjs )
	cava? ( media-libs/libcava )
	gtk3? ( dev-libs/wayland dev-libs/wayland-protocols gui-libs/gtk-layer-shell[vala] x11-libs/gdk-pixbuf:2 )
	gtk4? ( x11-libs/gdk-pixbuf:2 gui-libs/gtk4-layer-shell[vala] dev-libs/wayland )
	lua? ( dev-lua/luarocks dev-lua/lgi )
	${LUA_DEPS}
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	${RDEPEND}
	dev-build/meson
	dev-lang/vala[valadoc]
	gui-libs/astal[io]
"
#NOTE: astal depends on astal[io] to ensure dependencies are installed in correct order
#FIXME: The user should be able to refuse vala documentation via a USE flag

declare -A ASTAL_LIBS
ASTAL_LIBS=(
	[io]="lib/astal/io"
	[gtk3]="lib/astal/gtk3"
	[gtk4]="lib/astal/gtk4"

	[gjs]="lang/gjs"
	#[lua]="lang/lua" # Keep this separate since it does not use meson

	[apps]="lib/apps"
	[auth]="lib/auth"
	[battery]="lib/battery"
	[bluetooth]="lib/bluetooth"
	[cava]="lib/cava"
	[greetd]="lib/greet"
	[hyprland]="lib/hyprland"
	[mpris]="lib/mpris"
	[network]="lib/network"
	[notifd]="lib/notifd"
	[powerprofiles]="lib/powerprofiles"
	[river]="lib/river"
	[tray]="lib/tray"
	[wireplumber]="lib/wireplumber"
)

src_configure() {
	for lib in "${!ASTAL_LIBS[@]}"; do
		if use "$lib"; then
			BUILD_DIR="${WORKDIR}/$lib-build" EMESON_SOURCE="${ASTAL_LIBS[$lib]}" meson_src_configure
		fi
	done
}

src_compile() {
	local VALA_VER=$(best_version dev-lang/vala)
	VALA_VER=${VALA_VER#*/*-} # reduce it to ${PV}-${PR}
	VALA_VER=${VALA_VER%.*}   # remove patch version
	export VALADOC="valadoc-$VALA_VER"

	for lib in "${!ASTAL_LIBS[@]}"; do
		if use "$lib"; then
			BUILD_DIR="${WORKDIR}/$lib-build" EMESON_SOURCE="${ASTAL_LIBS[$lib]}" meson_src_compile
		fi
	done

	if use lua; then
		lua_foreach_impl lua_src_compile -C "lang/lua"
	fi
}

src_install() {
	for lib in "${!ASTAL_LIBS[@]}"; do
		if use "$lib"; then
			BUILD_DIR="${WORKDIR}/$lib-build" EMESON_SOURCE="${ASTAL_LIBS[$lib]}" meson_src_install
		fi
	done
	if use lua; then
		LUA_VERSION="$(lua_get_version)" lua_foreach_impl lua_src_install -C "lang/lua"
	fi
}

pkg_postinst() {
	optfeature "support for battery monitor" sys-power/upower
}
