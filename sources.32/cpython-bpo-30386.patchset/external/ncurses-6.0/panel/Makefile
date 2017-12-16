# $Id: Makefile.in,v 1.69 2015/08/05 23:15:41 tom Exp $
##############################################################################
# Copyright (c) 1998-2014,2015 Free Software Foundation, Inc.                #
#                                                                            #
# Permission is hereby granted, free of charge, to any person obtaining a    #
# copy of this software and associated documentation files (the "Software"), #
# to deal in the Software without restriction, including without limitation  #
# the rights to use, copy, modify, merge, publish, distribute, distribute    #
# with modifications, sublicense, and/or sell copies of the Software, and to #
# permit persons to whom the Software is furnished to do so, subject to the  #
# following conditions:                                                      #
#                                                                            #
# The above copyright notice and this permission notice shall be included in #
# all copies or substantial portions of the Software.                        #
#                                                                            #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    #
# THE ABOVE COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING    #
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER        #
# DEALINGS IN THE SOFTWARE.                                                  #
#                                                                            #
# Except as contained in this notice, the name(s) of the above copyright     #
# holders shall not be used in advertising or otherwise to promote the sale, #
# use or other dealings in this Software without prior written               #
# authorization.                                                             #
##############################################################################
#
# Author: Thomas E. Dickey 1996-on
#
# Makefile for panels source code.
#
# This makes the following:
#	libraries (normal/debug/profile/shared)
#
# The variable 'srcdir' refers to the source-distribution, and can be set with
# the configure script by "--srcdir=DIR".
#
# The rules are organized to produce the libraries for the configured models,

# turn off _all_ suffix rules; we'll generate our own
.SUFFIXES:

SHELL		= /bin/sh

THIS		= Makefile

x		= 
o		= .o

MODEL		= shared
DESTDIR		= 
top_srcdir	= ..
srcdir		= .
prefix		= /data/data/u.src/apps/cpython-bpo-30386/Android/build/python3.7-extlibs-android-19-armv7//data/local/tmp/python
exec_prefix	= ${prefix}
bindir		= ${exec_prefix}/bin
libdir		= ${exec_prefix}/lib
includedir	= ${prefix}/include
datarootdir	= ${prefix}/share
datadir		= ${datarootdir}
includesubdir	= /ncursesw

INCLUDEDIR	= $(DESTDIR)$(includedir)$(includesubdir)

PACKAGE		= ncursesw

LIBTOOL		= 
LIBTOOL_OPTS	=  
LIBTOOL_CLEAN	= 
LIBTOOL_COMPILE	= 
LIBTOOL_LINK	= ${CC}
LIBTOOL_INSTALL	= 
LIBTOOL_UNINSTALL = 
LT_UNDEF	= 

INSTALL		= /usr/bin/install -c
INSTALL_LIB	= /usr/bin/install -c -m 644
INSTALL_PROG	= ${INSTALL}
INSTALL_DATA	= ${INSTALL} -m 644

AR		= /data/data/u.root/android/android-ndk-r14b/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-ar
ARFLAGS		= -curv
AWK		= mawk
LD		= /data/data/u.root/android/android-ndk-r14b/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-ld
LN_S		= ln -s -f

CTAGS		= 
ETAGS		= 

CC		= /data/data/u.root/android/android-ndk-r14b/toolchains/llvm/prebuilt/linux-x86_64/bin/clang -target armv7-none-linux-androideabi -gcc-toolchain /data/data/u.root/android/android-ndk-r14b/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
CPP		= /lib/cpp
CFLAGS		= --sysroot=/data/data/u.root/android/android-ndk-r14b/sysroot -D__ANDROID_API__=19 -isystem /data/data/u.root/android/android-ndk-r14b/sysroot/usr/include/arm-linux-androideabi  --param max-inline-insns-single=1200

CPPFLAGS	= -I${top_srcdir}/ncurses -DHAVE_CONFIG_H -I. -I../include   -D_XOPEN_SOURCE=500 -D_FILE_OFFSET_BITS=64  -DNDEBUG

CCFLAGS		= $(CPPFLAGS) $(CFLAGS)

CFLAGS_LIBTOOL	= $(CCFLAGS)
CFLAGS_NORMAL	= $(CCFLAGS)
CFLAGS_DEBUG	= $(CCFLAGS) -g -DTRACE
CFLAGS_PROFILE	= $(CCFLAGS) -pg
CFLAGS_SHARED	= $(CCFLAGS) -fPIC

CFLAGS_DEFAULT	= $(CFLAGS_SHARED)

LINK		= $(LIBTOOL_LINK)
LDFLAGS		=  --sysroot=/data/data/u.root/android/android-ndk-r14b/platforms/android-19/arch-arm  

SHLIB_DIRS	= -L../lib
SHLIB_LIST	= $(SHLIB_DIRS) -lncursesw 

RPATH_LIST	= ${libdir}
RESULTING_SYMS	= 
VERSIONED_SYMS	= 
MK_SHARED_LIB	= ${CC} ${CFLAGS} -shared -Wl,-soname,`basename $@`,-stats,-lc -o $@

NCURSES_MAJOR	= 6
NCURSES_MINOR	= 0
REL_VERSION	= 6.0
ABI_VERSION	= 6

RANLIB		= /data/data/u.root/android/android-ndk-r14b/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-ranlib

LIBRARIES	=  ../lib/libpanelw.so ../lib/libpanelw.a ../lib/libpanelw_g.a

LINT		= 
LINT_OPTS	= 
LINT_LIBS	= -lpanel -lncurses 

AUTO_SRC	= \
		../include/panel.h

################################################################################
all \
libs \
install ::	$(AUTO_SRC) $(LIBRARIES)

sources:	$(AUTO_SRC)

$(DESTDIR)$(bindir) \
$(DESTDIR)$(libdir) :
	mkdir -p $@

# make a copy to simplify include-paths while still keeping panel's include
# file in this directory.
../include/panel.h : $(srcdir)/panel.h
	-rm -f $@
	cp $(srcdir)/panel.h $@

HEADER_DEPS = \
	$(srcdir)/panel.priv.h \
	$(srcdir)/panel.h

tags:
	$(CTAGS) *.[ch]

#TAGS:
#	$(ETAGS) *.[ch]

mostlyclean ::
	-rm -f core tags TAGS *~ *.bak *.i *.ln *.atac trace

clean :: mostlyclean
	-rm -f $(AUTO_SRC)
	-rm -rf .libs *.dSYM

distclean :: clean
	-rm -f Makefile

realclean :: distclean

###############################################################################
# The remainder of this file is automatically generated during configuration
###############################################################################

# Generated by CF_LIB_RULES
resulting.map: 
	sed  -e "s/NCURSES\([WT]\+\)\?_/NCURSES\16_/g" -e "/deprecated in ABI6/d" <  >$@

clean::
	rm -f resulting.map

# generated by mk-0th.awk
#   libname:    panelw
#   subsets:    termlib+ext_tinfo+base+widechar+ext_funcs

.SUFFIXES: .c .cc .h .i .ii
.c.i :
	$(CPP) $(CPPFLAGS) $< >$@
.cc.ii :
	$(CPP) $(CPPFLAGS) $< >$@
.h.i :
	$(CPP) $(CPPFLAGS) $< >$@

C_SRC = \
	$(srcdir)/panel.c \
	$(srcdir)/p_above.c \
	$(srcdir)/p_below.c \
	$(srcdir)/p_bottom.c \
	$(srcdir)/p_delete.c \
	$(srcdir)/p_hide.c \
	$(srcdir)/p_hidden.c \
	$(srcdir)/p_move.c \
	$(srcdir)/p_new.c \
	$(srcdir)/p_replace.c \
	$(srcdir)/p_show.c \
	$(srcdir)/p_top.c \
	$(srcdir)/p_update.c \
	$(srcdir)/p_user.c \
	$(srcdir)/p_win.c

# Producing llib-lpanelw is time-consuming, so there's no direct-dependency for
# it in the lintlib rule.  We'll only remove in the cleanest setup.

PANELW_SRC = \
	$(srcdir)/panel.c \
	$(srcdir)/p_above.c \
	$(srcdir)/p_below.c \
	$(srcdir)/p_bottom.c \
	$(srcdir)/p_delete.c \
	$(srcdir)/p_hide.c \
	$(srcdir)/p_hidden.c \
	$(srcdir)/p_move.c \
	$(srcdir)/p_new.c \
	$(srcdir)/p_replace.c \
	$(srcdir)/p_show.c \
	$(srcdir)/p_top.c \
	$(srcdir)/p_update.c \
	$(srcdir)/p_user.c \
	$(srcdir)/p_win.c

clean ::
	rm -f llib-lpanelw.*

realclean ::
	rm -f llib-lpanelw

llib-lpanelw : $(PANELW_SRC)
	cproto -a -l -DNCURSES_ENABLE_STDBOOL_H=0 -DLINT $(CPPFLAGS) $(PANELW_SRC) >$@

lintlib ::
	sh $(srcdir)/../misc/makellib panelw $(CPPFLAGS)

lint ::
	$(LINT) $(LINT_OPTS) $(CPPFLAGS) $(PANELW_SRC) $(LINT_LIBS)

# generated by mk-1st.awk (subset=termlib+ext_tinfo+base+widechar+ext_funcs)
#  name:          panelw
#  traces:        DEBUG
#  MODEL:         SHARED
#  CXX_MODEL:     SHARED
#  model:         obj_s
#  prefix:        lib
#  suffix:        .so
#  subset:        termlib+ext_tinfo+base+widechar+ext_funcs
#  driver:        no
#  ShlibVer:      no
#  ShlibVerInfix: no
#  SymLink:       ln -s -f
#  TermlibRoot:   ncursesw
#  TermlibSuffix: .so
#  ReLink:        yes
#  DoLinks:       no
#  rmSoLocs:      no
#  ldconfig:      :
#  overwrite:     no
#  depend:        ../include/ncurses_cfg.h ./panel.priv.h
#  host:          arm-unknown-linux-androideabi

SHARED_OBJS = \
	../obj_s/panel$o \
	../obj_s/p_above$o \
	../obj_s/p_below$o \
	../obj_s/p_bottom$o \
	../obj_s/p_delete$o \
	../obj_s/p_hide$o \
	../obj_s/p_hidden$o \
	../obj_s/p_move$o \
	../obj_s/p_new$o \
	../obj_s/p_replace$o \
	../obj_s/p_show$o \
	../obj_s/p_top$o \
	../obj_s/p_update$o \
	../obj_s/p_user$o \
	../obj_s/p_win$o

$(SHARED_OBJS) : ../include/ncurses_cfg.h ./panel.priv.h

../lib/libpanelw.so : \
		../lib \
		$(RESULTING_SYMS) $(SHARED_OBJS)
	@echo linking $@
	$(MK_SHARED_LIB) $(SHARED_OBJS) $(SHLIB_LIST) $(LDFLAGS)

install \
install.libs \
install.panelw :: $(DESTDIR)$(libdir)/libpanelw.so

$(DESTDIR)$(libdir)/libpanelw.so : \
		$(DESTDIR)$(libdir) \
		$(RESULTING_SYMS) $(SHARED_OBJS)
	@echo linking $@
	$(MK_SHARED_LIB) $(SHARED_OBJS) $(SHLIB_LIST) $(LDFLAGS)

uninstall \
uninstall.libs \
uninstall.panelw ::
	@echo uninstalling $(DESTDIR)$(libdir)/libpanelw.so
	-rm -f $(DESTDIR)$(libdir)/libpanelw.so

clean ::
	-rm -f ../lib/libpanelw.so

mostlyclean::
	-rm -f $(SHARED_OBJS)

# generated by mk-2nd.awk
#   model:      obj_s
#   MODEL:      SHARED
#   echo:       yes
#   subset:     termlib+ext_tinfo+base+widechar+ext_funcs
#   crenames:   no
#   cxxrenames: 
#   traces:     DEBUG
#   srcdir:     .

../obj_s/panel$o :	$(srcdir)/panel.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/panel.c

../obj_s/p_above$o :	$(srcdir)/p_above.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_above.c

../obj_s/p_below$o :	$(srcdir)/p_below.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_below.c

../obj_s/p_bottom$o :	$(srcdir)/p_bottom.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_bottom.c

../obj_s/p_delete$o :	$(srcdir)/p_delete.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_delete.c

../obj_s/p_hide$o :	$(srcdir)/p_hide.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_hide.c

../obj_s/p_hidden$o :	$(srcdir)/p_hidden.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_hidden.c

../obj_s/p_move$o :	$(srcdir)/p_move.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_move.c

../obj_s/p_new$o :	$(srcdir)/p_new.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_new.c

../obj_s/p_replace$o :	$(srcdir)/p_replace.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_replace.c

../obj_s/p_show$o :	$(srcdir)/p_show.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_show.c

../obj_s/p_top$o :	$(srcdir)/p_top.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_top.c

../obj_s/p_update$o :	$(srcdir)/p_update.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_update.c

../obj_s/p_user$o :	$(srcdir)/p_user.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_user.c

../obj_s/p_win$o :	$(srcdir)/p_win.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../panel/p_win.c


# generated by mk-1st.awk (subset=termlib+ext_tinfo+base+widechar+ext_funcs)
#  name:          panelw
#  traces:        DEBUG
#  MODEL:         NORMAL
#  CXX_MODEL:     NORMAL
#  model:         objects
#  prefix:        lib
#  suffix:        .a
#  subset:        termlib+ext_tinfo+base+widechar+ext_funcs
#  driver:        no
#  ShlibVer:      no
#  ShlibVerInfix: no
#  SymLink:       ln -s -f
#  TermlibRoot:   ncursesw
#  TermlibSuffix: .so
#  ReLink:        yes
#  DoLinks:       no
#  rmSoLocs:      no
#  ldconfig:      :
#  overwrite:     no
#  depend:        ../include/ncurses_cfg.h ./panel.priv.h
#  host:          arm-unknown-linux-androideabi

NORMAL_OBJS = \
	../objects/panel$o \
	../objects/p_above$o \
	../objects/p_below$o \
	../objects/p_bottom$o \
	../objects/p_delete$o \
	../objects/p_hide$o \
	../objects/p_hidden$o \
	../objects/p_move$o \
	../objects/p_new$o \
	../objects/p_replace$o \
	../objects/p_show$o \
	../objects/p_top$o \
	../objects/p_update$o \
	../objects/p_user$o \
	../objects/p_win$o

$(NORMAL_OBJS) : ../include/ncurses_cfg.h ./panel.priv.h

../lib/libpanelw.a : $(NORMAL_OBJS)
	$(AR) $(ARFLAGS) $@ $?
	$(RANLIB) $@

install \
install.libs \
install.panelw :: $(DESTDIR)$(libdir) ../lib/libpanelw.a
	@echo installing ../lib/libpanelw.a as $(DESTDIR)$(libdir)/libpanelw.a
	$(INSTALL_DATA) ../lib/libpanelw.a $(DESTDIR)$(libdir)/libpanelw.a
	$(RANLIB) $(DESTDIR)$(libdir)/libpanelw.a

uninstall \
uninstall.libs \
uninstall.panelw ::
	@echo uninstalling $(DESTDIR)$(libdir)/libpanelw.a
	-@rm -f $(DESTDIR)$(libdir)/libpanelw.a

clean ::
	-rm -f ../lib/libpanelw.a

mostlyclean::
	-rm -f $(NORMAL_OBJS)

# generated by mk-2nd.awk
#   model:      objects
#   MODEL:      NORMAL
#   echo:       yes
#   subset:     termlib+ext_tinfo+base+widechar+ext_funcs
#   crenames:   no
#   cxxrenames: 
#   traces:     DEBUG
#   srcdir:     .

../objects/panel$o :	$(srcdir)/panel.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/panel.c

../objects/p_above$o :	$(srcdir)/p_above.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_above.c

../objects/p_below$o :	$(srcdir)/p_below.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_below.c

../objects/p_bottom$o :	$(srcdir)/p_bottom.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_bottom.c

../objects/p_delete$o :	$(srcdir)/p_delete.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_delete.c

../objects/p_hide$o :	$(srcdir)/p_hide.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_hide.c

../objects/p_hidden$o :	$(srcdir)/p_hidden.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_hidden.c

../objects/p_move$o :	$(srcdir)/p_move.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_move.c

../objects/p_new$o :	$(srcdir)/p_new.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_new.c

../objects/p_replace$o :	$(srcdir)/p_replace.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_replace.c

../objects/p_show$o :	$(srcdir)/p_show.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_show.c

../objects/p_top$o :	$(srcdir)/p_top.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_top.c

../objects/p_update$o :	$(srcdir)/p_update.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_update.c

../objects/p_user$o :	$(srcdir)/p_user.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_user.c

../objects/p_win$o :	$(srcdir)/p_win.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../panel/p_win.c


# generated by mk-1st.awk (subset=termlib+ext_tinfo+base+widechar+ext_funcs)
#  name:          panelw
#  traces:        DEBUG
#  MODEL:         DEBUG
#  CXX_MODEL:     DEBUG
#  model:         obj_g
#  prefix:        lib
#  suffix:        _g.a
#  subset:        termlib+ext_tinfo+base+widechar+ext_funcs
#  driver:        no
#  ShlibVer:      no
#  ShlibVerInfix: no
#  SymLink:       ln -s -f
#  TermlibRoot:   ncursesw
#  TermlibSuffix: .so
#  ReLink:        yes
#  DoLinks:       no
#  rmSoLocs:      no
#  ldconfig:      :
#  overwrite:     no
#  depend:        ../include/ncurses_cfg.h ./panel.priv.h
#  host:          arm-unknown-linux-androideabi

DEBUG_OBJS = \
	../obj_g/panel$o \
	../obj_g/p_above$o \
	../obj_g/p_below$o \
	../obj_g/p_bottom$o \
	../obj_g/p_delete$o \
	../obj_g/p_hide$o \
	../obj_g/p_hidden$o \
	../obj_g/p_move$o \
	../obj_g/p_new$o \
	../obj_g/p_replace$o \
	../obj_g/p_show$o \
	../obj_g/p_top$o \
	../obj_g/p_update$o \
	../obj_g/p_user$o \
	../obj_g/p_win$o

$(DEBUG_OBJS) : ../include/ncurses_cfg.h ./panel.priv.h

../lib/libpanelw_g.a : $(DEBUG_OBJS)
	$(AR) $(ARFLAGS) $@ $?
	$(RANLIB) $@

install \
install.libs \
install.panelw :: $(DESTDIR)$(libdir) ../lib/libpanelw_g.a
	@echo installing ../lib/libpanelw_g.a as $(DESTDIR)$(libdir)/libpanelw_g.a
	$(INSTALL_DATA) ../lib/libpanelw_g.a $(DESTDIR)$(libdir)/libpanelw_g.a
	$(RANLIB) $(DESTDIR)$(libdir)/libpanelw_g.a

uninstall \
uninstall.libs \
uninstall.panelw ::
	@echo uninstalling $(DESTDIR)$(libdir)/libpanelw_g.a
	-@rm -f $(DESTDIR)$(libdir)/libpanelw_g.a

clean ::
	-rm -f ../lib/libpanelw_g.a

mostlyclean::
	-rm -f $(DEBUG_OBJS)

# generated by mk-2nd.awk
#   model:      obj_g
#   MODEL:      DEBUG
#   echo:       yes
#   subset:     termlib+ext_tinfo+base+widechar+ext_funcs
#   crenames:   no
#   cxxrenames: 
#   traces:     DEBUG
#   srcdir:     .

../obj_g/panel$o :	$(srcdir)/panel.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/panel.c

../obj_g/p_above$o :	$(srcdir)/p_above.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_above.c

../obj_g/p_below$o :	$(srcdir)/p_below.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_below.c

../obj_g/p_bottom$o :	$(srcdir)/p_bottom.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_bottom.c

../obj_g/p_delete$o :	$(srcdir)/p_delete.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_delete.c

../obj_g/p_hide$o :	$(srcdir)/p_hide.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_hide.c

../obj_g/p_hidden$o :	$(srcdir)/p_hidden.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_hidden.c

../obj_g/p_move$o :	$(srcdir)/p_move.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_move.c

../obj_g/p_new$o :	$(srcdir)/p_new.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_new.c

../obj_g/p_replace$o :	$(srcdir)/p_replace.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_replace.c

../obj_g/p_show$o :	$(srcdir)/p_show.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_show.c

../obj_g/p_top$o :	$(srcdir)/p_top.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_top.c

../obj_g/p_update$o :	$(srcdir)/p_update.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_update.c

../obj_g/p_user$o :	$(srcdir)/p_user.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_user.c

../obj_g/p_win$o :	$(srcdir)/p_win.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../panel/p_win.c


# generated by mk-hdr.awk
#  subset:     termlib+ext_tinfo+base+widechar+ext_funcs
#  compat:     yes

${INCLUDEDIR} :
	mkdir -p $@

install \
install.libs \
install.includes :: ${AUTO_SRC} ${INCLUDEDIR} \
		$(srcdir)/panel.h
	@ (cd ${INCLUDEDIR} && rm -f panel.h) ; ../headers.sh ${INSTALL_DATA} ${INCLUDEDIR} ${srcdir} $(srcdir)/panel.h

uninstall \
uninstall.libs \
uninstall.includes ::
	-@ (cd ${INCLUDEDIR} && rm -f panel.h)
depend : ${AUTO_SRC}
	makedepend -- ${CPPFLAGS} -- ${C_SRC}

# DO NOT DELETE THIS LINE -- make depend depends on it.
