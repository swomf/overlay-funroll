# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

VALA_USE_DEPEND="vapigen"
inherit meson vala

DESCRIPTION="Translate DBusMenu-exported menus into GMenuModels"
HOMEPAGE="https://gitlab.com/vala-panel-project/vala-panel-appmenu"
REVISION="4031e981aa60fa3cb4184edaaf20040a241ab6e3"
SRC_URI="https://gitlab.com/vala-panel-project/vala-panel-appmenu/-/archive/${REVISION}/vala-panel-appmenu-${REVISION}.tar.bz2 -> ${P}.tar.bz2"
S="${WORKDIR}/vala-panel-appmenu-${REVISION}"
EMESON_SOURCE="${S}/subprojects/appmenu-glib-translator"

LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~loong ~ppc64 ~riscv x86"

RDEPEND="
	>=dev-libs/glib-2.52.0:2
	>=x11-libs/gdk-pixbuf-2.0.0:2
"
DEPEND="${RDEPEND}"
BDEPEND="
	$(vala_depend)
	dev-libs/gobject-introspection
	dev-util/gdbus-codegen
	dev-util/glib-utils
	virtual/pkgconfig
"

src_configure() {
	vala_setup
	meson_src_configure
}
