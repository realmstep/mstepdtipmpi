var
//    ArrV: array of TStepArrayOfDbl; // веса. индексы: шаг, сост
//    ArrD: array of TStepArrayOfInt; //оптим.упр.индексы: шаг, упр
//    arrG: TStepArrayOfDbl; //усредненный шаговый доход
    ArrVCurrStep: array of Double; // веса. индексы: сост
    ArrDCurrStep: array of longint; //оптим.упр.индексы: упр
    ArrDCurrStepTemp: array of longint; //оптим.упр.индексы: упр
    ArrVPrevStep: array of Double; // веса. индексы: сост
    ArrDPrevStep: array of longint; //оптим.упр.индексы: упр
    arrG: array of Double; //усредненный шаговый доход
    currStep: longint;
    MaxStepCnt: longint; // Количество шагов. Есть еще нулевой шаг. Д.б. динамическим.

    procArrVCurrStep: array of Double; // веса. индексы: сост
    procArrDCurrStep: array of longint; //оптим.упр.индексы: упр
    procArrDCurrStepTemp: array of longint; //оптим.упр.индексы: упр
    procArrVPrevStep: array of Double; // веса. индексы: сост
//    procArrDPrevStep: array of longint; //оптим.упр.индексы: упр
	procSubArrVDispl, procSubArrDDispl: longint;
	procSubArrDDisplTemp: longint;
	procSubArrVDispls, procSubArrDDispls: array of longint;
	procSubArrDDisplsTemp: array of longint;
	sendSubArrVBufSize, sendSubArrDBufSize: longint;
	sendSubArrVBuf, sendSubArrDBuf: pointer;
	recvSubArrVBufSize, recvSubArrDBufSize: longint;
	recvSubArrVBuf, recvSubArrDBuf: pointer;
	aproc, ap: longint;
	str: string;

function IsSolved(): longint;
begin
  Result := 0;
  if currStep = MaxStepCnt then
  begin
    Result := -1;
  end;
  if currStep > 1 then
    if ( ( abs(arrG[currStep] - arrG[currStep - 1]) ) <
       ( 0.01 * abs(arrG[currStep - 1]) ) ) then
      Result := 1;
end;

// передать данные и вынести в XML
function addOsnNode():boolean;
var
	ai, ires: longint;
	dres: double;
	astr: string;
begin
	if not addOsnSteps then exit;

	osnStepNode:=aDoc.CreateElement('osnStepNode');

	addIntAttribute(osnStepNode, 'n1', currStep);
	addDblAttribute(osnStepNode, 'g_n1', arrG[currStep]);

	astr:='d=';
	for ai:=low(ArrDCurrStep)+1 to high(ArrDCurrStep) do begin // пропускаем 0й
		ires:= ArrDCurrStep[ai];
		astr:= astr + Format('%4d',[ires]) + ';';
	end;
	commentNode:=aDoc.CreateComment(astr);
	osnStepNode.AppendChild(commentNode);

	astr:='v=';
	for ai:=low(ArrVcurrStep)+1 to high(ArrVcurrStep) do begin // пропускаем 0й
		dres:=ArrVcurrStep[ai];
		astr:= astr + Format('%4f',[dres]) + ';';
	end;
	commentNode:=aDoc.CreateComment(astr);
	osnStepNode.AppendChild(commentNode);

	ires := IsSolved();
	if iRes  = 1 then begin
//    s:= 'Достигнута точность 0.01 по g. Вычисления остановлены.';
	    astr:= 'done. delta(g)<0.001';
		addStrAttribute(osnStepNode, 'result', astr);
	end
	else if iRes = -1 then begin
//  s:= 'Превышено максимальное количество шагов (' + IntToStr(MaxStepCnt) + ')' + 'Вычисления остановлены.'
	    astr:= 'stopped on MaxStepCnt' + IntToStr(MaxStepCnt);
		addStrAttribute(osnStepNode, 'result', astr);
	end;
		
	osnStepRootNode.AppendChild(osnStepNode);
end;


function Calc_qijk: boolean;
// расчет непосредственного дохода
// !!!совмещен с setAllJbyRNS()
var
	aVal: double;
	aNextNode: TDOMNode;
	ai, aj: longint;
begin
// qik=sum_po_j(pijk*rijk) сумма призведений дохода от перехода из и в j при к-м управлении
//  for j:=1 to Ns do begin
//    Result:= Result + Arr
//  end;

// поскольку 1) для каждого i есть только одно сост j куда переходить при к-м управлении
// 2) вероятность перехода =1
// то qijk==rijk
// удобнее просто перебрать все фазовые переходы
// использует XML
{	aNextNode:= stateTransRootNode.firstChild;
//	acnt:= 0;
	repeat
//		inc(acnt);
//		if acnt> StateTransCnt then break;
		aval:= getDblAttrValue(aNextNode, 'rijk', -1);
		addDblAttribute(aNextNode, 'qijk', aVal);
		aNextNode:= aNextNode.NextSibling;
	until not assigned(aNextNode);
}

	for ai:=1 to StateTransCnt do begin
		//найти ноду и изменить j
		StateTransArr[ai].rqijk:= StateTransArr[ai].rrijk;
	end;

// использует XML
// вывод в xml
	if not addStateTrans then exit;
	aNextNode:= stateTransRootNode.firstChild;
	ai:= 0;
	repeat
		inc(ai);
		if ai> StateTransCnt then break;
		aval:= StateTransArr[ai].rqijk;//getDblAttrValue(aNextNode, 'rijk', -1);
		addDblAttribute(aNextNode, 'qijk', aVal);
		aNextNode:= aNextNode.NextSibling;
	until not assigned(aNextNode);

end;

function InitDataArr(): boolean;
var
	aNextNode: TDOMNode;
	ai, aiCurrent, ak, akv1, aval: longint;
begin
	SetLength(ArrJ, Ns+1);
	SetLength(ArrR, Ns+1);
	SetLength(ArrQ, Ns+1);
	SetLength(ArrKv1, Ns+1);
	aNextNode:= stateTransRootNode.firstChild;
	aiCurrent:=low(longint);
	repeat
		ai:= getIntAttrValue(aNextNode, 'i', -1);
		if ai <> aiCurrent then begin
			aiCurrent:= ai;
			akv1:= getIntAttrValue(aNextNode, 'kv1', -1);
			if akv1=0 then
				akv1:= getIntAttrValue(aNextNode, 'ku1', -1);
			setLength(ArrJ[aiCurrent], akv1+1);
			setLength(ArrR[aiCurrent], akv1+1);
			setLength(ArrQ[aiCurrent], akv1+1);
			ArrKv1[aiCurrent]:= akv1; //для поиска kv1
		end;
		ak:=getIntAttrValue(aNextNode, 'k', -1);
//		if akv1<1 then 
//			readln();
		ArrJ[aiCurrent, ak]:= getIntAttrValue(aNextNode, 'j', -1);
		ArrR[aiCurrent, ak]:= getDblAttrValue(aNextNode, 'rijk', -1);
		ArrQ[aiCurrent, ak]:= getDblAttrValue(aNextNode, 'qijk', -1);
//		writeln('ai ', ai, ' akv1 ', akv1, ' ak ', ak
//				, ' ArrJ ', ArrJ[aiCurrent, ak], ' ArrR ', ArrR[aiCurrent, ak]:9:6, ' ArrQ ', ArrQ[aiCurrent, ak]:9:6);

		aNextNode:= aNextNode.NextSibling;
	until not assigned(aNextNode);
end;

function InitDataArrv2(): boolean;
var
//	aNextNode: TDOMNode;
	asttr, ai, aiCurrent, ak, akv1, aval: longint;
begin
	SetLength(ArrJ, Ns+1);
	SetLength(ArrR, Ns+1);
	SetLength(ArrQ, Ns+1);
	SetLength(ArrKv1, Ns+1);

	aiCurrent:=low(longint);
	asttr:=1;
	repeat
		ai:= StateTransArr[asttr].ri;
		if ai <> aiCurrent then begin
			aiCurrent:= ai;
			akv1:= StateTransArr[asttr].rkv1;
			if akv1=0 then
				akv1:= StateTransArr[asttr].rku1;
			setLength(ArrJ[aiCurrent], akv1+1);
			setLength(ArrR[aiCurrent], akv1+1);
			setLength(ArrQ[aiCurrent], akv1+1);
			ArrKv1[aiCurrent]:= akv1; //для поиска kv1
		end;
		ak:=StateTransArr[asttr].rk;
		ArrJ[aiCurrent, ak]:= StateTransArr[asttr].rj;//getIntAttrValue(aNextNode, 'j', -1);
		ArrR[aiCurrent, ak]:= StateTransArr[asttr].rrijk;//getDblAttrValue(aNextNode, 'rijk', -1);
		ArrQ[aiCurrent, ak]:= StateTransArr[asttr].rqijk;//getDblAttrValue(aNextNode, 'qijk', -1);
//		writeln('ai ', ai, ' akv1 ', akv1, ' ak ', ak
//				, ' ArrJ ', ArrJ[aiCurrent, ak], ' ArrR ', ArrR[aiCurrent, ak]:9:6, ' ArrQ ', ArrQ[aiCurrent, ak]:9:6);
		inc(asttr);
	until asttr>StateTransCnt;
end;

function FinalizeDataArr(): boolean;
var
	ai: longint;
begin
//	writeln('start FinalizeDataArr');
//	readln;
	for ai:= 0 to Length(ArrJ)-1 do
		SetLength(ArrJ[ai], 0);	
	SetLength(ArrJ, 0);	

	for ai:= 0 to Length(ArrR)-1 do
		SetLength(ArrR[ai], 0);	
	SetLength(ArrR, 0);	

	for ai:= 0 to Length(ArrQ)-1 do
		SetLength(ArrQ[ai], 0);	
	SetLength(ArrQ, 0);	

	SetLength(ArrKv1, 0);	
//	writeln('end FinalizeDataArr');
//	readln;
end;

function InitOsnShema: boolean;
var
  ai, aj: longint;
begin
//  Result := 0;
//Инициализация
	MaxStepCnt := 100;

	SetLength(ArrVCurrStep, Ns+1); // пропускаем 0й
	SetLength(ArrVPrevStep, Ns+1); // пропускаем 0й
//	writeln('SetLength(ArrVCurrStep, Ns ', Ns);
//	for ai := Low(ArrV) To High(ArrV) do
//		SetLength(ArrV[ai], MaxStepCnt+1); //!!! место для оптимизации -
    // можно инициализацию и размер менять по ходу расчёта со всеми прочими
    // прибамбасами c инициализацией порциями наперёд
	SetLength(ArrDCurrStep, Ns+1); // пропускаем 0й
	SetLength(ArrDcurrStepTemp, Ns+1); // пропускаем 0й
	
	SetLength(ArrDPrevStep, Ns+1); // пропускаем 0й
//	writeln('SetLength(ArrDCurrStep, Ns ', Ns);
//	for ai := Low(ArrD) To High(ArrD) do
//		SetLength(ArrD[ai], MaxStepCnt+1); //!!! место для оптимизации -
    // можно инициализацию и размер менять по ходу расчёта со всеми прочими
    // прибамбасами c инициализацией порциями наперёд
	SetLength(ArrG, MaxStepCnt+1);


// массивы весов и управлений для 0-го шага
	currStep:=0;
	for ai:=1 to Ns do begin
		ArrVCurrStep[ai]:=0; // веса. индексы: шаг, сост
		ArrDCurrStep[ai]:=0; // оптим.упр.индексы: шаг, упр
//		ArrVprevStep[ai-1]:=0; // веса. индексы: шаг, сост
//		ArrDprevStep[ai-1]:=0; // оптим.упр.индексы: шаг, упр
	end;
	arrG[currStep]:=0;

//	initDataArr();
	initDataArrv2();
// массивы весов и управлений для
//	for aj:=1 to MaxStepCnt do begin // 0 уже проинициализирован выше
//		for ai:=1 to Ns do begin
//			ArrV[ai-1, aj]:=low(longint); // веса. индексы: шаг, сост
//			ArrD[ai-1, aj]:=low(longint); // оптим.упр.индексы: шаг, упр
//		end;
//	end;

//  ShowOsnShemaStep;
end;

function FinalizeOsnShema: boolean;
var
	ai: longint;
begin
//	for ai := Low(ArrV) To High(ArrV) do
//		SetLength(ArrV[ai], 0); //!!! место для оптимизации -
	SetLength(ArrVCurrStep, 0);
	SetLength(ArrVPrevStep, 0);

//	for ai := Low(ArrD) To High(ArrD) do
//		SetLength(ArrD[ai], 0); //!!! место для оптимизации -
	SetLength(ArrDCurrStep, 0);
	SetLength(ArrDCurrStepTemp, 0);
	SetLength(ArrDPrevStep, 0);

	SetLength(ArrG, 0);

	FinalizeDataArr();
end;


function copyArrCurrToPrev: boolean;
var
	ai: longint;
begin
	for ai:=1 to Ns do begin
		ArrVprevStep[ai]:=ArrVcurrStep[ai]; // веса. индексы: шаг, сост
		ArrDprevStep[ai]:=ArrDcurrStep[ai]; // оптим.упр.индексы: шаг, упр
		ArrVcurrStep[ai]:=low(longint); // веса. индексы: шаг, сост
		ArrDcurrStep[ai]:=low(longint); // оптим.упр.индексы: шаг, упр
	end;
end;

function procCopyArrCurrToPrev: boolean;
var
	ai: longint;
begin
	for ai:=1 to Ns do begin
		procArrVprevStep[ai]:=procArrVcurrStep[ai]; // веса. индексы: шаг, сост
//		procArrDprevStep[ai]:=procArrDcurrStep[ai]; // оптим.упр.индексы: шаг, упр
		procArrVcurrStep[ai]:=low(longint); // веса. индексы: шаг, сост
//		procArrDcurrStep[ai]:=low(longint); // оптим.упр.индексы: шаг, упр
	end;
end;

function getStateTransInt(ai,  ak: longint; aname: string): longint;
var
	aNextNode: TDOMNode;
	ari, ark, aval: longint;
begin
	Result:= -1000;
	aNextNode:= stateTransRootNode.firstChild;
	repeat
		ari:=getIntAttrValue(aNextNode, 'i', -1);
		ark:=getIntAttrValue(aNextNode, 'k', -1);
		if ((ari=ai) and (ark=ak)) then begin
			aval:= getIntAttrValue(aNextNode, aname, -1);
			Result:=aval;
			break;
		end;
		aNextNode:= aNextNode.NextSibling;
	until not assigned(aNextNode);
end;

function getStateTransDbl(ai,  ak: longint; aname: string): double;
var
	aNextNode: TDOMNode;
	ari, ark: longint;
	aval: double;
begin
	Result:= -1000;
	aNextNode:= stateTransRootNode.firstChild;
	repeat
		ari:=getIntAttrValue(aNextNode, 'i', -1);
		ark:=getIntAttrValue(aNextNode, 'k', -1);
		if ((ari=ai) and (ark=ak)) then begin
			aval:= getDblAttrValue(aNextNode, aname, -1);
			Result:=aval;
			break;
		end;
		aNextNode:= aNextNode.NextSibling;
	until not assigned(aNextNode);
end;

function get_j(ai,  ak: longint): longint;
begin
//	result:=getStateTransInt(ai,  ak, 'j');
	result:= arrJ[ai, ak];
end;

function get_qik(ai, ak: longint): double;
begin
//	result:=getStateTransDbl(ai,  ak, 'qijk');
	result:= arrQ[ai, ak];
end;

function get_kv1(ai: longint): longint;
var
	aNextNode: TDOMNode;
	ari, aval: longint;
begin
	result:= arrKv1[ai];
{
	Result:= -1000;
	aNextNode:= stateTransRootNode.firstChild;
	repeat
		ari:=getIntAttrValue(aNextNode, 'i', -1);
		if ari=ai then begin
			aval:= getIntAttrValue(aNextNode, 'kv1', -1);
			Result:=aval;
			break;
		end;
		aNextNode:= aNextNode.NextSibling;
	until not assigned(aNextNode);
}
end;

function get_rijk(ai, ak: longint): double;
begin
//	result:= getStateTransDbl(ai,  ak, 'rijk');
	result:= arrR[ai, ak];
end;

////////////////////////////////////////////////////
function get_v(ai, ak: longint; var av1: longint; var av2: longint): boolean;
var
	aNextNode: TDOMNode;
	ari, ark: longint;
	asttr: longint;
begin
	asttr:=1;
	repeat
		ari:= StateTransArr[asttr].ri; //ari:=getIntAttrValue(aNextNode, 'i', -1);
		ark:= StateTransArr[asttr].rk; //ark:=getIntAttrValue(aNextNode, 'k', -1);
		if ((ari=ai) and (ark=ak)) then begin
			av1:= StateTransArr[asttr].rv1; //getIntAttrValue(aNextNode, 'v1', -1);
			av2:= StateTransArr[asttr].rv2; //getIntAttrValue(aNextNode, 'v2', -1);
			break;
		end;
		inc(asttr);
	until asttr>StateTransCnt;
{
	aNextNode:= stateTransRootNode.firstChild;
	repeat
		ari:=getIntAttrValue(aNextNode, 'i', -1);
		ark:=getIntAttrValue(aNextNode, 'k', -1);
		if ((ari=ai) and (ark=ak)) then begin
			av1:= getIntAttrValue(aNextNode, 'v1', -1);
			av2:= getIntAttrValue(aNextNode, 'v2', -1);
			break;
		end;
		aNextNode:= aNextNode.NextSibling;
	until not assigned(aNextNode);
}
end;

function InterpretResultsAsNode(): string;
// возвращает строку трассировки переходов
var
  i, j, k, v1, v2: longint;
  rijk, rsum, vsum: double;
  s, s1, s2: string;
begin
	i:= 1;
	s:='';
	s2:='';
	rsum:= 0;
	vsum:= 0;
	//  пропускаем переход из базового
	k:= arrDcurrStep[i];
	j:= get_j(i, k);

	s1:= #13#10 + 'from base state to initial state' + #13#10
//		+ 'i=' + format('%5d', [i]) + '-k=' + format('%5d', [k]) + '->j=' + format('%5d', [j]);
		+ format('i=%5d - k=%5d -> j= %5d', [i,k,j]);
	repeat
		i:=j;
		s:='';
		k:= arrDcurrStep[i];
		j:= get_j(i, k);
		rijk:= get_rijk(i, k);
		get_v(i, k, v1, v2);

		rsum:= rsum + rijk;
		vsum:= vsum + v2;

		s:= format('i=%5d - k=%5d -> j= %5d', [i,k,j]);
		rxi[v1]:= v2; // оптимальный ресурс
		s1:= s1 + #13#10 + s;
	until j=1;

	s1:= s1 + #13#10 + 'return to base state' + #13#10 ;

	rQSumMax:= rsum;

	Result:= s1;

end;

function InterpretResults(): string;
var
  i, j, k, v1, v2: longint;
  rijk, rsum, vsum: double;
  s, s1, s2: string;
begin
//  j:= 0;
  i:= 1;
  s:='';
  s2:='';
  rsum:= 0;
  vsum:= 0;
//  пропускаем переход из базового
  k:= arrDcurrStep[i];
  j:= get_j(i, k);

  s1:='в сост i=' + IntToStr(i) + #13#10
    + ' исп упр k= ' + IntToStr(k) + #13#10
    + ' переход в j= ' + IntToStr(j) + #13#10
    + ' из базового сост в начальное'
    ;
    writeln(s1);
  i:=j;

  repeat
    s:='';
    k:= arrDcurrStep[i];
    j:= get_j(i, k);
    rijk:= get_rijk(i, k);
    get_v(i, k, v1, v2);

    rsum:= rsum + rijk;
    vsum:= vsum + v2;

    if j=1 then begin
      s:= 'в сост i=' + IntToStr(i) + #13#10
        + ' исп упр k= ' + IntToStr(k) + #13#10
        + ' переход в j= ' + IntToStr(j) + #13#10
        + ' возврат в базовое состояние'
        ;
    end
    else begin
//      ArrReq[v1-1].rxi := v2;
//      ArrReq[v1-1].rqi := rijk; //! под вопросом - проверить что rijk совпадает с Rxi*rudi
      s:= 'в сост i=' + IntToStr(i) + #13#10
        + ' исп упр k= ' + IntToStr(k) + #13#10
        + ' переход в j= ' + IntToStr(j) + #13#10
        + ' на заявку v1= ' + IntToStr(v1) + #13#10
        + ' ресурс v2= ' + IntToStr(v2) + #13#10
        + ' доход перех rijk = ' + FloatToStr(rijk) + #13#10
        + ' всего ресурса vsum = ' + FloatToStr(vsum) + #13#10
        + ' всего дохода rsum = ' + FloatToStr(rsum)
        ;
		s2:=s2 + 'x_' + IntToStr(v1) + ' =   ' + Format('%d',[v2]) + ' ';
    end;
    writeln(s);
//    s1:= s1 + #13#10 + s;
    i:=j;
  until j=1;

	for i:= 1 to M do
		write('p_', i, ' = ', rudi[i]:6:3, ' ');
	writeln();

	writeln(s2);
	writeln('qSumMax ', rsum: 9:6);
//  Result:= s1 + #13#10 + 'Возврат в базовое состояние 1' + #13#10;

  Result:= '';

end;
///////

function CalcOsnSchemaStep(): longint;
var
	ai, aibase, ak, ai_j, ak_max, am, an: longint;
	ag_n1, avi_n1, axi, axi2, axi2_max: double;

	function CalcForState(): boolean;
	var
		ak: longint;
	begin
    // поиск max по ak
		// mpi найти локальный максимум по каждому процессу - начало
		axi2_max:= -1000;//low(double);
		ak_max:= 1;
		for ak:= 1 to get_kv1(ai) do begin
			ai_j:= get_j(ai, ak);
			if ai_j=-1000 then break; // если законились rijk <> low(longint)
			axi2:= ag_n1 + get_rijk(ai, ak)
				+ (1/cw)*arrVcurrStep[ai_j]
				- ((1/cw)-1)*arrVprevStep[ai_j];
			if axi2>axi2_max then begin
				axi2_max:= axi2;
				ak_max:=ak;
			end;
    	end;
		// mpi найти локальный максимум по каждому процессу - конец
		// mpi вернуть локальный макс. Определить глобальный макс
		axi:= axi2_max;
		avi_n1:= (1-cW)*arrVprevStep[ai] + cW*axi - cw*ag_n1;
		ArrVcurrStep[ai]:= avi_n1;
		ArrDcurrStep[ai]:= ak_max;
	end;

begin
// Цикл по шагам
	copyArrCurrToPrev();
	currStep:= currStep+1; //тек шаг = n+1
//	writeln('currStep ', currStep);
//	readLn();
// вес базового сост для любого шага 0
	aibase:=1;
	ArrVcurrStep[aibase]:=0; // веса. индексы: сост
	ArrDcurrStep[aibase]:=1; // оптим.упр.индексы: упр
	// в баз сост только одно управление и только 1 переход с вероятн 1
	ak:=1;
	ag_n1:= get_qik(aibase, ak) + arrVprevStep[get_j(aibase, ak)];
	arrG[currStep]:=ag_n1;

	// MPI 
	// ВНЕ ШАГА
	// посчитать кол-во сост для каждого процесса. м.б. внутри процесса чтобы избежать передачи
	// разослать кол-во состояний
	// разослать данные arrJ, ArrQ, ArrKv1
	// ВНУТРИ ШАГА
	// найти локальный макс
	// вернуть макс и номер сост

	// mpi разбросать по процессам по номерам состояний
{	for ai:= aibase+1 to Ns-1 do begin
		CalcForState();
	end;
}
	for am:= 1 to M do begin
		for an:= 1 to Nc+1 do begin
			ai:= aibase + (am-1)*(Nc+1) + an;
			CalcForState();
		end;
	end;

	ai:=Ns;
	CalcForState();

	CalcOsnSchemaStep := IsSolved();
end;

function CalcOsnSchema(): boolean;
var
	cnt: longint;
begin
	if myid <> 0 then exit;
//	if myid = 0 then begin
		cnt:=0;
   	repeat
   		inc(cnt);
   		if cnt>1000 then begin
   			writeln('Osn shema stopped by iteration cnt');
   			break;
   		end;
   		vIsDone := CalcOsnSchemaStep();
   		addOsnNode();
   	until vIsDone = 1;
//	end;
end;

// MPI ////////////////////////////////////////////////////////////////////////////////////////////////
function InitProcOsnShema(): boolean;
var
	ai, aj, aiCurrent: longint;
	arrJBuf: pointer;
	arrJBufSize: longint;
	arrJSizes : array of longint;
	s: string;
begin
	// ВНЕ ШАГА
	// посчитать кол-во сост для каждого процесса. м.б. внутри процесса чтобы избежать передачи
	// разослать кол-во состояний
	// разослать данные arrJ, ArrQ, ArrKv1

	MPI_BCAST(@cW, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);

	SetLength(procArrKv1, Ns+1);
	bcast_arrInt(ArrKv1, procArrKv1);

	// передать arrJ (двумерный)
	SetLength(procArrJ, Ns+1);
{	if myid = 0 then begin
			s:= '';
			for ai:= 1 to length(ArrJ)-1 do begin //
				for aj:= 1 to length(ArrJ[ai])-1 do begin 
					s:= s+ format('ArrJ[%d, %d] = %d ', [ai, aj, ArrJ[ai, aj]]);
//					write( 'ArrJ[',ai,',', aj, '] =' , ArrJ[ai, aj]:3, ' ');
				end;
				s:= s + #13#10;
			end;
			writeln(s);
	end;
}
	bcast_arrInt2Dim(ArrJ, procArrJ);
	MPI_Barrier(MPI_COMM_WORLD);
{	if myid <> 0 then begin
			s:= '';
			for ai:= 1 to length(procArrJ)-1 do begin //
				for aj:= 1 to length(procArrJ[ai])-1 do begin 
					s:= s+ format('procArrJ[%d, %d] = %d ', [ai, aj, procArrJ[ai, aj]]);
//					write( 'procArrJ[',ai,',', aj, '] =' , procArrJ[ai, aj]:3, ' ');
				end;
				s:= s + #13#10;
			end;
			writeln(s);
	end;
}
	// передать arrR (двумерный)
	SetLength(procArrR, Ns+1);
{			for ai:= 1 to length(ArrR)-1 do begin //
				for aj:= 1 to length(ArrR[ai])-1 do begin 
					write( 'ArrR[',ai,',', aj, '] =' , ArrR[ai, aj]:6:3, ' ');
				end;
				writeln();
			end;
}
	bcast_arrDbl2Dim(ArrR, procArrR);
{			for ai:= 1 to length(procArrR)-1 do begin //
				for aj:= 1 to length(procArrR[ai])-1 do begin 
					write( 'procArrR[',ai,',', aj, '] =' , procArrR[ai, aj]:6:3, ' ');
				end;
				writeln();
			end;
}
//	SetLength(ArrQ, Ns+1);

	SetLength(ArrVCurrStep, Ns+1); // пропускаем 0й

	SetLength(procArrVcurrStep, Ns+1);
	SetLength(procArrVprevStep, Ns+1);
	SetLength(procArrDcurrStep, Ns+1);
//	SetLength(procArrDcurrStepTemp, Ns+1);//procNc*M + 1

	// расчет кол-ва порций ресурса для процесса
	setLength(procNcArr, numprocs);
	setLength(procDownNcArr, numprocs);
	setLength(procNcArrTemp, numprocs);
    if myid = 0 then begin
//		setLength(procNcArr, numprocs);

		procNc:= (Nc+1) div numprocs;
		procDownNc:= 1;

		if ((Nc+1) mod numprocs) > 0 then begin // заявки нацело НЕ делятся по процессам
			inc(procNc);
		    restNc:= Nc+1;
			for ai:=0 to numprocs-1 do begin
				if restNc < 0  then
					procNcArr[ai]:=0
				else if restNc > procNc then
					procNcArr[ai]:= procNc
				else
					procNcArr[ai]:= restNc;

				procDownNcArr[ai]:=procDownNc;
				procDownNc:= procDownNc + procNcArr[ai];

				restNc:= restNc - procNc;
//				writeln(myid, '|procMArr[', ai, '] = ', procMArr[ai]);
				procNcArrTemp[ai]:= procNcArr[ai]*M;
			end;
		end
		else begin // заявки нацело делятся по процессам 
			for ai:=0 to numprocs-1 do begin
				procNcArr[ai]:=procNc;
				procDownNcArr[ai]:=procDownNc;
				procDownNc:= procDownNc + procNcArr[ai];

				procNcArrTemp[ai]:= procNcArr[ai]*M;
			end;
		end;
		procDownNc:= 1;
	end;
	MPI_BCAST(@procNcArr[0], numprocs, MPI_INT, 0, MPI_COMM_WORLD);

	// рассылка кол-ва заявок по процессам
	if myid = 0 then begin
//		writeln(myid, format(' send procNc=%d ', [procNcArr[0]]) );
	end;
	MPI_SCATTER(@procNcArr[0], 1, MPI_INT, @procNc, 1, MPI_INT, 0, MPI_COMM_WORLD);
//	writeln(myid, format(' recv procNc=%d ', [procNc]) );
{
	if myid = 0 then
		for ai:=0 to numprocs-1 do
			MPI_SEND(@procNcArr[ai], 1, MPI_INT, ai, teg, MPI_COMM_WORLD);

	// получение кол-ва заявок по процессам
	MPI_RECV(@procNc, 1, MPI_INT, 0, teg, MPI_COMM_WORLD, status);
}
	SetLength(procArrDcurrStepTemp, procNc*M + 1);//

	// рассылка начального номера заявки по процессам
	if myid = 0 then begin
//		writeln(myid, format(' send procDownNc=%d ', [procDownNcArr[0]]) );
	end;
	MPI_SCATTER(@procDownNcArr[0], 1, MPI_INT, @procDownNc, 1, MPI_INT, 0, MPI_COMM_WORLD);
//	writeln(myid, format(' recv procDownNc=%d ', [procDownNc]) );
{	if myid = 0 then begin
		procDownNc:= 1;
		for ai:= 0 to numprocs-1 do begin
			MPI_SEND(@procDownNc, 1, MPI_INT, ai, teg, MPI_COMM_WORLD);
			procDownNc:= procDownNc + procNcArr[ai];
		end;
		procDownNc:= 1;
	end;
	// получение начального номера заявки по процессам
	MPI_RECV(@procDownNc, 1, MPI_INT, 0, teg, MPI_COMM_WORLD, status);
}

	procUpNc:= procDownNc + procNc - 1;
	writeln(myid, '| procDownNc = ', procDownNc, ' procUpNc = ', procUpNc, ' procNc = ', procNc);

	// подготовка структур данных для сборки в цикле
//	if myid = 0 then begin
		// смещения для последующей сборки
		setLength(procSubArrVDispls, numprocs);
		setLength(procSubArrDDispls, numprocs);
		setLength(procSubArrDDisplsTemp, numprocs);

		procSubArrVDispl:=0;
		procSubArrDDispl:=0;
		procSubArrDDisplTemp:= 0;
		for ai:=0 to numprocs-1 do begin
			procSubArrVDispls[ai]:= procSubArrVDispl;
			procSubArrDDispls[ai]:= procSubArrDDispl;
			procSubArrDDisplsTemp[ai]:= procSubArrDDisplTemp;
			
		 	procSubArrVDispl:= procSubArrVDispl + procNcArr[ai];//*sizeOfDouble; 
		 	procSubArrDDispl:= procSubArrDDispl + procNcArr[ai];//*sizeOfLongint; 
			procSubArrDDisplTemp:= procSubArrDDisplTemp + procNcArr[ai]*M;
		end;
//	end;

	// буфер для отправки
	sendSubArrVBufSize:= procNc*sizeOfDouble;
	sendSubArrDBufSize:= M*procNc*sizeOfLongint;
	getMem(sendSubArrVBuf, sendSubArrVBufSize);
	getMem(sendSubArrDBuf, sendSubArrDBufSize);

	recvSubArrVBufSize:= (Nc+1)*sizeOfDouble;
	recvSubArrDBufSize:= (Nc+1)*sizeOfLongint;
	getMem(recvSubArrVBuf, recvSubArrVBufSize);
	getMem(recvSubArrDBuf, recvSubArrDBufSize);
end;

function FinalizeProcOsnShema(): boolean;
var
	ai: longint;
begin
	setLength(procArrKv1, 0);

	for ai:= 0 to Length(procArrJ)-1 do
		SetLength(procArrJ[ai], 0);	
	SetLength(procArrJ, 0);	

	SetLength(procArrVcurrStep, 0);
	SetLength(procArrVprevStep, 0);
	SetLength(procArrDcurrStep, 0);
	SetLength(procArrDcurrStepTemp, 0);

	setLength(procNcArr, 0);
	setLength(procDownNcArr, 0);
	setLength(procNcArrTemp, 0);

	for ai:= 0 to Length(procArrR)-1 do
		SetLength(procArrR[ai], 0);	
	SetLength(procArrR, 0);	

	setLength(procSubArrVDispls, 0);
	setLength(procSubArrDDispls, 0);
	setLength(procSubArrDDisplsTemp, 0);

	// чистим память
	freeMem(sendSubArrVBuf, sendSubArrVBufSize);
	freeMem(sendSubArrDBuf, sendSubArrDBufSize);

	freeMem(recvSubArrVBuf, recvSubArrVBufSize);
	freeMem(recvSubArrDBuf, recvSubArrDBufSize);
end;

function CalcOsnSchemaStepMPI(): longint;
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
    startTemp1:= MPI_Wtime; 

	if myid = 0 then begin
		copyArrCurrToPrev();

		currStep:= currStep+1; //тек шаг = n+1
		// вес базового сост для любого шага 0
//		aibase:=1;
		ArrVcurrStep[aibase]:=0; // веса. индексы: сост
		ArrDcurrStep[aibase]:=1; // оптим.упр.индексы: упр
		// в баз сост только одно управление и только 1 переход с вероятн 1
		ak:=1;
		ag_n1:= get_qik(aibase, ak) + arrVprevStep[get_j(aibase, ak)];
		arrG[currStep]:=ag_n1;
	end;
	endTemp1:= MPI_Wtime;
	writeln(myid, '|   InitStep ', endTemp1 - startTemp1: 9:6);
    startTemp1:= endTemp1;

{	for ai:= aibase to Ns-1 do begin
		writeln(format('ArrVcurrStep[%d] = %f', [ai, ArrVcurrStep[ai]]));
	end;
}	bcast_arrDbl(ArrVcurrStep, procArrVcurrStep);
{	for ai:= aibase to Ns-1 do begin
		writeln(format('procArrVcurrStep[%d] = %f', [ai, procArrVcurrStep[ai]]));
	end;
}	bcast_arrDbl(ArrVprevStep, procArrVprevStep);
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
	endTemp1:= MPI_Wtime;
	writeln(myid, '|   SendStepData ', endTemp1 - startTemp1: 9:6);
    startTemp1:= endTemp1;

	endTemp1:= MPI_Wtime;
	writeln(myid, '|   StartMainCycle ', endTemp1 - startTemp1: 9:6);
    startTemp1:= endTemp1;

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
	endTemp1:= MPI_Wtime;
	writeln(myid, '|       CalcData   ', endTemp1 - startTemp1: 9:6);
    startTemp1:= endTemp1;
		// отправить обновленные данные массива procArrVcurrStep
//		MPI_GATHERV(sendSubArrVBuf, procNc, MPI_Double, 
//					recvSubArrVBuf, procNcArr[0], procSubArrVDispls[0], MPI_Double, 0, MPI_COMM_WORLD);
		MPI_GATHERV(sendSubArrVBuf, procNc, MPI_Double, 
					recvSubArrVBuf, @(procNcArr[0]), @(procSubArrVDispls[0]), MPI_Double, 0, MPI_COMM_WORLD);

		// оптимизация отправлять значения в procArrDcurrStep в конце шага, а не для каждого am - доп кодирование
//		MPI_GATHERV(sendSubArrDBuf, procNc, MPI_INT,
//					recvSubArrDBuf, procNcArr[0], procSubArrDDispls[0], MPI_INT, 0, MPI_COMM_WORLD);
		MPI_GATHERV(sendSubArrDBuf, procNc, MPI_INT,
					recvSubArrDBuf, @(procNcArr[0]), @(procSubArrDDispls[0]), MPI_INT, 0, MPI_COMM_WORLD);

	endTemp1:= MPI_Wtime;
	writeln(myid, '|       SendData   ', endTemp1 - startTemp1: 9:6);
    startTemp1:= endTemp1;
		if myid = 0 then begin
			// распковать
			for an:= 1 to Nc+1 do begin
				ai:= aibase + (am-1)*(Nc+1) + an;
				acur_buf_dbl:= recvSubArrVBuf + (an-1)*sizeOfDouble;
				ArrVcurrStep[ai]:= acur_buf_dbl^;
//				writeln(format('ArrVcurrStep[%d] = %f // %f', [ai, ArrVcurrStep[ai],acur_buf_dbl^]));
				acur_buf_int:= recvSubArrDBuf + (an-1)*sizeOflongint;
				ArrDcurrStep[ai]:= acur_buf_int^;
			end;
		end;
	endTemp1:= MPI_Wtime;
	writeln(myid, '|       UnpackData ', endTemp1 - startTemp1: 9:6);
    startTemp1:= endTemp1;

		// bcast всем новые значения ArrVcurrStep для текущего шага
		// оптимизация. отправлять не все значения т.е. Ns, а только измененные на этом шаге т.е Nc+1  - доп кодирование
//		bcast_arrDbl(ArrVcurrStep, procArrVcurrStep);
		if myid=0 then begin
			for an:=0 to length(ArrVcurrStep)-1 do begin
				procArrVcurrStep[an]:= ArrVcurrStep[an];
			end;
		end;
//		ai:= aibase + (am-1)*(Nc+1) + an;
//		MPI_BCAST(@procArrVcurrStep[0], length(procArrVcurrStep), MPI_DOUBLE, 0, MPI_COMM_WORLD);
		ai:= aibase + (am-1)*(Nc+1);
		MPI_BCAST(@procArrVcurrStep[ai], Nc+1, MPI_DOUBLE, 0, MPI_COMM_WORLD);

	endTemp1:= MPI_Wtime;
	writeln(myid, '|       resendData ', endTemp1 - startTemp1: 9:6);
    startTemp1:= endTemp1;

	end;
	endTemp1:= MPI_Wtime;
	writeln(myid, '|   endMainCycle ', endTemp1 - startTemp1: 9:6);
    startTemp1:= endTemp1;

	// отправить обновленные данные массива procArrDcurrStep

	if myid = 0 then begin
		ai:=Ns;
		CalcForState();

		Result := IsSolved();
	end;
	endTemp1:= MPI_Wtime;
	writeln(myid, '|   endStep ', endTemp1 - startTemp1: 9:6);
    startTemp1:= endTemp1;
end;//v1
//////////////////////////////////////////////////////////////////////////////////////////////////
{$I CalcOsnSchemaStepMPIv2.pas}
///////////////////////////////////////////////////
function CalcOsnSchemaMPI(): boolean;
var
	cnt: longint;
begin

    startTemp:= MPI_Wtime; 
	InitProcOsnShema();
	endTemp:= MPI_Wtime;
//	writeln(myid, '| InitProcOsnShema ', endTemp - startTemp: 9:6);
	startTemp:= endTemp;
	
	if myid = 0 then begin
	    startOsnMPI:= MPI_Wtime;
	end;

	cnt:=0;
   	repeat
   		inc(cnt);
   		if cnt>1000 then begin
   			writeln('Osn shema MPI stopped by iteration cnt>1000');
   			break;
   		end;

//   		vIsDone := CalcOsnSchemaStepMPI();
   		vIsDone := CalcOsnSchemaStepMPIv2();
	endTemp:= MPI_Wtime;
//	writeln(myid, '| CalcOsnSchemaStepMPI cnt=', cnt, endTemp - startTemp: 9:6);
	startTemp:= endTemp;
		MPI_BCAST(@vIsDone, 1, MPI_INT, 0, MPI_COMM_WORLD);

		if myid = 0 then begin
   			addOsnNode();
		end;
   	until vIsDone = 1;

	if myid = 0 then begin
	    endOsnMPI:= MPI_Wtime;
		totalOsnMPI:= endOsnMPI-startOsnMPI;
		writeln(myid, format('| TIME totalOsnMPI=%.6f sec', [totalOsnMPI]));
	end;

	FinalizeProcOsnShema();
	endTemp:= MPI_Wtime;
//	writeln(myid, '| FinalizeProcOsnShema ', endTemp - startTemp: 9:6);
	startTemp:= endTemp;

end;
