unit mpi2;
{$mode objfpc} {$H+}

interface

{
  Automatically converted by H2Pas 1.0.0 from mpi2.h
  The following command line parameters were used:
    -D
    -u
    mpi2
    mpi2.h
}

  const
    External_library='mpich2.dll'; {Setup as you need}

{$PACKRECORDS C}

  Type

  Pchar  = ^char;
  Plongint  = ^longint;


    MPI_Status = record
        count : longint;
        cancelled : longint;
        MPI_SOURCE : longint;
        MPI_TAG : longint;
        MPI_ERROR : longint;
      end;

  PMPI_Status  = ^MPI_Status;



    MPI_Comm = longint;

    MPI_Datatype = longint;


  const
    MPI_COMM_WORLD: MPI_Comm = $44000000;    
    MPI_BSEND_OVERHEAD = 512;    


    HANDLE_KIND_MASK = $c0000000;
    HANDLE_KIND_SHIFT = 30;
//HANDLE_GET_KIND(a) (((unsigned)(a)&HANDLE_KIND_MASK)>>HANDLE_KIND_SHIFT)
//HANDLE_SET_KIND(a,kind) ((a)|((kind)<<HANDLE_KIND_SHIFT))

    MPID_DATATYPE         = $3;
    HANDLE_MPI_KIND_SHIFT = 26;

//    if (HANDLE_GET_MPI_KIND(datatype) != MPID_DATATYPE ||      \
//	(HANDLE_GET_KIND(datatype) == HANDLE_KIND_INVALID &&   \
//	datatype != MPI_DATATYPE_NULL))			       \

// HANDLE_GET_MPI_KIND(a) ( ((a)&0x3c000000) >> HANDLE_MPI_KIND_SHIFT )

// HANDLE_SET_MPI_KIND(a,kind) ((a) | ((kind) << HANDLE_MPI_KIND_SHIFT))
//* Handle types.  These are really 2 bits */
    HANDLE_KIND_INVALID  = $0;
    HANDLE_KIND_BUILTIN  = $1;
    HANDLE_KIND_DIRECT   = $2;
    HANDLE_KIND_INDIRECT = $3;
///* Mask assumes that ints are at least 4 bytes */
//


    MPI_BYTE  : MPI_Datatype = (HANDLE_KIND_BUILTIN shl HANDLE_KIND_SHIFT) 
								OR (MPID_DATATYPE shl HANDLE_MPI_KIND_SHIFT) 
								OR (sizeof(byte) shl 8)
								OR ( 3 );
    MPI_INT   : MPI_Datatype = (HANDLE_KIND_BUILTIN shl HANDLE_KIND_SHIFT) 
								OR (MPID_DATATYPE shl HANDLE_MPI_KIND_SHIFT) 
								OR (sizeof(longint) shl 8)
								OR ( 7 );
    MPI_DOUBLE: MPI_Datatype = (HANDLE_KIND_BUILTIN shl HANDLE_KIND_SHIFT) 
								OR (MPID_DATATYPE shl HANDLE_MPI_KIND_SHIFT) 
								OR (sizeof(double) shl 8)
								OR (12 );


{  function MPI_BYTE: MPI_Datatype;

  function MPI_DOUBLE: MPI_Datatype;

  function MPI_INT: MPI_Datatype;
}
  {    @EXTRA_STATUS_DECL@ }


  function MPI_Barrier(_para1:MPI_Comm):longint;cdecl;external External_library name 'MPI_Barrier';

  function MPI_Comm_size(_para1:MPI_Comm; _para2:Plongint):longint;cdecl;external External_library name 'MPI_Comm_size';

  function MPI_Comm_rank(_para1:MPI_Comm; _para2:Plongint):longint;cdecl;external External_library name 'MPI_Comm_rank';

  function MPI_Wtime:double;cdecl;external External_library name 'MPI_Wtime';

  function MPI_Init(_para1:Plongint; _para2:PPPchar):longint;cdecl;external External_library name 'MPI_Init';

  function MPI_Finalize:longint;cdecl;external External_library name 'MPI_Finalize';



  function MPI_Buffer_attach(_para1:pointer; _para2:longint):longint;cdecl;external External_library name 'MPI_Buffer_attach';

  function MPI_Buffer_detach(_para1:pointer; _para2:Plongint):longint;cdecl;external External_library name 'MPI_Buffer_detach';

  function MPI_Send(_para1:pointer; _para2:longint; _para3:MPI_Datatype; _para4:longint; _para5:longint; 
             _para6:MPI_Comm):longint;cdecl;external External_library name 'MPI_Send';

  function MPI_Recv(_para1:pointer; _para2:longint; _para3:MPI_Datatype; _para4:longint; _para5:longint; 
             _para6:MPI_Comm; _para7:PMPI_Status):longint;cdecl;external External_library name 'MPI_Recv';

//int MPI_Scatter (MPICH2_CONST void* ,                                     int, MPI_Datatype, 
//		void*, int, MPI_Datatype, int, MPI_Comm) MPICH_ATTR_POINTER_WITH_TYPE_TAG(1,3) MPICH_ATTR_POINTER_WITH_TYPE_TAG(4,6);
//int MPI_Scatterv(MPICH2_CONST void* , MPICH2_CONST int *, MPICH2_CONST int *,  MPI_Datatype, 
//		void*, int, MPI_Datatype, int, MPI_Comm) MPICH_ATTR_POINTER_WITH_TYPE_TAG(1,4) MPICH_ATTR_POINTER_WITH_TYPE_TAG(5,7);

  function MPI_Scatter(_para1:pointer; 						_para2:longint; _para3:MPI_Datatype; 
			_para4:pointer; _para5:longint; _para6:MPI_Datatype; _para8:longint; _para9:MPI_Comm):longint;cdecl;external External_library name 'MPI_Scatter';

  function MPI_Scatterv(_para1:pointer; _para2:Plongint; _para3:Plongint; _para4:MPI_Datatype; 
			_para5:pointer; _para6:longint; _para7:MPI_Datatype; _para8:longint; _para9:MPI_Comm):longint;cdecl;external External_library name 'MPI_Scatterv';

//int MPI_Gather (MPICH2_CONST void* , int, MPI_Datatype, void*, int, MPI_Datatype, int, MPI_Comm) MPICH_ATTR_POINTER_WITH_TYPE_TAG(1,3) MPICH_ATTR_POINTER_WITH_TYPE_TAG(4,6);
//int MPI_Gatherv(MPICH2_CONST void* , int, MPI_Datatype, void*, MPICH2_CONST int *,
//                MPICH2_CONST int *, MPI_Datatype, int, MPI_Comm) MPICH_ATTR_POINTER_WITH_TYPE_TAG(1,3) MPICH_ATTR_POINTER_WITH_TYPE_TAG(4,7);
  function MPI_Gather(_para1:pointer; _para2:longint; _para3:MPI_Datatype; 
			_para4:pointer; _para5:longint; _para6:MPI_Datatype; _para7:longint; _para8:MPI_Comm):longint;cdecl;external External_library name 'MPI_Gather';

  function MPI_Gatherv(_para1:pointer; _para2:longint; _para3:MPI_Datatype; _para4:pointer; _para5:Plongint; 
             _para6:Plongint; _para7:MPI_Datatype; _para8:longint; _para9:MPI_Comm):longint;cdecl;external External_library name 'MPI_Gatherv';

  function MPI_Allgatherv(_para1:pointer; _para2:longint; _para3:MPI_Datatype; _para4:pointer; _para5:Plongint; 
             _para6:Plongint; _para7:MPI_Datatype; _para8:MPI_Comm):longint;cdecl;external External_library name 'MPI_Allgatherv';

  function MPI_Bcast(_para1:pointer; _para2:longint; _para3:MPI_Datatype; _para4:longint; _para5:MPI_Comm):longint;cdecl;external External_library name 'MPI_Bcast';

  function MPI_Bsend(_para1:pointer; _para2:longint; _para3:MPI_Datatype; _para4:longint; _para5:longint; 
             _para6:MPI_Comm):longint;cdecl;external External_library name 'MPI_Bsend';


implementation

{
function MPI_INT: MPI_Datatype;
  begin
     MPI_INT := MPI_Datatype(7);
  end;

function MPI_BYTE: MPI_Datatype;
  begin
     MPI_BYTE := MPI_Datatype(3);
  end;

function MPI_DOUBLE: MPI_Datatype;
  begin
     MPI_DOUBLE := MPI_Datatype(12)];
  end;
}

end.
