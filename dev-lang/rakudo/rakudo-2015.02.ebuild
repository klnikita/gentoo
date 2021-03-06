# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PARROT_VERSION="6.7.0"

MY_PV="2015.01"

inherit eutils multilib

DESCRIPTION="A Perl 6 implementation built on the Parrot virtual machine"
HOMEPAGE="http://rakudo.org/"
SRC_URI="http://rakudo.org/downloads/${PN}/${P}.tar.gz"

LICENSE="Artistic-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc +parrot java moar"

RDEPEND="parrot? ( >=dev-lang/parrot-${PARROT_VERSION}:=[unicode] )
	>=dev-lang/nqp-${MY_PV}[parrot?,java?,moar?]"
DEPEND="${RDEPEND}
	dev-lang/perl"

src_prepare() {
	sed -i "s,\$(DOCDIR)/rakudo$,&-${PVR}," tools/build/Makefile-Parrot.in || die
}

src_configure() {
	use parrot && myconf+="parrot,"
	use java && myconf+="jvm,"
	use moar && myconf+="moar,"
	perl Configure.pl --backends=${myconf} --prefix=/usr || die

	# why doesn't ops2c get detected?! :(
	if use parrot; then
		 sed -i -e 's~OPS2C            = $(PARROT_BIN_DIR)/$(EXE)~OPS2C            = $(PARROT_BIN_DIR)/ops2c~' Makefile || die
	fi
}

src_test() {
	emake -j1 test || die
}

src_install() {
	emake -j1 DESTDIR="${ED}" install || die

	dodoc CREDITS README.md docs/ChangeLog docs/ROADMAP || die

	if use doc; then
		dohtml -A svg docs/architecture.html docs/architecture.svg || die
		dodoc docs/*.pod || die
		docinto announce
		dodoc docs/announce/* || die
	fi
}
