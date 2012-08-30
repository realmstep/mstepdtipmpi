const
	sizeOfDouble = sizeOf(Double);
	sizeOfLongint = sizeOf(Longint);

// INT /////////////////////////////////////////////////////////////////////////////////
function pack_arrInt(aa: array of longint; abuf: pointer):boolean;
var
	ai: longint;
	acur_buf: ^longint;
begin
	// ���������� 0� �������
	for ai:= 1 to length(aa)-1 do begin
		acur_buf:=abuf+(sizeOfLongint*(ai-1));
		acur_buf^:= aa[ai];
	end;
end;

function unpack_arrInt(abuf: pointer; var aa: array of longint): boolean;
var
	ai: longint;
	acur_buf: ^longint;
begin
	// ���������� 0� �������
	for ai:= 1 to length(aa)-1 do begin
		acur_buf:= abuf+(sizeOfLongint*(ai-1));
		aa[ai]:= acur_buf^;
	end;
end;

function bcast_arrInt(asend : array of Longint; var arecv: array of Longint): boolean;
var
	sendBuf, recvBuf: pointer;
	sendBufSize, recvBufSize, sendCnt: Longint;
begin
	if myid = 0 then
		sendCnt:= length(asend)-1 //0� ����������
	else
		sendCnt:= length(arecv)-1;//0� ����������
	sendBufSize:= sizeOfLongint*sendCnt; 
	try
		getMem(sendBuf, sendBufSize);
		if myid=0 then begin
			pack_arrInt(asend, sendBuf);
		end;
		MPI_BCAST(sendBuf, sendCnt, MPI_INT, 0, MPI_COMM_WORLD);

	finally
		unpack_arrInt(sendBuf, arecv);
		freeMem(sendBuf, sendBufSize);
	end;
end;

function bcast_arrInt2Dim(asend: T2DimArrOfLogint; var arecv: T2DimArrOfLogint): boolean;
// ��������� ��������� ������
var
	ai, aj, shift: longint;
	sendCnt, recvCnt: longint;
	sendBuf: pointer;
	sendBufSize, recvBufSize: longint;
	sendArrSizes, recvArrSizes : array of longint;
	acurBuf: ^longint;
begin
	// �������� ������ �������� Length(asend[ai]
	if myid = 0 then begin
		setLength(sendArrSizes, length(asend));
	end;
	setLength(recvArrSizes, length(arecv));

	if myid = 0 then begin
//		sendCnt:=0;
		for ai:= 1 to length(asend)-1 do begin //0� ����������
			sendArrSizes[ai]:= length(asend[ai])-1;
//			writeln('sendArrSizes[',ai,']', sendArrSizes[ai])
//			sendCnt:= sendCnt + sendArrSizes[ai];
		end;
	end;
	bcast_arrInt(sendArrSizes, recvArrSizes);
	sendCnt:=0;
	for ai:= 1 to length(arecv)-1 do begin //0� ����������
		if recvArrSizes[ai]>0 then // ����� ���������� ai, �� ������ = -1
			sendCnt:= sendCnt + recvArrSizes[ai];
//		writeln('recvArrSizes[',ai,'] = ', recvArrSizes[ai])
	end;

	sendBufSize:= sendCnt*sizeOfLongint;
//	writeln(myid, '| sendCnt = ', sendCnt, ' recvCnt = ', recvCnt);
	try
		getMem(sendBuf, sendBufSize);

		if myid = 0 then begin
			// ��������� asend (���������) � �����
			shift:=0;
			for ai:= 1 to length(asend)-1 do begin //
				for aj:= 1 to length(asend[ai])-1 do begin 
					acurBuf:= sendBuf + shift;
					acurBuf^:= asend[ai, aj];
					shift:= shift + sizeOfLongint; // ��������
				end;
			end;
//			writeln('asend[ai, aj] =', asend[ai, aj]);
		end;

		// �������� ����� ����� bcast
		MPI_BCAST(sendBuf, sendCnt, MPI_INT, 0, MPI_COMM_WORLD);
		// ����������� arecv (���������)
		shift:=0;
		for ai:= 1 to length(arecv)-1 do begin //
			setLength(arecv[ai], recvArrSizes[ai]+1); // ���������� ������ ���������� ��������
			for aj:= 1 to length(arecv[ai])-1 do begin 
				acurBuf:= sendBuf + shift;
				arecv[ai, aj]:= acurBuf^;
				shift:= shift + sizeOfLongint;// ��������
			end;
		end;
//			writeln('arecv[ai, aj] =', arecv[ai, aj]);
	finally
		freeMem(sendBuf, sendBufSize);
	end;
end;

// Dbl //////////////////
function pack_arrDbl(aa: array of Double; abuf: pointer) : boolean;
var
	ai: longint;
	acur_buf: ^Double;
begin
	// ���������� 0� �������
	for ai:= 1 to length(aa)-1 do begin
		acur_buf:=abuf+(sizeOfDouble*(ai-1));
			acur_buf^:= aa[ai];
	end;
end;

function unpack_arrDbl(abuf: pointer; var aa: array of Double):boolean;
var
	ai: longint;
	acur_buf: ^Double;
begin
	// ���������� 0� �������
	for ai:= 1 to length(aa)-1 do begin
		acur_buf:= abuf+(sizeOfDouble*(ai-1));
		aa[ai]:= acur_buf^;
	end;
end;

function bcast_arrDbl(asend : array of double; var arecv: array of double): boolean;
var
	sendBuf, recvBuf: pointer;
	sendBufSize, recvBufSize, sendCnt: longint;
begin
	if myid = 0 then
		sendCnt:= length(asend)-1 //0� ����������
	else
		sendCnt:= length(arecv)-1;//0� ����������
	sendBufSize:= sizeOfDouble*sendCnt; 
	try
		getMem(sendBuf, sendBufSize);
		if myid=0 then begin
			pack_arrDbl(asend, sendBuf);
		end;
		MPI_BCAST(sendBuf, sendCnt, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	finally
		unpack_arrDbl(sendBuf, arecv);
		freeMem(sendBuf, sendBufSize);
	end;
end;

function bcast_arrDbl2Dim(asend: T2DimArrOfDouble; var arecv: T2DimArrOfDouble): boolean;
// ��������� ��������� ������
var
	ai, aj, shift: longint;
	sendCnt, recvCnt: longint;
	sendBuf: pointer;
	sendBufSize, recvBufSize: longint;
	sendArrSizes, recvArrSizes : array of longint;
	acurBuf: ^double;
begin
	// �������� ������ �������� Length(asend[ai]
	if myid = 0 then begin
		setLength(sendArrSizes, length(asend));
	end;
	setLength(recvArrSizes, length(arecv));

	if myid = 0 then begin
//		sendCnt:=0;
		for ai:= 1 to length(asend)-1 do begin //0� ����������
			sendArrSizes[ai]:= length(asend[ai])-1;
//			sendCnt:= sendCnt + sendArrSizes[ai];
		end;
	end;
	bcast_arrInt(sendArrSizes, recvArrSizes);
	sendCnt:=0;
	for ai:= 1 to length(arecv)-1 do begin //0� ����������
		if recvArrSizes[ai]>0 then // ����� ���������� ai, �� ������ = -1
			sendCnt:= sendCnt + recvArrSizes[ai];
	end;

//	if myid = 0 then 
		sendBufSize:= sendCnt*sizeOfDouble;
//	else
//		sendBufSize:= recvCnt*sizeOfDouble;

	try
		getMem(sendBuf, sendBufSize);
		if myid = 0 then begin
			// ��������� asend (���������) � �����
			shift:=0;
			for ai:= 1 to length(asend)-1 do begin //
				for aj:= 1 to length(asend[ai])-1 do begin 
					acurBuf:= sendBuf + shift;
					acurBuf^:= asend[ai, aj];
					shift:= shift + sizeOfDouble; // ��������
				end;
			end;
		end;
		// �������� ����� ����� bcast
		MPI_BCAST(sendBuf, sendCnt, MPI_DOUBLE, 0, MPI_COMM_WORLD);
		// ����������� arecv (���������)
		shift:=0;
		for ai:= 1 to length(arecv)-1 do begin //
			setLength(arecv[ai], recvArrSizes[ai]+1); // ���������� ������ ���������� ��������
			for aj:= 1 to length(arecv[ai])-1 do begin 
				acurBuf:= sendBuf + shift;
				arecv[ai, aj]:= acurBuf^;
				shift:= shift + sizeOfDouble;// ��������
			end;
		end;
	finally
		freeMem(sendBuf, sendBufSize);
	end;
end;

{
function scatterV_arrDbl(asend : array of double; var arec: array of double): boolean;
var
	sendBuf, recBuf: pointer;
	sendBufSize, recBufSize, aRecCnt: longint;
begin
	sendBufSize:= sizeOfDouble*(length(asend)-1); //���������� 0� �������
	aRecCnt:= (length(arec)-1); //���������� 0� �������
	recBufSize:= sizeOfDouble*aRecCnt;
	try
		if myid=0 then begin
			getMem(sendBuf, sendBufSize);
			pack_arrDbl(asend, sendBuf);
		end;
		getMem(recBuf, recBufSize);
		// �������� ������� �� numproc ������ �� sendcounts - �������� � ���������
		MPI_SCATTERV(sendBuf, sendcounts[0], displs[0], MPI_DOUBLE, recBuf, aRecCnt, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	finally
		unpack_arrDbl(recBuf, arec);
		freeMem(recBuf, recBufSize);
		if myid=0 then
			freeMem(sendBuf, sendBufSize);
	end;
end;
}

