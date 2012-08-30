
unit mpi2;
interface

{
  Automatically converted by H2Pas 1.0.0 from mpi2.h
  The following command line parameters were used:
    -D
    -u
    mpi2
    mpi2.h
    -o
    mpi2tmp.pp
}

  const
    External_library=''; {Setup as you need}

  Type
  Pchar  = ^char;
  Plongint  = ^longint;
  PMPI_Status  = ^MPI_Status;
{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


{$ifndef MPI_INCLUDED}
{$define MPI_INCLUDED}  

  type
    MPI_Comm = longint;

  const
    MPI_COMM_WORLD = $44000000;    

  function MPI_Barrier(_para1:MPI_Comm):longint;cdecl;external External_library name 'MPI_Barrier';

  function MPI_Comm_size(_para1:MPI_Comm; _para2:Plongint):longint;cdecl;external External_library name 'MPI_Comm_size';

  function MPI_Comm_rank(_para1:MPI_Comm; _para2:Plongint):longint;cdecl;external External_library name 'MPI_Comm_rank';

  function MPI_Wtime:double;cdecl;external External_library name 'MPI_Wtime';

  function MPI_Init(_para1:Plongint; _para2:PPPchar):longint;cdecl;external External_library name 'MPI_Init';

  function MPI_Finalize:longint;cdecl;external External_library name 'MPI_Finalize';


  type
    MPI_Datatype = longint;

    MPI_BYTE = MPI_Datatype;

    MPI_DOUBLE = MPI_Datatype;

    MPI_INT = MPI_Datatype;
  {    @EXTRA_STATUS_DECL@ }

    MPI_Status = record
        count : longint;
        cancelled : longint;
        MPI_SOURCE : longint;
        MPI_TAG : longint;
        MPI_ERROR : longint;
      end;

  const
    MPI_BSEND_OVERHEAD = 512;    

  function MPI_Buffer_attach(_para1:pointer; _para2:longint):longint;cdecl;external External_library name 'MPI_Buffer_attach';

  function MPI_Buffer_detach(_para1:pointer; _para2:Plongint):longint;cdecl;external External_library name 'MPI_Buffer_detach';

{$define MPICH2_CONST}  
  function MPI_Send(_para1:pointer; _para2:longint; _para3:MPI_Datatype; _para4:longint; _para5:longint; 
             _para6:MPI_Comm):longint;cdecl;external External_library name 'MPI_Send';

  function MPI_Recv(_para1:pointer; _para2:longint; _para3:MPI_Datatype; _para4:longint; _para5:longint; 
             _para6:MPI_Comm; _para7:PMPI_Status):longint;cdecl;external External_library name 'MPI_Recv';

  function MPI_Scatter(_para1:pointer; _para2:longint; _para3:MPI_Datatype; _para4:pointer; _para5:longint; 
             _para6:MPI_Datatype; _para7:longint; _para8:MPI_Comm):longint;cdecl;external External_library name 'MPI_Scatter';

  function MPI_Scatterv(_para1:pointer; _para2:Plongint; _para3:Plongint; _para4:MPI_Datatype; _para5:pointer; 
             _para6:longint; _para7:MPI_Datatype; _para8:longint; _para9:MPI_Comm):longint;cdecl;external External_library name 'MPI_Scatterv';

  function MPI_Gatherv(_para1:pointer; _para2:longint; _para3:MPI_Datatype; _para4:pointer; _para5:Plongint; 
             _para6:Plongint; _para7:MPI_Datatype; _para8:longint; _para9:MPI_Comm):longint;cdecl;external External_library name 'MPI_Gatherv';

  function MPI_Allgatherv(_para1:pointer; _para2:longint; _para3:MPI_Datatype; _para4:pointer; _para5:Plongint; 
             _para6:Plongint; _para7:MPI_Datatype; _para8:MPI_Comm):longint;cdecl;external External_library name 'MPI_Allgatherv';

  function MPI_Bcast(_para1:pointer; _para2:longint; _para3:MPI_Datatype; _para4:longint; _para5:MPI_Comm):longint;cdecl;external External_library name 'MPI_Bcast';

  function MPI_Bsend(_para1:pointer; _para2:longint; _para3:MPI_Datatype; _para4:longint; _para5:longint; 
             _para6:MPI_Comm):longint;cdecl;external External_library name 'MPI_Bsend';


implementation


end.
