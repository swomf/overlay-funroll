# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

GO_OPTIONAL=1
inherit go-module meson optfeature

DESCRIPTION="Scaffolding CLI tool for Astal and Gnim projects"
HOMEPAGE="https://github.com/Aylur/ags"
SRC_URI="
	https://github.com/Aylur/ags/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/swomf/reproducible-tarballs/releases/download/${P}/${P}-deps.tar.xz
	https://github.com/swomf/reproducible-tarballs/releases/download/${P}/${P}-node_modules.tar.xz
"

S="${WORKDIR}/ags-${PV}"

LICENSE="Apache-2.0 BSD BSD-2 GPL-3 MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-libs/gjs
	dev-libs/gobject-introspection
	gui-libs/astal-gtk4
	gui-libs/astal-io
	gui-libs/gtk4-layer-shell
	net-libs/nodejs[npm]
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-lang/go-1.24.6
	app-arch/unzip
	virtual/pkgconfig
"

src_unpack() {
	default
	mv "${WORKDIR}"/node_modules "${S}" || die
}

src_configure() {
	go-module_src_configure
	meson_src_configure
}

pkg_postinst() {
	optfeature "GTK 3 projects" gui-libs/astal-gtk3
	optfeature "Blueprint UI files" dev-util/blueprint-compiler
	optfeature "SCSS stylesheets" dev-util/dart-sass-bin
}
