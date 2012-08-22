var
//    ArrV: array of TStepArrayOfDbl; // ���. �������: 蠣, ���
//    ArrD: array of TStepArrayOfInt; //��⨬.��.�������: 蠣, ��
//    arrG: TStepArrayOfDbl; //��।����� 蠣��� ��室
    ArrVCurrStep: array of Double; // ���. �������: ���
    ArrDCurrStep: array of longint; //��⨬.��.�������: ��
    ArrDCurrStepTemp: array of longint; //��⨬.��.�������: ��
    ArrVPrevStep: array of Double; // ���. �������: ���
    ArrDPrevStep: array of longint; //��⨬.��.�������: ��
    arrG: array of Double; //��।����� 蠣��� ��室
    currStep: longint;
    MaxStepCnt: longint; // ������⢮ 蠣��. ���� �� �㫥��� 蠣. �.�. �������᪨�.

    procArrVCurrStep: array of Double; // ���. �������: ���
    procArrDCurrStep: array of longint; //��⨬.��.�������: ��
    procArrDCurrStepTemp: array of longint; //��⨬.��.�������: ��
    procArrVPrevStep: array of Double; // ���. �������: ���
//    procArrDPrevStep: array of longint; //��⨬.��.�������: ��
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

// ��।��� ����� � �뭥�� � XML
function addOsnNode():boolean;
var
	ai, ires: longint;
	dres: double;
	astr: string;
begin
	osnStepNode:=aDoc.CreateElement('osnStepNode');

	addIntAttribute(osnStepNode, 'n1', currStep);
	addDblAttribute(osnStepNode, 'g_n1', arrG[currStep]);

	astr:='d=';
	for ai:=low(ArrDCurrStep)+1 to high(ArrDCurrStep) do begin // �ய�᪠�� 0�
		ires:= ArrDCurrStep[ai];
		astr:= astr + Format('%4d',[ires]) + ';';
	end;
	commentNode:=aDoc.CreateComment(astr);
	osnStepNode.AppendChild(commentNode);

	astr:='v=';
	for ai:=low(ArrVcurrStep)+1 to high(ArrVcurrStep) do begin // �ய�᪠�� 0�
		dres:=ArrVcurrStep[ai];
		astr:= astr + Format('%4f',[dres]) + ';';
	end;
	commentNode:=aDoc.CreateComment(astr);
	osnStepNode.AppendChild(commentNode);

	ires := IsSolved();
	if iRes  = 1 then begin
//    s:= '���⨣��� �筮��� 0.01 �� g. ���᫥��� ��⠭������.';
	    astr:= 'done. delta(g)<0.001';
		addStrAttribute(osnStepNode, 'result', astr);
	end
	else if iRes = -1 then begin
//  s:= '�ॢ�襭� ���ᨬ��쭮� ������⢮ 蠣�� (' + IntToStr(MaxStepCnt) + ')' + '���᫥��� ��⠭������.'
	    astr:= 'stopped on MaxStepCnt' + IntToStr(MaxStepCnt);
		addStrAttribute(osnStepNode, 'result', astr);
	end;
		
	osnStepRootNode.AppendChild(osnStepNode);
end;


function Calc_qijk: boolean;
// ����� �����।�⢥����� ��室�
// �.�. ᮢ��饭 � setAllJbyRNS()
var
	aVal: double;
	aNextNode: TDOMNode;
begin
// qik=sum_po_j(pijk*rijk) �㬬� �ਧ������� ��室� �� ���室� �� � � j �� �-� �ࠢ�����
//  for j:=1 to Ns do begin
//    Result:= Result + Arr
//  end;

// ��᪮��� 1) ��� ������� i ���� ⮫쪮 ���� ��� j �㤠 ���室��� �� �-� �ࠢ�����
// 2) ����⭮��� ���室� =1
// � qijk==rijk
// 㤮���� ���� ��ॡ��� �� 䠧��� ���室�
// �ᯮ���� XML
	aNextNode:= stateTransRootNode.firstChild;
//	acnt:= 0;
	repeat
//		inc(acnt);
//		if acnt> StateTransCnt then break;
		aval:= getDblAttrValue(aNextNode, 'rijk', -1);
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
			ArrKv1[aiCurrent]:= akv1; //��� ���᪠ kv1
		end;
		ak:=getIntAttrValue(aNextNode, 'k', -1);
//		writeln('ai ', ai, ' akv1 ', akv1, ' ak ', ak);
//		if akv1<1 then 
//			readln();
		ArrJ[aiCurrent, ak]:= getIntAttrValue(aNextNode, 'j', -1);
		ArrR[aiCurrent, ak]:= getDblAttrValue(aNextNode, 'rijk', -1);
		ArrQ[aiCurrent, ak]:= getDblAttrValue(aNextNode, 'qijk', -1);

		aNextNode:= aNextNode.NextSibling;
	until not assigned(aNextNode);
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
//���樠������
	MaxStepCnt := 100;

	SetLength(ArrVCurrStep, Ns+1); // �ய�᪠�� 0�
	SetLength(ArrVPrevStep, Ns+1); // �ய�᪠�� 0�
//	writeln('SetLength(ArrVCurrStep, Ns ', Ns);
//	for ai := Low(ArrV) To High(ArrV) do
//		SetLength(ArrV[ai], MaxStepCnt+1); //!!! ���� ��� ��⨬���樨 -
    // ����� ���樠������ � ࠧ��� ������ �� 室� ����� � �ᥬ� ��稬�
    // �ਡ����ᠬ� c ���樠����樥� ����ﬨ ������
	SetLength(ArrDCurrStep, Ns+1); // �ய�᪠�� 0�
	SetLength(ArrDcurrStepTemp, Ns+1); // �ய�᪠�� 0�
	
	SetLength(ArrDPrevStep, Ns+1); // �ய�᪠�� 0�
//	writeln('SetLength(ArrDCurrStep, Ns ', Ns);
//	for ai := Low(ArrD) To High(ArrD) do
//		SetLength(ArrD[ai], MaxStepCnt+1); //!!! ���� ��� ��⨬���樨 -
    // ����� ���樠������ � ࠧ��� ������ �� 室� ����� � �ᥬ� ��稬�
    // �ਡ����ᠬ� c ���樠����樥� ����ﬨ ������
	SetLength(ArrG, MaxStepCnt+1);


// ���ᨢ� ��ᮢ � �ࠢ����� ��� 0-�� 蠣�
	currStep:=0;
	for ai:=1 to Ns do begin
		ArrVCurrStep[ai]:=0; // ���. �������: 蠣, ���
		ArrDCurrStep[ai]:=0; // ��⨬.��.�������: 蠣, ��
//		ArrVprevStep[ai-1]:=0; // ���. �������: 蠣, ���
//		ArrDprevStep[ai-1]:=0; // ��⨬.��.�������: 蠣, ��
	end;
	arrG[currStep]:=0;

	initDataArr();
// ���ᨢ� ��ᮢ � �ࠢ����� ���
//	for aj:=1 to MaxStepCnt do begin // 0 㦥 �ந��樠����஢�� ���
//		for ai:=1 to Ns do begin
//			ArrV[ai-1, aj]:=low(longint); // ���. �������: 蠣, ���
//			ArrD[ai-1, aj]:=low(longint); // ��⨬.��.�������: 蠣, ��
//		end;
//	end;

//  ShowOsnShemaStep;
end;

function FinalizeOsnShema: boolean;
var
	ai: longint;
begin
//	for ai := Low(ArrV) To High(ArrV) do
//		SetLength(ArrV[ai], 0); //!!! ���� ��� ��⨬���樨 -
	SetLength(ArrVCurrStep, 0);
	SetLength(ArrVPrevStep, 0);

//	for ai := Low(ArrD) To High(ArrD) do
//		SetLength(ArrD[ai], 0); //!!! ���� ��� ��⨬���樨 -
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
		ArrVprevStep[ai]:=ArrVcurrStep[ai]; // ���. �������: 蠣, ���
		ArrDprevStep[ai]:=ArrDcurrStep[ai]; // ��⨬.��.�������: 蠣, ��
		ArrVcurrStep[ai]:=low(longint); // ���. �������: 蠣, ���
		ArrDcurrStep[ai]:=low(longint); // ��⨬.��.�������: 蠣, ��
	end;
end;

function procCopyArrCurrToPrev: boolean;
var
	ai: longint;
begin
	for ai:=1 to Ns do begin
		procArrVprevStep[ai]:=procArrVcurrStep[ai]; // ���. �������: 蠣, ���
//		procArrDprevStep[ai]:=procArrDcurrStep[ai]; // ��⨬.��.�������: 蠣, ��
		procArrVcurrStep[ai]:=low(longint); // ���. �������: 蠣, ���
//		procArrDcurrStep[ai]:=low(longint); // ��⨬.��.�������: 蠣, ��
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
begin
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

end;

function IterpretResultsAsNode(): string;
// �����頥� ��ப� ����஢�� ���室��
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
	//  �ய�᪠�� ���室 �� ��������
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
		rxi[v1]:= v2; // ��⨬���� �����
		s1:= s1 + #13#10 + s;
	until j=1;

	s1:= s1 + #13#10 + 'return to base state' + #13#10 ;

	rQSumMax:= rsum;

	Result:= s1;

end;

function IterpretResults(): string;
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
//  �ய�᪠�� ���室 �� ��������
  k:= arrDcurrStep[i];
  j:= get_j(i, k);

  s1:='� ��� i=' + IntToStr(i) + #13#10
    + ' �� �� k= ' + IntToStr(k) + #13#10
    + ' ���室 � j= ' + IntToStr(j) + #13#10
    + ' �� �������� ��� � ��砫쭮�'
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
      s:= '� ��� i=' + IntToStr(i) + #13#10
        + ' �� �� k= ' + IntToStr(k) + #13#10
        + ' ���室 � j= ' + IntToStr(j) + #13#10
        + ' ������ � ������� ���ﭨ�'
        ;
    end
    else begin
//      ArrReq[v1-1].rxi := v2;
//      ArrReq[v1-1].rqi := rijk; //! ��� ����ᮬ - �஢���� �� rijk ᮢ������ � Rxi*rudi
      s:= '� ��� i=' + IntToStr(i) + #13#10
        + ' �� �� k= ' + IntToStr(k) + #13#10
        + ' ���室 � j= ' + IntToStr(j) + #13#10
        + ' �� ��� v1= ' + IntToStr(v1) + #13#10
        + ' ����� v2= ' + IntToStr(v2) + #13#10
        + ' ��室 ���� rijk = ' + FloatToStr(rijk) + #13#10
        + ' �ᥣ� ����� vsum = ' + FloatToStr(vsum) + #13#10
        + ' �ᥣ� ��室� rsum = ' + FloatToStr(rsum)
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
//  Result:= s1 + #13#10 + '������ � ������� ���ﭨ� 1' + #13#10;

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
    // ���� max �� ak
		// mpi ���� ������� ���ᨬ� �� ������� ������ - ��砫�
		axi2_max:= -1000;//low(double);
		ak_max:= 1;
		for ak:= 1 to get_kv1(ai) do begin
			ai_j:= get_j(ai, ak);
			if ai_j=-1000 then break; // �᫨ ���������� rijk <> low(longint)
			axi2:= ag_n1 + get_rijk(ai, ak)
				+ (1/cw)*arrVcurrStep[ai_j]
				- ((1/cw)-1)*arrVprevStep[ai_j];
			if axi2>axi2_max then begin
				axi2_max:= axi2;
				ak_max:=ak;
			end;
    	end;
		// mpi ���� ������� ���ᨬ� �� ������� ������ - �����
		// mpi ������ ������� ����. ��।����� �������� ����
		axi:= axi2_max;
		avi_n1:= (1-cW)*arrVprevStep[ai] + cW*axi - cw*ag_n1;
		ArrVcurrStep[ai]:= avi_n1;
		ArrDcurrStep[ai]:= ak_max;
	end;

begin
// ���� �� 蠣��
	copyArrCurrToPrev();
	currStep:= currStep+1; //⥪ 蠣 = n+1
//	writeln('currStep ', currStep);
//	readLn();
// ��� �������� ��� ��� ��� 蠣� 0
	aibase:=1;
	ArrVcurrStep[aibase]:=0; // ���. �������: ���
	ArrDcurrStep[aibase]:=1; // ��⨬.��.�������: ��
	// � ��� ��� ⮫쪮 ���� �ࠢ����� � ⮫쪮 1 ���室 � ����� 1
	ak:=1;
	ag_n1:= get_qik(aibase, ak) + arrVprevStep[get_j(aibase, ak)];
	arrG[currStep]:=ag_n1;

	// MPI 
	// ��� ����
	// ������� ���-�� ��� ��� ������� �����. �.�. ����� ����� �⮡� �������� ��।��
	// ࠧ�᫠�� ���-�� ���ﭨ�
	// ࠧ�᫠�� ����� arrJ, ArrQ, ArrKv1
	// ������ ����
	// ���� ������� ����
	// ������ ���� � ����� ���

	// mpi ࠧ����� �� ����ᠬ �� ����ࠬ ���ﭨ�
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
	// ��� ����
	// ������� ���-�� ��� ��� ������� �����. �.�. ����� ����� �⮡� �������� ��।��
	// ࠧ�᫠�� ���-�� ���ﭨ�
	// ࠧ�᫠�� ����� arrJ, ArrQ, ArrKv1

	MPI_BCAST(@cW, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);

	SetLength(procArrKv1, Ns+1);
	bcast_arrInt(ArrKv1, procArrKv1);

	// ��।��� arrJ (��㬥��)
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
	// ��।��� arrR (��㬥��)
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

	SetLength(ArrVCurrStep, Ns+1); // �ய�᪠�� 0�

	SetLength(procArrVcurrStep, Ns+1);
	SetLength(procArrVprevStep, Ns+1);
	SetLength(procArrDcurrStep, Ns+1);
//	SetLength(procArrDcurrStepTemp, Ns+1);//procNc*M + 1

	// ���� ���-�� ���権 ����� ��� �����
	setLength(procNcArr, numprocs);
	setLength(procNcArrTemp, numprocs);
    if myid = 0 then begin
//		setLength(procNcArr, numprocs);

		procNc:= (Nc+1) div numprocs;

		if ((Nc+1) mod numprocs) > 0 then begin // ��� ��楫� �� ������� �� ����ᠬ
			inc(procNc);
		    restNc:= Nc+1;
			for ai:=0 to numprocs-1 do begin
				if restNc < 0  then
					procNcArr[ai]:=0
				else if restNc > procNc then
					procNcArr[ai]:= procNc
				else
					procNcArr[ai]:= restNc;
				restNc:= restNc - procNc;
//				writeln(myid, '|procMArr[', ai, '] = ', procMArr[ai]);
				procNcArrTemp[ai]:= procNcArr[ai]*M;
			end;
		end
		else begin // ��� ��楫� ������� �� ����ᠬ 
			for ai:=0 to numprocs-1 do begin
				procNcArr[ai]:=procNc;
				procNcArrTemp[ai]:= procNcArr[ai]*M;
			end;
		end;
	end;
	MPI_BCAST(@procNcArr[0], numprocs, MPI_INT, 0, MPI_COMM_WORLD);

	// ���뫪� ���-�� ��� �� ����ᠬ
	if myid = 0 then
		for ai:=0 to numprocs-1 do
			MPI_SEND(@procNcArr[ai], 1, MPI_INT, ai, teg, MPI_COMM_WORLD);

	// ����祭�� ���-�� ��� �� ����ᠬ
	MPI_RECV(@procNc, 1, MPI_INT, 0, teg, MPI_COMM_WORLD, status);

	SetLength(procArrDcurrStepTemp, procNc*M + 1);//

	// ���뫪� ��砫쭮�� ����� ��� �� ����ᠬ
	if myid = 0 then begin
		procDownNc:= 1;
		for ai:= 0 to numprocs-1 do begin
			MPI_SEND(@procDownNc, 1, MPI_INT, ai, teg, MPI_COMM_WORLD);
			procDownNc:= procDownNc + procNcArr[ai];
		end;
		procDownNc:= 1;
	end;

	// ����祭�� ��砫쭮�� ����� ��� �� ����ᠬ
	MPI_RECV(@procDownNc, 1, MPI_INT, 0, teg, MPI_COMM_WORLD, status);

	procUpNc:= procDownNc + procNc - 1;
//	writeln(myid, '| procDownNc = ', procDownNc, ' procUpNc = ', procUpNc, ' procNc = ', procNc);

	// �����⮢�� ������� ������ ��� ᡮન � 横��
//	if myid = 0 then begin
		// ᬥ饭�� ��� ��᫥���饩 ᡮન
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

	// ���� ��� ��ࠢ��
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
	setLength(procNcArrTemp, 0);

	for ai:= 0 to Length(procArrR)-1 do
		SetLength(procArrR[ai], 0);	
	SetLength(procArrR, 0);	

	setLength(procSubArrVDispls, 0);
	setLength(procSubArrDDispls, 0);
	setLength(procSubArrDDisplsTemp, 0);

	// ��⨬ ������
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
    // ���� max �� ak
		// mpi ���� ������� ���ᨬ� �� ������� ������ - ��砫�
		axi2_max:= -1000;//low(double);
		ak_max:= 1;
		for ak:= 1 to procArrKv1[ai] do begin
			ai_j:= procArrJ[ai, ak];
			if ai_j=-1000 then break; // �᫨ ���������� rijk <> low(longint)
			axi2:= ag_n1 + procArrR[ai, ak]
				+ (1/cw)*procArrVcurrStep[ai_j]
				- ((1/cw)-1)*procArrVprevStep[ai_j];
			if axi2>axi2_max then begin
				axi2_max:= axi2;
				ak_max:=ak;
			end;
    	end;
		// mpi ���� ������� ���ᨬ� �� ������� ������ - �����
		// mpi ������ ������� ����. ��।����� �������� ����
		axi:= axi2_max;
		avi_n1:= (1-cW)*procArrVprevStep[ai] + cW*axi - cw*ag_n1;
		procArrVcurrStep[ai]:= avi_n1;
		procArrDcurrStep[ai]:= ak_max;
		// ������ ���� ⮫쪮 ��������� ����� �� ai �� procArrVcurrStep, procArrDcurrStep
	end;

	function CalcForState(): boolean;
	var
		ak: longint;
	begin
    // ���� max �� ak
		// mpi ���� ������� ���ᨬ� �� ������� ������ - ��砫�
		axi2_max:= -1000;//low(double);
		ak_max:= 1;
		for ak:= 1 to ArrKv1[ai] do begin
			ai_j:= ArrJ[ai, ak];
			if ai_j=-1000 then break; // �᫨ ���������� rijk <> low(longint)
			axi2:= ag_n1 + ArrR[ai, ak]
				+ (1/cw)*ArrVcurrStep[ai_j]
				- ((1/cw)-1)*ArrVprevStep[ai_j];
			if axi2>axi2_max then begin
				axi2_max:= axi2;
				ak_max:=ak;
			end;
    	end;
		// mpi ���� ������� ���ᨬ� �� ������� ������ - �����
		// mpi ������ ������� ����. ��।����� �������� ����
		axi:= axi2_max;
		avi_n1:= (1-cW)*ArrVprevStep[ai] + cW*axi - cw*ag_n1;
		ArrVcurrStep[ai]:= avi_n1;
		ArrDcurrStep[ai]:= ak_max;
	end;
var
	acur_buf_int: ^longint;
	acur_buf_dbl: ^double;
begin
// ���� �� 蠣��
	aibase:=1;
    startTemp1:= MPI_Wtime; 

	if myid = 0 then begin
		copyArrCurrToPrev();

		currStep:= currStep+1; //⥪ 蠣 = n+1
		// ��� �������� ��� ��� ��� 蠣� 0
//		aibase:=1;
		ArrVcurrStep[aibase]:=0; // ���. �������: ���
		ArrDcurrStep[aibase]:=1; // ��⨬.��.�������: ��
		// � ��� ��� ⮫쪮 ���� �ࠢ����� � ⮫쪮 1 ���室 � ����� 1
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

	// ������ ����
	// ���� ������� ����
	// ������ ���� � ����� ���

	// mpi ࠧ����� �� ����ᠬ �� ����ࠬ ���ﭨ�
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
			// 㯠������ � ���� ���������� ����� procArrVcurrStep
			acur_buf_dbl:= sendSubArrVBuf + (an-procDownNc)*sizeOfDouble;
			acur_buf_dbl^:= procArrVcurrStep[ai];
//			writeln(format('procArrVcurrStep[%d] = %f', [ai, procArrVcurrStep[ai]]));
			acur_buf_int:= sendSubArrDBuf + (an-procDownNc)*sizeOfLongint;
			acur_buf_int^:= procArrDcurrStep[ai];
		end;
	endTemp1:= MPI_Wtime;
	writeln(myid, '|       CalcData   ', endTemp1 - startTemp1: 9:6);
    startTemp1:= endTemp1;
		// ��ࠢ��� ���������� ����� ���ᨢ� procArrVcurrStep
		MPI_GATHERV(sendSubArrVBuf, procNc, MPI_Double, 
					recvSubArrVBuf, procNcArr[0], procSubArrVDispls[0], MPI_Double, 0, MPI_COMM_WORLD);

		// ��⨬����� ��ࠢ���� ���祭�� � procArrDcurrStep � ���� 蠣�, � �� ��� ������� am - ��� ����஢����
		MPI_GATHERV(sendSubArrDBuf, procNc, MPI_INT,
					recvSubArrDBuf, procNcArr[0], procSubArrDDispls[0], MPI_INT, 0, MPI_COMM_WORLD);

	endTemp1:= MPI_Wtime;
	writeln(myid, '|       SendData   ', endTemp1 - startTemp1: 9:6);
    startTemp1:= endTemp1;
		if myid = 0 then begin
			// �ᯪ�����
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

		// bcast �ᥬ ���� ���祭�� ArrVcurrStep ��� ⥪�饣� 蠣�
		// ��⨬�����. ��ࠢ���� �� �� ���祭�� �.�. Ns, � ⮫쪮 ��������� �� �⮬ 蠣� �.� Nc+1  - ��� ����஢����
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

	// ��ࠢ��� ���������� ����� ���ᨢ� procArrDcurrStep

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
function CalcOsnSchemaStepMPIv2(): longint;
var
	ai, aibase, ak, ai_j, ak_max, am, an: longint;
	ag_n1, avi_n1, axi, axi2, axi2_max: double;

	function procCalcForState(): boolean;
	var
		ak: longint;
	begin
    // ���� max �� ak
		// mpi ���� ������� ���ᨬ� �� ������� ������ - ��砫�
		axi2_max:= -1000;//low(double);
		ak_max:= 1;
		for ak:= 1 to procArrKv1[ai] do begin
			ai_j:= procArrJ[ai, ak];
			if ai_j=-1000 then break; // �᫨ ���������� rijk <> low(longint)
			axi2:= ag_n1 + procArrR[ai, ak]
				+ (1/cw)*procArrVcurrStep[ai_j]
				- ((1/cw)-1)*procArrVprevStep[ai_j];
			if axi2>axi2_max then begin
				axi2_max:= axi2;
				ak_max:=ak;
			end;
    	end;
		// mpi ���� ������� ���ᨬ� �� ������� ������ - �����
		// mpi ������ ������� ����. ��।����� �������� ����
		axi:= axi2_max;
		avi_n1:= (1-cW)*procArrVprevStep[ai] + cW*axi - cw*ag_n1;
		procArrVcurrStep[ai]:= avi_n1;
		procArrDcurrStep[ai]:= ak_max;
		// ������ ���� ⮫쪮 ��������� ����� �� ai �� procArrVcurrStep, procArrDcurrStep
	end;

	function CalcForState(): boolean;
	var
		ak: longint;
	begin
    // ���� max �� ak
		// mpi ���� ������� ���ᨬ� �� ������� ������ - ��砫�
		axi2_max:= -1000;//low(double);
		ak_max:= 1;
		for ak:= 1 to ArrKv1[ai] do begin
			ai_j:= ArrJ[ai, ak];
			if ai_j=-1000 then break; // �᫨ ���������� rijk <> low(longint)
			axi2:= ag_n1 + ArrR[ai, ak]
				+ (1/cw)*ArrVcurrStep[ai_j]
				- ((1/cw)-1)*ArrVprevStep[ai_j];
			if axi2>axi2_max then begin
				axi2_max:= axi2;
				ak_max:=ak;
			end;
    	end;
		// mpi ���� ������� ���ᨬ� �� ������� ������ - �����
		// mpi ������ ������� ����. ��।����� �������� ����
		axi:= axi2_max;
		avi_n1:= (1-cW)*ArrVprevStep[ai] + cW*axi - cw*ag_n1;
		ArrVcurrStep[ai]:= avi_n1;
		ArrDcurrStep[ai]:= ak_max;
	end;
var
	acur_buf_int: ^longint;
	acur_buf_dbl: ^double;
begin
// ���� �� 蠣��
	writeln(myid, '|   BeforeStep ');
	aibase:=1;
//    startTemp1:= MPI_Wtime; 

//	procCopyArrCurrToPrev();
	if myid = 0 then begin
		copyArrCurrToPrev();

		currStep:= currStep+1; //⥪ 蠣 = n+1
		// ��� �������� ��� ��� ��� 蠣� 0
		ArrVcurrStep[aibase]:=0; // ���. �������: ��� aibase:=1;
		ArrDcurrStep[aibase]:=1; // ��⨬.��.�������: ��
		// � ��� ��� ⮫쪮 ���� �ࠢ����� � ⮫쪮 1 ���室 � ����� 1
		ak:=1;
		ag_n1:= get_qik(aibase, ak) + arrVprevStep[get_j(aibase, ak)];
		arrG[currStep]:=ag_n1;
	end;
//	endTemp1:= MPI_Wtime;
//	writeln(myid, '|   InitStep ', endTemp1 - startTemp1: 9:6);
//    startTemp1:= endTemp1;

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

	// ������ ����
	// ���� ������� ����
	// ������ ���� � ����� ���

	// mpi ࠧ����� �� ����ᠬ �� ����ࠬ ���ﭨ�
{	for ai:= aibase+1 to Ns-1 do begin
		CalcForState();
	end;
}
//	endTemp1:= MPI_Wtime;
//	writeln(myid, '|   SendStepData ', endTemp1 - startTemp1: 9:6);
//    startTemp1:= endTemp1;

//	endTemp1:= MPI_Wtime;
//	writeln(myid, '|   StartMainCycle ', endTemp1 - startTemp1: 9:6);
//    startTemp1:= endTemp1;

//	writeln(' procDownNc ', procDownNc, ' procUpNc ', procUpNc);
	for am:= 1 to M do begin
//		for an:= 1 to Nc+1 do begin
		for an:= procDownNc to procUpNc do begin
			ai:= aibase + (am-1)*(Nc+1) + an;
			procCalcForState();
//			writeln(myid, '| ai = ', ai);
			// 㯠������ � ���� ���������� ����� procArrVcurrStep
			acur_buf_dbl:= sendSubArrVBuf + (an-procDownNc)*sizeOfDouble;
			acur_buf_dbl^:= procArrVcurrStep[ai];
//			writeln(format('procArrVcurrStep[%d] = %f', [ai, procArrVcurrStep[ai]]));
			acur_buf_int:= sendSubArrDBuf + (an-procDownNc)*sizeOfLongint;
			acur_buf_int^:= procArrDcurrStep[ai];
		end;
//	endTemp1:= MPI_Wtime;
//	writeln(myid, '|       CalcData   ', endTemp1 - startTemp1: 9:6);
//    startTemp1:= endTemp1;
		// ��ࠢ��� ���������� ����� ���ᨢ� procArrVcurrStep
//		MPI_GATHERV(sendSubArrVBuf, procNc, MPI_Double, 
//					recvSubArrVBuf, procNcArr[0], procSubArrVDispls[0], MPI_Double, 0, MPI_COMM_WORLD);
		ai:= aibase + (am-1)*(Nc+1);
//		writeln('ai = ', ai, ' ai+procDownNc =', ai+procDownNc, '', );
		MPI_ALLGATHERV(@procArrVcurrStep[ai+procDownNc], procNc, MPI_Double, 
					@ArrVcurrStep[ai+1], procNcArr[0], procSubArrVDispls[0], MPI_Double, MPI_COMM_WORLD);
		for an:= 1 to Nc+1 do begin
			ai:= aibase + (am-1)*(Nc+1) + an;
			procArrVcurrStep[ai]:=ArrVcurrStep[ai];
		end;

//	endTemp1:= MPI_Wtime;
//	writeln(myid, '|       SendData   ', endTemp1 - startTemp1: 9:6);
//    startTemp1:= endTemp1;
{		if myid = 0 then begin
			// �ᯪ�����
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

		// bcast �ᥬ ���� ���祭�� ArrVcurrStep ��� ⥪�饣� 蠣�
		// ��⨬�����. ��ࠢ���� �� �� ���祭�� �.�. Ns, � ⮫쪮 ��������� �� �⮬ 蠣� �.� Nc+1  - ��� ����஢����
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

//	endTemp1:= MPI_Wtime;
//	writeln(myid, '|       resendData ', endTemp1 - startTemp1: 9:6);
//    startTemp1:= endTemp1;

	end;

//	endTemp1:= MPI_Wtime;
//	writeln(myid, '|   endMainCycle ', endTemp1 - startTemp1: 9:6);
//    startTemp1:= endTemp1;

{
	for am:= 1 to M do begin
		// ��९������� � ᤥ���� 1� ��।���
		ai:= aibase + (am-1)*(Nc+1);
		MPI_GATHERV(@procArrDcurrStep[ai+procDownNc], procNc, MPI_INT,
					@ArrDcurrStep[ai+1], procNcArr[0], procSubArrDDispls[0], MPI_INT, 0, MPI_COMM_WORLD);
	end;
}
	ap:=0;

//	str:= #13#10;
//	writeln(' procDownNc ', procDownNc, ' procUpNc ', procUpNc);
	for am:= 1 to M do begin
		// ��९������� � ᤥ���� 1� ��।���
		for an:=procDownNc to procUpNc do begin
			ai:= aibase + (am-1)*(Nc+1) + an;
			procArrDcurrStepTemp[ap]:= procArrDcurrStep[ai];
			ap:=ap+1;//�� 1 �� M*procNc
			// ��� ��� ���� �����
//			str:= str + format('d[%d]=%d ', [ai, procArrDcurrStep[ai]]);
		end;
//		str:= str + #13#10;
	end;
//	writeln(myid, ' | 1', str);
	
	// 0� procArrDcurrStepTemp �ய�᪠��
//	writeln('length(procArrDcurrStepTemp) = ', length(procArrDcurrStepTemp), ' procNc*M = ', procNc*M);
//	writeln('length(ArrDcurrStepTemp) = ', length(ArrDcurrStepTemp), ' procNcArrTemp[0] = ', procNcArrTemp[0]);
	MPI_GATHERV(@procArrDcurrStepTemp[0], procNc*M, MPI_INT,
				@ArrDcurrStepTemp[aibase+1], procNcArrTemp[0], procSubArrDDisplsTemp[0], MPI_INT, 0, MPI_COMM_WORLD);

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
			// �ᯠ������
					ai:= aibase + (am-1)*(Nc+1) + an;
					ap:= ap + 1;//�� 1 �� M*procNc
//					writeln(' ap=', ap , ' ai=', ai);
					ArrDcurrStep[ai]:= ArrDcurrStepTemp[ap];
					// ��� ��� ���� �����
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
//	endTemp1:= MPI_Wtime;
//	writeln(myid, '|       sendD ', endTemp1 - startTemp1: 9:6);
//    startTemp1:= endTemp1;

	// ��ࠢ��� ���������� ����� ���ᨢ� procArrDcurrStep

	if myid = 0 then begin
		ai:=Ns;
		CalcForState();

		Result := IsSolved();
	end;
//	endTemp1:= MPI_Wtime;
//	writeln(myid, '|   endStep ', endTemp1 - startTemp1: 9:6,#13#10);
//    startTemp1:= endTemp1;
{	if myid = 0 then
		readln();
	MPI_Barrier(MPI_COMM_WORLD);
}
end;//v2

///////////////////////////////////////////////////
function CalcOsnSchemaMPI(): boolean;
var
	cnt: longint;
begin
	if myid = 0 then begin
	    startOsnMPI:= MPI_Wtime;
	end;

    startTemp:= MPI_Wtime; 
	InitProcOsnShema();
	endTemp:= MPI_Wtime;
	writeln(myid, '| InitProcOsnShema ', endTemp - startTemp: 9:6);
	startTemp:= endTemp;
	
	cnt:=0;
   	repeat
   		inc(cnt);
   		if cnt>1000 then begin
   			writeln('Osn shema MPI stopped by iteration cnt');
   			break;
   		end;

//   		vIsDone := CalcOsnSchemaStepMPI();
   		vIsDone := CalcOsnSchemaStepMPIv2();
	endTemp:= MPI_Wtime;
	writeln(myid, '| CalcOsnSchemaStepMPI cnt=', cnt, endTemp - startTemp: 9:6);
	startTemp:= endTemp;
		MPI_BCAST(@vIsDone, 1, MPI_INT, 0, MPI_COMM_WORLD);

		if myid = 0 then begin
   			addOsnNode();
		end;
   	until vIsDone = 1;

	FinalizeProcOsnShema();
	endTemp:= MPI_Wtime;
	writeln(myid, '| FinalizeProcOsnShema ', endTemp - startTemp: 9:6);
	startTemp:= endTemp;

	if myid = 0 then begin
	    endOsnMPI:= MPI_Wtime;
		totalOsnMPI:= endOsnMPI-startOsnMPI;
		writeln('totalOsnMPI', totalOsnMPI:9:6);
	end;
end;
