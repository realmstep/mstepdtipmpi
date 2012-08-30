type PtStateTransRec = ^tStateTransRec;

function procAddSStateTrans(
	ai, aj, ak: longint; apijk, arijk: double;
	az1i, az2i, aRNSi, az1j, az2j, aRNSj, au1, aku1, av1, av2, akv1, ansgh: longint
  ): longint;
begin
	Result:= procStateTransCnt;
	if arijk = low(longint) then begin
		Exit;
	end;
	procStateTransCnt:= procStateTransCnt + 1;
	Result:= procStateTransCnt;
// добавляет запись к массиву записей процесса
	with procStateTransArr[procStateTransCnt] do begin
		ri    :=i;
		rj    :=j;
		rk    :=k;
		rpijk :=pijk;
		rrijk :=rijk;
		rz1i  :=z1i;
		rz2i  :=z2i;
		rRNSi :=RNSi;
		rz1j  :=z1j;
		rz2j  :=z2j;
		rRNSj :=RNSj;
		ru1   :=u1;
		rKu1  :=Ku1;
		rv1   :=v1;
		rv2   :=v2;
		rKv1  :=Kv1;
		rnsgh :=nsgh;
	end;
{
	procAddStateTransRecord(
      i, j, k, pijk, rijk,
      z1i, z2i, RNSi, z1j, z2j, RNSj,
      u1, Ku1, v1, v2, Kv1, nsgh
	);
}
end;

function AddSStateTransToArr(
	ai, aj, ak: longint; apijk, arijk: double;
	az1i, az2i, aRNSi, az1j, az2j, aRNSj, au1, aku1, av1, av2, akv1, ansgh: longint
  ): longint;
begin
	Result:= StateTransCnt;
	if arijk = low(longint) then begin
		Exit;
	end;
	StateTransCnt:= StateTransCnt + 1;
	Result:= StateTransCnt;
// добавляет запись к массиву записей процесса
//	writeln('AddSStateTransToArr i=', ai); 
	with StateTransArr[StateTransCnt] do begin
		ri    :=ai;
		rj    :=aj;
		rk    :=ak;
		rpijk :=apijk;
		rrijk :=arijk;
		rz1i  :=az1i;
		rz2i  :=az2i;
		rRNSi :=aRNSi;
		rz1j  :=az1j;
		rz2j  :=az2j;
		rRNSj :=aRNSj;
		ru1   :=au1;
		rKu1  :=aKu1;
		rv1   :=av1;
		rv2   :=av2;
		rKv1  :=aKv1;
		rnsgh :=ansgh;
	end;
{
	procAddStateTransRecord(
      i, j, k, pijk, rijk,
      z1i, z2i, RNSi, z1j, z2j, RNSj,
      u1, Ku1, v1, v2, Kv1, nsgh
	);
}
end;

function AddSStateTrans(
	ai, aj, ak: longint; apijk, arijk: double;
	az1i, az2i, aRNSi, az1j, az2j, aRNSj, au1, aku1, av1, av2, akv1, ansgh: longint
  ): longint;
// Todo Параметры не используются
begin
	Result:= StateTransCnt;
	if arijk = low(longint) then begin
		Exit;
	end;
	StateTransCnt:= StateTransCnt + 1;
	Result:= StateTransCnt;
// добавляет XML
	addStateTransNode(
      ai, aj, ak, apijk, arijk,
      az1i, az2i, aRNSi, az1j, az2j, aRNSj,
      au1, aKu1, av1, av2, aKv1, ansgh
	);
end;

function calc_ns(ag, ah: longint):longint;
begin
   	Result:= rsti[ag]*ah;
end;

function procCalc_ns(ag, ah: longint):longint;
begin
   	Result:= procrsti[ag]*ah;
end;

function getJbyRNS(aRNS: longint): longint;
var
	ai: longint;
begin
	Result:=-1;
	for ai:=1 to Ns do
		if RNS[ai]=aRNS then begin
			Result:=ai;
			break;
		end;
end;

function setAllJbyRNS(): boolean;
var
	ai, aj: longint;
begin
// использует XML
{
	stateTransNode:= stateTransRootNode.firstChild;
	for i:=1 to StateTransCnt do begin
		//найти ноду и изменить j
		aj:= getJbyRNS( getIntAttrValue(stateTransNode, 'RNSj', -1) );
		addIntAttribute(stateTransNode, 'j', aj);
		stateTransNode:= stateTransNode.NextSibling;
	end;
}       
	for ai:=1 to StateTransCnt do begin
		//найти ноду и изменить j
		aj:= getJbyRNS(StateTransArr[ai].rRNSj);
		StateTransArr[ai].rj:=aj;
	end;
end;

function calcRNS(az1, az2, anC: longint): longint;
begin
  if ((az1=-1) and (az2=-1)) then               	
    Result:= 0
  else
    Result:= 1 + az1 + (anC+1)*az2;
end;

function AddStateTransForBaseState(): boolean;
begin // i= 1;
	j:= -1000; // не определено
	k:= 1; // только одно немгн
	pijk:= 1; rijk:= 0;

	z1i:=-1; z2i:=-1; RNSi:=calcRNS(z1i, z2i, nC); RNS[i]:= RNSi;
// для немгновенных управлений
	z1j:= 0; z2j:= 0; RNSj:=calcRNS(z1j, z2j, nC);
	Ku1:=1; u1:=0;
// для мгновенных управлений
	Kv1:=0;
	v1:=-1000; // не определено
	v2:=-1000; // не определено
	nsgh:=-1000; // не определено
	
//	StateTransCnt:= AddSStateTrans(
	StateTransCnt:= AddSStateTransToArr(
		i, j, k, pijk, rijk,
		z1i, z2i, RNSi, z1j, z2j, RNSj,
		u1, Ku1, v1, v2, Kv1, nsgh
	);
end;

function calcStateTransOrig(): longint;
// реализация "в лоб" по Синицыну-Бурлакову
begin
//  Result:= 0;
//  M:= ReqTypeCnt;//кол-во заявок

  i:=1; // базовое состояние
  AddStateTransForBaseState();
////////////////////////////////////////////////////////////////////////////////
  for z2:= M downto 1 do begin // по заявкам - показателям
    for z1:=0 to Nc do begin // по ресурсу - количество кусков
     i:= i + 1; {i=2..Ns-1}
  // для немгновенных управлений 2.1
      Ku1:=0;
      u1:=-1000; // не определено
  // для мгновенных управлений 2.2
      pijk:= 1;

      z1i:=z1; z2i:=z2; RNSi:=calcRNS(z1i, z2i, nC); RNS[i]:= RNSi;

      if z2=M then begin
      // переход в базовое состояние 2.2.2
        z1j:= -1; z2j:= -1; RNSj:=calcRNS(z1j, z2j, nC);
        rijk:= 0;
        Kv1:=1; v1:=0; v2:=0;
        k:=1;
        nsgh:=-1000; // не определено

        StateTransCnt:= AddSStateTrans(
          i, j, k, pijk, rijk,
          z1i, z2i, RNSi, z1j, z2j, RNSj,
          u1, Ku1, v1, v2, Kv1, nsgh);
      end // z2=M
      else {z2 < M 2.2.1} begin
        z2j:=z2+1;

        Kv1:=rlmxi[z2j]-rlmni[z2j]+1;
        k:=0;
        // по выделению ресурса на следующую заявку
        for h:= rlmni[z2j] to rlmxi[z2j] do begin
          k:=k+1;
          nsgh:= calc_ns(z2j, h);
          if (z1i + nsgh)<=nC then begin // 2.2.1.1
            z1j:= z1i + nsgh;
            v1:= z2j;
            v2:= h;
            rijk:= rudi[z2j]*h;
          end
          else begin // 2.2.1.2
            z1j:= nC;
            rijk:= low(longint); // чтобы не переходить в это недопустимое сост
            v1:= z2j;
            v2:= h;
          end;
          RNSj:=calcRNS(z1j, z2j, nC);

          StateTransCnt:= AddSStateTrans(
            i, j, k, pijk, rijk,
            z1i, z2i, RNSi, z1j, z2j, RNSj,
            u1, Ku1, v1, v2, Kv1, nsgh);
        end; // of for h
      end; // z2<M

    end; // z1
  end; // z2

//////////////////////////////////////////////////////////////////////////////
  i:=Ns; // исходное состояние
//  z1:= 0;
  z2:= 0;
  z1i:= 0; z2i:= 0; RNSi:=calcRNS(z1i, z2i, nC); RNS[i]:=RNSi;

  // для немгновенных управлений 2.1
  Ku1:=0;
  u1:=-1000; // не определено

  j:= -1000; // не определено
  k:= -1000; // не определено

// для мгновенных управлений 2.2
  pijk := 1;
  z2j := z2 + 1; //!!! - ПРОВЕРИТЬ

  Kv1:=rlmxi[z2j]-rlmni[z2j]+1;
  k:=0;
  for h:= rlmni[z2j] to rlmxi[z2j] do begin
    k:=k+1;
    nsgh:= calc_ns(z2j, h);
    if (z1i + nsgh)<=nC then begin // 2.2.1.1
      z1j:= z1i + nsgh;
      v1:= z2j;
      v2:= h;
      rijk:= rudi[z2j]*h;
    end
    else begin // 2.2.1.2
      z1j:= nC;
      rijk:= low(longint); // чтобы не переходить в это недопустимое сост
      v1:= z2j;
      v2:= h;
    end;
    RNSj:=calcRNS(z1j, z2j, nC);

    StateTransCnt:= AddSStateTrans(
      i, j, k, pijk, rijk,
      z1i, z2i, RNSi, z1j, z2j, RNSj,
      u1, Ku1, v1, v2, Kv1, nsgh);
  end; // of for h
end;

///////////////// Модификация /////////////////////////////////////////
function procAddAllStateTransForOneState(): boolean;
begin
	Kv1:=procrlmxi[z2j]-procrlmni[z2j]+1; // кол-во управлений
	setLength(procStateTransArr, length(procStateTransArr) + Kv1 + 1); // с запасом на все управления, 0й пропускаем

	k:=0; // номер управления
	for h:= procrlmni[z2j] to procrlmxi[z2j] do begin
		k:=k+1;
		// mpi надо передать rsti в каждый процесс 
		nsgh:= procCalc_ns(z2j, h); // необходимый ресурс
		if (z1i + nsgh)<=nC then begin // 2.2.1.1
			z1j:= z1i + nsgh;
			v1:= z2j;
			v2:= h;
			// mpi надо передать rudi в каждый процесс 
			rijk:= procrudi[z2j]*h; // доход от перехода
    	end
		else begin // 2.2.1.2
			z1j:= nC;
			rijk:= low(longint); // чтобы не переходить в это недопустимое сост
			v1:= z2j;
			v2:= h;
		end;
		RNSj:=calcRNS(z1j, z2j, nC);
		// mpi добавлять в локальный массив фазовых переходов для процесса
		// mpi накапливать локальный StateTransCnt для процесса
		procStateTransCnt:= procAddSStateTrans(
			i, j, k, pijk, rijk,
			z1i, z2i, RNSi, z1j, z2j, RNSj,
			u1, Ku1, v1, v2, Kv1, nsgh);

	end; // of for h

	setLength(procStateTransArr, procStateTransCnt+1); // оставляем только добавленные управления. 0й пропускаем
end;

function AddAllStateTransForOneState(): boolean;
// добавить все переходы для одного сотояния
begin
	// mpi надо передать rlmxi, rlmni в каждый процесс

	Kv1:=rlmxi[z2j]-rlmni[z2j]+1; // кол-во управлений
	setLength(StateTransArr, length(StateTransArr) + Kv1 + 1); // с запасом на все управления, 0й пропускаем

	k:=0; // номер управления
	for h:= rlmni[z2j] to rlmxi[z2j] do begin
		k:=k+1;
		// mpi надо передать rsti в каждый процесс 
		nsgh:= calc_ns(z2j, h); // необходимый ресурс
		if (z1i + nsgh)<=nC then begin // 2.2.1.1
			z1j:= z1i + nsgh;
			v1:= z2j;
			v2:= h;
			// mpi надо передать rudi в каждый процесс 
			rijk:= rudi[z2j]*h; // доход от перехода
    	end
		else begin // 2.2.1.2
			z1j:= nC;
			rijk:= low(longint); // чтобы не переходить в это недопустимое сост
			v1:= z2j;
			v2:= h;
		end;
		RNSj:=calcRNS(z1j, z2j, nC);
		// mpi добавлять в локальный массив фазовых переходов для процесса
		// mpi накапливать локальный StateTransCnt для процесса
//		StateTransCnt:= AddSStateTrans(
		StateTransCnt:= AddSStateTransToArr(
			i, j, k, pijk, rijk,
			z1i, z2i, RNSi, z1j, z2j, RNSj,
			u1, Ku1, v1, v2, Kv1, nsgh);
	end; // of for h

	setLength(StateTransArr, StateTransCnt+1); // оставляем только добавленные управления. 0й пропускаем
end;

function AddAllStateTransToBaseState(): boolean;
// добавить все переходы В базовое состояния j = 1
begin
	z2:= M;
    for z1:=0 to Nc do begin // по ресурсу - количество кусков
		i:= i + 1; {i=2..Ns-1}
// для немгновенных управлений 2.1
	    Ku1:=0; u1:=-1000; // не определено
// для мгновенных управлений 2.2
		pijk:= 1;
		z1i:=z1; z2i:=z2; RNSi:=calcRNS(z1i, z2i, nC); RNS[i]:= RNSi;
//		if z2=M then begin
		// переход в базовое состояние 2.2.2
        z1j:= -1; z2j:= -1; RNSj:=calcRNS(z1j, z2j, nC);
        rijk:= 0;
        Kv1:=1; v1:=0; v2:=0;
		// только 1
        k:=1;
        nsgh:=-1000; // не определено

//        StateTransCnt:= AddSStateTrans(
        StateTransCnt:= AddSStateTransToArr(
			i, j, k, pijk, rijk,
			z1i, z2i, RNSi, z1j, z2j, RNSj,
			u1, Ku1, v1, v2, Kv1, nsgh);
//      end // z2=M
	end;
end;

function AddAllStateTransForInitialState(): boolean;
// добавить все переходы для исходного состояния
begin
	i:= Ns; // исходное состояние
	z1i:= 0; z2i:= 0; RNSi:=calcRNS(z1i, z2i, nC); RNS[i]:=RNSi;

	// для немгновенных управлений 2.1
	Ku1:=0; u1:=-1000; // не определено

	j:= -1000; // не определено
	k:= -1000; // не определено

	// для мгновенных управлений 2.2
	pijk := 1;
	z2j := 1;

	AddAllStateTransForOneState();
end;


function InitProcStateTrans(): boolean;
// подготовка данных для расчета
// разослать общие данные M кол-во заявок, Nc кол-во порций ресурса, Ns кол-во состояний
// рассчитать кол-во заявок, которые обрабатывает каждый процесс. сохранить в массив. разослать
var
	restM, ai: longint;	
    buf: pointer;
	bufsize: longint;
begin
	// общие данные	

	writeln('InitProcStateTrans before first bcast'); 
	writeln(Format('MPI_INT=%d', [MPI_INT])); 
    
	MPI_BCAST(@M, 1, MPI_INT, 0, MPI_COMM_WORLD);
	writeln(myid, format(' M=%d', [M]) );
	writeln('InitProcStateTrans after first bcast'); 

	MPI_BCAST(@Nc, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_BCAST(@Ns, 1, MPI_INT, 0, MPI_COMM_WORLD);
	writeln('InitProcStateTrans after last bcast'); 

	// расчет кол-ва заявок для процесса
    if myid = 0 then begin
		setLength(procMArr, numprocs);
		setLength(procUpMArr, numprocs);

		procM:= (M-1) div numprocs; //M-1 потому как для Mю заявку считаем отдельно
		writeln(myid, format(' M=%d, procM=%d, numprocs=%d', [M, procM, numprocs]) );

		procUpM:= M-1;
		if ((M-1) mod numprocs) > 0 then begin // заявки нацело НЕ делятся по процессам
			inc(procM);
		    restM:= M-1;
			for ai:=0 to numprocs-1 do begin
				if restM < 0  then
					procMArr[ai]:=0
				else if restM > procM then
					procMArr[ai]:= procM
				else
					procMArr[ai]:= restM;
				restM:= restM - procM;
				procUpMArr[ai]:=procUpM;
				procUpM:= procUpM - procMArr[ai];//дубль с restM

//				writeln(myid, format(' 1 procMArr[%d]=%d ', [ai, M]) );
			end;
		end
		else begin // заявки нацело делятся по процессам 
			for ai:=0 to numprocs-1 do begin
				procMArr[ai]:=procM;
				procUpMArr[ai]:=procUpM;
				procUpM:= procUpM - procMArr[ai];
//				writeln(myid, format(' 2 procMArr[%d]=%d ', [ai, procMArr[ai]]) );
			end;
		end;
//		procUpM:= M-1;
	end;

	// рассылка кол-ва заявок по процессам
	if myid=0 then begin
		writeln(myid, format(' send procM=%d ', [procMArr[0]]) );
	end;
	MPI_SCATTER(@procMArr[0], 1, MPI_INT, @procM, 1, MPI_INT, 0, MPI_COMM_WORLD);
	writeln(myid, format(' recv procM=%d ', [procM]) );

{	bufsize := SizeOf(longint) + MPI_BSEND_OVERHEAD;
	getMem(buf, bufsize);
	MPI_BUFFER_ATTACH(buf, bufsize);
	if myid = 0 then
		for ai:=0 to numprocs-1 do begin
//            writeln('procMArr[ai] ', procMArr[ai], ' before MPI_BSEND(@procMArr[ai], 1, MPI_INT, ai, teg, MPI_COMM_WORLD) 1'); 

//			MPI_SEND(@procMArr[ai], 1, MPI_INT, ai, teg, MPI_COMM_WORLD);

			MPI_BSEND(@procMArr[ai], 1, MPI_INT, ai, teg, MPI_COMM_WORLD);


//            writeln('after MPI_BSEND(@procMArr[ai], 1, MPI_INT, ai, teg, MPI_COMM_WORLD) 1'); 
		end;

	// получение кол-ва заявок по процессам
//    writeln(myid, ' before MPI_RECV(@procM, 1, MPI_INT, 0, teg, MPI_COMM_WORLD, status) 1'); 
	MPI_RECV(@procM, 1, MPI_INT, 0, teg, MPI_COMM_WORLD, status);
    writeln(myid, 'procM ', procM, ' after MPI_RECV(@procM, 1, MPI_INT, 0, teg, MPI_COMM_WORLD, status) 1'); 
//	MPI_BUFFER_DETACH(buf, @bufsize);
//	freeMem(buf, bufsize);
//	writeln(myid, '| procM = ', procM);
}
	// рассылка начального номера заявки по процессам
	if myid=0 then begin
		writeln(myid, format(' send procUpM=%d ', [procUpMArr[0]]) );
	end;
	MPI_SCATTER(@procUpMArr[0], 1, MPI_INT, @procUpM, 1, MPI_INT, 0, MPI_COMM_WORLD);
	writeln(myid, format(' recv procUpM=%d ', [procUpM]) );
{
	if myid = 0 then begin
		tprocUpM:= M-1;
		for ai:= 0 to numprocs-1 do begin
			writeln(myid, format(' send tprocUpM=%d ', [tprocUpM]) );
			MPI_BSEND(@tprocUpM, 1, MPI_INT, ai, teg, MPI_COMM_WORLD);
			tprocUpM:= tprocUpM - procMArr[ai];
		end;
	end;

	// получение начального номера заявки по процессам
	MPI_RECV(@procUpM, 1, MPI_INT, 0, teg, MPI_COMM_WORLD, status);
	writeln(myid, format(' recv procUpM=%d ', [procUpM]) );
}
	procDownM:= procUpM - procM + 1;
	writeln(myid, '| procUpM = ', procUpM, ' procDownM = ', procDownM, ' procM = ', procM);

//	MPI_BUFFER_DETACH(buf, @bufsize);
//	freeMem(buf, bufsize);


	// инициализация данных для процесса
	setLength(procrlmxi, M+1);
	setLength(procrlmni, M+1);
	setLength(procrsti, M+1);
	setLength(procrudi, M+1);
//	setLength(procrxi, M+1);
//	setLength(procrqi, M+1);
	
	// рассылка данных для расчета в процессе
	bcast_arrInt(rlmxi, procrlmxi);
	bcast_arrInt(rlmni, procrlmni);
	bcast_arrInt(rsti, procrsti);
	bcast_arrDbl(rudi, procrudi);
//	writeln(myid, '| Init| Ok');
end;

function FinalizeProcStateTrans():boolean;
begin
	setLength(procrlmxi, 0);
	setLength(procrlmni, 0);
	setLength(procrsti, 0);
	setLength(procrudi, 0);
	setLength(procrxi, 0);
	setLength(procrqi, 0);

	if myid = 0 then begin
		setLength(procMArr, 0);
		setLength(procUpMArr, 0);
	end;
end;


// v1 
{
function packProcStateTransArr(aarr : array of tStateTransRec; abuf: pointer): boolean;
var
	ai: longint;
//	acur_buf, acur_buf1: pointer;
	acur_buf: ^tStateTransRec;
begin
	writeln('in packProcStateTransArr');
	for ai:=1 to length(aarr)-1 do begin
		acur_buf:=abuf+(sizeOfStateTransRec*(ai-1)); // смещение на всю запись
        acur_buf^:= aarr[ai];
	end;
	writeln('out packProcStateTransArr');

end;
}

// v2
function packProcStateTransArr(aarrptr : PtStateTransRec; aarrlen: longint; abuf: pointer): boolean;
var
	ai: longint;
	acur_buf: PtStateTransRec;
begin
	writeln('in packProcStateTransArr');
	for ai:=1 to aarrlen - 1 do begin
		acur_buf:=abuf+(sizeOfStateTransRec*(ai-1)); // смещение на всю запись
        acur_buf^:= (aarrptr + ai - 1)^;
	end;
	writeln('out packProcStateTransArr');
end;


function unpackProcStateTransArr(abuf: pointer; aRecCnt: longint): boolean;
var
	ai: longint;
	acur_buf: ^tStateTransRec;
begin
	// увеличить размер массива StateTransArr
//	writeln('old length(StateTransArr) = ', length(StateTransArr), 'new length = ', length(StateTransArr) + aRecCnt);
	setLength(StateTransArr, length(StateTransArr) + aRecCnt);

	for ai:=1 to aRecCnt do begin
		acur_buf:=abuf+(sizeOfStateTransRec*(ai-1)); // смещение на всю запись
{
	writeln(myid, '| i = ', acur_buf^.ri
				, ' j = ', acur_buf^.rj
				, ' k = ', acur_buf^.rk );
}
//        StateTransCnt:= AddSStateTrans(
        StateTransCnt:= AddSStateTransToArr(
			acur_buf^.ri, acur_buf^.rj, acur_buf^.rk, acur_buf^.rpijk, acur_buf^.rrijk,
			acur_buf^.rz1i, acur_buf^.rz2i, acur_buf^.rRNSi, acur_buf^.rz1j, acur_buf^.rz2j, acur_buf^.rRNSj,
			acur_buf^.ru1, acur_buf^.rKu1, acur_buf^.rv1, acur_buf^.rv2, acur_buf^.rKv1, acur_buf^.rnsgh
		);
	end;
end;

function calcStateTransModified(): longint;
// реализация "многопроцессорная" модификация - Степанюк
var
	startI: Longint; 
	ai,aj: longint;
	procStateTransSendBufSize, procStateTransRecvBufSize: longint;
	procStateTransSendBuf, procStateTransRecvBuf: pointer;

	acur_buf: ^longint;
	sendCnt, recvCnt: longint;
	SendBufSize, RecvBufSize: longint;
	SendBuf, RecvBuf: pointer;
    buf: pointer;
	bufsize: longint;

	tempStateTransCnt: longint;
begin
	if myid = 0 then begin
		// пропускаем 0й - 1шт, TransForBaseState - 1шт, AllStateTransToBaseState - Nc+1шт
		setLength(StateTransArr, 1 + 1 + (Nc+1));
		i:= 1;
		AddStateTransForBaseState();
		// j:= 1. все переходы В базовое состояние 2.2.2. Для оптимизации вынесено из цикла (убрано условие в цикле) 
		AddAllStateTransToBaseState();

		tempStateTransCnt:= StateTransCnt;
//		setLength(StateTransArr, StateTransCnt + 1);// пропускаем 0й

	    startStateTransMPI:= MPI_Wtime;
	end;

	// 1 посчитать количество заявок для процесса procM
	// разослать procM
	// разослать procData: proclmxi, proclmni, procrsti, procrudi
//    startTemp:= MPI_Wtime; 
	InitProcStateTrans();
//	endTemp:= MPI_Wtime;
//	writeln(myid, '| InitProcStateTrans ', endTemp - startTemp: 9:6);
//    startTemp:= endTemp;
	// выполнит цикл расчета для каждого процесса
	// 2 основной цикл переходов z2<M
//	for z2:= M-1 downto 1 do begin // по заявкам - показателям
	startI:= 1 + Nc + 1 + ((Nc+1)*(M-1 - procUpM));
	setLength(procRNS, procM*(Nc+1) + 1); //0й пропукскаем
	i:= startI;// пропустили обработанные другими процессами
	procStateTransCnt:=0;
	for z2:= procUpM downto procDownM do begin // по заявкам - показателям
		// mpi по z2 - можно посчитать шаг для процесса как ф-ция от номера процесса
		z2j:=z2+1;

		for z1:=0 to Nc do begin // по ресурсу - количество кусков
			// mpi инкриментируется линейно -> можно посчитать шаг для процесса
			// для каждого значения z2 делаем Nc+1 инкремент -> надо передать Nc

			i:= i + 1; {i=1+Nc..Ns-1, кроме переходов: из базового сост 1шт, в базовое сост Nc шт, и из исходного сост}
//			writeln(myid, '| i ', i);
			// для немгновенных управлений 2.1
			Ku1:=0; u1:=-1000; // не определено
			// для мгновенных управлений 2.2
			pijk:= 1;

			z1i:=z1; z2i:=z2; RNSi:=calcRNS(z1i, z2i, nC); 
			// mpi добавление RNS - вернуть от каждого процесса

			procRNS[i-startI]:= RNSi; //RNS[i]:= RNSi;
			// переход в базовое состояние 2.2.2 добавлены в AddAllStateTransToBaseState
			// {z2 < M 2.2.1}
			// z2j:=z2+1;// вынесено под for z2 ...
			procAddAllStateTransForOneState();
		end; // z1
	end; // z2
	// mpi - собрать локальные массивы фазовых переходов из процессов
//	endTemp:= MPI_Wtime;
//	writeln(myid, '| StateTrans main Cycle ', endTemp - startTemp: 9:6);
//    startTemp:= endTemp;

	// 3 вернуть в главный процесс
	// - кол-во переходов procStateTransCnt
	// - массив переходов procStateTransArr
	// - массив procRNS
    	startTemp1:= MPI_Wtime;

	// - кол-во переходов procStateTransCnt
	if myid = 0 then begin
		setLength(procStateTransCntArr, numprocs);
	end;
	writeln(myid, format('| procStateTransCnt = %d', [ procStateTransCnt ] ));
   	MPI_GATHER(@procStateTransCnt, 1, MPI_INT, @procStateTransCntArr[myid], 1, MPI_INT, 0, MPI_COMM_WORLD);
	if myid = 0 then begin
		writeln(myid, format('| procStateTransCntArr[%d] = %d', [ myid, procStateTransCntArr[0] ] ));
	end;

{
	MPI_SEND(@procStateTransCnt, 1, MPI_INT, 0, teg, MPI_COMM_WORLD);
	if myid = 0 then begin
		setLength(procStateTransCntArr, numprocs);
		for ai:=0 to numprocs-1 do begin
			MPI_RECV(@procStateTransCntArr[ai], 1, MPI_INT, ai, teg, MPI_COMM_WORLD, status);
//			writeln(myid, '| procStateTransCntArr[', ai, '] = ', procStateTransCntArr[ai]);
		end;
	end;
}
//		endTemp1:= MPI_Wtime;
//		writeln(myid, '| MPI_BSEND(procStateTrans: MPI_RECV(@procStateTransCntArr[ai] ', endTemp1 - startTemp1: 9:6);
//    	startTemp1:= endTemp1;

	// - массив переходов procStateTransArr
    procStateTransSendBufSize := procStateTransCnt*sizeOfStateTransRec;
	try
		getMem(procStateTransSendBuf, procStateTransSendBufSize);

//		endTemp1:= MPI_Wtime;
//		writeln(myid, '| MPI_BSEND(procStateTrans: getMem(procStateTransSendBuf ', endTemp1 - startTemp1: 9:6);
//    	startTemp1:= endTemp1;

//writeln(myid, '| before packProcStateTransArr');
		writeln('before packProcStateTransArr ' +
          'with cnt=' + IntToStr(procStateTransCnt) + ' and size = ' + IntToStr(procStateTransSendBufSize));
//v1		packProcStateTransArr(procStateTransArr, procStateTransSendBuf);
//v2
		packProcStateTransArr(
          Addr(procStateTransArr[Low(procStateTransArr)]), 
          Length(procStateTransArr),
          procStateTransSendBuf);
		writeln('after packProcStateTransArr');

//		endTemp1:= MPI_Wtime;
//		writeln(myid, '| MPI_BSEND(procStateTrans: packProcStateTransArr ', endTemp1 - startTemp1: 9:6);
//    	startTemp1:= endTemp1;

//writeln(myid, '| after packProcStateTransArr', ' procStateTransSendBufSize = ', procStateTransSendBufSize);
//        MPI_buffer_attach
		bufsize:=procStateTransSendBufSize + 2*MPI_BSEND_OVERHEAD;
		getMem(buf, bufsize);

//		endTemp1:= MPI_Wtime;
//		writeln(myid, '| MPI_BSEND(procStateTrans: getMem(buf for MPI_BUFFER_ATTACH ', endTemp1 - startTemp1: 9:6);
//    	startTemp1:= endTemp1;

		MPI_BUFFER_ATTACH(buf, bufsize);
		MPI_BSEND(procStateTransSendBuf, procStateTransSendBufSize, MPI_BYTE, 0, teg, MPI_COMM_WORLD);

//		endTemp1:= MPI_Wtime;
//		writeln(myid, '| MPI_BSEND(procStateTrans: MPI_BSEND(procStateTransSendBuf ', endTemp1 - startTemp1: 9:6);
//    	startTemp1:= endTemp1;
//writeln(myid, '| after MPI_SEND(procStateTransSendBuf');
//readln();
//writeln(myid, '| before if myid = 0');
		if myid = 0 then
			for ai:=0 to numprocs-1 do begin
			    procStateTransRecvBufSize:= procStateTransCntArr[ai]*sizeOfStateTransRec;
//writeln(myid, '| before getMem(procStateTransRecvBuf');
				getMem(procStateTransRecvBuf, procStateTransRecvBufSize);

//		endTemp1:= MPI_Wtime;
//		writeln(myid, '| MPI_BSEND(procStateTrans: getMem(procStateTransRecvBuf ', endTemp1 - startTemp1: 9:6);
//    	startTemp1:= endTemp1;

				try
//writeln(myid, '| before MPI_RECV(procStateTransRecvBuf');
					MPI_RECV(procStateTransRecvBuf, procStateTransRecvBufSize, MPI_BYTE, ai, teg, MPI_COMM_WORLD, status);

//		endTemp1:= MPI_Wtime;
//		writeln(myid, '| MPI_BSEND(procStateTrans: MPI_RECV(procStateTransRecvBuf ', endTemp1 - startTemp1: 9:6);
//    	startTemp1:= endTemp1;

//writeln(myid, '| before unpackProcStateTransArr');
					unpackProcStateTransArr(procStateTransRecvBuf, procStateTransCntArr[ai]);

//		endTemp1:= MPI_Wtime;
//		writeln(myid, '| MPI_BSEND(procStateTrans: unpackProcStateTransArr(procStateTransRecvBuf ', endTemp1 - startTemp1: 9:6);
//    	startTemp1:= endTemp1;
				finally
					freeMem(procStateTransRecvBuf, procStateTransRecvBufSize);
				end;
			end;
	finally
//		MPI_BUFFER_DETACH(buf, bufsize);
		MPI_BUFFER_DETACH(buf, @bufsize);
		freeMem(buf, bufsize);
		freeMem(procStateTransSendBuf, procStateTransSendBufSize);
	end;

//		endTemp1:= MPI_Wtime;
//		writeln(myid, '| MPI_BSEND(procStateTrans: freeMem(procStateTransSendBuf ', endTemp1 - startTemp1: 9:6);
//    	startTemp1:= endTemp1;

//	endTemp:= MPI_Wtime;
//	writeln(myid, '| MPI_BSEND(procStateTrans ', endTemp - startTemp: 9:6);
//    startTemp:= endTemp;

	// - массив procRNS
//	writeln(myid, '| before procRNS');
	sendCnt:= procM*(Nc+1); //0й пропускаем . д.б равно length(procRNS)-1
//	sendBuf, recBuf: pointer;
	sendBufSize:= sizeOfLongint*sendCnt;
	try
		getMem(sendBuf, sendBufSize);
//		for ai:=1 to sendCnt do
//			writeln('procRNS[', ai, '] = ', procRNS[ai]);			
		pack_arrInt(procRNS, sendBuf);

		if myid = 0 then begin
//				recvBufSize:= sizeOfLongint*recvCnt;
//			bufsize:= sizeOfLongint*recvCnt;
//			getMem(buf, bufsize);
//			MPI_BUFFER_ATTACH(buf, bufsize);
		end;
		bufsize:= sizeOfLongint*recvCnt;
		getMem(buf, bufsize);
		MPI_BUFFER_ATTACH(buf, bufsize);

		MPI_BSEND(sendBuf, sendCnt, MPI_INT, 0, teg, MPI_COMM_WORLD);

		if myid = 0 then begin
			procUpM:= M-1;
    		for ai:=0 to numprocs-1 do begin
				recvCnt:= procMArr[ai]*(Nc+1);
				recvBufSize:= sizeOfLongint*recvCnt;
				try
					getMem(recvBuf, recvBufSize);
					MPI_RECV(recvBuf, recvCnt, MPI_INT, ai, teg, MPI_COMM_WORLD, status);
					// добавить из буфера в RNS
					startI:= 1 + (Nc + 1) + ((Nc+1)*(M-1-procUpM));
//					for aj:= 1 to length(aa)-1 do begin	// пропускаем 0й элемент
					for aj:= 1 to procMArr[ai]*(Nc+1) do begin	// пропускаем 0й элемент
						acur_buf:= recvBuf+(sizeOfLongint*(aj-1));
						RNS[startI+aj]:= acur_buf^;
//						writeln('RNS[', startI+aj,'] = ', acur_buf^);
					end;
				finally
					freeMem(recvBuf, recvBufSize);
				end;
				procUpM:= procUpM - procMArr[ai];
			end;
//			MPI_BUFFER_DETACH(buf, @bufsize);
//			freeMem(buf, bufsize);
		end;
			MPI_BUFFER_DETACH(buf, @bufsize);
			freeMem(buf, bufsize);
	finally
		freeMem(sendBuf, sendBufSize);
	end;

//	endTemp:= MPI_Wtime;
//	writeln(myid, '| MPI_SEND procRNS ', endTemp - startTemp: 9:6);
//  startTemp:= endTemp;

	FinalizeProcStateTrans();
	setLength(procRNS, 0); 
	setLength(procStateTransArr, 0); 
	if myid = 0 then
		setLength(procStateTransCntArr, 0);

//	endTemp:= MPI_Wtime;
//	writeln(myid, '| FinalizeProcStateTrans ', endTemp - startTemp: 9:6);
//    startTemp:= endTemp;


	//i:=Ns; добавить все переходы для исходного состояния
	if myid = 0 then begin
	    endStateTransMPI:= MPI_Wtime;
		totalStateTransMPI:=totalStateTransMPI + endStateTransMPI-startStateTransMPI;
		writeln(myid, '| totalStateTransMPI ', totalStateTransMPI: 9:6);

		//Скопировать в ноды от номера перед главным циклом до текущего
//		writeln('tempStateTransCnt+1 = ', tempStateTransCnt+1
//			, ' StateTransCnt = ', StateTransCnt
//			, ' length(StateTransArr) = ', length(StateTransArr));

//		setLength(StateTransArr, 0);

//		writeln(' before AddAllStateTransForInitialState ');

		AddAllStateTransForInitialState();

		setAllJbyRNS();

		for ai:= 1 to StateTransCnt do begin
			with StateTransArr[ai] do begin
				addStateTransNode(
    			  ri, rj, rk, rpijk, rrijk,
	    		  rz1i, rz2i, rRNSi, rz1j, rz2j, rRNSj,
			      ru1, rKu1, rv1, rv2, rKv1, rnsgh
				);
			end;
		end;

		// Перенесен в Main
//		setLength(StateTransArr, 0);
//		writeln(' after AddAllStateTransForInitialState ');
	end;
end;
