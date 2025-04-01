# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A miniature file watcher, similar to inotifywait"
HOMEPAGE="https://github.com/swomf/mfw"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/swomf/mfw"
else
	SRC_URI="https://github.com/swomf/${PN}/archive/refs/tags/v${PV}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~m68k ~ppc64 ~riscv ~x86"
fi

LICENSE="GPL-3"
SLOT="0"

RDEPEND=""
DEPEND=""
BDEPEND=""

src_install() {
	# DESTDIR support only added after v0.2.1
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
}
