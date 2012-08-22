var
	z1, z2, h, M: longint;
	pijk, rijk : double;
	i, j, k, z1i, z2i, RNSi, z1j, z2j, RNSj, u1, Ku1, v1, v2, Kv1, nsgh: longint;

    nC: longint; // ресурс прибора в тактах
    Ns: integer; // число фазовых состояний = 2 + (nC+1)*M
    cW: Double; // релаксационный множитель
    StateTransCnt: longint; // количество фазовых переходов
	RNS: array of longint; // расчётные номера состояний (хеш-значения)

	procRNS: array of longint; // расчётные номера состояний (хеш-значения)
    procStateTransCnt: longint; // количество фазовых переходов

//  tReqRec = record // данные заявки m-го типа
    rlmni: array of longint;   // мин число заявок
    rlmxi: array of longint;   // макс число заявок
    rsti: array of longint; // стоимость = ресурс на заявку
    rudi: array of double; // доход в ед времени от заявки
    rxi: array of longint; // оптимальный ресурс
    rqi: array of double; // достигнутое значение показателя
	rQSumMax: double; // оптимальное значение верхнего показателя
	rTrace: String; //оптимальные переходы

//	sendcounts, displs: array of longint;

// для одного процесса
	procMArr: array of longint; // массив кол-ва заявок по процессам
    procM: longint; // количество заявок
	procUpM, procDownM: longint; // начальная и конечная заявка для процесса
    procrlmni: array of longint;   // мин число заявок
    procrlmxi: array of longint;   // макс число заявок
    procrsti: array of longint; // стоимость = ресурс на заявку
    procrudi: array of double; // доход в ед времени от заявки
    procrxi: array of longint; // оптимальный ресурс
    procrqi: array of double; // достигнутое значение показателя

// osn
type
	T2DimArrOfLogint = array of array of Longint;
	T2DimArrOfDouble = array of array of Double;

var
	arrJ: T2DimArrOfLogint; // для оптимизации осн схемы. Индексы: i, k
	arrR: T2DimArrOfDouble;  // для оптимизации осн схемы. Индексы: i, k
	arrQ: T2DimArrOfDouble;  // для оптимизации осн схемы. Индексы: i, k
	arrKv1: array of Longint; // для оптимизации осн схемы. Индексы: i

	procArrJ: T2DimArrOfLogint; // для оптимизации осн схемы. Индексы: i, k
	procArrR: array of array of Double;  // для оптимизации осн схемы. Индексы: i, k
	procArrQ: array of array of Double;  // для оптимизации осн схемы. Индексы: i, k
	procArrKv1: array of Longint; // для оптимизации осн схемы. Индексы: i

	procUpNc, procDownNc, procNc, restNc: longint;
	procNcArr: array of longint;
	procNcArrTemp: array of longint;
	procNcDispls: array of longint;

// служебные
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
	tStateTransRec = record // данные таблицы фазовых переходов
	    ri : longint; // номер исходного состояния
	    rj : longint; // номер конечного состояния
	    rk : longint; // номер шаг управления немгновенного или мгновенного
	    rpijk : double; // вероятность перехода из i в j при k-м управлении
	    rrijk : double; // шаговый доход перехода из i в j при k-м управлении

	    rRNSi: longint;   // расч номер исх состояния
	    // вектор фазового состояния - исходного
	    rz1i: longint; // ресурс в тактах потраченный на рассм на тек момент типов заявок
	    rz2i: longint; // тип заявки к которому уже применено управление = выбрано сколько заявок обслужить
	
	    rRNSj: longint;   // расч номер конечного состояния
	    // вектор фазового состояния - конечного
	    rz1j: longint; // ресурс в тактах потраченный на рассм на тек момент типов заявок
	    rz2j: longint; // тип заявки к которому уже применено управление = выбрано сколько заявок обслужить

	    ru1: longint; // вектор немгн шаг упр. при u1=0 переход из базового сост в исходное
	    rku1: longint; // кол-во немгн упр в сост i
	
	    // вектор мгн шаг упр
	    rkv1: longint; // кол-во мгн упр в сост i
	    rv1: longint; // тип выбр заявок
	    rv2: longint; // кол-во выбр заявок
	
	    rnsgh: longint; // значение в тактах для h*stg h-число заявок, g - тип заявки, stg - стоимость = ресурс на заявку

	    rqijk: double; // непосредственно ожидаемый доход
	  end;
var
	procStateTransArr: array of tStateTransRec;
	StateTransArr: array of tStateTransRec;
	procStateTransCntArr: array of longint;
const
	sizeOfStateTransRec = sizeOf(tStateTransRec);