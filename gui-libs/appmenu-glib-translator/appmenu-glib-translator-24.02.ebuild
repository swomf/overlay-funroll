# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Global Menu for Vala Panel (and xfce4-panel and mate-panel)"
HOMEPAGE="https://gitlab.com/vala-panel-project/vala-panel-appmenu"
SRC_URI="https://gitlab.com/-/project/6865053/uploads/df5899c60d0835ef6593dfd2f709a8e3/${P}.tar.xz"
S="${WORKDIR}"/${P}

LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~loong ~ppc64 ~riscv x86"
IUSE="gtk2 test wayland"

RDEPEND="
	>=x11-libs/gdk-pixbuf-2.0.0
	dev-util/glib-utils
	dev-util/gdbus-codegen
	>=x11-libs/gtk+-3.22.0:3[wayland?]
	>=dev-libs/gobject-introspection-1.0.0
	dev-lang/vala
"
DEPEND="
	>=dev-libs/glib-2.52.0
	${RDEPEND}
	wayland? ( dev-libs/wayland )
"
BDEPEND="
	virtual/pkgconfig
"
