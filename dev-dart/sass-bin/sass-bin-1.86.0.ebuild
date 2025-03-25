# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
#MY_PN=${PN%-bin}

DESCRIPTION=" The reference implementation of Sass, written in Dart."
HOMEPAGE="https://github.com/sass/dart-sass"
SRC_URI="
amd64? (
    https://github.com/sass/dart-sass/releases/download/${PV}/dart-sass-1.86.0-linux-x64.tar.gz
)
arm? (
    https://github.com/sass/dart-sass/releases/download/${PV}/dart-sass-1.86.0-linux-arm.tar.gz
)
arm64? (
    https://github.com/sass/dart-sass/releases/download/${PV}/dart-sass-1.86.0-linux-arm64.tar.gz
)
x86? (
    https://github.com/sass/dart-sass/releases/download/${PV}/dart-sass-1.86.0-linux-ia32.tar.gz
)
riscv? (
    https://github.com/sass/dart-sass/releases/download/${PV}/dart-sass-1.86.0-linux-riscv64.tar.gz
)
ppc-macos? (
    https://github.com/sass/dart-sass/releases/download/${PV}/dart-sass-1.86.0-macos-x64.tar.gz
)
"
# excluded: windows-x64, windows-ia32, windows-arm64
#           macos-arm64
#           android-x64 android-ia32 android-arm64 android-arm

# from src/LICENSE file
LICENSE="MIT BSD-3-Clause Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~amd64 ~arm ~arm64 ~x86 ~riscv ~ppc-macos"

DEPEND="sys-libs/glibc"
RDEPEND="${DEPEND}"

QA_PREBUILT="usr/bin/*"
RESTRICT="strip"
S="${WORKDIR}/dart-sass"

# NOTE: If there is ever a way to build dart-sass from dart,
#       which would require:
#         1. package dart
#         2. set up a bootstrap for dart
#         3. package dart-sass
#       then we'd have to set up some kind of eselect
#       and symlink to sass-bin. But nah -- we just dobin sass.
DIR="/opt/${PN}"
src_install() {
	exeinto "${DIR}"
	doexe sass

	exeinto "${DIR}/src"
	doexe src/dart

	insinto "${DIR}/src"
	doins src/LICENSE src/sass.snapshot

	dosym "${DIR}/sass" "/usr/bin/sass"
}

pkg_postinst() {
	elog "If a non -bin version of dart sass is packaged,"
	elog "revdeps will need to be updated to use a virtual package"
}
