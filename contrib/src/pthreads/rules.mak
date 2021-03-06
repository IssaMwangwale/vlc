# POSIX threads

ifndef HAVE_WIN32
PKGS_FOUND += pthreads
endif

PTHREADS_W32_VERSION := 2-9-1
PTHREADS_W32_URL := ftp://sources.redhat.com/pub/pthreads-win32/pthreads-w32-$(PTHREADS_W32_VERSION)-release.tar.gz

$(TARBALLS)/pthreads-w32-$(PTHREADS_W32_VERSION)-release.tar.gz:
	$(call download_pkg,$(PTHREADS_W32_URL),pthreads)

.sum-pthreads: pthreads-w32-$(PTHREADS_W32_VERSION)-release.tar.gz

ifdef HAVE_WIN32
pthreads: pthreads-w32-$(PTHREADS_W32_VERSION)-release.tar.gz .sum-pthreads
	$(UNPACK)
	sed -e 's/^CROSS.*=/CROSS ?=/' -i.orig $(UNPACK_DIR)/GNUmakefile
ifdef HAVE_WINSTORE
	$(APPLY) $(SRC)/pthreads/winrt.patch
endif
	$(APPLY) $(SRC)/pthreads/implib.patch
	$(APPLY) $(SRC)/pthreads/x86-inline-asm.patch
	$(APPLY) $(SRC)/pthreads/arm64.patch
	$(APPLY) $(SRC)/pthreads/pthreads-fix-warning.patch
	$(APPLY) $(SRC)/pthreads/pthreads-fix-mode_t.patch
	$(MOVE)

ifdef HAVE_CROSS_COMPILE
PTHREADS_W32_CONF := CROSS="$(HOST)-"
endif

.pthreads: pthreads
	cd $< && $(HOSTVARS) $(PTHREADS_W32_CONF) $(MAKE) GC-static
	mkdir -p -- "$(PREFIX)/include"
	cd $< && cp -v pthread.h sched.h semaphore.h "$(PREFIX)/include/"
	mkdir -p -- "$(PREFIX)/lib"
	cp -v $</*.a "$(PREFIX)/lib/"
	touch $@
endif
