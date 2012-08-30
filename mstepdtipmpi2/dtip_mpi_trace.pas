function trace(aNode: TDOMNode; adeep: string): boolean;
var
	ai, aj, ak: longint;
	aNextNode: TDOMNode;
//	acnt: integer;
	adeep1: string;
begin
	ai:=getIntAttrValue(aNode, 'i', -1);
	aj:=getIntAttrValue(aNode, 'j', -1);
	if aj=1 then begin
		adeep1:= adeep + Format('%2d',[ai]) + '->' + Format('%2d',[aj]);
		writeln(adeep1);
		exit;
	end;
	aNextNode:= stateTransRootNode.firstChild;
//	acnt:= 0;
	repeat
//		inc(acnt);
//		if acnt> StateTransCnt then break;
		if getIntAttrValue(aNextNode, 'i', -1) = aj then begin
			adeep1:= adeep + Format('%2d',[ai]) + '->' + Format('%2d',[aj]) +  '|';
			trace(aNextNode, adeep1);
		end;
		aNextNode:= aNextNode.NextSibling;
	until not assigned(aNextNode);
end;
