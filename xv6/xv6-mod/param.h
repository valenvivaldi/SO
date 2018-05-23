#define NPROC        64  // maximum number of processes
#define KSTACKSIZE 4096  // size of per-process kernel stack
#define NCPU          8  // maximum number of CPUs
#define NOFILE       16  // open files per process
#define NFILE       100  // open files per system
#define NINODE       50  // maximum number of active i-nodes
#define NDEV         10  // maximum major device number
#define ROOTDEV       1  // device number of file system root disk
#define MAXARG       32  // max exec arguments
#define MAXOPBLOCKS  10  // max # of blocks any FS op writes
#define LOGSIZE      (MAXOPBLOCKS*3)  // max data sectors in on-disk log
#define NBUF         (MAXOPBLOCKS*3)  // size of disk block cache
#define TIMESLICE    40  //amount of ticks per burst of execution
#define MLFLEVELS    4   // amount of levels in the MLF structure
#define MLFMAXLEVEL  0   // level of maximum priority in the mlf
#define AGEFORSCALING  50  // age needed to climb the mlf levels
#define TICKSFORAGING 100  //
#define ACTIVATEAGING  1 // 1 for activate the priority increase by aging, 0 for disable
#define MAXSEM  30  //
#define MAXPROCSEM 5
#define MAXSTACKPAGES 5  // max pages of stack for each process
