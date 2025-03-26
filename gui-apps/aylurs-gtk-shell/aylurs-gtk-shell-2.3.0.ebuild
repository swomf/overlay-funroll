# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module optfeature

DESCRIPTION="Aylurs's Gtk Shell (AGS), An eww inspired gtk widget system."
HOMEPAGE="https://github.com/Aylur/ags"
SRC_URI="
	https://github.com/Aylur/ags/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/swomf/reproducible-tarballs/releases/download/${P}/${P}-deps.tar.xz -> ${P}-vendor.tar.xz
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}/ags-${PV}"
BUILD_DIR="${S}/build"

RDEPEND="
	gui-libs/astal[gjs]
	gui-libs/gtk4-layer-shell
"
DEPEND="
	${RDEPEND}
"

src_compile() {
	# from wiki
	ego build -ldflags "\
    -X 'main.gtk4LayerShell=$(pkg-config --variable=libdir gtk4-layer-shell-0)/libgtk4-layer-shell.so' \
    -X 'main.astalGjs=$(pkg-config --variable=srcdir astal-gjs)'" || die
}

src_install() {
	dobin ags
}

pkg_postinst() {
	elog "ags v2 includes many breaking changes compared to v1. Revert to 1.8.2 if needed."
	elog "To install backend astal libraries, install dev-libs/astal[io] first, then configure astal USE flags."
	optfeature "Support for scss" dev-dart/sass-bin
}
