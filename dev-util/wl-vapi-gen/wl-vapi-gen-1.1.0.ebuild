# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )
inherit meson python-single-r1

DESCRIPTION="Generate Vala bindings for Wayland protocols"
HOMEPAGE="https://codeberg.org/kotontrion/wl-vapi-gen"
SRC_URI="https://github.com/kotontrion/wl-vapi-gen/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="${PYTHON_DEPS}"
BDEPEND="
	${PYTHON_DEPS}
	dev-build/meson
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
