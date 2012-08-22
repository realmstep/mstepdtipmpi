program dtip_mpi_main;
// поиск оптимального распределеня ДТИП
// условия. Общая сумма <= ограничения
{$mode objfpc} {$H+}

uses
	mpi,
	sysutils,
	Classes, dom, XMLRead, XMLWrite;

{$I dtip_mpi_var.pas}

{$I dtip_mpi_xml.pas}
{$I dtip_mpi_trace.pas}

{$I dtip_mpi_data.pas}	

{$I dtip_mpi_comm.pas}	

{$I dtip_mpi_sttr.pas}

{$I dtip_mpi_osn.pas}	
var
	ab: boolean;

begin
    MPI_Init(argc,argv);
    teg := 0;
    MPI_Comm_size(MPI_COMM_WORLD, numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, myid);
	writeln(myid, ' before all');

    if myid = 0 then begin
		startwtime := MPI_Wtime;
//		InitData();
	    ab:= initData();
    	if not ab then begin
        	writeln('init failed');
			exit;
		end;

	    startStateTrans:= MPI_Wtime;
		totalStateTransMPI:=0;
	end;
	calcStateTransModified();


    if myid = 0 then begin
	    endStateTrans:= MPI_Wtime;
		totalStateTrans:= endStateTrans-startStateTrans;

		setAllJbyRNS();
		// рассчитать непосредственно ожидаемый доход
		Calc_qijk();
	end;

    if myid = 0 then begin
	    startOsn:= MPI_Wtime;
		InitOsnShema();

		addOsnNode(); // 0й шаг
	end;
	
//	CalcOsnSchema();
	CalcOsnSchemaMPI();

    if myid = 0 then begin
	    endOsn:= MPI_Wtime;
		totalOsn:= endOsn-startOsn;

//		rTrace:=IterpretResults();
		rTrace:=IterpretResultsAsNode();

		FinalizeOsnShema();
	end;

	MPI_Barrier(MPI_COMM_WORLD);

    if myid = 0 then begin
		endwtime := MPI_Wtime;
		totaltime:= endwtime-startwtime;

		FinalizeData();

		writeln('time for calcStateTransModified:', totaltime:9:6);

		writeln('Completed at ', numprocs, ' procs. Press Enter to continue...');
//		readln();
	end;
	MPI_Finalize;

end.
