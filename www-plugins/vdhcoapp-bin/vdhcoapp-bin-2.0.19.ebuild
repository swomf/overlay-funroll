# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Companion application for Video DownloadHelper browser add-on"
HOMEPAGE="https://github.com/aclap-dev/vdhcoapp"
SRC_URI="
system-ffmpeg? (
	amd64? ( https://github.com/aclap-dev/vdhcoapp/releases/download/v${PV}/vdhcoapp-noffmpeg-linux-x86_64.tar.bz2 )
	arm64? (  https://github.com/aclap-dev/vdhcoapp/releases/download/v${PV}/vdhcoapp-noffmpeg-linux-aarch64.tar.bz2 )
	x86? ( https://github.com/aclap-dev/vdhcoapp/releases/download/v${PV}/vdhcoapp-noffmpeg-linux-i686.tar.bz2 )
)
!system-ffmpeg? (
	amd64? ( https://github.com/aclap-dev/vdhcoapp/releases/download/v${PV}/vdhcoapp-linux-x86_64.tar.bz2 )
	arm64? (  https://github.com/aclap-dev/vdhcoapp/releases/download/v${PV}/vdhcoapp-linux-aarch64.tar.bz2 )
	x86? ( https://github.com/aclap-dev/vdhcoapp/releases/download/v${PV}/vdhcoapp-linux-i686.tar.bz2 )
)
"

S="${WORKDIR}/vdhcoapp-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="+system-ffmpeg"

RDEPEND="system-ffmpeg? ( media-video/ffmpeg )"

RESTRICT="strip" # -bin

src_install() {
	dodir "/opt/${P}"
	cp -R "${S}/." "${D}/opt/${P}" || die "Install failed!"
	dosym ../../opt/${P}/vdhcoapp /usr/bin/vdhcoapp-bin
}

pkg_postinst() {
	elog "After installing the Video DownloadHelper browser extension,"
	elog "register the coapp with your browser by running:"
	elog "\t${PN} install"
	elog "as a non-root user."
}
