var
	aDoc: TXMLDocument;
	RootNode, parentNode, textNode, commentNode: TDOMNode;
	stateTransRootNode, stateTransNode: TDOMNode;
	osnStepRootNode, osnStepNode: TDOMNode;
	tempRootNode, tempNode: TDOMNode;

function getIntNodeValue(aDoc: TXMLDocument;aname: string; adef: longint): longint;
var
	astr: string;
begin
	astr:= aDoc.getElementsByTagName(aname)[0].TextContent;
	if astr='' then
		getIntNodeValue:= adef
	else
		getIntNodeValue:= StrToInt(astr);
end;

function getIntAttrValue(anode:TDOMNode; aname: string; adef: longint): longint;
var
	astr: string;
begin
	astr:= TDOMElement(aNode).getAttribute(aname);
	if astr='' then
		getIntAttrValue:= adef
	else
		getIntAttrValue:= StrToInt(astr);
end;

function getDblNodeValue(aDoc: TXMLDocument;aname: string; adef: double): double;
var
	astr: string;
begin
	astr:= aDoc.getElementsByTagName(aname)[0].TextContent;
	if astr='' then
		Result:= adef
	else
		Result:= StrToFloat(astr);
end;

function getDblAttrValue(anode:TDOMNode; aname: string; adef: Double): Double;
var
	astr: string;
begin
	astr:= TDOMElement(aNode).getAttribute(aname);
	if astr='' then
		getDblAttrValue:= adef
	else
		getDblAttrValue:= StrToFloat(astr);
end;

function getBoolNodeValue(aDoc: TXMLDocument;aname: string; adef: boolean): boolean;
var
	astr: string;
begin
	astr:= aDoc.getElementsByTagName(aname)[0].TextContent;
	if astr='' then
		result:= adef
	else
		result:= StrToBool(astr);
end;

function getStrNodeValue(aDoc: TXMLDocument;aname: string; adef: string): string;
var
	astr: string;
begin
	astr:= aDoc.getElementsByTagName(aname)[0].TextContent;
	if astr='' then
		result:= adef
	else
		result:= astr;
end;

/////////////////////////////////
function addIntNode(var aRootNode:TDOMNode; aNodeName:string; aNodeValue:Longint):boolean;
begin	
	parentNode:=aDoc.CreateElement(aNodeName);
	textNode:=aDoc.CreateTextNode(Format('%d',[aNodeValue]));
	parentNode.AppendChild(textNode);
	aRootNode.AppendChild(parentNode);
end;

function addDblNode(var aRootNode:TDOMNode; aNodeName:string; aNodeValue:Double):boolean;
begin	
	parentNode:=aDoc.CreateElement(aNodeName);
	textNode:=aDoc.CreateTextNode(Format('%.5f',[aNodeValue]));
	parentNode.AppendChild(textNode);
	aRootNode.AppendChild(parentNode);
end;

function addIntAttribute(var aNode:TDOMNode; aName:string; aValue:longint):boolean;
begin	
	TDOMElement(aNode).SetAttribute(aName, Format('%d',[aValue]));
end;

function addDblAttribute(var aNode:TDOMNode; aName:string; aValue:Double):boolean;
begin	
	TDOMElement(aNode).SetAttribute(aName, Format('%f',[aValue]));
end;

function addStrAttribute(var aNode:TDOMNode; aName:string; aValue:string):boolean;
begin	
	TDOMElement(aNode).SetAttribute(aName, aValue);
end;

function InitializeXML():boolean;
var
	aNode: TDOMNode;
begin
	aDoc:= TXMLDocument.create;
	aNode := aDoc.CreateElement('dtipout');
	aDoc.AppendChild(aNode);
	RootNode:=aDoc.DocumentElement;

   	stateTransRootNode:=aDoc.CreateElement('stateTransRoot');

   	osnStepRootNode:=aDoc.CreateElement('osnStepRoot');
end;

// вывод данных наилучшего распределения в XML
// вариант 2.
// скопировать данные из входного файла 
// изменить значения на нижнем уровне
// обновить значения узлов
// проверить значение для верхнего узла
function ordersXMLOut(): boolean;
var
	inOrdersNode, inNodeorderNode, NextNode: TDOMNode;
	ai, axsum, axtotal: longint;
	aqsum, aqtotal:double;
	nodeList: TDOMNodeList;
begin
	commentNode:=aDoc.CreateComment('best distribution');
	RootNode.AppendChild(commentNode);
	// скопировать данные из входного файла 
	ReadXMLFile(inDoc, inFileName);
	tempRootNode:= aDoc.importNode(inDoc.getElementsByTagName('orders')[0],true);
	inDoc.Free;
   	RootNode.AppendChild(tempRootNode);
	// изменить значения на нижнем уровне
	nodeList:= aDoc.getElementsByTagName('order');
	axtotal:= 0;
	aqtotal:= 0;
	for ai:=1 to nodeList.length do begin
	    tempNode:= nodeList[ai-1];
		TDOMElement(tempNode).SetAttribute('q', Format('%1.5f',[rxi[ai]*getDblAttrValue(tempNode, 'p', 0)]));
		TDOMElement(tempNode).SetAttribute('x', Format('%d',[rxi[ai]]));
		axtotal:= axtotal + rxi[ai];
		aqtotal:= aqtotal + rudi[ai]*rxi[ai];
	end;
	// обновить значения узлов. Предполагаем что 1 уровень
	nodeList:= aDoc.getElementsByTagName('nodeorder');
	for ai:=1 to nodeList.length do begin
	    tempNode:= nodeList[ai-1];
		// перебор по надам нижнего уровня
		nextNode:= tempNode.firstChild;
		axsum:=0;
		aqsum:=0;
		repeat
			axsum:=axsum + getIntAttrValue(nextNode, 'x', 0);
			aqsum:=aqsum + getDblAttrValue(nextNode, 'q', 0);
			nextNode:= nextNode.nextSibling;
		until not(Assigned(nextNode));
		TDOMElement(tempNode).SetAttribute('x', Format('%d',[axsum]));
		TDOMElement(tempNode).SetAttribute('q', Format('%1.5f',[aqsum]));
	end;
	// обновить верхний узел
	TDOMElement(tempRootNode).SetAttribute('x', Format('%d',[axtotal]));
	TDOMElement(tempRootNode).SetAttribute('q', Format('%1.5f',[aqtotal]));

end;

function FinalizeXML():boolean;
var
	ai: longint;
begin
	// основные параметры
	commentNode:=aDoc.CreateComment('main data');
   	tempRootNode:=aDoc.CreateElement('mainDataRoot');
	addIntNode(tempRootNode, 'numprocs', numprocs);
	addIntNode(tempRootNode, 'orderCnt', M);
	addIntNode(tempRootNode, 'resourceCnt', Nc);
	addIntNode(tempRootNode, 'stateCnt', Ns);
	addIntNode(tempRootNode, 'stateTransCnt', stateTransCnt);
	RootNode.AppendChild(commentNode);
   	RootNode.AppendChild(tempRootNode);

	// вывод распределения
// вариант 2. с учетом 1го уровня иерархии	
	ordersXMLOut();
{
вариант 1. без иерархии
	commentNode:=aDoc.CreateComment('best distribution');
	RootNode.AppendChild(commentNode);
   	tempRootNode:=aDoc.CreateElement('orders');

	for ai:= 1 to M do begin
		tempNode:=aDoc.CreateElement('order');
		TDOMElement(tempNode).SetAttribute('q', Format('%1.5f',[rudi[ai]*rxi[ai]]));
		TDOMElement(tempNode).SetAttribute('p', Format('%1.5f',[rudi[ai]]));
		TDOMElement(tempNode).SetAttribute('x', Format('%3d',[rxi[ai]]));
		TDOMElement(tempNode).SetAttribute('mn', Format('%3d',[rlmni[ai]]));
		TDOMElement(tempNode).SetAttribute('mx', Format('%3d',[rlmxi[ai]]));
//		TDOMElement(tempNode).SetAttribute('name', Format('%d',[i]));
		tempRootNode.AppendChild(tempNode);
	end;
   	RootNode.AppendChild(tempRootNode);
}

	// основные результаты
	commentNode:=aDoc.CreateComment('results');
	RootNode.AppendChild(commentNode);
   	tempRootNode:=aDoc.CreateElement('resultsRoot');
//	tempRootNode.AppendChild(commentNode);
	addDblNode(tempRootNode, 'bestValue', rQSumMax);

	// время выполнения
	addDblNode(tempRootNode, 'totaltime', totaltime);
	addDblNode(tempRootNode, 'totalStateTrans', totalStateTrans);
	addDblNode(tempRootNode, 'totalStateTransMPI', totalStateTransMPI);// по 0му процессу
	addDblNode(tempRootNode, 'totalOsn', totalOsn);
	addDblNode(tempRootNode, 'totalOsnMPI', totalOsnMPI);

	// трассировка для основной схемы. можно убрать после отладки
	commentNode:=aDoc.CreateComment(rTrace);
	tempRootNode.AppendChild(commentNode);

   	RootNode.AppendChild(tempRootNode);

	// данные о фазовых переходах. можно убрать после отладки
	commentNode:=aDoc.CreateComment('state trans data');
	RootNode.AppendChild(commentNode);
   	RootNode.AppendChild(stateTransRootNode);

	// данные о шагах основной схемы оптимизации. можно убрать после отладки
	commentNode:=aDoc.CreateComment('osn schema steps data');
	RootNode.AppendChild(commentNode);
   	RootNode.AppendChild(osnStepRootNode);

	writeXMLFile(aDoc, outFileName);
	aDoc.Free;
end;

function addStateTransNode(
	ai, aj, ak: longint; apijk, arijk: double;
	az1i, az2i, aRNSi, az1j, az2j, aRNSj, au1, aku1, av1, av2, akv1, ansgh: longint
):boolean;
begin
	if not addStateTrans then exit;
	stateTransNode:=aDoc.CreateElement('stateTrans');
	addIntAttribute(stateTransNode, 'i', ai);
	addIntAttribute(stateTransNode, 'j', aj);
	addIntAttribute(stateTransNode, 'k', ak);

	addDblAttribute(stateTransNode, 'pijk', apijk);
	addDblAttribute(stateTransNode, 'rijk', arijk);

	addIntAttribute(stateTransNode, 'z1i', az1i);
	addIntAttribute(stateTransNode, 'z2i', az2i); 
	addIntAttribute(stateTransNode, 'RNSi', aRNSi); 
	addIntAttribute(stateTransNode, 'z1j', az1j); 
	addIntAttribute(stateTransNode, 'z2j', az2j); 
	addIntAttribute(stateTransNode, 'RNSj', aRNSj); 
	addIntAttribute(stateTransNode, 'u1', au1); 
	addIntAttribute(stateTransNode, 'ku1', aku1); 
	addIntAttribute(stateTransNode, 'v1', av1); 
	addIntAttribute(stateTransNode, 'v2', av2); 
	addIntAttribute(stateTransNode, 'kv1', akv1); 
	addIntAttribute(stateTransNode, 'nsgh',  ansgh);

	stateTransRootNode.AppendChild(stateTransNode);
end;
