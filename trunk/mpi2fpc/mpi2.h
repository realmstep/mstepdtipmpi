#ifndef MPI_INCLUDED
#define MPI_INCLUDED

typedef int MPI_Comm;

#define MPI_COMM_WORLD 0x44000000

int MPI_Barrier(MPI_Comm );
int MPI_Comm_size(MPI_Comm, int *);
int MPI_Comm_rank(MPI_Comm, int *);

double MPI_Wtime(void);
int MPI_Init(int *, char ***);
int MPI_Finalize(void);

typedef int MPI_Datatype;

typedef MPI_Datatype MPI_BYTE;
typedef MPI_Datatype MPI_DOUBLE;
typedef MPI_Datatype MPI_INT;

typedef struct MPI_Status {
    int count;
    int cancelled;
    int MPI_SOURCE;
    int MPI_TAG;
    int MPI_ERROR;
//    @EXTRA_STATUS_DECL@
} MPI_Status;

#define MPI_BSEND_OVERHEAD 512

int MPI_Buffer_attach( void*, int);
int MPI_Buffer_detach( void*, int *);

#define MPICH2_CONST

int MPI_Send(void*, int, MPI_Datatype, int, int, MPI_Comm);
int MPI_Recv(void*, int, MPI_Datatype, int, int, MPI_Comm, MPI_Status *);

int MPI_Scatter (void* , int,           MPI_Datatype, void*, int, MPI_Datatype, int, MPI_Comm);

int MPI_Scatterv(void* , int *, int *,  MPI_Datatype, void*, int, MPI_Datatype, int, MPI_Comm);

int MPI_Gatherv(void* , int, MPI_Datatype, void*, int *,
                int *, MPI_Datatype, int, MPI_Comm);

int MPI_Allgatherv(void* , int, MPI_Datatype, void*, int *,
                   int *, MPI_Datatype, MPI_Comm);

int MPI_Bcast(void*, int, MPI_Datatype, int, MPI_Comm);

int MPI_Bsend(void*, int, MPI_Datatype, int, int, MPI_Comm);



