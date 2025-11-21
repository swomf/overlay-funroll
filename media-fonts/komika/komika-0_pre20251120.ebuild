# Copyright 2021-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font

DESCRIPTION="komika font family (comic-book style display fonts)"
HOMEPAGE="https://www.1001fonts.com/komika-font.html"
SRC_URI="https://www.1001fonts.com/download/${PN}.zip -> ${P}.zip"
S="${WORKDIR}"

LICENSE="komika"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="bindist mirror strip"

FONT_SUFFIX="ttf"
