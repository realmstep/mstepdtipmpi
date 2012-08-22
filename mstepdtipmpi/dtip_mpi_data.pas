// �������� ������������ ������
// maxAmountInPieces >= 0 and <= max(longint) or const
// orderCnt > 0 and < max(longint) or const 
// sum(p[ai]) = 1
function validateData(): boolean;
var
	ab: boolean;
	ai: longint;
	asum: double;
begin
	ab:= ((nC>=0) and (nC <= 100000));
	if not ab then
		writeln('invalid maxAmountInPieces ', nC);
    validateData:= ab;

	ab:= ((M>0) and (M <= 10000));
	if not ab then
		writeln('invalid orderCnt ', M);
    validateData:= (validateData and ab);

    asum:= 0;
	for ai:=1 to M do begin
		asum:= asum + rudi[ai];
		if not(rlmni[ai]>=0) then begin
			writeln('invalid mn[', ai, ']');
			validateData:= false;
		end;
		if not(rlmni[ai]<=rlmxi[ai]) then begin
			writeln('invalid mx[', ai, ']');
			validateData:= false;
		end;
	end;
	ab:= (abs(asum-1)<0.000001);
	if not ab then
		writeln('invalid sum p[i] ', asum:9:6);
    validateData:= (validateData and ab);
end;

function InitOrders(): boolean;
var
	astr: string;
	ordersNode, NextNode: TDOMNode;
	ai: longint;
begin
	ordersNode:= inDoc.getElementsByTagName('orders')[0];
	ai:=0;
	NextNode:= ordersNode.firstChild;
	repeat
		inc(ai);
		if ai>M then break;

		rudi[ai]:=getDblAttrValue(NextNode, 'p', 0.0);
		rlmni[ai]:=getIntAttrValue(NextNode, 'mn', minAmountPerOrder);
		rlmxi[ai]:=getIntAttrValue(NextNode, 'mx', maxAmountPerOrder);
		rsti[ai] :=1; //業� �� ���� �� �� 䠩��
		rxi[ai]  :=0; //x �� �� - ��砫쭠� ���樠������
		rqi[ai]  :=0; //q ��� - ��砫쭠� ���樠������

	    NextNode := NextNode.NextSibling;
	until not Assigned(NextNode);
	Result:= (ai=M);
end;

function InitData():boolean;
var
	ai: longint;
	at: string;
	bOk: boolean;
begin
	InitializeXML();
	
	inFileName:= paramStr(1);
	if inFileName='' then
		inFileName:= 'dtipdata.xml';
	outFileName:= paramStr(2);
	if outFileName='' then
		outFileName:= 'dtip_mpi_out' + FormatDateTime('YYYYMMDDHHNNSS', now) + '.xml';
;
	
	ReadXMLFile(inDoc, inFileName);
	try

		maxIterationCnt:= getIntNodeValue(inDoc, 'maxIterationCnt', 1000000);// ��࠭�祭�� �� ���� ���-�� ���権
		minAmountPerOrder:= getIntNodeValue(inDoc, 'minAmountPerOrder', 0);
		maxAmountPerOrder:= getIntNodeValue(inDoc, 'maxAmountPerOrder', 2);

		cW:= getDblNodeValue(inDoc, 'cW', 0.8);// ५���樮��� �����⥫�.

		M:= getIntNodeValue(inDoc, 'orderCnt', 3); //���-�� ���

	    nC:= getIntNodeValue(inDoc, 'maxAmountInPieces', 5); // ����� �ਡ�� � ⠪��

		Ns:= 2 + (Nc + 1) * M; // ���-�� 䠧���� ���ﭨ�

		//0� ����� ����� �ய�᪠��
		SetLength(RNS, Ns+1);

		SetLength(rlmni, M+1);//��� ��࠭�祭��
		SetLength(rlmxi, M+1);//���� ��࠭�祭��
		SetLength(rsti , M+1);//�⮨����� �������
		SetLength(rudi , M+1);//��室 �������
		SetLength(rxi  , M+1);//��।������ ����ᮢ
		SetLength(rqi  , M+1);//���祭�� ������⥫��
		
		bOk:= InitOrders();
{	
	for ai:=1 to M do begin
		rlmni[ai]:=0; //���
		rlmxi[ai]:=2; //����
		rsti[ai] :=1; //業� �� 
//		rudi[1] :=0.2; //p ��室
		rxi[ai]  :=0; //x �� ��
		rqi[ai]  :=0; //q ���
	end;
	rlmni[2]:=1; //���
	rlmxi[2]:=1; //����

	rudi[1] :=2; //p ��室
	rudi[2] :=5; //p ��室
	rudi[3] :=3; //p ��室
}
		if not bOk then begin
			initData:= false;
			exit;
		end;
	finally
		inDoc.Free;
	end;

	Result:= validateData();
end;

function FinalizeData(): boolean;
// 䨭�������
begin 
	FinalizeXML();

	SetLength(RNS, 0);

	SetLength(rlmni, 0);//ReqTypeCnt
	SetLength(rlmxi, 0);//ReqTypeCnt
	SetLength(rsti , 0);//ReqTypeCnt
	SetLength(rudi , 0);//ReqTypeCnt
	SetLength(rxi  , 0);//ReqTypeCnt
	SetLength(rqi  , 0);//ReqTypeCnt

//	writeln('trace start');
//	trace(stateTransRootNode.firstChild,'');
//	writeln('trace finish');
end;