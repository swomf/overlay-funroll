# Copyright 2021-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font

DESCRIPTION="world's biggest collection of classic text mode fonts, system fonts and BIOS fonts from DOS-era IBM PCs and compatibles"
HOMEPAGE="https://int10h.org/oldschool-pc-fonts/"
SRC_URI="https://int10h.org/oldschool-pc-fonts/download/oldschool_pc_font_pack_v${PV}_linux.zip -> ${P}.zip"
S="${WORKDIR}"

LICENSE="CC-BY-SA-4.0"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="bindist mirror strip"

FONT_SUFFIX="ttf"

src_prepare() {
	default
	mv */*.ttf . || die
}
