var
	z1, z2, h, M: longint;
	pijk, rijk : double;
	i, j, k, z1i, z2i, RNSi, z1j, z2j, RNSj, u1, Ku1, v1, v2, Kv1, nsgh: longint;

    nC: longint; // ����� �ਡ�� � ⠪��
    Ns: integer; // �᫮ 䠧���� ���ﭨ� = 2 + (nC+1)*M
    cW: Double; // ५���樮��� �����⥫�
    StateTransCnt: longint; // ������⢮ 䠧���� ���室��
	RNS: array of longint; // ������ ����� ���ﭨ� (��-���祭��)

	procRNS: array of longint; // ������ ����� ���ﭨ� (��-���祭��)
    procStateTransCnt: longint; // ������⢮ 䠧���� ���室��

//  tReqRec = record // ����� ��� m-�� ⨯�
    rlmni: array of longint;   // ��� �᫮ ���
    rlmxi: array of longint;   // ���� �᫮ ���
    rsti: array of longint; // �⮨����� = ����� �� ���
    rudi: array of double; // ��室 � �� �६��� �� ���
    rxi: array of longint; // ��⨬���� �����
    rqi: array of double; // ���⨣��⮥ ���祭�� ������⥫�
	rQSumMax: double; // ��⨬��쭮� ���祭�� ���孥�� ������⥫�
	rTrace: String; //��⨬���� ���室�

//	sendcounts, displs: array of longint;

// ��� ������ �����
	procMArr: array of longint; // ���ᨢ ���-�� ��� �� ����ᠬ
    procM: longint; // ������⢮ ���
	procUpM, procDownM: longint; // ��砫쭠� � ����筠� ��� ��� �����
    procrlmni: array of longint;   // ��� �᫮ ���
    procrlmxi: array of longint;   // ���� �᫮ ���
    procrsti: array of longint; // �⮨����� = ����� �� ���
    procrudi: array of double; // ��室 � �� �६��� �� ���
    procrxi: array of longint; // ��⨬���� �����
    procrqi: array of double; // ���⨣��⮥ ���祭�� ������⥫�

// osn
type
	T2DimArrOfLogint = array of array of Longint;
	T2DimArrOfDouble = array of array of Double;

var
	arrJ: T2DimArrOfLogint; // ��� ��⨬���樨 �� �奬�. �������: i, k
	arrR: T2DimArrOfDouble;  // ��� ��⨬���樨 �� �奬�. �������: i, k
	arrQ: T2DimArrOfDouble;  // ��� ��⨬���樨 �� �奬�. �������: i, k
	arrKv1: array of Longint; // ��� ��⨬���樨 �� �奬�. �������: i

	procArrJ: T2DimArrOfLogint; // ��� ��⨬���樨 �� �奬�. �������: i, k
	procArrR: array of array of Double;  // ��� ��⨬���樨 �� �奬�. �������: i, k
	procArrQ: array of array of Double;  // ��� ��⨬���樨 �� �奬�. �������: i, k
	procArrKv1: array of Longint; // ��� ��⨬���樨 �� �奬�. �������: i

	procUpNc, procDownNc, procNc, restNc: longint;
	procNcArr: array of longint;
	procNcArrTemp: array of longint;
	procNcDispls: array of longint;

// �㦥���
	vIsDone: longint;
    inFileName, outFileName: string;
	inDoc: TXMLDocument;
	maxIterationCnt: longint;
	minAmountPerOrder, maxAmountPerOrder: longint;

// mpi
    numprocs, myid : longint;
    teg : longint;
    status : MPI_Status;
	startwtime, endwtime, totaltime : double;
	startStateTrans, endStateTrans, totalStateTrans : double;
	startStateTransMPI, endStateTransMPI, totalStateTransMPI : double;
	startOsn, endOsn, totalOsn : double;
	startOsnMPI, endOsnMPI, totalOsnMPI : double;
	startTemp, endTemp, totalTemp: double;
	startTemp1, endTemp1, totalTemp1: double;
type
	tStateTransRec = record // ����� ⠡���� 䠧���� ���室��
	    ri : longint; // ����� ��室���� ���ﭨ�
	    rj : longint; // ����� ����筮�� ���ﭨ�
	    rk : longint; // ����� 蠣 �ࠢ����� ������������� ��� �����������
	    rpijk : double; // ����⭮��� ���室� �� i � j �� k-� �ࠢ�����
	    rrijk : double; // 蠣��� ��室 ���室� �� i � j �� k-� �ࠢ�����

	    rRNSi: longint;   // ��� ����� ��� ���ﭨ�
	    // ����� 䠧����� ���ﭨ� - ��室����
	    rz1i: longint; // ����� � ⠪�� ����祭�� �� ��� �� ⥪ ������ ⨯�� ���
	    rz2i: longint; // ⨯ ��� � ���஬� 㦥 �ਬ����� �ࠢ����� = ��࠭� ᪮�쪮 ��� ���㦨��
	
	    rRNSj: longint;   // ��� ����� ����筮�� ���ﭨ�
	    // ����� 䠧����� ���ﭨ� - ����筮��
	    rz1j: longint; // ����� � ⠪�� ����祭�� �� ��� �� ⥪ ������ ⨯�� ���
	    rz2j: longint; // ⨯ ��� � ���஬� 㦥 �ਬ����� �ࠢ����� = ��࠭� ᪮�쪮 ��� ���㦨��

	    ru1: longint; // ����� ����� 蠣 ��. �� u1=0 ���室 �� �������� ��� � ��室���
	    rku1: longint; // ���-�� ����� �� � ��� i
	
	    // ����� ��� 蠣 ��
	    rkv1: longint; // ���-�� ��� �� � ��� i
	    rv1: longint; // ⨯ ��� ���
	    rv2: longint; // ���-�� ��� ���
	
	    rnsgh: longint; // ���祭�� � ⠪�� ��� h*stg h-�᫮ ���, g - ⨯ ���, stg - �⮨����� = ����� �� ���

	    rqijk: double; // �����।�⢥��� �������� ��室
	  end;
var
	procStateTransArr: array of tStateTransRec;
	StateTransArr: array of tStateTransRec;
	procStateTransCntArr: array of longint;
const
	sizeOfStateTransRec = sizeOf(tStateTransRec);