EAPI=8

inherit shell-completion

DESCRIPTION="A cozy nest for your scripts."
HOMEPAGE="https://github.com/ianthehenry/sd"
SRC_URI="https://github.com/ianthehenry/sd/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="app-shells/bash"

S="${WORKDIR}/sd-${PV}"

src_install() {
	dobin sd
	dozshcomp _sd
	dodoc README.md
}
