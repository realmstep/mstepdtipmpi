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
// �������� ������ � ���ᨢ� ����ᥩ �����
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
// �������� ������ � ���ᨢ� ����ᥩ �����
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
// Todo ��ࠬ���� �� �ᯮ�������
begin
	Result:= StateTransCnt;
	if arijk = low(longint) then begin
		Exit;
	end;
	StateTransCnt:= StateTransCnt + 1;
	Result:= StateTransCnt;
// �������� XML
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
	aj: longint;
begin
// �ᯮ���� XML
	stateTransNode:= stateTransRootNode.firstChild;
	for i:=1 to StateTransCnt do begin
		//���� ���� � �������� j
		aj:= getJbyRNS( getIntAttrValue(stateTransNode, 'RNSj', -1) );
		addIntAttribute(stateTransNode, 'j', aj);
		stateTransNode:= stateTransNode.NextSibling;
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
	j:= -1000; // �� ��।�����
	k:= 1; // ⮫쪮 ���� �����
	pijk:= 1; rijk:= 0;

	z1i:=-1; z2i:=-1; RNSi:=calcRNS(z1i, z2i, nC); RNS[i]:= RNSi;
// ��� ������������ �ࠢ�����
	z1j:= 0; z2j:= 0; RNSj:=calcRNS(z1j, z2j, nC);
	Ku1:=1; u1:=0;
// ��� ���������� �ࠢ�����
	Kv1:=0;
	v1:=-1000; // �� ��।�����
	v2:=-1000; // �� ��।�����
	nsgh:=-1000; // �� ��।�����
	
	StateTransCnt:= AddSStateTrans(
		i, j, k, pijk, rijk,
		z1i, z2i, RNSi, z1j, z2j, RNSj,
		u1, Ku1, v1, v2, Kv1, nsgh
	);
end;

function calcStateTransOrig(): longint;
// ॠ������ "� ���" �� �������-��ૠ����
begin
//  Result:= 0;
//  M:= ReqTypeCnt;//���-�� ���

  i:=1; // ������� ���ﭨ�
  AddStateTransForBaseState();
////////////////////////////////////////////////////////////////////////////////
  for z2:= M downto 1 do begin // �� ���� - ������⥫�
    for z1:=0 to Nc do begin // �� ������ - ������⢮ ��᪮�
     i:= i + 1; {i=2..Ns-1}
  // ��� ������������ �ࠢ����� 2.1
      Ku1:=0;
      u1:=-1000; // �� ��।�����
  // ��� ���������� �ࠢ����� 2.2
      pijk:= 1;

      z1i:=z1; z2i:=z2; RNSi:=calcRNS(z1i, z2i, nC); RNS[i]:= RNSi;

      if z2=M then begin
      // ���室 � ������� ���ﭨ� 2.2.2
        z1j:= -1; z2j:= -1; RNSj:=calcRNS(z1j, z2j, nC);
        rijk:= 0;
        Kv1:=1; v1:=0; v2:=0;
        k:=1;
        nsgh:=-1000; // �� ��।�����

        StateTransCnt:= AddSStateTrans(
          i, j, k, pijk, rijk,
          z1i, z2i, RNSi, z1j, z2j, RNSj,
          u1, Ku1, v1, v2, Kv1, nsgh);
      end // z2=M
      else {z2 < M 2.2.1} begin
        z2j:=z2+1;

        Kv1:=rlmxi[z2j]-rlmni[z2j]+1;
        k:=0;
        // �� �뤥����� ����� �� ᫥������ ���
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
            rijk:= low(longint); // �⮡� �� ���室��� � �� �������⨬�� ���
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
  i:=Ns; // ��室��� ���ﭨ�
//  z1:= 0;
  z2:= 0;
  z1i:= 0; z2i:= 0; RNSi:=calcRNS(z1i, z2i, nC); RNS[i]:=RNSi;

  // ��� ������������ �ࠢ����� 2.1
  Ku1:=0;
  u1:=-1000; // �� ��।�����

  j:= -1000; // �� ��।�����
  k:= -1000; // �� ��।�����

// ��� ���������� �ࠢ����� 2.2
  pijk := 1;
  z2j := z2 + 1; //!!! - ���������

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
      rijk:= low(longint); // �⮡� �� ���室��� � �� �������⨬�� ���
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

///////////////// ����䨪��� /////////////////////////////////////////
function procAddAllStateTransForOneState(): boolean;
begin
	Kv1:=procrlmxi[z2j]-procrlmni[z2j]+1; // ���-�� �ࠢ�����
	setLength(procStateTransArr, length(procStateTransArr) + Kv1 + 1); // � ����ᮬ �� �� �ࠢ�����, 0� �ய�᪠��

	k:=0; // ����� �ࠢ�����
	for h:= procrlmni[z2j] to procrlmxi[z2j] do begin
		k:=k+1;
		// mpi ���� ��।��� rsti � ����� ����� 
		nsgh:= procCalc_ns(z2j, h); // ����室��� �����
		if (z1i + nsgh)<=nC then begin // 2.2.1.1
			z1j:= z1i + nsgh;
			v1:= z2j;
			v2:= h;
			// mpi ���� ��।��� rudi � ����� ����� 
			rijk:= procrudi[z2j]*h; // ��室 �� ���室�
    	end
		else begin // 2.2.1.2
			z1j:= nC;
			rijk:= low(longint); // �⮡� �� ���室��� � �� �������⨬�� ���
			v1:= z2j;
			v2:= h;
		end;
		RNSj:=calcRNS(z1j, z2j, nC);
		// mpi ��������� � ������� ���ᨢ 䠧���� ���室�� ��� �����
		// mpi ����������� ������� StateTransCnt ��� �����
		procStateTransCnt:= procAddSStateTrans(
			i, j, k, pijk, rijk,
			z1i, z2i, RNSi, z1j, z2j, RNSj,
			u1, Ku1, v1, v2, Kv1, nsgh);

	end; // of for h

	setLength(procStateTransArr, procStateTransCnt+1); // ��⠢�塞 ⮫쪮 ���������� �ࠢ�����. 0� �ய�᪠��
end;

function AddAllStateTransForOneState(): boolean;
// �������� �� ���室� ��� ������ ��ﭨ�
begin
	// mpi ���� ��।��� rlmxi, rlmni � ����� �����

	Kv1:=rlmxi[z2j]-rlmni[z2j]+1; // ���-�� �ࠢ�����
	k:=0; // ����� �ࠢ�����
	for h:= rlmni[z2j] to rlmxi[z2j] do begin
		k:=k+1;
		// mpi ���� ��।��� rsti � ����� ����� 
		nsgh:= calc_ns(z2j, h); // ����室��� �����
		if (z1i + nsgh)<=nC then begin // 2.2.1.1
			z1j:= z1i + nsgh;
			v1:= z2j;
			v2:= h;
			// mpi ���� ��।��� rudi � ����� ����� 
			rijk:= rudi[z2j]*h; // ��室 �� ���室�
    	end
		else begin // 2.2.1.2
			z1j:= nC;
			rijk:= low(longint); // �⮡� �� ���室��� � �� �������⨬�� ���
			v1:= z2j;
			v2:= h;
		end;
		RNSj:=calcRNS(z1j, z2j, nC);
		// mpi ��������� � ������� ���ᨢ 䠧���� ���室�� ��� �����
		// mpi ����������� ������� StateTransCnt ��� �����
		StateTransCnt:= AddSStateTrans(
			i, j, k, pijk, rijk,
			z1i, z2i, RNSi, z1j, z2j, RNSj,
			u1, Ku1, v1, v2, Kv1, nsgh);
	end; // of for h
end;

function AddAllStateTransToBaseState(): boolean;
// �������� �� ���室� � ������� ���ﭨ� j = 1
begin
	z2:= M;
    for z1:=0 to Nc do begin // �� ������ - ������⢮ ��᪮�
		i:= i + 1; {i=2..Ns-1}
// ��� ������������ �ࠢ����� 2.1
	    Ku1:=0; u1:=-1000; // �� ��।�����
// ��� ���������� �ࠢ����� 2.2
		pijk:= 1;
		z1i:=z1; z2i:=z2; RNSi:=calcRNS(z1i, z2i, nC); RNS[i]:= RNSi;
//		if z2=M then begin
		// ���室 � ������� ���ﭨ� 2.2.2
        z1j:= -1; z2j:= -1; RNSj:=calcRNS(z1j, z2j, nC);
        rijk:= 0;
        Kv1:=1; v1:=0; v2:=0;
		// ⮫쪮 1
        k:=1;
        nsgh:=-1000; // �� ��।�����

        StateTransCnt:= AddSStateTrans(
			i, j, k, pijk, rijk,
			z1i, z2i, RNSi, z1j, z2j, RNSj,
			u1, Ku1, v1, v2, Kv1, nsgh);
//      end // z2=M
	end;
end;

function AddAllStateTransForInitialState(): boolean;
// �������� �� ���室� ��� ��室���� ���ﭨ�
begin
	i:= Ns; // ��室��� ���ﭨ�
	z1i:= 0; z2i:= 0; RNSi:=calcRNS(z1i, z2i, nC); RNS[i]:=RNSi;

	// ��� ������������ �ࠢ����� 2.1
	Ku1:=0; u1:=-1000; // �� ��।�����

	j:= -1000; // �� ��।�����
	k:= -1000; // �� ��।�����

	// ��� ���������� �ࠢ����� 2.2
	pijk := 1;
	z2j := 1;

	AddAllStateTransForOneState();
end;


function InitProcStateTrans(): boolean;
// �����⮢�� ������ ��� ����
// ࠧ�᫠�� ��騥 ����� M ���-�� ���, Nc ���-�� ���権 �����, Ns ���-�� ���ﭨ�
// ������� ���-�� ���, ����� ��ࠡ��뢠�� ����� �����. ��࠭��� � ���ᨢ. ࠧ�᫠��
var
	restM, ai: longint;	
begin
	// ��騥 �����	
	MPI_BCAST(@M, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_BCAST(@Nc, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_BCAST(@Ns, 1, MPI_INT, 0, MPI_COMM_WORLD);

	// ���� ���-�� ��� ��� �����
    if myid = 0 then begin
		setLength(procMArr, numprocs);

		procM:= (M-1) div numprocs; //M-1 ��⮬� ��� ��� M� ��� ��⠥� �⤥�쭮

		if ((M-1) mod numprocs) > 0 then begin // ��� ��楫� �� ������� �� ����ᠬ
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
//				writeln(myid, '|procMArr[', ai, '] = ', procMArr[ai]);
			end;
		end
		else begin // ��� ��楫� ������� �� ����ᠬ 
			for ai:=0 to numprocs-1 do begin
				procMArr[ai]:=procM;
			end;
		end;
	end;

	// ���뫪� ���-�� ��� �� ����ᠬ
	if myid = 0 then
		for ai:=0 to numprocs-1 do
			MPI_SEND(@procMArr[ai], 1, MPI_INT, ai, teg, MPI_COMM_WORLD);

	// ����祭�� ���-�� ��� �� ����ᠬ
	MPI_RECV(@procM, 1, MPI_INT, 0, teg, MPI_COMM_WORLD, status);
//	writeln(myid, '| procM = ', procM);

	// ���뫪� ��砫쭮�� ����� ��� �� ����ᠬ
	if myid = 0 then begin
		procUpM:= M-1;
		for ai:= 0 to numprocs-1 do begin
			MPI_SEND(@procUpM, 1, MPI_INT, ai, teg, MPI_COMM_WORLD);
			procUpM:= procUpM - procMArr[ai];
		end;
	end;

	// ����祭�� ��砫쭮�� ����� ��� �� ����ᠬ
	MPI_RECV(@procUpM, 1, MPI_INT, 0, teg, MPI_COMM_WORLD, status);

	procDownM:= procUpM - procM + 1;
	writeln(myid, '| procUpM = ', procUpM, ' procDownM = ', procDownM, ' procM = ', procM);


	// ���樠������ ������ ��� �����
	setLength(procrlmxi, M+1);
	setLength(procrlmni, M+1);
	setLength(procrsti, M+1);
	setLength(procrudi, M+1);
//	setLength(procrxi, M+1);
//	setLength(procrqi, M+1);
	
	// ���뫪� ������ ��� ���� � �����
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
	end;
end;


function packProcStateTransArr(aarr : array of tStateTransRec; abuf: pointer): boolean;
var
	ai: longint;
//	acur_buf, acur_buf1: pointer;
	acur_buf: ^tStateTransRec;
begin
	for ai:=1 to length(aarr)-1 do begin
		acur_buf:=abuf+(sizeOfStateTransRec*(ai-1)); // ᬥ饭�� �� ��� ������
        acur_buf^:= aarr[ai];
	end;

end;

function unpackProcStateTransArr(abuf: pointer; aRecCnt: longint): boolean;
var
	ai: longint;
	acur_buf: ^tStateTransRec;
begin
	// 㢥����� ࠧ��� ���ᨢ� StateTransArr
//	writeln('old length(StateTransArr) = ', length(StateTransArr), 'new length = ', length(StateTransArr) + aRecCnt);
	setLength(StateTransArr, length(StateTransArr) + aRecCnt);

	for ai:=1 to aRecCnt do begin
		acur_buf:=abuf+(sizeOfStateTransRec*(ai-1)); // ᬥ饭�� �� ��� ������
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
// ॠ������ "����������ୠ�" ����䨪��� - �⥯���
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
		i:= 1;
		AddStateTransForBaseState();
		// j:= 1. �� ���室� � ������� ���ﭨ� 2.2.2. ��� ��⨬���樨 �뭥ᥭ� �� 横�� (�࠭� �᫮��� � 横��) 
		AddAllStateTransToBaseState();

		tempStateTransCnt:= StateTransCnt;
		setLength(StateTransArr, StateTransCnt + 1);// �ய�᪠�� 0�

	    startStateTransMPI:= MPI_Wtime;
	end;

	// 1 ������� ������⢮ ��� ��� ����� procM
	// ࠧ�᫠�� procM
	// ࠧ�᫠�� procData: proclmxi, proclmni, procrsti, procrudi
//    startTemp:= MPI_Wtime; 
	InitProcStateTrans();
//	endTemp:= MPI_Wtime;
//	writeln(myid, '| InitProcStateTrans ', endTemp - startTemp: 9:6);
//    startTemp:= endTemp;
	// �믮���� 横� ���� ��� ������� �����
	// 2 �᭮���� 横� ���室�� z2<M
//	for z2:= M-1 downto 1 do begin // �� ���� - ������⥫�
	startI:= 1 + Nc + 1 + ((Nc+1)*(M-1 - procUpM));
	setLength(procRNS, procM*(Nc+1) + 1); //0� �ய�᪠��
	i:= startI;// �ய��⨫� ��ࠡ�⠭�� ��㣨�� ����ᠬ�
	procStateTransCnt:=0;
	for z2:= procUpM downto procDownM do begin // �� ���� - ������⥫�
		// mpi �� z2 - ����� ������� 蠣 ��� ����� ��� �-�� �� ����� �����
		z2j:=z2+1;

		for z1:=0 to Nc do begin // �� ������ - ������⢮ ��᪮�
			// mpi ���ਬ�������� ������� -> ����� ������� 蠣 ��� �����
			// ��� ������� ���祭�� z2 ������ Nc+1 ���६��� -> ���� ��।��� Nc

			i:= i + 1; {i=1+Nc..Ns-1, �஬� ���室��: �� �������� ��� 1��, � ������� ��� Nc ��, � �� ��室���� ���}
//			writeln(myid, '| i ', i);
			// ��� ������������ �ࠢ����� 2.1
			Ku1:=0; u1:=-1000; // �� ��।�����
			// ��� ���������� �ࠢ����� 2.2
			pijk:= 1;

			z1i:=z1; z2i:=z2; RNSi:=calcRNS(z1i, z2i, nC); 
			// mpi ���������� RNS - ������ �� ������� �����

			procRNS[i-startI]:= RNSi; //RNS[i]:= RNSi;
			// ���室 � ������� ���ﭨ� 2.2.2 ��������� � AddAllStateTransToBaseState
			// {z2 < M 2.2.1}
			// z2j:=z2+1;// �뭥ᥭ� ��� for z2 ...
			procAddAllStateTransForOneState();
		end; // z1
	end; // z2
	// mpi - ᮡ��� ������� ���ᨢ� 䠧���� ���室�� �� ����ᮢ
//	endTemp:= MPI_Wtime;
//	writeln(myid, '| StateTrans main Cycle ', endTemp - startTemp: 9:6);
//    startTemp:= endTemp;

	// 3 ������ � ������ �����
	// - ���-�� ���室�� procStateTransCnt
	// - ���ᨢ ���室�� procStateTransArr
	// - ���ᨢ procRNS
    	startTemp1:= MPI_Wtime;

	// - ���-�� ���室�� procStateTransCnt
	MPI_SEND(@procStateTransCnt, 1, MPI_INT, 0, teg, MPI_COMM_WORLD);
	if myid = 0 then begin
		setLength(procStateTransCntArr, numprocs);
		for ai:=0 to numprocs-1 do begin
			MPI_RECV(@procStateTransCntArr[ai], 1, MPI_INT, ai, teg, MPI_COMM_WORLD, status);
//			writeln(myid, '| procStateTransCntArr[', ai, '] = ', procStateTransCntArr[ai]);
		end;
	end;
//		endTemp1:= MPI_Wtime;
//		writeln(myid, '| MPI_BSEND(procStateTrans: MPI_RECV(@procStateTransCntArr[ai] ', endTemp1 - startTemp1: 9:6);
//    	startTemp1:= endTemp1;

	// - ���ᨢ ���室�� procStateTransArr
    procStateTransSendBufSize := procStateTransCnt*sizeOfStateTransRec;
	try
		getMem(procStateTransSendBuf, procStateTransSendBufSize);

//		endTemp1:= MPI_Wtime;
//		writeln(myid, '| MPI_BSEND(procStateTrans: getMem(procStateTransSendBuf ', endTemp1 - startTemp1: 9:6);
//    	startTemp1:= endTemp1;

//writeln(myid, '| before packProcStateTransArr');
		packProcStateTransArr(procStateTransArr, procStateTransSendBuf);

//		endTemp1:= MPI_Wtime;
//		writeln(myid, '| MPI_BSEND(procStateTrans: packProcStateTransArr ', endTemp1 - startTemp1: 9:6);
//    	startTemp1:= endTemp1;

//writeln(myid, '| after packProcStateTransArr', ' procStateTransSendBufSize = ', procStateTransSendBufSize);
//        MPI_buffer_attach
		bufsize:=procStateTransSendBufSize + MPI_BSEND_OVERHEAD;
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
		MPI_BUFFER_DETACH(buf, bufsize);
		freeMem(buf, bufsize);
		freeMem(procStateTransSendBuf, procStateTransSendBufSize);
	end;

//		endTemp1:= MPI_Wtime;
//		writeln(myid, '| MPI_BSEND(procStateTrans: freeMem(procStateTransSendBuf ', endTemp1 - startTemp1: 9:6);
//    	startTemp1:= endTemp1;

//	endTemp:= MPI_Wtime;
//	writeln(myid, '| MPI_BSEND(procStateTrans ', endTemp - startTemp: 9:6);
//    startTemp:= endTemp;

	// - ���ᨢ procRNS
//	writeln(myid, '| before procRNS');
	sendCnt:= procM*(Nc+1); //0� �ய�᪠�� . �.� ࠢ�� length(procRNS)-1
//	sendBuf, recBuf: pointer;
	sendBufSize:= sizeOfLongint*sendCnt;
	try
		getMem(sendBuf, sendBufSize);
//		for ai:=1 to sendCnt do
//			writeln('procRNS[', ai, '] = ', procRNS[ai]);			
		pack_arrInt(procRNS, sendBuf);

		MPI_SEND(sendBuf, sendCnt, MPI_INT, 0, teg, MPI_COMM_WORLD);

		if myid = 0 then begin
			procUpM:= M-1;
    		for ai:=0 to numprocs-1 do begin
				recvCnt:= procMArr[ai]*(Nc+1);
				recvBufSize:= sizeOfLongint*recvCnt;
				try
					getMem(recvBuf, recvBufSize);
					MPI_RECV(recvBuf, recvCnt, MPI_INT, ai, teg, MPI_COMM_WORLD, status);
					// �������� �� ���� � RNS
					startI:= 1 + (Nc + 1) + ((Nc+1)*(M-1-procUpM));
//					for aj:= 1 to length(aa)-1 do begin	// �ய�᪠�� 0� �����
					for aj:= 1 to procMArr[ai]*(Nc+1) do begin	// �ய�᪠�� 0� �����
						acur_buf:= recvBuf+(sizeOfLongint*(aj-1));
						RNS[startI+aj]:= acur_buf^;
//						writeln('RNS[', startI+aj,'] = ', acur_buf^);
					end;
				finally
					freeMem(recvBuf, recvBufSize);
				end;
				procUpM:= procUpM - procMArr[ai];
			end;
		end;
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


	//i:=Ns; �������� �� ���室� ��� ��室���� ���ﭨ�
	if myid = 0 then begin
	    endStateTransMPI:= MPI_Wtime;
		totalStateTransMPI:=totalStateTransMPI + endStateTransMPI-startStateTransMPI;
		writeln(myid, '| totalStateTransMPI ', totalStateTransMPI: 9:6);

		//�����஢��� � ���� �� ����� ��। ������ 横��� �� ⥪�饣�
//		writeln('tempStateTransCnt+1 = ', tempStateTransCnt+1
//			, ' StateTransCnt = ', StateTransCnt
//			, ' length(StateTransArr) = ', length(StateTransArr));
		for ai:= tempStateTransCnt+1 to StateTransCnt do begin
			with StateTransArr[ai] do begin
				addStateTransNode(
    			  ri, rj, rk, rpijk, rrijk,
	    		  rz1i, rz2i, rRNSi, rz1j, rz2j, rRNSj,
			      ru1, rKu1, rv1, rv2, rKv1, rnsgh
				);
			end;
		end;

		setLength(StateTransArr, 0);

//		writeln(' before AddAllStateTransForInitialState ');

		AddAllStateTransForInitialState();

//		writeln(' after AddAllStateTransForInitialState ');
	end;
end;
