/*-----------------------------------------------------------------------*/
/* Low level disk control module for Win32              (C)ChaN, 2013    */
/*-----------------------------------------------------------------------*/

#include "diskio.h"		/* Declarations of disk functions */
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>


#define MAX_DRIVES	10		/* Max number of physical drives to be used */
#define	SZ_BLOCK	8		/* Block size to be returned by GET_BLOCK_SIZE command */

UINT SZ_RAMDISK = 0;		/* Size of drive 0 (RAM disk) [MiB] */
#define SS_RAMDISK	512		/* Sector size of drive 0 (RAM disk) [byte] */


void diskio_initialization(UINT diskSize) {
    SZ_RAMDISK = diskSize;
}

int do_test_disk_io_read(void *buf, uint32_t offset, uint32_t size);

int do_test_disk_io_write(const void *buf, uint32_t offset, uint32_t size);

/*--------------------------------------------------------------------------

   Module Private Functions

---------------------------------------------------------------------------*/

#define	BUFSIZE 262144UL	/* Size of data transfer buffer */

typedef struct {
    DSTATUS	status;
    WORD sz_sector;
    DWORD n_sectors;
} STAT;

static int disk_exit=0;
static int Drives = 1;
static volatile STAT Stat[MAX_DRIVES];

//BYTE *Buffer, *RamDisk;	/* Poiter to the data transfer buffer and ramdisk */


int get_status (
    BYTE pdrv
)
{
    volatile STAT *stat = &Stat[pdrv];
    //DWORD dw;

    if (pdrv == 0) {	/* RAMDISK */
        stat->sz_sector = SS_RAMDISK;
        if (stat->sz_sector < FF_MIN_SS || stat->sz_sector > FF_MAX_SS) return 0;
        stat->n_sectors = (DWORD)((QWORD)SZ_RAMDISK / SS_RAMDISK);
        stat->status = 0;
        return 1;
    }

    return 1;
}


/*--------------------------------------------------------------------------
   Public Functions
---------------------------------------------------------------------------*/

int static_init()
{
    static int is_inited = 0;
    if( is_inited ) return is_inited;

//    Buffer = malloc(BUFSIZE);
//    if (!Buffer) return 0;

    is_inited =1;
    return is_inited;
}


int static_close()
{
    disk_exit = 1;
    return 0;
}

int static_fini()
{
    static_close();

//    free(Buffer);
    return 0;
}


/*-----------------------------------------------------------------------*/
/* Initialize Disk Drive                                                 */
/*-----------------------------------------------------------------------*/

DSTATUS disk_initialize (
    BYTE pdrv		/* Physical drive nmuber */
)
{
    DSTATUS sta;

    if (pdrv >= Drives) {
        sta = STA_NOINIT;
    } else {
        get_status(pdrv);
        sta = Stat[pdrv].status;
    }

    return sta;
}



/*-----------------------------------------------------------------------*/
/* Get Disk Status                                                       */
/*-----------------------------------------------------------------------*/
DSTATUS disk_status (
    BYTE pdrv		/* Physical drive nmuber (0) */
)
{
    DSTATUS sta;

    if (pdrv >= Drives) {
        sta = STA_NOINIT;
    } else {
        sta = Stat[pdrv].status;
    }

    return sta;
}

//static FFMutex *mutex_r = NULL;
//static FFCond  *cond_r  = NULL;
//static int     isLock_r = 0;
//
//static FFMutex *mutex_w = NULL;
//static FFCond  *cond_w  = NULL;
//static int     isLock_w = 0;
//
//void mutexLock_r(void){
//    if (mutex_r == NULL) mutex_r = CreateFFMutex();
//    if (cond_r  == NULL) cond_r  = CreateFFCond();
//    printf("---> pthread pause R.\n");
//
//    LockFFMutex(mutex_r);
//    FFCondWait(cond_r, mutex_r);
//    UnlockFFMutex(mutex_r);
//}
//
//void mutexUnlock_r(void){
//    printf("---> pthread continue R.\n");
//    FFCondSignal(cond_r);
//    isLock_r = 0;
//}
//
//void mutexLock_w(void){
//    if (mutex_w == NULL) mutex_w = CreateFFMutex();
//    if (cond_w  == NULL) cond_w  = CreateFFCond();
//    printf("---> pthread pause W.\n");
//
//    LockFFMutex(mutex_w);
//    FFCondWait(cond_w, mutex_w);
//    UnlockFFMutex(mutex_w);
//}
//
//void mutexUnlock_w(void){
//    printf("---> pthread continue W.\n");
//    FFCondSignal(cond_w);
//    isLock_w = 0;
//}

/*-----------------------------------------------------------------------*/
/* Read Sector(s)                                                        */
/*-----------------------------------------------------------------------*/
DRESULT disk_read (
    BYTE pdrv,			/* Physical drive nmuber (0) */
    BYTE *buff,			/* Pointer to the data buffer to store read data */
    DWORD sector,		/* Start sector number (LBA) */
    UINT count			/* Number of sectors to read */
)
{
    DWORD nc;
    DSTATUS res;

    if (pdrv >= Drives || Stat[pdrv].status & STA_NOINIT) {
        return RES_NOTRDY;
    }

    nc = (DWORD)count * Stat[pdrv].sz_sector;
    long long offset = (long long)sector * Stat[pdrv].sz_sector;
    if (pdrv) {	/* Physical dirve */
    } else {	/* RAM disk */
        if(!do_test_disk_io_read(buff, (uint32_t)offset, nc)){
            res = RES_ERROR;
        }else{
            res = RES_OK;
        }
    }

    return res;
}



/*-----------------------------------------------------------------------*/
/* Write Sector(s)                                                       */
/*-----------------------------------------------------------------------*/
DRESULT disk_write (
    BYTE pdrv,			/* Physical drive nmuber (0) */
    const BYTE *buff,	/* Pointer to the data to be written */
    DWORD sector,		/* Start sector number (LBA) */
    UINT count			/* Number of sectors to write */
)
{
    DWORD nc = 0;
    DRESULT res;

    if (pdrv >= Drives || Stat[pdrv].status & STA_NOINIT) {
        return RES_NOTRDY;
    }

    res = RES_OK;
    if (Stat[pdrv].status & STA_PROTECT) {
        res = RES_WRPRT;
    } else {
        nc = (DWORD)count * Stat[pdrv].sz_sector;
        if (nc > BUFSIZE) res = RES_PARERR;
    }

    long long offset = (long long)sector * Stat[pdrv].sz_sector;
    if (offset >= (QWORD)SZ_RAMDISK) {
        res = RES_ERROR;
    } else {
        // FIXME: replace with writeBluetooh(offset, buff, nc);
        if(!do_test_disk_io_write(buff, (uint32_t) offset, nc)){
            res = RES_ERROR;
        }else{
            res = RES_OK;
        }
    }
    return res;
}


/*-----------------------------------------------------------------------*/
/* Miscellaneous Functions                                               */
/*-----------------------------------------------------------------------*/

DRESULT disk_ioctl (
    BYTE pdrv,		/* Physical drive nmuber (0) */
    BYTE ctrl,		/* Control code */
    void *buff		/* Buffer to send/receive data */
)
{
    DRESULT res;


    if (pdrv >= Drives || (Stat[pdrv].status & STA_NOINIT)) {
        return RES_NOTRDY;
    }

    res = RES_PARERR;
    switch (ctrl) {
    case CTRL_SYNC:			/* Nothing to do */
        res = RES_OK;
        break;

    case GET_SECTOR_COUNT:	/* Get number of sectors on the drive */
        *(DWORD*)buff = Stat[pdrv].n_sectors;
        res = RES_OK;
        break;

    case GET_SECTOR_SIZE:	/* Get size of sector for generic read/write */
        *(WORD*)buff = Stat[pdrv].sz_sector;
        res = RES_OK;
        break;

    case GET_BLOCK_SIZE:	/* Get internal block size in unit of sector */
        *(DWORD*)buff = 8;
        res = RES_OK;
        break;

    case 200:				/* Load disk image file to the RAM disk (drive 0) */
        break;
    }

    return res;
}


DWORD get_fattime (void)
{
    struct tm tm;

    time_t ts = time(NULL);

    localtime_r(&ts, &tm);

    return   ((DWORD)(tm.tm_year + 1900 - 1980) << 25)
           | ((DWORD)(tm.tm_mon + 1) << 21)
           | ((DWORD)tm.tm_mday << 16)
           | (WORD)(tm.tm_hour << 11)
           | (WORD)(tm.tm_min << 5)
           | (WORD)(tm.tm_sec >> 1);
}
