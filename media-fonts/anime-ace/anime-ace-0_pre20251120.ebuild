# Copyright 2021-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="anime-ace family (freeware comic-book style display fonts)"
HOMEPAGE="https://www.1001fonts.com/${PN}-font.html"
SRC_URI="https://www.1001fonts.com/download/${PN}.zip -> ${P}.zip"
S="${WORKDIR}"

LICENSE="anime-ace"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="bindist mirror strip"

FONT_SUFFIX="ttf"
