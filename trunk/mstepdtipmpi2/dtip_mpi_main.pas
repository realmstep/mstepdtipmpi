program dtip_mpi_main;
// поиск оптимального распределеня ДТИП
// условия. Общая сумма <= ограничения
{$mode objfpc} {$H+}

uses
//v32	mpi,
//v64
	mpi2,
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
    MPI_Init(@argc,@argv);
    teg := 0;
    MPI_Comm_size(MPI_COMM_WORLD, @numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, @myid);
	writeln(myid, '| before all');

    if myid = 0 then begin
		writeln(myid, '| started at ', numprocs, ' procs');

		startwtime := MPI_Wtime;

       	writeln(myid, '| before initData');
	    ab:= initData();
    	if not ab then begin
        	writeln(myid, '| initData failed');
			exit;
		end;
       	writeln(myid, '| initData finished ok');

	    startStateTrans:= MPI_Wtime;
		totalStateTransMPI:=0;
	end;

	writeln(myid, '| before calcStateTrans');
	calcStateTransModified();
	writeln(myid, '| calcStateTrans finished ok');

    if myid = 0 then begin
	    endStateTrans:= MPI_Wtime;
		totalStateTrans:= endStateTrans-startStateTrans;
		writeln(myid, format('| TIME totalStateTrans=%.6f sec', [totalStateTrans]));

		// рассчитать непосредственно ожидаемый доход
		writeln(myid, '| before Calc_qijk');
		Calc_qijk();
		writeln(myid, '| Calc_qijk finished ok');
	end;

    if myid = 0 then begin
	    startOsn:= MPI_Wtime;
		writeln(myid, '| before InitOsnShema');
		InitOsnShema();

		addOsnNode(); // 0й шаг
		writeln(myid, '| InitOsnShema finished ok');
	end;
	
	writeln(myid, '| before CalcOsnSchema');
	CalcOsnSchemaMPI();
	writeln(myid, '| CalcOsnSchema finished ok');

    if myid = 0 then begin
	    endOsn:= MPI_Wtime;
		totalOsn:= endOsn-startOsn;
		writeln(myid, format('| TIME totalOsn=%.6f sec', [totalOsn]));

//		rTrace:=InterpretResults();
		writeln(myid, '| before InterpretResults');
		rTrace:=InterpretResultsAsNode();
		writeln(myid, '| InterpretResults finished ok');

		writeln(myid, '| before FinalizeOsnShema');
		FinalizeOsnShema();
		writeln(myid, '| FinalizeOsnShema finished ok');
	end;

	MPI_Barrier(MPI_COMM_WORLD);

    if myid = 0 then begin
		endwtime := MPI_Wtime;
		totaltime:= endwtime-startwtime;

		writeln(myid, '| before FinalizeData');
		FinalizeData();
		freeMem(status, SizeOf(MPI_Status));
		status := Nil;
		// перенесен из sttr
		setLength(StateTransArr, 0);
		writeln(myid, '| FinalizeData finished ok');

		writeln(myid, '| TOTAL time:', totaltime:9:6);
//		readln();
	end;
	MPI_Finalize;

end.
