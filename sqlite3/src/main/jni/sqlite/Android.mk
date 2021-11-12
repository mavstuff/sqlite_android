
LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SHORT_COMMANDS:= true

# If using SEE, uncomment the following:
# LOCAL_CFLAGS += -DSQLITE_HAS_CODEC

#Define HAVE_USLEEP, otherwise ALL sleep() calls take at least 1000ms
LOCAL_CFLAGS += -DHAVE_USLEEP=1

# Enable SQLite extensions.
LOCAL_CFLAGS += -DSQLITE_ENABLE_FTS5 
LOCAL_CFLAGS += -DSQLITE_ENABLE_RTREE
LOCAL_CFLAGS += -DSQLITE_ENABLE_JSON1
LOCAL_CFLAGS += -DSQLITE_ENABLE_FTS3
LOCAL_CFLAGS += -DSQLITE_ENABLE_BATCH_ATOMIC_WRITE

# This is important - it causes SQLite to use memory for temp files. Since 
# Android has no globally writable temp directory, if this is not defined the
# application throws an exception when it tries to create a temp file.
#
LOCAL_CFLAGS += -DSQLITE_TEMP_STORE=3

LOCAL_CFLAGS += -DHAVE_CONFIG_H -DKHTML_NO_EXCEPTIONS -DGKWQ_NO_JAVA
LOCAL_CFLAGS += -DNO_SUPPORT_JS_BINDING -DQT_NO_WHEELEVENT -DKHTML_NO_XBL
LOCAL_CFLAGS += -U__APPLE__
LOCAL_CFLAGS += -DHAVE_STRCHRNUL=0
LOCAL_CFLAGS += -DSQLITE_USE_URI=1
LOCAL_CFLAGS += -DSQLITE_ENABLE_ICU=1
LOCAL_CFLAGS += -Wno-unused-parameter -Wno-int-to-pointer-cast
LOCAL_CFLAGS += -Wno-uninitialized -Wno-parentheses

LOCAL_CFLAGS += '-DICU_DATA_DIR_PREFIX_ENV_VAR="ANDROID_ROOT"'
LOCAL_CFLAGS += '-LOCAL_C_INCLUDESDICU_DATA_DIR="/usr/icu"'
LOCAL_CFLAGS += -D_REENTRANT -DU_COMMON_IMPLEMENTATION -DU_I18N_IMPLEMENTATION

LOCAL_CPPFLAGS += -Wno-conversion-null

ifeq ($(TARGET_ARCH), arm)
	LOCAL_CFLAGS += -DPACKED="__attribute__ ((packed))"
else
	LOCAL_CFLAGS += -DPACKED=""
endif

LOCAL_SRC_FILES +=    \
	../icu/cmemory.c          ../icu/cstring.c          \
	../icu/cwchar.c           ../icu/locmap.c           \
	../icu/punycode.c         ../icu/putil.c            \
	../icu/uarrsort.c         ../icu/ubidi.c            \
	../icu/ubidiln.c          ../icu/ubidi_props.c      \
	../icu/ubidiwrt.c         ../icu/ucase.c            \
	../icu/ucasemap.c         ../icu/ucat.c             \
	../icu/uchar.c            ../icu/ucln_cmn.c         \
	../icu/ucmndata.c         ../icu/icudt44l_dat.s     \
	../icu/ucnv2022.c         ../icu/ucnv_bld.c         \
	../icu/ucnvbocu.c         ../icu/ucnv.c             \
	../icu/ucnv_cb.c          ../icu/ucnv_cnv.c         \
	../icu/ucnvdisp.c         ../icu/ucnv_err.c         \
	../icu/ucnv_ext.c         ../icu/ucnvhz.c           \
	../icu/ucnv_io.c          ../icu/ucnvisci.c         \
	../icu/ucnvlat1.c         ../icu/ucnv_lmb.c         \
	../icu/ucnvmbcs.c         ../icu/ucnvscsu.c         \
	../icu/ucnv_set.c         ../icu/ucnv_u16.c         \
	../icu/ucnv_u32.c         ../icu/ucnv_u7.c          \
	../icu/ucnv_u8.c                             \
	../icu/udata.c            ../icu/udatamem.c         \
	../icu/udataswp.c         ../icu/uenum.c            \
	../icu/uhash.c            ../icu/uinit.c            \
	../icu/uinvchar.c         ../icu/uloc.c             \
	../icu/umapfile.c         ../icu/umath.c            \
	../icu/umutex.c           ../icu/unames.c           \
	../icu/unorm_it.c         ../icu/uresbund.c         \
	../icu/ures_cnv.c         ../icu/uresdata.c         \
	../icu/usc_impl.c         ../icu/uscript.c          \
	../icu/ushape.c           ../icu/ustrcase.c         \
	../icu/ustr_cnv.c         ../icu/ustrfmt.c          \
	../icu/ustring.c          ../icu/ustrtrns.c         \
	../icu/ustr_wcs.c         ../icu/utf_impl.c         \
	../icu/utrace.c           ../icu/utrie.c            \
 	../icu/utypes.c           ../icu/wintz.c            \
 	../icu/utrie2_builder.c   ../icu/icuplug.c          \
 	../icu/propsvec.c         ../icu/ulist.c            \
 	../icu/uloc_tag.c  \
    ../icu/bmpset.cpp      ../icu/unisetspan.cpp   \
	../icu/brkeng.cpp      ../icu/brkiter.cpp      \
	../icu/caniter.cpp     ../icu/chariter.cpp     \
	../icu/dictbe.cpp      ../icu/locbased.cpp     \
	../icu/locid.cpp       ../icu/locutil.cpp      \
	../icu/normlzr.cpp     ../icu/parsepos.cpp     \
	../icu/propname.cpp    ../icu/rbbi.cpp         \
	../icu/rbbidata.cpp    ../icu/rbbinode.cpp     \
	../icu/rbbirb.cpp      ../icu/rbbiscan.cpp     \
	../icu/rbbisetb.cpp    ../icu/rbbistbl.cpp     \
	../icu/rbbitblb.cpp    ../icu/resbund_cnv.cpp  \
	../icu/resbund.cpp     ../icu/ruleiter.cpp     \
	../icu/schriter.cpp    ../icu/serv.cpp         \
	../icu/servlk.cpp      ../icu/servlkf.cpp      \
	../icu/servls.cpp      ../icu/servnotf.cpp     \
	../icu/servrbf.cpp     ../icu/servslkf.cpp     \
	../icu/triedict.cpp    ../icu/ubrk.cpp         \
	../icu/uchriter.cpp    ../icu/uhash_us.cpp     \
	../icu/uidna.cpp       ../icu/uiter.cpp        \
	../icu/unifilt.cpp     ../icu/unifunct.cpp     \
	../icu/uniset.cpp      ../icu/uniset_props.cpp \
	../icu/unistr_case.cpp ../icu/unistr_cnv.cpp   \
	../icu/unistr.cpp      ../icu/unistr_props.cpp \
	../icu/unormcmp.cpp    ../icu/unorm.cpp        \
	../icu/uobject.cpp     ../icu/uset.cpp         \
	../icu/usetiter.cpp    ../icu/uset_props.cpp   \
	../icu/usprep.cpp      ../icu/ustack.cpp       \
	../icu/ustrenum.cpp    ../icu/utext.cpp        \
	../icu/util.cpp        ../icu/util_props.cpp   \
	../icu/uvector.cpp     ../icu/uvectr32.cpp     \
	../icu/errorcode.cpp                    \
	../icu/bytestream.cpp  ../icu/stringpiece.cpp  \
	../icu/mutex.cpp       ../icu/dtintrv.cpp      \
	../icu/ucnvsel.cpp     ../icu/uvectr64.cpp     \
	../icu/locavailable.cpp         ../icu/locdispnames.cpp   \
	../icu/loclikely.cpp            ../icu/locresdata.cpp     \
	../icu/normalizer2impl.cpp      ../icu/normalizer2.cpp    \
	../icu/filterednormalizer2.cpp  ../icu/ucol_swp.cpp       \
	../icu/uprops.cpp      ../icu/utrie2.cpp \
	../icu/bocsu.c     ../icu/ucln_in.c  ../icu/decContext.c \
	../icu/ulocdata.c  ../icu/utmscale.c ../icu/decNumber.c \
        ../icu/indiancal.cpp   ../icu/dtptngen.cpp ../icu/dtrule.cpp   \
        ../icu/persncal.cpp    ../icu/rbtz.cpp     ../icu/reldtfmt.cpp \
        ../icu/taiwncal.cpp    ../icu/tzrule.cpp   ../icu/tztrans.cpp  \
        ../icu/udatpg.cpp      ../icu/vtzone.cpp                \
	../icu/anytrans.cpp    ../icu/astro.cpp    ../icu/buddhcal.cpp \
	../icu/basictz.cpp     ../icu/calendar.cpp ../icu/casetrn.cpp  \
	../icu/choicfmt.cpp    ../icu/coleitr.cpp  ../icu/coll.cpp     \
	../icu/cpdtrans.cpp    ../icu/csdetect.cpp ../icu/csmatch.cpp  \
	../icu/csr2022.cpp     ../icu/csrecog.cpp  ../icu/csrmbcs.cpp  \
	../icu/csrsbcs.cpp     ../icu/csrucode.cpp ../icu/csrutf8.cpp  \
	../icu/curramt.cpp     ../icu/currfmt.cpp  ../icu/currunit.cpp \
	../icu/datefmt.cpp     ../icu/dcfmtsym.cpp ../icu/decimfmt.cpp \
	../icu/digitlst.cpp    ../icu/dtfmtsym.cpp ../icu/esctrn.cpp   \
	../icu/fmtable_cnv.cpp ../icu/fmtable.cpp  ../icu/format.cpp   \
	../icu/funcrepl.cpp    ../icu/gregocal.cpp ../icu/gregoimp.cpp \
	../icu/hebrwcal.cpp    ../icu/inputext.cpp ../icu/islamcal.cpp \
	../icu/japancal.cpp    ../icu/measfmt.cpp  ../icu/measure.cpp  \
	../icu/msgfmt.cpp      ../icu/name2uni.cpp ../icu/nfrs.cpp     \
	../icu/nfrule.cpp      ../icu/nfsubs.cpp   ../icu/nortrans.cpp \
	../icu/nultrans.cpp    ../icu/numfmt.cpp   ../icu/olsontz.cpp  \
	../icu/quant.cpp       ../icu/rbnf.cpp     ../icu/rbt.cpp      \
	../icu/rbt_data.cpp    ../icu/rbt_pars.cpp ../icu/rbt_rule.cpp \
	../icu/rbt_set.cpp     ../icu/regexcmp.cpp ../icu/regexst.cpp  \
	../icu/rematch.cpp     ../icu/remtrans.cpp ../icu/repattrn.cpp \
	../icu/search.cpp      ../icu/simpletz.cpp ../icu/smpdtfmt.cpp \
	../icu/sortkey.cpp     ../icu/strmatch.cpp ../icu/strrepl.cpp  \
	../icu/stsearch.cpp    ../icu/tblcoll.cpp  ../icu/timezone.cpp \
	../icu/titletrn.cpp    ../icu/tolowtrn.cpp ../icu/toupptrn.cpp \
	../icu/translit.cpp    ../icu/transreg.cpp ../icu/tridpars.cpp \
	../icu/ucal.cpp        ../icu/ucol_bld.cpp ../icu/ucol_cnt.cpp \
	../icu/ucol.cpp        ../icu/ucoleitr.cpp ../icu/ucol_elm.cpp \
	../icu/ucol_res.cpp    ../icu/ucol_sit.cpp ../icu/ucol_tok.cpp \
	../icu/ucsdet.cpp      ../icu/ucurr.cpp    ../icu/udat.cpp     \
	../icu/umsg.cpp        ../icu/unesctrn.cpp ../icu/uni2name.cpp \
	../icu/unum.cpp        ../icu/uregexc.cpp  ../icu/uregex.cpp   \
	../icu/usearch.cpp     ../icu/utrans.cpp   ../icu/windtfmt.cpp \
 	../icu/winnmfmt.cpp    ../icu/zonemeta.cpp ../icu/zstrfmt.cpp  \
 	../icu/numsys.cpp      ../icu/chnsecal.cpp \
 	../icu/cecal.cpp       ../icu/coptccal.cpp ../icu/ethpccal.cpp \
 	../icu/brktrans.cpp    ../icu/wintzimpl.cpp ../icu/plurrule.cpp \
 	../icu/plurfmt.cpp     ../icu/dtitvfmt.cpp ../icu/dtitvinf.cpp \
 	../icu/tmunit.cpp      ../icu/tmutamt.cpp  ../icu/tmutfmt.cpp  \
 	../icu/colldata.cpp    ../icu/bmsearch.cpp ../icu/bms.cpp      \
        ../icu/currpinf.cpp    ../icu/uspoof.cpp   ../icu/uspoof_impl.cpp \
        ../icu/uspoof_build.cpp     \
        ../icu/regextxt.cpp    ../icu/selfmt.cpp   ../icu/uspoof_conf.cpp \
        ../icu/uspoof_wsconf.cpp ../icu/ztrans.cpp ../icu/zrule.cpp  \
        ../icu/vzone.cpp       ../icu/fphdlimp.cpp ../icu/fpositer.cpp\
        ../icu/locdspnm.cpp    ../icu/decnumstr.cpp ../icu/ucol_wgt.cpp



LOCAL_SRC_FILES +=                             \
	android_database_SQLiteCommon.cpp     \
	android_database_SQLiteConnection.cpp \
	android_database_SQLiteGlobal.cpp     \
	android_database_SQLiteDebug.cpp      \
	JNIHelp.cpp JniConstants.cpp \
	assetvfs.c

LOCAL_SRC_FILES += sqlite3.c


LOCAL_C_INCLUDES += $(LOCAL_PATH) $(LOCAL_PATH)/nativehelper/ $(LOCAL_PATH)/../icu/

LOCAL_MODULE:= libsqliteX
LOCAL_LDLIBS += -ldl -llog -landroid

include $(BUILD_SHARED_LIBRARY)

