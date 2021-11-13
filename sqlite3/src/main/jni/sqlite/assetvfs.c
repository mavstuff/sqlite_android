// assetvfs - virtual filesystem for SQLite that allows opening the files 
// from Android assets (C) 2021 Artem Moroz, artem.moroz[at]gmail.com
//
// To open the database from assets, use the following Java code:
// SQLiteDatabase db = SQLiteDatabase.openDatabase("file:yourfile.db?vfs=assetvfs", null, SQLiteDatabase.OPEN_READONLY);
// 
// 

#include "sqlite3.h"

#include <assert.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/file.h>
#include <sys/param.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>
#include <fcntl.h>

#include <android/asset_manager.h>
#include <android/asset_manager_jni.h>

extern AAssetManager* g_pAssetManager;

/*
** The maximum pathname length supported by this VFS.
*/
#define MAXPATHNAME 512

/*
** When using this VFS, the sqlite3_file* handles that SQLite uses are
** actually pointers to instances of type DemoFile.
*/
typedef struct DemoFile DemoFile;
struct DemoFile {
    sqlite3_file base;              /* Base class. Must be first. */
    AAsset* pAsset;
};

/*
** Write directly to the file passed as the first argument. Even if the
** file has a write-buffer (DemoFile.aBuffer), ignore it.
*/
static int demoDirectWrite(
        DemoFile *p,                    /* File handle */
        const void *zBuf,               /* Buffer containing data to write */
        int iAmt,                       /* Size of data to write in bytes */
        sqlite_int64 iOfst              /* File offset to write to */
){
    return SQLITE_OK;
}

/*
** Flush the contents of the DemoFile.aBuffer buffer to disk. This is a
** no-op if this particular file does not have a buffer (i.e. it is not
** a journal file) or if the buffer is currently empty.
*/
static int demoFlushBuffer(DemoFile *p){
    return SQLITE_OK;
}

/*
** Close a file.
*/
static int demoClose(sqlite3_file *pFile) {
    DemoFile *p = (DemoFile *) pFile;

    demoFlushBuffer(p);
    AAsset_close(p->pAsset);

    return SQLITE_OK;
}

/*
** Read data from a file.
*/
static int demoRead(
        sqlite3_file *pFile,
        void *zBuf,
        int iAmt,
        sqlite_int64 iOfst
){
    DemoFile *p = (DemoFile*)pFile;
    off_t ofst;                     /* Return value from lseek() */
    int nRead;                      /* Return value from read() */
    int rc;                         /* Return code from demoFlushBuffer() */

    /* Flush any data in the write buffer to disk in case this operation
    ** is trying to read data the file-region currently cached in the buffer.
    ** It would be possible to detect this case and possibly save an
    ** unnecessary write here, but in practice SQLite will rarely read from
    ** a journal file when there is data cached in the write-buffer.
    */
    rc = demoFlushBuffer(p);
    if( rc!=SQLITE_OK ){
        return rc;
    }

    ofst = AAsset_seek64(p->pAsset, iOfst, SEEK_SET);
    if( ofst!=iOfst ){
        return SQLITE_IOERR_READ;
    }

    nRead = AAsset_read(p->pAsset, zBuf, iAmt);

    if( nRead==iAmt ){
        return SQLITE_OK;
    }else if( nRead>=0 ){
        if( nRead<iAmt ){
            memset(&((char*)zBuf)[nRead], 0, iAmt-nRead);
        }
        return SQLITE_IOERR_SHORT_READ;
    }

    return SQLITE_IOERR_READ;
}

/*
** Write data to a crash-file.
*/
static int demoWrite(
        sqlite3_file *pFile,
        const void *zBuf,
        int iAmt,
        sqlite_int64 iOfst
){
    //DemoFile *p = (DemoFile*)pFile;

    return SQLITE_OK;
}

/*
** Truncate a file. This is a no-op for this VFS (see header comments at
** the top of the file).
*/
static int demoTruncate(sqlite3_file *pFile, sqlite_int64 size) {
    return SQLITE_OK;
}

/*
** Sync the contents of the file to the persistent media.
*/
static int demoSync(sqlite3_file *pFile, int flags){
    DemoFile *p = (DemoFile*)pFile;
    return SQLITE_OK;
}

/*
** Write the size of the file in bytes to *pSize.
*/
static int demoFileSize(sqlite3_file *pFile, sqlite_int64 *pSize){
    DemoFile *p = (DemoFile*)pFile;
    int rc;                         /* Return code from fstat() call */

    /* Flush the contents of the buffer to disk. As with the flush in the
    ** demoRead() method, it would be possible to avoid this and save a write
    ** here and there. But in practice this comes up so infrequently it is
    ** not worth the trouble.
    */
    rc = demoFlushBuffer(p);
    if( rc!=SQLITE_OK ){
        return rc;
    }

    *pSize = AAsset_getLength64(p->pAsset);

    return SQLITE_OK;
}

/*
** Locking functions. The xLock() and xUnlock() methods are both no-ops.
** The xCheckReservedLock() always indicates that no other process holds
** a reserved lock on the database file. This ensures that if a hot-journal
** file is found in the file-system it is rolled back.
*/
static int demoLock(sqlite3_file *pFile, int eLock){
    return SQLITE_OK;
}
static int demoUnlock(sqlite3_file *pFile, int eLock){
    return SQLITE_OK;
}
static int demoCheckReservedLock(sqlite3_file *pFile, int *pResOut){
    *pResOut = 0;
    return SQLITE_OK;
}

/*
** No xFileControl() verbs are implemented by this VFS.
*/
static int demoFileControl(sqlite3_file *pFile, int op, void *pArg){
    return SQLITE_NOTFOUND;
}

/*
** The xSectorSize() and xDeviceCharacteristics() methods. These two
** may return special values allowing SQLite to optimize file-system
** access to some extent. But it is also safe to simply return 0.
*/
static int demoSectorSize(sqlite3_file *pFile){
    return 0;
}
static int demoDeviceCharacteristics(sqlite3_file *pFile){
    return 0;
}

/*
** Open a file handle.
*/
static int demoOpen(
        sqlite3_vfs *pVfs,              /* VFS */
        const char *zName,              /* File to open, or 0 for a temp file */
        sqlite3_file *pFile,            /* Pointer to DemoFile struct to populate */
        int flags,                      /* Input SQLITE_OPEN_XXX flags */
        int *pOutFlags                  /* Output SQLITE_OPEN_XXX flags (or NULL) */
){
    static const sqlite3_io_methods demoio = {
            1,                            /* iVersion */
            demoClose,                    /* xClose */
            demoRead,                     /* xRead */
            demoWrite,                    /* xWrite */
            demoTruncate,                 /* xTruncate */
            demoSync,                     /* xSync */
            demoFileSize,                 /* xFileSize */
            demoLock,                     /* xLock */
            demoUnlock,                   /* xUnlock */
            demoCheckReservedLock,        /* xCheckReservedLock */
            demoFileControl,              /* xFileControl */
            demoSectorSize,               /* xSectorSize */
            demoDeviceCharacteristics     /* xDeviceCharacteristics */
    };

    DemoFile *p = (DemoFile*)pFile; /* Populate this structure */

    if( zName==0 ){
        return SQLITE_IOERR;
    }

    memset(p, 0, sizeof(DemoFile));

    AAsset * pAsset = AAssetManager_open(g_pAssetManager, zName, AASSET_MODE_RANDOM);
    if (!pAsset)
    {
        return SQLITE_CANTOPEN;
    }
    p->pAsset = pAsset;

    if( pOutFlags ){
        *pOutFlags = flags;
    }
    p->base.pMethods = &demoio;
    return SQLITE_OK;
}

/*
** Delete the file identified by argument zPath. If the dirSync parameter
** is non-zero, then ensure the file-system modification to delete the
** file has been synced to disk before returning.
*/
static int demoDelete(sqlite3_vfs *pVfs, const char *zPath, int dirSync){
    return SQLITE_IOERR_DELETE;
}

#ifndef F_OK
# define F_OK 0
#endif
#ifndef R_OK
# define R_OK 4
#endif
#ifndef W_OK
# define W_OK 2
#endif

/*
** Query the file-system to see if the named file exists, is readable or
** is both readable and writable.
*/
static int demoAccess(
        sqlite3_vfs *pVfs,
        const char *zPath,
        int flags,
        int *pResOut
){

    AAsset * pAsset = AAssetManager_open(g_pAssetManager, zPath, AASSET_MODE_RANDOM);
    if (pAsset)
    {
        *pResOut = 1;
        AAsset_close(pAsset);

    } else {
        *pResOut = 0;
    }

    return SQLITE_OK;
}

/*
** Argument zPath points to a nul-terminated string containing a file path.
** If zPath is an absolute path, then it is copied as is into the output
** buffer. Otherwise, if it is a relative path, then the equivalent full
** path is written to the output buffer.
**
** This function assumes that paths are UNIX style. Specifically, that:
**
**   1. Path components are separated by a '/'. and
**   2. Full paths begin with a '/' character.
*/
static int demoFullPathname(
        sqlite3_vfs *pVfs,              /* VFS */
        const char *zPath,              /* Input path (possibly a relative path) */
        int nPathOut,                   /* Size of output buffer in bytes */
        char *zPathOut                  /* Pointer to output buffer */
){
    strcpy(zPathOut, zPath);
    //sqlite3_snprintf(nPathOut, zPathOut, "%s", zPath);
    zPathOut[nPathOut-1] = '\0';

    return SQLITE_OK;
}

/*
** The following four VFS methods:
**
**   xDlOpen
**   xDlError
**   xDlSym
**   xDlClose
**
** are supposed to implement the functionality needed by SQLite to load
** extensions compiled as shared objects. This simple VFS does not support
** this functionality, so the following functions are no-ops.
*/
static void *demoDlOpen(sqlite3_vfs *pVfs, const char *zPath){
    return 0;
}
static void demoDlError(sqlite3_vfs *pVfs, int nByte, char *zErrMsg){
    sqlite3_snprintf(nByte, zErrMsg, "Loadable extensions are not supported");
    zErrMsg[nByte-1] = '\0';
}
static void (*demoDlSym(sqlite3_vfs *pVfs, void *pH, const char *z))(void){
    return 0;
}
static void demoDlClose(sqlite3_vfs *pVfs, void *pHandle){
    return;
}

/*
** Parameter zByte points to a buffer nByte bytes in size. Populate this
** buffer with pseudo-random data.
*/
static int demoRandomness(sqlite3_vfs *pVfs, int nByte, char *zByte){
    return SQLITE_OK;
}

/*
** Sleep for at least nMicro microseconds. Return the (approximate) number
** of microseconds slept for.
*/
static int demoSleep(sqlite3_vfs *pVfs, int nMicro){
    sleep(nMicro / 1000000);
    usleep(nMicro % 1000000);
    return nMicro;
}

/*
** Set *pTime to the current UTC time expressed as a Julian day. Return
** SQLITE_OK if successful, or an error code otherwise.
**
**   http://en.wikipedia.org/wiki/Julian_day
**
** This implementation is not very good. The current time is rounded to
** an integer number of seconds. Also, assuming time_t is a signed 32-bit
** value, it will stop working some time in the year 2038 AD (the so-called
** "year 2038" problem that afflicts systems that store time this way).
*/
static int demoCurrentTime(sqlite3_vfs *pVfs, double *pTime){
    time_t t = time(0);
    *pTime = t/86400.0 + 2440587.5;
    return SQLITE_OK;
}

/*
** This function returns a pointer to the VFS implemented in this file.
** To make the VFS available to SQLite:
**
**   sqlite3_vfs_register(sqlite3_assetvfs(), 0);
*/
sqlite3_vfs *sqlite3_assetvfs(void){
    static sqlite3_vfs assetvfs = {
            1,                            /* iVersion */
            sizeof(DemoFile),             /* szOsFile */
            MAXPATHNAME,                  /* mxPathname */
            0,                            /* pNext */
            "assetvfs",                       /* zName */
            0,                            /* pAppData */
            demoOpen,                     /* xOpen */
            demoDelete,                   /* xDelete */
            demoAccess,                   /* xAccess */
            demoFullPathname,             /* xFullPathname */
            demoDlOpen,                   /* xDlOpen */
            demoDlError,                  /* xDlError */
            demoDlSym,                    /* xDlSym */
            demoDlClose,                  /* xDlClose */
            demoRandomness,               /* xRandomness */
            demoSleep,                    /* xSleep */
            demoCurrentTime,              /* xCurrentTime */
    };
    return &assetvfs;
}


