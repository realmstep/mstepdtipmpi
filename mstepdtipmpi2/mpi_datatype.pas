{$mode objfpc} {$H+}
uses
	mpi2,
	sysutils;
var
	val:longword;
begin
	val:= MPI_INT
	;
	writeln(format('%X', [ val ] ) );
{
	val:= HANDLE_KIND_MASK
	;
	writeln(format('%X', [ val ] ) );
	
	val:= HANDLE_KIND_MASK
        OR (MPID_DATATYPE shl HANDLE_KIND_SHIFT) 
	;
	writeln(format('%X', [ val ] ) );
}
	val:= (HANDLE_KIND_BUILTIN shl HANDLE_KIND_SHIFT)
		OR (MPID_DATATYPE shl HANDLE_MPI_KIND_SHIFT)
		OR (sizeof(longint) shl 8)
		OR ( $7) //MPI_INT
	;
	writeln(format('%X', [ val ] ) );

//		(MPID_DATATYPE shr HANDLE_KIND_SHIFT) 
//		OR (HANDLE_KIND_BUILTIN shr HANDLE_MPI_KIND_SHIFT) 
//		OR (7 shr HANDLE_MPI_KIND_SHIFT)
//	]) );
//	writeln( format('%d',[ val ] ) );

//HANDLE_GET_KIND(a) (((unsigned)(a)&HANDLE_KIND_MASK)>>HANDLE_KIND_SHIFT)
//HANDLE_SET_KIND(a,kind) ((a)|((kind)<<HANDLE_KIND_SHIFT))
	writeln('HANDLE_GET_KIND ', format('%X', [ ((val) AND HANDLE_KIND_MASK) shr HANDLE_KIND_SHIFT ] ) );

//    if (HANDLE_GET_MPI_KIND(datatype) != MPID_DATATYPE ||      \
//	(HANDLE_GET_KIND(datatype) == HANDLE_KIND_INVALID &&   \
//	datatype != MPI_DATATYPE_NULL))			       \

// HANDLE_GET_MPI_KIND(a) ( ((a)&0x3c000000) >> HANDLE_MPI_KIND_SHIFT )
// HANDLE_SET_MPI_KIND(a,kind) ((a) | ((kind) << HANDLE_MPI_KIND_SHIFT))
//* Handle types.  These are really 2 bits */
	writeln('HANDLE_GET_MPI_KIND ', format('%X', [ ((val) AND $3c000000) shr HANDLE_MPI_KIND_SHIFT ] ) );

//#define MPID_Datatype_get_basic_id(a) ((a)&0x000000ff)
	writeln('MPID_Datatype_get_basic_id ', format('%X', [ ((val) AND $000000ff) ] ) );
//#define MPID_Datatype_get_basic_size(a) (((a)&0x0000ff00)>>8)
	writeln('MPID_Datatype_get_basic_size ', format('%X', [ ((val) AND $0000ff00) shr 8 ] ) );

end.
