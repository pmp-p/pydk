# $Id: Makefile.in,v 1.64 2015/08/05 23:15:41 tom Exp $
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
# Makefile for menu source code.
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

LIBRARIES	=  ../lib/libmenuw.so ../lib/libmenuw.a ../lib/libmenuw_g.a

LINT		= 
LINT_OPTS	= 
LINT_LIBS	= -lmenu -lncurses 

AUTO_SRC	= \
		../include/menu.h \
		../include/eti.h \
		../include/mf_common.h

################################################################################
all \
libs \
install ::	$(AUTO_SRC) $(LIBRARIES)

sources :	$(AUTO_SRC)

$(DESTDIR)$(bindir) \
$(DESTDIR)$(libdir) :
	mkdir -p $@

# make copies to simplify include-paths while still keeping menu's include
# file in this directory.
../include/menu.h : $(srcdir)/menu.h
	-rm -f $@
	cp $(srcdir)/menu.h $@
../include/eti.h : $(srcdir)/eti.h
	-rm -f $@
	cp $(srcdir)/eti.h $@
../include/mf_common.h : $(srcdir)/mf_common.h
	-rm -f $@
	cp $(srcdir)/mf_common.h $@

HEADER_DEPS = \
	$(srcdir)/menu.priv.h \
	$(AUTO_SRC) \
	../include/curses.h

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
#   libname:    menuw
#   subsets:    termlib+ext_tinfo+base+widechar+ext_funcs

.SUFFIXES: .c .cc .h .i .ii
.c.i :
	$(CPP) $(CPPFLAGS) $< >$@
.cc.ii :
	$(CPP) $(CPPFLAGS) $< >$@
.h.i :
	$(CPP) $(CPPFLAGS) $< >$@

C_SRC = \
	$(srcdir)/m_attribs.c \
	$(srcdir)/m_cursor.c \
	$(srcdir)/m_driver.c \
	$(srcdir)/m_format.c \
	$(srcdir)/m_global.c \
	$(srcdir)/m_hook.c \
	$(srcdir)/m_item_cur.c \
	$(srcdir)/m_item_nam.c \
	$(srcdir)/m_item_new.c \
	$(srcdir)/m_item_opt.c \
	$(srcdir)/m_item_top.c \
	$(srcdir)/m_item_use.c \
	$(srcdir)/m_item_val.c \
	$(srcdir)/m_item_vis.c \
	$(srcdir)/m_items.c \
	$(srcdir)/m_new.c \
	$(srcdir)/m_opts.c \
	$(srcdir)/m_pad.c \
	$(srcdir)/m_pattern.c \
	$(srcdir)/m_post.c \
	$(srcdir)/m_req_name.c \
	$(srcdir)/m_scale.c \
	$(srcdir)/m_spacing.c \
	$(srcdir)/m_sub.c \
	$(srcdir)/m_trace.c \
	$(srcdir)/m_userptr.c \
	$(srcdir)/m_win.c

# Producing llib-lmenuw is time-consuming, so there's no direct-dependency for
# it in the lintlib rule.  We'll only remove in the cleanest setup.

MENUW_SRC = \
	$(srcdir)/m_attribs.c \
	$(srcdir)/m_cursor.c \
	$(srcdir)/m_driver.c \
	$(srcdir)/m_format.c \
	$(srcdir)/m_global.c \
	$(srcdir)/m_hook.c \
	$(srcdir)/m_item_cur.c \
	$(srcdir)/m_item_nam.c \
	$(srcdir)/m_item_new.c \
	$(srcdir)/m_item_opt.c \
	$(srcdir)/m_item_top.c \
	$(srcdir)/m_item_use.c \
	$(srcdir)/m_item_val.c \
	$(srcdir)/m_item_vis.c \
	$(srcdir)/m_items.c \
	$(srcdir)/m_new.c \
	$(srcdir)/m_opts.c \
	$(srcdir)/m_pad.c \
	$(srcdir)/m_pattern.c \
	$(srcdir)/m_post.c \
	$(srcdir)/m_req_name.c \
	$(srcdir)/m_scale.c \
	$(srcdir)/m_spacing.c \
	$(srcdir)/m_sub.c \
	$(srcdir)/m_trace.c \
	$(srcdir)/m_userptr.c \
	$(srcdir)/m_win.c

clean ::
	rm -f llib-lmenuw.*

realclean ::
	rm -f llib-lmenuw

llib-lmenuw : $(MENUW_SRC)
	cproto -a -l -DNCURSES_ENABLE_STDBOOL_H=0 -DLINT $(CPPFLAGS) $(MENUW_SRC) >$@

lintlib ::
	sh $(srcdir)/../misc/makellib menuw $(CPPFLAGS)

lint ::
	$(LINT) $(LINT_OPTS) $(CPPFLAGS) $(MENUW_SRC) $(LINT_LIBS)

# generated by mk-1st.awk (subset=termlib+ext_tinfo+base+widechar+ext_funcs)
#  name:          menuw
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
#  depend:        ../include/ncurses_cfg.h ./menu.priv.h
#  host:          arm-unknown-linux-androideabi

SHARED_OBJS = \
	../obj_s/m_attribs$o \
	../obj_s/m_cursor$o \
	../obj_s/m_driver$o \
	../obj_s/m_format$o \
	../obj_s/m_global$o \
	../obj_s/m_hook$o \
	../obj_s/m_item_cur$o \
	../obj_s/m_item_nam$o \
	../obj_s/m_item_new$o \
	../obj_s/m_item_opt$o \
	../obj_s/m_item_top$o \
	../obj_s/m_item_use$o \
	../obj_s/m_item_val$o \
	../obj_s/m_item_vis$o \
	../obj_s/m_items$o \
	../obj_s/m_new$o \
	../obj_s/m_opts$o \
	../obj_s/m_pad$o \
	../obj_s/m_pattern$o \
	../obj_s/m_post$o \
	../obj_s/m_req_name$o \
	../obj_s/m_scale$o \
	../obj_s/m_spacing$o \
	../obj_s/m_sub$o \
	../obj_s/m_userptr$o \
	../obj_s/m_win$o

$(SHARED_OBJS) : ../include/ncurses_cfg.h ./menu.priv.h

../lib/libmenuw.so : \
		../lib \
		$(RESULTING_SYMS) $(SHARED_OBJS)
	@echo linking $@
	$(MK_SHARED_LIB) $(SHARED_OBJS) $(SHLIB_LIST) $(LDFLAGS)

install \
install.libs \
install.menuw :: $(DESTDIR)$(libdir)/libmenuw.so

$(DESTDIR)$(libdir)/libmenuw.so : \
		$(DESTDIR)$(libdir) \
		$(RESULTING_SYMS) $(SHARED_OBJS)
	@echo linking $@
	$(MK_SHARED_LIB) $(SHARED_OBJS) $(SHLIB_LIST) $(LDFLAGS)

uninstall \
uninstall.libs \
uninstall.menuw ::
	@echo uninstalling $(DESTDIR)$(libdir)/libmenuw.so
	-rm -f $(DESTDIR)$(libdir)/libmenuw.so

clean ::
	-rm -f ../lib/libmenuw.so

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

../obj_s/m_attribs$o :	$(srcdir)/m_attribs.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_attribs.c

../obj_s/m_cursor$o :	$(srcdir)/m_cursor.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_cursor.c

../obj_s/m_driver$o :	$(srcdir)/m_driver.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_driver.c

../obj_s/m_format$o :	$(srcdir)/m_format.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_format.c

../obj_s/m_global$o :	$(srcdir)/m_global.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_global.c

../obj_s/m_hook$o :	$(srcdir)/m_hook.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_hook.c

../obj_s/m_item_cur$o :	$(srcdir)/m_item_cur.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_item_cur.c

../obj_s/m_item_nam$o :	$(srcdir)/m_item_nam.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_item_nam.c

../obj_s/m_item_new$o :	$(srcdir)/m_item_new.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_item_new.c

../obj_s/m_item_opt$o :	$(srcdir)/m_item_opt.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_item_opt.c

../obj_s/m_item_top$o :	$(srcdir)/m_item_top.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_item_top.c

../obj_s/m_item_use$o :	$(srcdir)/m_item_use.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_item_use.c

../obj_s/m_item_val$o :	$(srcdir)/m_item_val.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_item_val.c

../obj_s/m_item_vis$o :	$(srcdir)/m_item_vis.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_item_vis.c

../obj_s/m_items$o :	$(srcdir)/m_items.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_items.c

../obj_s/m_new$o :	$(srcdir)/m_new.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_new.c

../obj_s/m_opts$o :	$(srcdir)/m_opts.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_opts.c

../obj_s/m_pad$o :	$(srcdir)/m_pad.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_pad.c

../obj_s/m_pattern$o :	$(srcdir)/m_pattern.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_pattern.c

../obj_s/m_post$o :	$(srcdir)/m_post.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_post.c

../obj_s/m_req_name$o :	$(srcdir)/m_req_name.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_req_name.c

../obj_s/m_scale$o :	$(srcdir)/m_scale.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_scale.c

../obj_s/m_spacing$o :	$(srcdir)/m_spacing.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_spacing.c

../obj_s/m_sub$o :	$(srcdir)/m_sub.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_sub.c

../obj_s/m_userptr$o :	$(srcdir)/m_userptr.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_userptr.c

../obj_s/m_win$o :	$(srcdir)/m_win.c \
			$(HEADER_DEPS)
	cd ../obj_s; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_SHARED) -c ../menu/m_win.c


# generated by mk-1st.awk (subset=termlib+ext_tinfo+base+widechar+ext_funcs)
#  name:          menuw
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
#  depend:        ../include/ncurses_cfg.h ./menu.priv.h
#  host:          arm-unknown-linux-androideabi

NORMAL_OBJS = \
	../objects/m_attribs$o \
	../objects/m_cursor$o \
	../objects/m_driver$o \
	../objects/m_format$o \
	../objects/m_global$o \
	../objects/m_hook$o \
	../objects/m_item_cur$o \
	../objects/m_item_nam$o \
	../objects/m_item_new$o \
	../objects/m_item_opt$o \
	../objects/m_item_top$o \
	../objects/m_item_use$o \
	../objects/m_item_val$o \
	../objects/m_item_vis$o \
	../objects/m_items$o \
	../objects/m_new$o \
	../objects/m_opts$o \
	../objects/m_pad$o \
	../objects/m_pattern$o \
	../objects/m_post$o \
	../objects/m_req_name$o \
	../objects/m_scale$o \
	../objects/m_spacing$o \
	../objects/m_sub$o \
	../objects/m_userptr$o \
	../objects/m_win$o

$(NORMAL_OBJS) : ../include/ncurses_cfg.h ./menu.priv.h

../lib/libmenuw.a : $(NORMAL_OBJS)
	$(AR) $(ARFLAGS) $@ $?
	$(RANLIB) $@

install \
install.libs \
install.menuw :: $(DESTDIR)$(libdir) ../lib/libmenuw.a
	@echo installing ../lib/libmenuw.a as $(DESTDIR)$(libdir)/libmenuw.a
	$(INSTALL_DATA) ../lib/libmenuw.a $(DESTDIR)$(libdir)/libmenuw.a
	$(RANLIB) $(DESTDIR)$(libdir)/libmenuw.a

uninstall \
uninstall.libs \
uninstall.menuw ::
	@echo uninstalling $(DESTDIR)$(libdir)/libmenuw.a
	-@rm -f $(DESTDIR)$(libdir)/libmenuw.a

clean ::
	-rm -f ../lib/libmenuw.a

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

../objects/m_attribs$o :	$(srcdir)/m_attribs.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_attribs.c

../objects/m_cursor$o :	$(srcdir)/m_cursor.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_cursor.c

../objects/m_driver$o :	$(srcdir)/m_driver.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_driver.c

../objects/m_format$o :	$(srcdir)/m_format.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_format.c

../objects/m_global$o :	$(srcdir)/m_global.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_global.c

../objects/m_hook$o :	$(srcdir)/m_hook.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_hook.c

../objects/m_item_cur$o :	$(srcdir)/m_item_cur.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_item_cur.c

../objects/m_item_nam$o :	$(srcdir)/m_item_nam.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_item_nam.c

../objects/m_item_new$o :	$(srcdir)/m_item_new.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_item_new.c

../objects/m_item_opt$o :	$(srcdir)/m_item_opt.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_item_opt.c

../objects/m_item_top$o :	$(srcdir)/m_item_top.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_item_top.c

../objects/m_item_use$o :	$(srcdir)/m_item_use.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_item_use.c

../objects/m_item_val$o :	$(srcdir)/m_item_val.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_item_val.c

../objects/m_item_vis$o :	$(srcdir)/m_item_vis.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_item_vis.c

../objects/m_items$o :	$(srcdir)/m_items.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_items.c

../objects/m_new$o :	$(srcdir)/m_new.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_new.c

../objects/m_opts$o :	$(srcdir)/m_opts.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_opts.c

../objects/m_pad$o :	$(srcdir)/m_pad.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_pad.c

../objects/m_pattern$o :	$(srcdir)/m_pattern.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_pattern.c

../objects/m_post$o :	$(srcdir)/m_post.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_post.c

../objects/m_req_name$o :	$(srcdir)/m_req_name.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_req_name.c

../objects/m_scale$o :	$(srcdir)/m_scale.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_scale.c

../objects/m_spacing$o :	$(srcdir)/m_spacing.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_spacing.c

../objects/m_sub$o :	$(srcdir)/m_sub.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_sub.c

../objects/m_userptr$o :	$(srcdir)/m_userptr.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_userptr.c

../objects/m_win$o :	$(srcdir)/m_win.c \
			$(HEADER_DEPS)
	cd ../objects; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_NORMAL) -c ../menu/m_win.c


# generated by mk-1st.awk (subset=termlib+ext_tinfo+base+widechar+ext_funcs)
#  name:          menuw
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
#  depend:        ../include/ncurses_cfg.h ./menu.priv.h
#  host:          arm-unknown-linux-androideabi

DEBUG_OBJS = \
	../obj_g/m_attribs$o \
	../obj_g/m_cursor$o \
	../obj_g/m_driver$o \
	../obj_g/m_format$o \
	../obj_g/m_global$o \
	../obj_g/m_hook$o \
	../obj_g/m_item_cur$o \
	../obj_g/m_item_nam$o \
	../obj_g/m_item_new$o \
	../obj_g/m_item_opt$o \
	../obj_g/m_item_top$o \
	../obj_g/m_item_use$o \
	../obj_g/m_item_val$o \
	../obj_g/m_item_vis$o \
	../obj_g/m_items$o \
	../obj_g/m_new$o \
	../obj_g/m_opts$o \
	../obj_g/m_pad$o \
	../obj_g/m_pattern$o \
	../obj_g/m_post$o \
	../obj_g/m_req_name$o \
	../obj_g/m_scale$o \
	../obj_g/m_spacing$o \
	../obj_g/m_sub$o \
	../obj_g/m_trace$o \
	../obj_g/m_userptr$o \
	../obj_g/m_win$o

$(DEBUG_OBJS) : ../include/ncurses_cfg.h ./menu.priv.h

../lib/libmenuw_g.a : $(DEBUG_OBJS)
	$(AR) $(ARFLAGS) $@ $?
	$(RANLIB) $@

install \
install.libs \
install.menuw :: $(DESTDIR)$(libdir) ../lib/libmenuw_g.a
	@echo installing ../lib/libmenuw_g.a as $(DESTDIR)$(libdir)/libmenuw_g.a
	$(INSTALL_DATA) ../lib/libmenuw_g.a $(DESTDIR)$(libdir)/libmenuw_g.a
	$(RANLIB) $(DESTDIR)$(libdir)/libmenuw_g.a

uninstall \
uninstall.libs \
uninstall.menuw ::
	@echo uninstalling $(DESTDIR)$(libdir)/libmenuw_g.a
	-@rm -f $(DESTDIR)$(libdir)/libmenuw_g.a

clean ::
	-rm -f ../lib/libmenuw_g.a

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

../obj_g/m_attribs$o :	$(srcdir)/m_attribs.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_attribs.c

../obj_g/m_cursor$o :	$(srcdir)/m_cursor.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_cursor.c

../obj_g/m_driver$o :	$(srcdir)/m_driver.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_driver.c

../obj_g/m_format$o :	$(srcdir)/m_format.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_format.c

../obj_g/m_global$o :	$(srcdir)/m_global.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_global.c

../obj_g/m_hook$o :	$(srcdir)/m_hook.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_hook.c

../obj_g/m_item_cur$o :	$(srcdir)/m_item_cur.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_item_cur.c

../obj_g/m_item_nam$o :	$(srcdir)/m_item_nam.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_item_nam.c

../obj_g/m_item_new$o :	$(srcdir)/m_item_new.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_item_new.c

../obj_g/m_item_opt$o :	$(srcdir)/m_item_opt.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_item_opt.c

../obj_g/m_item_top$o :	$(srcdir)/m_item_top.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_item_top.c

../obj_g/m_item_use$o :	$(srcdir)/m_item_use.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_item_use.c

../obj_g/m_item_val$o :	$(srcdir)/m_item_val.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_item_val.c

../obj_g/m_item_vis$o :	$(srcdir)/m_item_vis.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_item_vis.c

../obj_g/m_items$o :	$(srcdir)/m_items.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_items.c

../obj_g/m_new$o :	$(srcdir)/m_new.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_new.c

../obj_g/m_opts$o :	$(srcdir)/m_opts.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_opts.c

../obj_g/m_pad$o :	$(srcdir)/m_pad.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_pad.c

../obj_g/m_pattern$o :	$(srcdir)/m_pattern.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_pattern.c

../obj_g/m_post$o :	$(srcdir)/m_post.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_post.c

../obj_g/m_req_name$o :	$(srcdir)/m_req_name.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_req_name.c

../obj_g/m_scale$o :	$(srcdir)/m_scale.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_scale.c

../obj_g/m_spacing$o :	$(srcdir)/m_spacing.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_spacing.c

../obj_g/m_sub$o :	$(srcdir)/m_sub.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_sub.c

../obj_g/m_trace$o :	$(srcdir)/m_trace.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_trace.c

../obj_g/m_userptr$o :	$(srcdir)/m_userptr.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_userptr.c

../obj_g/m_win$o :	$(srcdir)/m_win.c \
			$(HEADER_DEPS)
	cd ../obj_g; $(LIBTOOL_COMPILE) $(CC) $(CFLAGS_DEBUG) -c ../menu/m_win.c


# generated by mk-hdr.awk
#  subset:     termlib+ext_tinfo+base+widechar+ext_funcs
#  compat:     yes

${INCLUDEDIR} :
	mkdir -p $@

install \
install.libs \
install.includes :: ${AUTO_SRC} ${INCLUDEDIR} \
		$(srcdir)/eti.h \
		$(srcdir)/menu.h
	@ (cd ${INCLUDEDIR} && rm -f eti.h) ; ../headers.sh ${INSTALL_DATA} ${INCLUDEDIR} ${srcdir} $(srcdir)/eti.h
	@ (cd ${INCLUDEDIR} && rm -f menu.h) ; ../headers.sh ${INSTALL_DATA} ${INCLUDEDIR} ${srcdir} $(srcdir)/menu.h

uninstall \
uninstall.libs \
uninstall.includes ::
	-@ (cd ${INCLUDEDIR} && rm -f eti.h)
	-@ (cd ${INCLUDEDIR} && rm -f menu.h)
depend : ${AUTO_SRC}
	makedepend -- ${CPPFLAGS} -- ${C_SRC}

# DO NOT DELETE THIS LINE -- make depend depends on it.
