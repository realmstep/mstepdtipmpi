// яЁютхЁъш ъюЁЁхъЄэюёЄш фрээ√ї
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
		rsti[ai] :=1; //цена ед пока не из файла
		rxi[ai]  :=0; //x выд рес - начальная инициализация
		rqi[ai]  :=0; //q пок - начальная инициализация

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

		maxIterationCnt:= getIntNodeValue(inDoc, 'maxIterationCnt', 1000000);// ограничение на макс кол-во итераций
		minAmountPerOrder:= getIntNodeValue(inDoc, 'minAmountPerOrder', 0);
		maxAmountPerOrder:= getIntNodeValue(inDoc, 'maxAmountPerOrder', 2);

		cW:= getDblNodeValue(inDoc, 'cW', 0.8);// релаксационный множитель.

		M:= getIntNodeValue(inDoc, 'orderCnt', 3); //кол-во заявок

	    nC:= getIntNodeValue(inDoc, 'maxAmountInPieces', 5); // ресурс прибора в тактах

		Ns:= 2 + (Nc + 1) * M; // кол-во фазовых состояний

		//0й элемент везде пропускаем
		SetLength(RNS, Ns+1);

		SetLength(rlmni, M+1);//мин ограничение
		SetLength(rlmxi, M+1);//макс ограничение
		SetLength(rsti , M+1);//стоимость единицы
		SetLength(rudi , M+1);//доход единицы
		SetLength(rxi  , M+1);//распределение ресурсов
		SetLength(rqi  , M+1);//значения показателей
		
		bOk:= InitOrders();
{	
	for ai:=1 to M do begin
		rlmni[ai]:=0; //мин
		rlmxi[ai]:=2; //макс
		rsti[ai] :=1; //цена ед 
//		rudi[1] :=0.2; //p доход
		rxi[ai]  :=0; //x выд рес
		rqi[ai]  :=0; //q пок
	end;
	rlmni[2]:=1; //мин
	rlmxi[2]:=1; //макс

	rudi[1] :=2; //p доход
	rudi[2] :=5; //p доход
	rudi[3] :=3; //p доход
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
// финализация
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