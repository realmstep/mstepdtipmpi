function CalcOsnSchemaStepMPIv2(): longint;
var
	ai, aibase, ak, ai_j, ak_max, am, an: longint;
	ag_n1, avi_n1, axi, axi2, axi2_max: double;

	function procCalcForState(): boolean;
	var
		ak: longint;
	begin
    // поиск max по ak
		// mpi найти локальный максимум по каждому процессу - начало
		axi2_max:= -1000;//low(double);
		ak_max:= 1;
		for ak:= 1 to procArrKv1[ai] do begin
			ai_j:= procArrJ[ai, ak];
			if ai_j=-1000 then break; // если законились rijk <> low(longint)
			axi2:= ag_n1 + procArrR[ai, ak]
				+ (1/cw)*procArrVcurrStep[ai_j]
				- ((1/cw)-1)*procArrVprevStep[ai_j];
			if axi2>axi2_max then begin
				axi2_max:= axi2;
				ak_max:=ak;
			end;
    	end;
		// mpi найти локальный максимум по каждому процессу - конец
		// mpi вернуть локальный макс. Определить глобальный макс
		axi:= axi2_max;
		avi_n1:= (1-cW)*procArrVprevStep[ai] + cW*axi - cw*ag_n1;
		procArrVcurrStep[ai]:= avi_n1;
		procArrDcurrStep[ai]:= ak_max;
		// вернуть надо только измененные данные по ai из procArrVcurrStep, procArrDcurrStep
	end;

	function CalcForState(): boolean;
	var
		ak: longint;
	begin
    // поиск max по ak
		// mpi найти локальный максимум по каждому процессу - начало
		axi2_max:= -1000;//low(double);
		ak_max:= 1;
		for ak:= 1 to ArrKv1[ai] do begin
			ai_j:= ArrJ[ai, ak];
			if ai_j=-1000 then break; // если законились rijk <> low(longint)
			axi2:= ag_n1 + ArrR[ai, ak]
				+ (1/cw)*ArrVcurrStep[ai_j]
				- ((1/cw)-1)*ArrVprevStep[ai_j];
			if axi2>axi2_max then begin
				axi2_max:= axi2;
				ak_max:=ak;
			end;
    	end;
		// mpi найти локальный максимум по каждому процессу - конец
		// mpi вернуть локальный макс. Определить глобальный макс
		axi:= axi2_max;
		avi_n1:= (1-cW)*ArrVprevStep[ai] + cW*axi - cw*ag_n1;
		ArrVcurrStep[ai]:= avi_n1;
		ArrDcurrStep[ai]:= ak_max;
	end;
var
	acur_buf_int: ^longint;
	acur_buf_dbl: ^double;
begin
// Цикл по шагам
	aibase:=1;
	if messageMode = 'debug' then begin
		writeln(myid, '|   BeforeStep ');
	    startTemp1:= MPI_Wtime; 
	end;

//	procCopyArrCurrToPrev();
	if myid = 0 then begin
		copyArrCurrToPrev();

		currStep:= currStep+1; //тек шаг = n+1
		// вес базового сост для любого шага 0
		ArrVcurrStep[aibase]:=0; // веса. индексы: сост aibase:=1;
		ArrDcurrStep[aibase]:=1; // оптим.упр.индексы: упр
		// в баз сост только одно управление и только 1 переход с вероятн 1
		ak:=1;
		ag_n1:= get_qik(aibase, ak) + arrVprevStep[get_j(aibase, ak)];
		arrG[currStep]:=ag_n1;
	end;
	if messageMode = 'debug' then begin
		endTemp1:= MPI_Wtime;
		writeln(myid, '|   InitStep ', endTemp1 - startTemp1: 9:6);
	    startTemp1:= endTemp1;
	end;

{	for ai:= aibase to Ns-1 do begin
		writeln(format('ArrVcurrStep[%d] = %f', [ai, ArrVcurrStep[ai]]));
	end;
}
	bcast_arrDbl(ArrVcurrStep, procArrVcurrStep);

{	for ai:= aibase to Ns-1 do begin
		writeln(format('procArrVcurrStep[%d] = %f', [ai, procArrVcurrStep[ai]]));
	end;
}
	bcast_arrDbl(ArrVprevStep, procArrVprevStep);
//	bcast_arrDbl(ArrVcurrStep, procArrVcurrStep);
	MPI_BCAST(@ag_n1, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
//	writeln(myid, '| ag_n1 = ', ag_n1:6:3);

	// ВНУТРИ ШАГА
	// найти локальный макс
	// вернуть макс и номер сост

	// mpi разбросать по процессам по номерам состояний
{	for ai:= aibase+1 to Ns-1 do begin
		CalcForState();
	end;
}
	if messageMode = 'debug' then begin
		endTemp1:= MPI_Wtime;
		writeln(myid, '|   SendStepData ', endTemp1 - startTemp1: 9:6);
	    startTemp1:= endTemp1;

		endTemp1:= MPI_Wtime;
		writeln(myid, '|   StartMainCycle ', endTemp1 - startTemp1: 9:6);
	    startTemp1:= endTemp1;
	end;

//	writeln(' procDownNc ', procDownNc, ' procUpNc ', procUpNc);
	for am:= 1 to M do begin
//		for an:= 1 to Nc+1 do begin
		for an:= procDownNc to procUpNc do begin
			ai:= aibase + (am-1)*(Nc+1) + an;
			procCalcForState();
//			writeln(myid, '| ai = ', ai);
			// упаковать в буфер обновленные данные procArrVcurrStep
			acur_buf_dbl:= sendSubArrVBuf + (an-procDownNc)*sizeOfDouble;
			acur_buf_dbl^:= procArrVcurrStep[ai];
//			writeln(format('procArrVcurrStep[%d] = %f', [ai, procArrVcurrStep[ai]]));
			acur_buf_int:= sendSubArrDBuf + (an-procDownNc)*sizeOfLongint;
			acur_buf_int^:= procArrDcurrStep[ai];
		end;
		if messageMode = 'debug' then begin
			endTemp1:= MPI_Wtime;
			writeln(myid, '|       CalcData   ', endTemp1 - startTemp1: 9:6);
		    startTemp1:= endTemp1;
		end;
		// отправить обновленные данные массива procArrVcurrStep
//		MPI_GATHERV(sendSubArrVBuf, procNc, MPI_Double, 
//					recvSubArrVBuf, procNcArr[0], procSubArrVDispls[0], MPI_Double, 0, MPI_COMM_WORLD);
		ai:= aibase + (am-1)*(Nc+1);
//		writeln('ai = ', ai, ' ai+procDownNc =', ai+procDownNc, '', );
//		MPI_ALLGATHERV(@procArrVcurrStep[ai+procDownNc], procNc, MPI_Double, 
//					@ArrVcurrStep[ai+1], procNcArr[0], procSubArrVDispls[0], MPI_Double, MPI_COMM_WORLD);
		MPI_ALLGATHERV(@procArrVcurrStep[ai+procDownNc], procNc, MPI_Double, 
					@ArrVcurrStep[ai+1], @(procNcArr[0]), @(procSubArrVDispls[0]), MPI_Double, MPI_COMM_WORLD);
		for an:= 1 to Nc+1 do begin
			ai:= aibase + (am-1)*(Nc+1) + an;
			procArrVcurrStep[ai]:=ArrVcurrStep[ai];
		end;

		if messageMode = 'debug' then begin
			endTemp1:= MPI_Wtime;
			writeln(myid, '|       SendData   ', endTemp1 - startTemp1: 9:6);
		    startTemp1:= endTemp1;
		end;
{		if myid = 0 then begin
			// распковать
			for an:= 1 to Nc+1 do begin
				ai:= aibase + (am-1)*(Nc+1) + an;
				acur_buf_dbl:= recvSubArrVBuf + (an-1)*sizeOfDouble;
//				ArrVcurrStep[ai]:= acur_buf_dbl^;
//				writeln(format('ArrVcurrStep[%d] = %f // %f', [ai, ArrVcurrStep[ai],acur_buf_dbl^]));
				acur_buf_int:= recvSubArrDBuf + (an-1)*sizeOflongint;
				ArrDcurrStep[ai]:= acur_buf_int^;
			end;
		end;
}

		// bcast всем новые значения ArrVcurrStep для текущего шага
		// оптимизация. отправлять не все значения т.е. Ns, а только измененные на этом шаге т.е Nc+1  - доп кодирование
//		bcast_arrDbl(ArrVcurrStep, procArrVcurrStep);
//		if myid=0 then begin
//			for an:=0 to length(ArrVcurrStep)-1 do begin
//				procArrVcurrStep[an]:= ArrVcurrStep[an];
//			end;
//		end;
//		ai:= aibase + (am-1)*(Nc+1) + an;
//		MPI_BCAST(@procArrVcurrStep[0], length(procArrVcurrStep), MPI_DOUBLE, 0, MPI_COMM_WORLD);
//		ai:= aibase + (am-1)*(Nc+1);
//		MPI_BCAST(@procArrVcurrStep[ai], Nc+1, MPI_DOUBLE, 0, MPI_COMM_WORLD);

		if messageMode = 'debug' then begin
			endTemp1:= MPI_Wtime;
			writeln(myid, '|       resendData ', endTemp1 - startTemp1: 9:6);
		    startTemp1:= endTemp1;
		end;

	end;

	if messageMode = 'debug' then begin
		endTemp1:= MPI_Wtime;
		writeln(myid, '|   endMainCycle ', endTemp1 - startTemp1: 9:6);
	    startTemp1:= endTemp1;
	end;
{
	for am:= 1 to M do begin
		// перепаковать и сделать 1у передачу
		ai:= aibase + (am-1)*(Nc+1);
		MPI_GATHERV(@procArrDcurrStep[ai+procDownNc], procNc, MPI_INT,
					@ArrDcurrStep[ai+1], procNcArr[0], procSubArrDDispls[0], MPI_INT, 0, MPI_COMM_WORLD);
	end;
}
	ap:=0;

//	str:= #13#10;
//	writeln(' procDownNc ', procDownNc, ' procUpNc ', procUpNc);
	for am:= 1 to M do begin
		// перепаковать и сделать 1у передачу
		for an:=procDownNc to procUpNc do begin
			ai:= aibase + (am-1)*(Nc+1) + an;
			procArrDcurrStepTemp[ap]:= procArrDcurrStep[ai];
			ap:=ap+1;//от 1 до M*procNc
			// для проца идут подряд
//			str:= str + format('d[%d]=%d ', [ai, procArrDcurrStep[ai]]);
		end;
//		str:= str + #13#10;
	end;
//	writeln(myid, ' | 1', str);
	
	// 0й procArrDcurrStepTemp пропускаем
//	writeln('length(procArrDcurrStepTemp) = ', length(procArrDcurrStepTemp), ' procNc*M = ', procNc*M);
//	writeln('length(ArrDcurrStepTemp) = ', length(ArrDcurrStepTemp), ' procNcArrTemp[0] = ', procNcArrTemp[0]);
//	MPI_GATHERV(@procArrDcurrStepTemp[0], procNc*M, MPI_INT,
//				@ArrDcurrStepTemp[aibase+1], procNcArrTemp[0], procSubArrDDisplsTemp[0], MPI_INT, 0, MPI_COMM_WORLD);
	MPI_GATHERV(@procArrDcurrStepTemp[0], procNc*M, MPI_INT,
				@ArrDcurrStepTemp[aibase+1], @(procNcArrTemp[0]), @(procSubArrDDisplsTemp[0]), MPI_INT, 0, MPI_COMM_WORLD);

//	writeln(myid, ' | procDownNc ', procDownNc, ' procUpNc ', procUpNc);
	if myid=0 then begin
		ap:=aibase;
		procDownNc:= 1;
		for aproc:= 0 to numprocs-1 do begin
			procNc:= procNcArr[aproc];
			procUpNc:= procDownNc + procNc - 1;
//			str:= #13#10;
			for am:= 1 to M do begin
//				for an:=procDownNc to procUpNc do begin
				for an:=procDownNc to procUpNc do begin
			// распаковать
					ai:= aibase + (am-1)*(Nc+1) + an;
					ap:= ap + 1;//от 1 до M*procNc
//					writeln(' ap=', ap , ' ai=', ai);
					ArrDcurrStep[ai]:= ArrDcurrStepTemp[ap];
					// для проца идут подряд
//					str:= str + format('d[%d]=%d ', [ai, ArrDcurrStep[ai] ]);
				end;//an
//				str:= str + #13#10;
			end;//am
			procDownNc:= procDownNc + procNcArr[aproc];
//			writeln(aproc, ' | 2', str);
		end;//ap
		procDownNc:= 1;
		procNc:= procNcArr[0];
		procUpNc:= procDownNc + procNc - 1;
	end;
	if messageMode = 'debug' then begin
		endTemp1:= MPI_Wtime;
		writeln(myid, '|       sendD ', endTemp1 - startTemp1: 9:6);
	    startTemp1:= endTemp1;
	end;

	// отправить обновленные данные массива procArrDcurrStep

	if myid = 0 then begin
		ai:=Ns;
		CalcForState();

		Result := IsSolved();
	end;
	if messageMode = 'debug' then begin
		endTemp1:= MPI_Wtime;
		writeln(myid, '|   endStep ', endTemp1 - startTemp1: 9:6,#13#10);
	    startTemp1:= endTemp1;
	end;
{	if myid = 0 then
		readln();
	MPI_Barrier(MPI_COMM_WORLD);
}
end;//v2
