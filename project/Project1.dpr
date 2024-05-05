program Project1;

{$APPTYPE CONSOLE}
{$R *.res}

{ used units and modules }
uses
  System.SysUtils, Windows;

{ types }
type
  TString = string[20];

  { specFuns data types }
  TCompPartsArr = array of integer;
  TcompPartsMtx = array of TCompPartsArr;

  { partList }
  PartListDataType = packed record
    partCode: integer;
    partTypeCode: integer;
    manufacturer: TString;
    modelName: TString;
    parameters: TString;
    price: real;
    availability: integer;
  end;

  PartListType = ^PartListPointer;

  PartListPointer = packed record
    lastID: integer;
    partListInfo: PartListDataType;
    partListNextElement: PartListType;
  end;

  PartListFileType = file of PartListDataType;

  { partTypeList }
  PartTypeListDataType = packed record
    partTypeCode: integer;
    partTypeName: TString;
  end;

  PartTypeListType = ^PartTypeListPointer;

  PartTypeListPointer = packed record
    lastID: integer;
    partTypeListInfo: PartTypeListDataType;
    partTypeListNextElement: PartTypeListType;
  end;

  PartTypeListFileType = file of PartTypeListDataType;

  { compatiblePartList }
  CompatiblePartListDataType = packed record
    firstPartCode: integer;
    secondPartCode: integer;
  end;

  CompatiblePartListType = ^CompatiblePartListPointer;

  CompatiblePartListPointer = packed record
    compatiblePartListInfo: CompatiblePartListDataType;
    compatiblePartListNextElement: CompatiblePartListType;
  end;

  CompatiblePartListFileType = file of CompatiblePartListDataType;
  { procedures }

  { console clear procedure }
procedure ClearScreen();
var
  stdout: THandle;
  csbi: TConsoleScreenBufferInfo;
  ConsoleSize: DWORD;
  NumWritten: DWORD;
  Origin: TCoord;
begin
  stdout := GetStdHandle(STD_OUTPUT_HANDLE);
  Win32Check(stdout <> INVALID_HANDLE_VALUE);
  Win32Check(GetConsoleScreenBufferInfo(stdout, csbi));
  ConsoleSize := csbi.dwSize.X * csbi.dwSize.Y;
  Origin.X := 0;
  Origin.Y := 0;
  Win32Check(FillConsoleOutputCharacter(stdout, ' ', ConsoleSize, Origin,
    NumWritten));
  Win32Check(FillConsoleOutputAttribute(stdout, csbi.wAttributes, ConsoleSize,
    Origin, NumWritten));
  Win32Check(SetConsoleCursorPosition(stdout, Origin));
  sleep(115);
end;

{ procedure ReadFromFiles }
procedure ReadFromFiles(list1: PartListType; list2: PartTypeListType;
  list3: CompatiblePartListType; var isReadFromFile: boolean);

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

var
  header1: PartListType;
  header2: PartTypeListType;

var
  isAgreed: boolean;
  directoryPath, folder_files_name, path1, path2, path3: string;
  error1, error2, error3: integer;
  partListFile: PartListFileType;
  partTypeListFile: PartTypeListFileType;
  compatiblePartListFile: CompatiblePartListFileType;

begin
  isAgreed := false;
  header1 := list1;
  header2 := list2;
  ClearScreen();
  writeln('Вы выбрали функцию чтения данных из файлов.');
  writeln;
  if isReadFromFile then
  begin
    writeln('Данные из файлов уже были прочтены. Повторное чтение недоступно.');
    sleep(1200);
  end
  else
  begin
    if (list2^.partTypeListNextElement <> nil) then
    begin
      writeln('В списках уже имеются данные. Открытие файлов повлечет перезапись данных.');
      writeln;
      checkInput := '';
      checkErrorCode := 1;
      while checkErrorCode > 0 do
      begin
        write('Введите 1, чтобы прочитать данные из файлов, иначе введите 0: ');
        readln(checkInput);
        writeln;
        val(String(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode > 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
          ClearScreen();
        end
        else
          case checkInt of
            1:
              isAgreed := true;
            0:
              isAgreed := false;
          else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
              ClearScreen();
            end;
          end;
      end;
    end
    else
      isAgreed := true;
    if not isAgreed then
    begin
      ClearScreen();
      writeln('Вы отказались от открытия файлов.');
      sleep(1200);
    end
    else
    begin
      repeat
        writeln('Введите абсолютный путь к папке, которая будет содержать файлы со списками(или нажмите для выхода).');
        writeln;
        readln(directoryPath);
        writeln;
        if (not directoryExists(directoryPath)) and (directoryPath <> '') then
        begin
          writeln('Такой директории не существует. Нажмите для повторного ввода.');
          readln;
          ClearScreen();
        end;
      until (directoryExists(directoryPath)) or (directoryPath = '');
      if directoryPath = '' then
      begin
        ClearScreen();
        writeln('Вы отказались от открытия файлов.');
        sleep(1200);
      end
      else
      begin
        repeat
          writeln('Введите имя папки(или нажмите для выхода): ');
          writeln;
          readln(folder_files_name);
          writeln;
          if (not directoryExists(directoryPath + '\' + folder_files_name)) and
            (folder_files_name <> '') then
          begin
            writeln('Такой папки не существует. Нажмите для повторного ввода.');
            readln;
            ClearScreen();
          end;
        until (directoryExists(directoryPath + '\' + folder_files_name)) or
          (folder_files_name = '');
        if folder_files_name = '' then
        begin
          ClearScreen();
          writeln('Вы отказались от открытия файлов.');
          sleep(1200);
        end
        else
        begin
          directoryPath := directoryPath + '\' + folder_files_name;
          path1 := directoryPath + '\' + folder_files_name +
            '_PartListData.upozn';
          path2 := directoryPath + '\' + folder_files_name +
            '_PartTypeListData.upozn';
          path3 := directoryPath + '\' + folder_files_name +
            '_CompatiblePartListData.upozn';
{$I-}
          assignFile(partListFile, path1);
          reset(partListFile);
          error1 := IOResult;
          assignFile(partTypeListFile, path2);
          reset(partTypeListFile);
          error2 := IOResult;
          assignFile(compatiblePartListFile, path3);
          reset(compatiblePartListFile);
          error3 := IOResult;
          if not((error1 = 0) and (error2 = 0) and (error3 = 0)) then
          begin
            writeln('В введенной директории отсутствуют файлы.');
            writeln;
            writeln('Нажмите, чтобы продолжить.');
            readln;
          end
          else
          begin
            while not EOF(partListFile) do
            begin
              new(list1^.partListNextElement);
              list1 := list1^.partListNextElement;
              read(partListFile, list1^.partListInfo);
            end;
            list1^.partListNextElement := nil;
            header1^.lastID := list1^.partListInfo.partCode;
            while not EOF(partTypeListFile) do
            begin
              new(list2^.partTypeListNextElement);
              list2 := list2^.partTypeListNextElement;
              read(partTypeListFile, list2^.partTypeListInfo);
            end;
            list2^.partTypeListNextElement := nil;
            header2^.lastID := list2^.partTypeListInfo.partTypeCode;
            while not EOF(compatiblePartListFile) do
            begin
              new(list3^.compatiblePartListNextElement);
              list3 := list3^.compatiblePartListNextElement;
              read(compatiblePartListFile, list3^.compatiblePartListInfo);
            end;
            list3^.compatiblePartListNextElement := nil;
            closeFile(partListFile);
            closeFile(partTypeListFile);
            closeFile(compatiblePartListFile);
            ClearScreen();
            writeln('Данные прочтены.');
            sleep(1200);
            isReadFromFile := true;
          end;
        end;
      end;
    end;
  end;
end;

{ ShowListFunctions }
{ function ShowListMenu }
function ShowListMenu(): integer;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

begin
  checkInput := '';
  checkInt := 0;
  checkErrorCode := 1;
  while (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3)) do
  begin
    ClearScreen();
    writeln('Вы выбрали функцию просмотра списков.');
    writeln;
    writeln('Доступные для просмотра списки: ');
    writeln('1. Список комплектующих.');
    writeln('2. Список типов комплектующих.');
    writeln('3. Список совместимых комплектующих.');
    writeln;
    write('Введите номер списка, который хотите просмотреть(или введите 0, чтобы выйти из функции просмотра): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3)) then
    begin
      writeln('Списка с заданным номером не существует. Нажмите для повторного ввода.');
      readln;
    end;
  end;
  result := checkInt;
end;

{ procedure ShowPartList }
procedure ShowPartList(list: PartListType);

begin
  ClearScreen();
  writeln('Список комплектующих.');
  writeln;
  writeln('-----------------------------------------------------------------------------------------------------------------------------------------');
  writeln('| Код комплектующего | Код типа комплектующего |    Изготовитель    |       Модель       |      Параметры     |   Цена   |  Количество  |');
  writeln('-----------------------------------------------------------------------------------------------------------------------------------------');
  list := list^.partListNextElement;
  while list <> nil do
  begin
    writeln('|', list^.partListInfo.partCode:19, ' |',
      list^.partListInfo.partTypeCode:24, ' |', list^.partListInfo.manufacturer
      :19, ' |', list^.partListInfo.modelName:19, ' |',
      list^.partListInfo.parameters:19, ' |', list^.partListInfo.price:9:2,
      ' |', list^.partListInfo.availability:13, ' |');
    writeln('-----------------------------------------------------------------------------------------------------------------------------------------');
    list := list^.partListNextElement;
  end;
  writeln;
  writeln('Нажмите, чтобы продолжить.');
  readln;
end;

{ procedure ShowPartTypeList }
procedure ShowPartTypeList(list: PartTypeListType);

begin
  ClearScreen();
  writeln('Список типов комплектующих.');
  writeln;
  writeln('------------------------------------------------');
  writeln('| Код типа комплектующего |      Название      |');
  writeln('------------------------------------------------');
  list := list^.partTypeListNextElement;
  while list <> nil do
  begin
    writeln('|', list^.partTypeListInfo.partTypeCode:24, ' |',
      list^.partTypeListInfo.partTypeName:19, ' |');
    writeln('------------------------------------------------');
    list := list^.partTypeListNextElement;
  end;
  writeln;
  writeln('Нажмите, чтобы продолжить.');
  readln;
end;

{ procedure ShowCompatiblePartList }
procedure ShowCompatiblePartList(list: CompatiblePartListType);

begin
  ClearScreen();
  writeln('Список совместимых комплектующих.');
  writeln;
  writeln('-----------------------------------------------------------');
  writeln('| Код первого комплектующего | Код второго комплектующего |');
  writeln('-----------------------------------------------------------');
  list := list^.compatiblePartListNextElement;
  while list <> nil do
  begin
    writeln('|', list^.compatiblePartListInfo.firstPartCode:27, ' |',
      list^.compatiblePartListInfo.secondPartCode:27, ' |');
    writeln('-----------------------------------------------------------');
    list := list^.compatiblePartListNextElement;
  end;
  writeln;
  writeln('Нажмите, чтобы продолжить.');
  readln;
end;

{ SortListFunctions }
{ function SortListMenu }
function SortListMenu(): integer;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

begin
  checkInput := '';
  checkInt := 0;
  checkErrorCode := 1;
  while (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3)) do
  begin
    ClearScreen();
    writeln('Вы выбрали функцию сортировки списков.');
    writeln;
    writeln('Доступные для сортировки списки: ');
    writeln('1. Список комплектующих.');
    writeln('2. Список типов комплектующих.');
    writeln('3. Список совместимых комплектующих.');
    writeln;
    write('Введите номер списка, который хотите сортировать(или введите 0, чтобы выйти из функции сортировки): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3)) then
    begin
      writeln('Списка с заданным номером не существует. Нажмите для повторного ввода.');
      readln;
    end;
  end;
  result := checkInt;
end;

{ procedure SortPartList }
procedure SortPartList(list: PartListType);

  function CurrPrevComp(code: integer; curr, prev: PartListType): boolean;

  var
    comp: boolean;

  begin
    comp := false;
    case code of
      1:
        comp := (curr^.partListInfo.partCode >=
          prev^.partListNextElement^.partListInfo.partCode);
      2:
        comp := (curr^.partListInfo.partTypeCode >=
          prev^.partListNextElement^.partListInfo.partTypeCode);
      3:
        comp := (curr^.partListInfo.manufacturer >=
          prev^.partListNextElement^.partListInfo.manufacturer);
      4:
        comp := (curr^.partListInfo.modelName >=
          prev^.partListNextElement^.partListInfo.modelName);
      5:
        comp := (curr^.partListInfo.price >=
          prev^.partListNextElement^.partListInfo.price);
      6:
        comp := (curr^.partListInfo.availability >=
          prev^.partListNextElement^.partListInfo.availability);
    end;
    result := comp;
  end;

  procedure SortPartListElements(list: PartListType; fieldCode: integer);

  var
    sorted, curr, prev: PartListType;
    comparator1: boolean;

  begin
    comparator1 := false;
    sorted := list;
    list := list^.partListNextElement;
    sorted^.partListNextElement := nil;
    while list <> nil do
    begin
      curr := list;
      list := list^.partListNextElement;
      case fieldCode of
        1:
          comparator1 := (curr^.partListInfo.partCode <
            sorted^.partListInfo.partCode);
        2:
          comparator1 := (curr^.partListInfo.partTypeCode <
            sorted^.partListInfo.partTypeCode);
        3:
          comparator1 := (curr^.partListInfo.manufacturer <
            sorted^.partListInfo.manufacturer);
        4:
          comparator1 := (curr^.partListInfo.modelName <
            sorted^.partListInfo.modelName);
        5:
          comparator1 :=
            (curr^.partListInfo.price < sorted^.partListInfo.price);
        6:
          comparator1 := (curr^.partListInfo.availability <
            sorted^.partListInfo.availability)
      end;
      if comparator1 then
      begin
        curr^.partListNextElement := sorted;
        sorted := curr;
      end
      else
      begin
        prev := sorted;
        while (prev^.partListNextElement <> nil) and
          (CurrPrevComp(fieldCode, curr, prev)) do
          prev := prev^.partListNextElement;
        curr^.partListNextElement := prev^.partListNextElement;
        prev^.partListNextElement := curr;
      end;
    end;
    // list := sorted;
  end;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

begin
  checkInput := '';
  checkInt := 0;
  checkErrorCode := 1;
  while (checkErrorCode > 0) or ((checkInt < 1) or (checkInt > 6)) do
  begin
    ClearScreen();
    writeln('Доступные поля для сортировки: ');
    writeln;
    writeln('1. Код комплектующего.');
    writeln('2. Код типа комплектующего.');
    writeln('3. Производитель.');
    writeln('4. Имя модели.');
    writeln('5. Цена.');
    writeln('6. Количество.');
    writeln;
    write('Введите номер поля: ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) or ((checkInt < 1) or (checkInt > 6)) then
    begin
      writeln('Введенное поле не существует. Нажмите для повторного ввода.');
      readln;
    end;
  end;
  if not((list = nil) or (list^.partListNextElement = nil)) then
    SortPartListElements(list, checkInt);
  ClearScreen();
  writeln('Список отсортирован.');
  sleep(1200);
end;

{ procedure SortPartTypeList }
procedure SortPartTypeList(list: PartTypeListType);

  function CurrPrevComp(code: integer; curr, prev: PartTypeListType): boolean;

  var
    comp: boolean;

  begin
    comp := false;
    case code of
      1:
        comp := (curr^.partTypeListInfo.partTypeCode >=
          prev^.partTypeListNextElement^.partTypeListInfo.partTypeCode);
      2:
        comp := (curr^.partTypeListInfo.partTypeName >=
          prev^.partTypeListNextElement^.partTypeListInfo.partTypeName);
    end;
    result := comp;
  end;

  procedure SortPartTypeListElements(list: PartTypeListType;
    fieldCode: integer);

  var
    sorted, curr, prev: PartTypeListType;
    comparator1: boolean;

  begin
    comparator1 := false;
    sorted := list;
    list := list^.partTypeListNextElement;
    sorted^.partTypeListNextElement := nil;
    while list <> nil do
    begin
      curr := list;
      list := list^.partTypeListNextElement;
      case fieldCode of
        1:
          comparator1 := (curr^.partTypeListInfo.partTypeCode <
            sorted^.partTypeListInfo.partTypeCode);
        2:
          comparator1 := (curr^.partTypeListInfo.partTypeName <
            sorted^.partTypeListInfo.partTypeName);
      end;
      if comparator1 then
      begin
        curr^.partTypeListNextElement := sorted;
        sorted := curr;
      end
      else
      begin
        prev := sorted;
        while (prev^.partTypeListNextElement <> nil) and
          (CurrPrevComp(fieldCode, curr, prev)) do
          prev := prev^.partTypeListNextElement;
        curr^.partTypeListNextElement := prev^.partTypeListNextElement;
        prev^.partTypeListNextElement := curr;
      end;
    end;
    // list := sorted;
  end;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

begin
  checkInput := '';
  checkInt := 0;
  checkErrorCode := 1;
  while (checkErrorCode > 0) or ((checkInt < 1) or (checkInt > 2)) do
  begin
    ClearScreen();
    writeln('Доступные поля для сортировки: ');
    writeln;
    writeln('1. Код типа комплектующего.');
    writeln('2. Название.');
    writeln;
    write('Введите номер поля: ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) or ((checkInt < 1) or (checkInt > 2)) then
    begin
      writeln('Введенное поле не существует. Нажмите для повторного ввода.');
      readln;
    end;
  end;
  if not((list = nil) or (list^.partTypeListNextElement = nil)) then
    SortPartTypeListElements(list, checkInt);
  ClearScreen();
  writeln('Список отсортирован.');
  sleep(1200);
end;

{ procedure SortCompatiblePartList }
procedure SortCompatiblePartList(list: CompatiblePartListType);

  function CurrPrevComp(code: integer;
    curr, prev: CompatiblePartListType): boolean;

  var
    comp: boolean;

  begin
    comp := false;
    case code of
      1:
        comp := (curr^.compatiblePartListInfo.firstPartCode >=
          prev^.compatiblePartListNextElement^.compatiblePartListInfo.
          firstPartCode);
      2:
        comp := (curr^.compatiblePartListInfo.secondPartCode >=
          prev^.compatiblePartListNextElement^.compatiblePartListInfo.
          secondPartCode);
    end;
    result := comp;
  end;

  procedure SortCompatiblePartListElements(list: CompatiblePartListType;
    fieldCode: integer);

  var
    sorted, curr, prev: CompatiblePartListType;
    comparator1: boolean;

  begin
    comparator1 := false;
    sorted := list;
    list := list^.compatiblePartListNextElement;
    sorted^.compatiblePartListNextElement := nil;
    while list <> nil do
    begin
      curr := list;
      list := list^.compatiblePartListNextElement;
      case fieldCode of
        1:
          comparator1 := (curr^.compatiblePartListInfo.firstPartCode <
            sorted^.compatiblePartListInfo.firstPartCode);
        2:
          comparator1 := (curr^.compatiblePartListInfo.secondPartCode <
            sorted^.compatiblePartListInfo.secondPartCode);
      end;
      if comparator1 then
      begin
        curr^.compatiblePartListNextElement := sorted;
        sorted := curr;
      end
      else
      begin
        prev := sorted;
        while (prev^.compatiblePartListNextElement <> nil) and
          (CurrPrevComp(fieldCode, curr, prev)) do
          prev := prev^.compatiblePartListNextElement;
        curr^.compatiblePartListNextElement :=
          prev^.compatiblePartListNextElement;
        prev^.compatiblePartListNextElement := curr;
      end;
    end;
    // list := sorted;
  end;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

begin
  checkInput := '';
  checkInt := 0;
  checkErrorCode := 1;
  while (checkErrorCode > 0) or ((checkInt < 1) or (checkInt > 2)) do
  begin
    ClearScreen();
    writeln('Доступные поля для сортировки: ');
    writeln;
    writeln('1. Код первого комплектующего.');
    writeln('2. Код второго комплектующего.');
    writeln;
    write('Введите номер поля: ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) or ((checkInt < 1) or (checkInt > 2)) then
    begin
      writeln('Введенное поле не существует. Нажмите для повторного ввода.');
      readln;
    end;
  end;
  if not((list = nil) or (list^.compatiblePartListNextElement = nil)) then
    SortCompatiblePartListElements(list, checkInt);
  ClearScreen();
  writeln('Список отсортирован.');
  sleep(1200);
end;

{ FindInListFunctions }
{ function FindInListMenu }
function FindInListMenu(): integer;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

begin
  checkInput := '';
  checkInt := 0;
  checkErrorCode := 1;
  while (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3)) do
  begin
    ClearScreen();
    writeln('Вы выбрали функцию поиска данных в списках.');
    writeln;
    writeln('Доступные для поиска списки: ');
    writeln('1. Список комплектующих.');
    writeln('2. Список типов комплектующих.');
    writeln('3. Список совместимых комплектующих.');
    writeln;
    write('Введите номер списка,в котором хотите провести поиск(или введите 0, чтобы выйти из функции поиска): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3)) then
    begin
      writeln('Списка с заданным номером не существует. Нажмите для повторного ввода.');
      readln;
    end;
  end;
  result := checkInt;
end;

{ procedure FindInPartList }
procedure FindInPartList(list: PartListType);

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

var
  fieldCode: integer;
  isTableShown, isNotExit, isNotExitCheck, comparator: boolean;
  header: PartListType;

begin
  header := list;
  isNotExit := true;
  comparator := false;
  while isNotExit do
  begin
    checkInput := '';
    checkInt := 0;
    checkErrorCode := 1;
    while (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 4)) do
    begin
      ClearScreen();
      writeln('Доступные поля для поиска: ');
      writeln;
      writeln('1. Код комплектующего.');
      writeln('2. Код типа комплектующего.');
      writeln('3. Производитель.');
      writeln('4. Имя модели.');
      writeln;
      write('Введите номер поля(введите 0 для выхода): ');
      readln(checkInput);
      writeln;
      val(string(checkInput), checkInt, checkErrorCode);
      if (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 4)) then
      begin
        writeln('Введенное поле не существует. Нажмите для повторного ввода.');
        readln;
      end;
    end;
    if checkInt <> 0 then
    begin
      fieldCode := checkInt;
      checkInput := '';
      checkInt := 0;
      checkErrorCode := 1;
      case fieldCode of
        1 .. 2:
          begin
            while (checkErrorCode > 0) or (checkInt = 0) do
            begin
              ClearScreen();
              case fieldCode of
                1:
                  write('Введите код комплектующего: ');
                2:
                  write('Введите код типа комплектующего: ');
              end;
              readln(checkInput);
              writeln;
              val(string(checkInput), checkInt, checkErrorCode);
              if (checkErrorCode > 0) or (checkInt = 0) then
              begin
                writeln('Некорректный ввод. Нажмите для повторного ввода.');
                readln;
              end;
            end;
          end;
        3 .. 4:
          begin
            while checkInput = '' do
            begin
              ClearScreen();
              case fieldCode of
                3:
                  write('Введите имя изготовителя: ');
                4:
                  write('Введите имя модели: ');
              end;
              readln(checkInput);
              writeln;
              if (checkInput = '') then
              begin
                writeln('Некорректный ввод. Нажмите для повторного ввода.');
                readln;
              end;
            end;
            checkInput := LowerCase(Trim(checkInput));
          end;
      end;
      isTableShown := false;
      while list <> nil do
      begin
        case fieldCode of
          1:
            comparator := (list^.partListInfo.partCode = checkInt);
          2:
            comparator := (list^.partListInfo.partTypeCode = checkInt);
          3:
            comparator := (AnsiLowerCase(Trim(list^.partListInfo.manufacturer))
              = checkInput);
          4:
            comparator := (AnsiLowerCase(Trim(list^.partListInfo.modelName))
              = checkInput);
        end;
        if comparator then
        begin
          if not isTableShown then
          begin
            writeln('Искомые записи.');
            writeln;
            writeln('-----------------------------------------------------------------------------------------------------------------------------------------');
            writeln('| Код комплектующего | Код типа комплектующего |    Изготовитель    |       Модель       |      Параметры     |   Цена   |  Количество  |');
            writeln('-----------------------------------------------------------------------------------------------------------------------------------------');
            isTableShown := true;
          end;
          writeln('|', list^.partListInfo.partCode:19, ' |',
            list^.partListInfo.partTypeCode:24, ' |',
            list^.partListInfo.manufacturer:19, ' |',
            list^.partListInfo.modelName:19, ' |', list^.partListInfo.parameters
            :19, ' |', list^.partListInfo.price:9:2, ' |',
            list^.partListInfo.availability:13, ' |');
          writeln('-----------------------------------------------------------------------------------------------------------------------------------------');
        end;
        list := list^.partListNextElement;
      end;
      if not isTableShown then
        writeln('Записи не найдены.');
      writeln;
      writeln('Нажмите, чтобы продолжить.');
      readln;
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('Введите 0, чтобы перейти к меню списков, или 1 для продолжения поиска: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if checkErrorCode > 0 then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end
        else
          case checkInt of
            1:
              begin
                isNotExitCheck := false;
                list := header;
              end;
            0:
              begin
                isNotExitCheck := false;
                isNotExit := false;
              end;
          else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('Вы отказались от поиска.');
      sleep(1200);
      isNotExit := false;
    end;
  end;
end;

{ procedure FindInPartTypeList }
procedure FindInPartTypeList(list: PartTypeListType);

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

var
  fieldCode: integer;
  isTableShown, isNotExit, isNotExitCheck, comparator: boolean;
  header: PartTypeListType;

begin
  header := list;
  isNotExit := true;
  comparator := false;
  while isNotExit do
  begin
    checkInput := '';
    checkInt := 0;
    checkErrorCode := 1;
    while (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 2)) do
    begin
      ClearScreen();
      writeln('Доступные поля для поиска: ');
      writeln;
      writeln('1. Код типа комплектующего.');
      writeln('2. Название.');
      writeln;
      write('Введите номер поля(введите 0 для выхода): ');
      readln(checkInput);
      writeln;
      val(string(checkInput), checkInt, checkErrorCode);
      if (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 2)) then
      begin
        writeln('Введенное поле не существует. Нажмите для повторного ввода.');
        readln;
      end;
    end;
    if checkInt <> 0 then
    begin
      fieldCode := checkInt;
      checkInput := '';
      checkInt := 0;
      checkErrorCode := 1;
      case fieldCode of
        1:
          begin
            while (checkErrorCode > 0) or (checkInt = 0) do
            begin
              ClearScreen();
              write('Введите код типа комплектующего: ');
              readln(checkInput);
              writeln;
              val(string(checkInput), checkInt, checkErrorCode);
              if (checkErrorCode > 0) or (checkInt = 0) then
              begin
                writeln('Некорректный ввод. Нажмите для повторного ввода.');
                readln;
              end;
            end;
          end;
        2:
          begin
            while checkInput = '' do
            begin
              ClearScreen();
              write('Введите название: ');
              readln(checkInput);
              writeln;
              if checkInput = '' then
              begin
                writeln('Некорректный ввод. Нажмите для повторного ввода.');
                readln;
              end;
            end;
            checkInput := AnsiLowerCase(Trim(checkInput));
          end;
      end;
      isTableShown := false;
      while list <> nil do
      begin
        case fieldCode of
          1:
            comparator := (list^.partTypeListInfo.partTypeCode = checkInt);
          2:
            comparator :=
              (AnsiLowerCase(Trim(list^.partTypeListInfo.partTypeName))
              = checkInput);
        end;
        if comparator then
        begin
          if not isTableShown then
          begin
            writeln('Искомые записи.');
            writeln;
            writeln('------------------------------------------------');
            writeln('| Код типа комплектующего |      Название      |');
            writeln('------------------------------------------------');
            isTableShown := true;
          end;
          writeln('|', list^.partTypeListInfo.partTypeCode:24, ' |',
            list^.partTypeListInfo.partTypeName:19, ' |');
          writeln('------------------------------------------------');
        end;
        list := list^.partTypeListNextElement;
      end;
      if not isTableShown then
        writeln('Записи не найдены.');
      writeln;
      writeln('Нажмите, чтобы продолжить.');
      readln;
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('Введите 0, чтобы перейти к меню списков, или 1 для продолжения поиска: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end
        else
          case checkInt of
            1:
              begin
                isNotExitCheck := false;
                list := header;
              end;
            0:
              begin
                isNotExitCheck := false;
                isNotExit := false;
              end;
          else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('Вы отказались от поиска.');
      sleep(1200);
      isNotExit := false;
    end;
  end;
end;

{ procedure FindInCompatiblePartList }
procedure FindInCompatiblePartList(list: CompatiblePartListType);

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

var
  isTableShown, isNotExit, isNotExitCheck: boolean;
  header: CompatiblePartListType;

begin
  header := list;
  isNotExit := true;
  while isNotExit do
  begin
    checkInput := '';
    checkInt := 0;
    checkErrorCode := 1;
    while (checkErrorCode > 0) do
    begin
      ClearScreen();
      write('Введите код комплектующего(введите 0 для выхода): ');
      readln(checkInput);
      writeln;
      val(string(checkInput), checkInt, checkErrorCode);
      if (checkErrorCode > 0) then
      begin
        writeln('Некорректный ввод. Нажмите для повторного ввода.');
        readln;
      end;
    end;
    if checkInt <> 0 then
    begin
      isTableShown := false;
      while list <> nil do
      begin
        if (list^.compatiblePartListInfo.firstPartCode = checkInt) or
          (list^.compatiblePartListInfo.secondPartCode = checkInt) then
        begin
          if not isTableShown then
          begin
            writeln('Искомые записи.');
            writeln;
            writeln('-----------------------------------------------------------');
            writeln('| Код первого комплектующего | Код второго комплектующего |');
            writeln('-----------------------------------------------------------');
            isTableShown := true;
          end;
          writeln('|', list^.compatiblePartListInfo.firstPartCode:27, ' |',
            list^.compatiblePartListInfo.secondPartCode:27, ' |');
          writeln('-----------------------------------------------------------');
        end;
        list := list^.compatiblePartListNextElement;
      end;
      if not isTableShown then
        writeln('Записи не найдены.');
      writeln;
      writeln('Нажмите, чтобы продолжить.');
      readln;
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('Введите 0, чтобы перейти к меню списков, или 1 для продолжения поиска: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if checkErrorCode <> 0 then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end
        else
          case checkInt of
            1:
              begin
                isNotExitCheck := false;
                list := header;
              end;
            0:
              begin
                isNotExitCheck := false;
                isNotExit := false;
              end;
          else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('Вы отказались от поиска.');
      sleep(1200);
      isNotExit := false;
    end;
  end;
end;

{ AddToListFunctions }
{ function AddToListMenu }
function AddToListMenu(): integer;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

begin
  checkInput := '';
  checkInt := 0;
  checkErrorCode := 1;
  while ((checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3))) do
  begin
    ClearScreen();
    writeln('Вы выбрали функцию добавления данных в спискок.');
    writeln;
    writeln('Доступные для добавления данных списки: ');
    writeln('1. Список комплектующих.');
    writeln('2. Список типов комплектующих.');
    writeln('3. Список совместимых комплектующих.');
    writeln;
    write('Введите номер списка,в котором хотите провести добавление(или введите 0, чтобы выйти из функции добавления): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if ((checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3))) then
    begin
      writeln('Списка с заданным номером не существует. Нажмите для повторного ввода.');
      readln;
    end;
  end;
  result := checkInt;
end;

{ procedure AddToPartList }
procedure AddToPartList(list: PartListType; checkList: PartTypeListType);

var
  isNotExit, isNotExitCheck, isInList, isAgreed: boolean;
  findStr: TString;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;
  checkReal: real;

var
  checkHeader1, header: PartListType;
  checkHeader2: PartTypeListType;

begin
  header := list;
  checkInt := 0;
  isAgreed := false;
  while list^.partListNextElement <> nil do
    list := list^.partListNextElement;
  isNotExit := true;
  while isNotExit do
  begin
    ClearScreen();
    writeln('Нажмите, чтобы ознакомиться с доступными типами копмлектующих.');
    readln;
    ShowPartTypeList(checkList);
    isInList := true;
    while isInList do
    begin
      checkInput := '';
      checkInt := 0;
      checkErrorCode := 1;
      while (checkErrorCode > 0) do
      begin
        ClearScreen();
        write('Введите код типа комлектующего(или введите 0, чтобы выйти из данной функции): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode > 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end;
      end;
      if checkInt <> 0 then
      begin
        checkHeader2 := checkList;
        while ((checkHeader2^.partTypeListInfo.partTypeCode <> checkInt) and
          (checkHeader2^.partTypeListNextElement <> nil)) do
          checkHeader2 := checkHeader2^.partTypeListNextElement;
        if checkHeader2^.partTypeListInfo.partTypeCode <> checkInt then
        begin
          writeln('Такого типа комплектующего не существует. Нажмите для повторного ввода.');
          readln;
        end
        else
        begin
          isInList := false;
          isAgreed := true;
        end;
      end
      else
      begin
        isInList := false;
        isAgreed := false;
      end;
    end;
    if isAgreed then
    begin
      inc(header^.lastID);
      new(list^.partListNextElement);
      list := list^.partListNextElement;
      list^.partListInfo.partCode := header^.lastID;
      list^.partListNextElement := nil;
      list^.partListInfo.partTypeCode := checkInt;
      checkInput := '';
      while checkInput = '' do
      begin
        write('Введите имя изготовителя: ');
        readln(checkInput);
        writeln;
        if (checkInput = '') then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
          ClearScreen();
        end;
      end;
      list^.partListInfo.manufacturer := checkInput;
      isInList := true;
      while isInList do
      begin
        checkInput := '';
        while checkInput = '' do
        begin
          write('Введите имя модели: ');
          readln(checkInput);
          writeln;
          if (checkInput = '') then
          begin
            writeln('Некорректный ввод. Нажмите для повторного ввода.');
            readln;
            ClearScreen();
          end;
        end;
        findStr := AnsiLowerCase(Trim(checkInput));
        checkHeader1 := header;
        while ((AnsiLowerCase(Trim(checkHeader1^.partListInfo.modelName)) <>
          findStr) and (checkHeader1^.partListNextElement <> nil)) do
          checkHeader1 := checkHeader1^.partListNextElement;
        if (AnsiLowerCase(Trim(checkHeader1^.partListInfo.modelName)) = findStr)
        then
        begin
          writeln('Данная модель уже есть в списке. Нажмите для повторного ввода.');
          readln;
          ClearScreen();
        end
        else
          isInList := false;
      end;
      list^.partListInfo.modelName := checkInput;
      checkInput := '';
      while checkInput = '' do
      begin
        write('Введите параметры модели: ');
        readln(checkInput);
        writeln;
        if (checkInput = '') then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
          ClearScreen();
        end;
      end;
      list^.partListInfo.parameters := checkInput;
      checkInput := '';
      checkErrorCode := 1;
      checkReal := -1;
      while (checkErrorCode > 0) or (checkReal < 0) do
      begin
        write('Введите цену: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkReal, checkErrorCode);
        if (checkErrorCode > 0) or (checkReal < 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
          ClearScreen();
        end;
      end;
      list^.partListInfo.price := checkReal;
      checkInput := '';
      checkErrorCode := 1;
      checkInt := -1;
      while (checkErrorCode > 0) or (checkInt < 0) do
      begin
        write('Введите количество: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode > 0) or (checkInt < 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
          ClearScreen();
        end;
      end;
      list^.partListInfo.availability := checkInt;
      ClearScreen();
      writeln('Запись была добавлена в список.');
      sleep(1200);
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('Введите 0, чтобы перейти к меню списков, или 1 для продолжения добавления: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end
        else
          case checkInt of
            1:
              isNotExitCheck := false;
            0:
              begin
                isNotExitCheck := false;
                isNotExit := false;
              end;
          else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('Вы отказались от добавления записи.');
      sleep(1200);
      isNotExit := false;
    end;
  end;
end;

{ procedure AddToPartTypeList }
procedure AddToPartTypeList(list: PartTypeListType);

var
  isNotExit, isNotExitCheck, isInList, isAgreed: boolean;

var
  checkInput: TString;
  checkErrorCode: integer;
  checkInt: integer;

var
  findStr: TString;
  checkHeader, header: PartTypeListType;

begin
  header := list;
  isAgreed := false;
  while list^.partTypeListNextElement <> nil do
    list := list^.partTypeListNextElement;
  isNotExit := true;
  while isNotExit do
  begin
    isInList := true;
    while isInList do
    begin
      checkHeader := header;
      checkInput := '';
      while (checkInput = '') and (checkInput <> '0') do
      begin
        ClearScreen();
        write('Введите название типа комлектующего(или введите 0 для выхода из фукнции): ');
        readln(checkInput);
        writeln;
        if (checkInput = '') and (checkInput <> '0') then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end;
      end;
      if checkInput = '0' then
      begin
        isInList := false;
        isAgreed := false;
      end
      else
      begin
        findStr := AnsiLowerCase(Trim(checkInput));
        while (AnsiLowerCase(Trim(checkHeader^.partTypeListInfo.partTypeName))
          <> findStr) and (checkHeader^.partTypeListNextElement <> nil) do
          checkHeader := checkHeader^.partTypeListNextElement;
        if (AnsiLowerCase(Trim(checkHeader^.partTypeListInfo.partTypeName))
          = findStr) then
        begin
          writeln('Данный элемент уже есть в списке. Нажмите для повторного ввода.');
          readln;
        end
        else
          isInList := false;
        isAgreed := true;
      end;
    end;
    if isAgreed then
    begin
      inc(header^.lastID);
      new(list^.partTypeListNextElement);
      list := list^.partTypeListNextElement;
      list^.partTypeListNextElement := nil;
      list^.partTypeListInfo.partTypeCode := header^.lastID;
      list^.partTypeListInfo.partTypeName := checkInput;
      ClearScreen();
      writeln('Запись была добавлена в список.');
      sleep(1200);
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('Введите 0, чтобы перейти к меню списков, или 1 для продолжения добавления: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end
        else
          case checkInt of
            1:
              isNotExitCheck := false;
            0:
              begin
                isNotExitCheck := false;
                isNotExit := false;
              end;
          else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('Вы отказались от добавления записи.');
      sleep(1200);
      isNotExit := false;
    end;
  end;
end;

{ procedure AddToCompatiblePartList }
procedure AddToCompatiblePartList(list: CompatiblePartListType;
  checkList: PartListType);

var
  isNotExit, isNotExitCheck, isInList, isAgreed: boolean;

var
  checkErrorCode: integer;
  checkInput: TString;
  checkInt, checkInt1, checkInt2, temp: integer;

var
  header, tempHeader, checkHeader1: CompatiblePartListType;
  checkHeader2: PartListType;

begin
  header := list;
  checkInt1 := 0;
  checkInt2 := 0;
  isNotExit := true;
  isAgreed := false;
  while isNotExit do
  begin
    ClearScreen();
    writeln('Нажмите, чтобы ознакомиться со списком комплектующих.');
    readln;
    ShowPartList(checkList);
    isInList := true;
    while isInList do
    begin
      checkInput := '';
      checkErrorCode := 1;
      checkInt1 := 0;
      while (checkErrorCode > 0) or (checkInt1 = 0) do
      begin
        ClearScreen();
        write('Введите код первого комплектующего: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt1, checkErrorCode);
        if (checkErrorCode > 0) or (checkInt1 = 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end
      end;
      checkInput := '';
      checkErrorCode := 1;
      checkInt2 := 0;
      while (checkErrorCode > 0) or (checkInt1 = 0) do
      begin
        write('Введите код второго комплектующего: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt2, checkErrorCode);
        if (checkErrorCode > 0) or (checkInt2 = 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
          ClearScreen();
        end
      end;
      checkInput := '';
      checkErrorCode := 1;
      while checkErrorCode > 0 do
      begin
        ClearScreen();
        write('Чтобы подтвердить добавление, введите 1, иначе 0: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          if ((checkInt <> 0) or (checkInt <> 1)) then
          begin
            writeln('Некорректный ввод. Нажмите для повторного ввода.');
            readln;
          end;
        end
        else
          case checkInt of
            1:
              isAgreed := true;
            0:
              isAgreed := false;
          end;
      end;
      if isAgreed then
      begin
        if checkInt1 > checkInt2 then
        begin
          temp := checkInt1;
          checkInt1 := checkInt2;
          checkInt2 := temp;
        end;
        checkHeader1 := header;
        while ((checkHeader1^.compatiblePartListInfo.firstPartCode <> checkInt1)
          and (checkHeader1^.compatiblePartListInfo.secondPartCode <> checkInt2)
          ) and (checkHeader1^.compatiblePartListNextElement <> nil) do
          checkHeader1 := checkHeader1^.compatiblePartListNextElement;
        if ((checkHeader1^.compatiblePartListInfo.firstPartCode = checkInt1) and
          (checkHeader1^.compatiblePartListInfo.secondPartCode = checkInt2))
        then
        begin
          writeln('Данная запись уже есть в списке. Нажмите для повторного ввода.');
          readln;
        end
        else
        begin
          checkHeader2 := checkList;
          while (checkHeader2^.partListInfo.partCode <> checkInt1) and
            (checkHeader2^.partListNextElement <> nil) do
            checkHeader2 := checkHeader2^.partListNextElement;
          if checkHeader2^.partListInfo.partCode <> checkInt1 then
          begin
            writeln('Комплектующего с таким кодом не существует. Нажмите для повторного ввода.');
            readln;
          end
          else
          begin
            checkHeader2 := checkList;
            while (checkHeader2^.partListInfo.partCode <> checkInt2) and
              (checkHeader2^.partListNextElement <> nil) do
              checkHeader2 := checkHeader2^.partListNextElement;
            if checkHeader2^.partListInfo.partCode <> checkInt2 then
            begin
              writeln('Комплектующего с таким кодом не существует. Нажмите для повторного ввода.');
              readln;
            end
            else if checkInt1 = checkInt2 then
            begin
              writeln('Комплектующее не может быть совместимым само с собой. Нажмите для повторного ввода.');
              readln;
            end
            else
              isInList := false;
          end;
        end;
      end
      else
        isInList := false;
    end;
    if isAgreed then
    begin
      tempHeader := list^.compatiblePartListNextElement;
      new(list^.compatiblePartListNextElement);
      list^.compatiblePartListNextElement^.compatiblePartListInfo.firstPartCode
        := checkInt1;
      list^.compatiblePartListNextElement^.compatiblePartListInfo.secondPartCode
        := checkInt2;
      list^.compatiblePartListNextElement^.compatiblePartListNextElement :=
        tempHeader;
      ClearScreen();
      writeln('Запись была добавлена в список.');
      sleep(1200);
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('Введите 0, чтобы перейти к меню списков, или 1 для продолжения добавления: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end
        else
          case checkInt of
            1:
              isNotExitCheck := false;
            0:
              begin
                isNotExitCheck := false;
                isNotExit := false;
              end;
          else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('Вы отказались от добавления записи.');
      sleep(1200);
      isNotExit := false;
    end;
  end;
end;

{ DeleteFromListFunctions }
{ function DeleteFromListMenu }
function DeleteFromListMenu(): integer;

var
  checkInput: TString;
  checkErrorCode: integer;
  checkInt: integer;

begin
  checkErrorCode := 1;
  checkInput := '';
  checkInt := 0;
  while ((checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3))) do
  begin
    ClearScreen();
    writeln('Вы выбрали функцию удаления данных из списков.');
    writeln;
    writeln('Доступные для удаления списки: ');
    writeln('1. Список комплектующих.');
    writeln('2. Список типов комплектующих.');
    writeln('3. Список совместимых комплектующих.');
    writeln;
    write('Введите номер списка, из которого хотите удалять(или введите 0, чтобы выйти из функции удаления): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if ((checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3))) then
    begin
      writeln('Списка с заданным номером не существует. Нажмите для повторного ввода.');
      readln;
    end;
  end;
  result := checkInt;
end;

{ procedure DeleteFromPartList }
procedure DeleteFromPartList(list: PartListType;
  deleteList1: CompatiblePartListType);

var
  isNotExit, isNotExitCheck, isInList, isAgreed, flag: boolean;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

var
  partCode: integer;

var
  checkHeader1, temp1: PartListType;
  checkHeader2, temp2: CompatiblePartListType;

begin
  isNotExit := true;
  isAgreed := false;
  partCode := 0;
  checkInt := 0;
  checkHeader1 := nil;
  ClearScreen();
  writeln('По нажатию клавиши будет выведен список.');
  writeln;
  writeln('Во время просмотра выберите запись, чтобы в дальнейшем ввести ее код для удаления.');
  readln;
  ShowPartList(list);
  while isNotExit do
  begin
    isInList := true;
    while isInList do
    begin
      checkInput := '';
      checkInt := 0;
      checkErrorCode := 1;
      while (checkErrorCode > 0) do
      begin
        ClearScreen();
        write('Введите код комплектующего(или 0 для выхода из функции): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode > 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end;
      end;
      if checkInt = 0 then
      begin
        isInList := false;
      end
      else
      begin
        checkHeader1 := list;
        flag := true;
        while (checkHeader1^.partListNextElement <> nil) and flag do
        begin
          if (checkHeader1^.partListNextElement^.partListInfo.partCode <>
            checkInt) then
            checkHeader1 := checkHeader1^.partListNextElement
          else
            flag := false;
        end;
        if not flag then
        begin
          partCode := checkHeader1^.partListNextElement^.partListInfo.partCode;
          isInList := false;
        end
        else
        begin
          writeln('Комплектующего с введенным кодом не существует. Нажмите для повторного ввода.');
          readln;
        end;
      end;
    end;
    if checkInt = 0 then
    begin
      ClearScreen();
      writeln('Вы отказались от удаления записи.');
      sleep(1200);
      isNotExit := false;
    end
    else
    begin
      checkInput := '';
      checkErrorCode := 1;
      while checkErrorCode > 0 do
      begin
        ClearScreen();
        write('Удаление записи может повлечь удаление записей из других списков. Для подтверждения удаления введите 1, иначе 0: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          if ((checkInt <> 0) or (checkInt <> 1)) then
          begin
            writeln('Некорректный ввод. Нажмите для повторного ввода.');
            readln;
          end;
        end
        else
          case checkInt of
            1:
              isAgreed := true;
            0:
              isAgreed := false;
          end;
      end;
      if isAgreed then
      begin
        temp1 := checkHeader1^.partListNextElement^.partListNextElement;
        dispose(checkHeader1^.partListNextElement);
        checkHeader1^.partListNextElement := temp1;
        checkHeader2 := deleteList1;
        while checkHeader2^.compatiblePartListNextElement <> nil do
        begin
          if (checkHeader2^.compatiblePartListNextElement.
            compatiblePartListInfo.firstPartCode = partCode) or
            (checkHeader2^.compatiblePartListNextElement.compatiblePartListInfo.
            secondPartCode = partCode) then
          begin
            temp2 := checkHeader2^.compatiblePartListNextElement^.
              compatiblePartListNextElement;
            dispose(checkHeader2^.compatiblePartListNextElement);
            checkHeader2^.compatiblePartListNextElement := temp2;
          end
          else
            checkHeader2 := checkHeader2^.compatiblePartListNextElement;
        end;
        ClearScreen();
        writeln('Запись была удалена.');
        sleep(1200);
      end
      else
      begin
        ClearScreen();
        writeln('Вы отказались от удаления записи.');
        sleep(1200);
      end;
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('Введите 0, чтобы перейти к меню списков, или 1 для продолжения удаления: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end
        else
          case checkInt of
            1:
              isNotExitCheck := false;
            0:
              begin
                isNotExitCheck := false;
                isNotExit := false;
              end;
          else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
            end;
          end;
      end;
    end;
  end;
end;

{ procedure DeleteFromPartTypeList }
procedure DeleteFromPartTypeList(deleteList1: PartListType;
  list: PartTypeListType; deleteList2: CompatiblePartListType);

var
  isNotExit, isNotExitCheck, isInList, isAgreed, flag: boolean;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

var
  partTypeCode, partCode: integer;

var
  checkHeader1, temp1: PartListType;
  checkHeader2, temp2: PartTypeListType;
  checkHeader3, temp3: CompatiblePartListType;

begin
  isNotExit := true;
  isAgreed := false;
  checkInt := 0;
  partTypeCode := 0;
  checkHeader2 := nil;
  ClearScreen();
  writeln('По нажатию клавиши будет выведен список.');
  writeln;
  writeln('Во время просмотра выберите запись, чтобы в дальнейшем ввести ее код для удаления.');
  readln;
  ShowPartTypeList(list);
  while isNotExit do
  begin
    isInList := true;
    while isInList do
    begin
      checkInput := '';
      checkInt := 0;
      checkErrorCode := 1;
      while (checkErrorCode > 0) do
      begin
        ClearScreen();
        write('Введите код типа комплектующего(или 0, чтобы выйти из функции): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode > 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end;
      end;
      if checkInt = 0 then
      begin
        isInList := false;
      end
      else
      begin
        checkHeader2 := list;
        flag := true;
        while (checkHeader2^.partTypeListNextElement <> nil) and (flag) do
        begin
          if (checkHeader2^.partTypeListNextElement^.partTypeListInfo.
            partTypeCode <> checkInt) then
            checkHeader2 := checkHeader2^.partTypeListNextElement
          else
            flag := false;
        end;
        if not flag then
        begin
          partTypeCode := checkHeader2^.partTypeListNextElement^.
            partTypeListInfo.partTypeCode;
          isInList := false;
        end
        else
        begin
          writeln('Такого типа комплектующего не существует. Нажмите для повторного ввода.');
          readln;
        end;
      end;
    end;
    if checkInt = 0 then
    begin
      ClearScreen();
      writeln('Вы отказались от добавления записи.');
      sleep(1200);
      isNotExit := false;
    end
    else
    begin
      checkInput := '';
      checkErrorCode := 1;
      while checkErrorCode > 0 do
      begin
        ClearScreen();
        write('Удаление записи может повлечь удаление записей из других списков. Для подтверждения удаления введите 1, иначе 0: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          if ((checkInt <> 0) or (checkInt <> 1)) then
          begin
            writeln('Некорректный ввод. Нажмите для повторного ввода.');
            readln;
          end;
        end
        else
          case checkInt of
            1:
              isAgreed := true;
            0:
              isAgreed := false;
          end;
      end;
      if isAgreed then
      begin
        temp2 := checkHeader2^.partTypeListNextElement^.partTypeListNextElement;
        dispose(checkHeader2^.partTypeListNextElement);
        checkHeader2^.partTypeListNextElement := temp2;
        checkHeader1 := deleteList1;
        while checkHeader1^.partListNextElement <> nil do
        begin
          if checkHeader1^.partListNextElement^.partListInfo.partTypeCode = partTypeCode
          then
          begin
            partCode := checkHeader1^.partListNextElement^.
              partListInfo.partCode;
            temp1 := checkHeader1^.partListNextElement^.partListNextElement;
            dispose(checkHeader1^.partListNextElement);
            checkHeader1^.partListNextElement := temp1;
            checkHeader3 := deleteList2;
            while checkHeader3^.compatiblePartListNextElement <> nil do
            begin
              if (checkHeader3^.compatiblePartListNextElement.
                compatiblePartListInfo.firstPartCode = partCode) or
                (checkHeader3^.compatiblePartListNextElement.
                compatiblePartListInfo.secondPartCode = partCode) then
              begin
                temp3 := checkHeader3^.compatiblePartListNextElement^.
                  compatiblePartListNextElement;
                dispose(checkHeader3^.compatiblePartListNextElement);
                checkHeader3^.compatiblePartListNextElement := temp3;
              end
              else
                checkHeader3 := checkHeader3^.compatiblePartListNextElement;
            end;
          end
          else
            checkHeader1 := checkHeader1^.partListNextElement;
        end;
        ClearScreen();
        writeln('Запись была удалена.');
        sleep(1200);
      end
      else
      begin
        ClearScreen();
        writeln('Вы отказались от удаления записи.');
        sleep(1200);
      end;
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('Введите 0, чтобы перейти к меню списков, или 1 для продолжения удаления: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end
        else
          case checkInt of
            1:
              isNotExitCheck := false;
            0:
              begin
                isNotExitCheck := false;
                isNotExit := false;
              end;
          else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
            end;
          end;
      end;
    end;
  end;
end;

{ procedure DeleteFromCompatiblePartList }
procedure DeleteFromCompatiblePartList(list: CompatiblePartListType);

var
  isNotExit, isNotExitCheck, isInList, isAgreed, flag: boolean;

var
  checkInput: TString;
  checkInt, checkInt1, checkInt2, checkErrorCode, temp1: integer;

var
  checkHeader, temp: CompatiblePartListType;

begin
  isNotExit := true;
  isAgreed := false;
  checkInt1 := 0;
  checkHeader := nil;
  ClearScreen();
  writeln('По нажатию клавиши будет выведен список.');
  writeln;
  writeln('Во время просмотра выберите запись, чтобы в дальнейшем ввести ее код для удаления.');
  readln;
  ShowCompatiblePartList(list);
  while isNotExit do
  begin
    isInList := true;
    while isInList do
    begin
      checkInput := '';
      checkInt1 := 0;
      checkErrorCode := 1;
      while (checkErrorCode > 0) do
      begin
        ClearScreen();
        write('Введите код первого комплектующего(или 0 для выхода из функции): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt1, checkErrorCode);
        if (checkErrorCode > 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end;
      end;
      if checkInt1 = 0 then
      begin
        isInList := false;
      end
      else
      begin
        checkInput := '';
        checkInt2 := 0;
        checkErrorCode := 1;
        while (checkErrorCode > 0) or (checkInt2 = 0) do
        begin
          write('Введите код второго комплектующего: ');
          readln(checkInput);
          writeln;
          val(string(checkInput), checkInt2, checkErrorCode);
          if (checkErrorCode > 0) or (checkInt2 = 0) then
          begin
            writeln('Некорректный ввод. Нажмите для повторного ввода.');
            readln;
            ClearScreen();
          end;
        end;
        checkHeader := list;
        flag := true;
        if checkInt1 > checkInt2 then
        begin
          temp1 := checkInt1;
          checkInt1 := checkInt2;
          checkInt2 := temp1;
        end;
        while (checkHeader^.compatiblePartListNextElement <> nil) and flag do
        begin
          if (checkHeader^.compatiblePartListNextElement^.
            compatiblePartListInfo.firstPartCode = checkInt1) and
            (checkHeader^.compatiblePartListNextElement^.compatiblePartListInfo.
            secondPartCode = checkInt2) then
            flag := false
          else
            checkHeader := checkHeader^.compatiblePartListNextElement;
        end;
        if flag then
        begin
          writeln('Данная запись отсутсвует в списке. Нажмите для повторного ввода.');
          readln;
        end
        else
          isInList := false;
      end;
    end;
    if checkInt1 = 0 then
    begin
      ClearScreen();
      writeln('Вы отказались от удаления.');
      sleep(1200);
      isNotExit := false;
    end
    else
    begin
      checkInput := '';
      checkErrorCode := 1;
      while checkErrorCode > 0 do
      begin
        ClearScreen();
        write('Для подтверждения удаления введите 1, иначе 0: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          if ((checkInt <> 0) or (checkInt <> 1)) then
          begin
            writeln('Некорректный ввод. Нажмите для повторного ввода.');
            readln;
          end;
        end
        else
          case checkInt of
            1:
              isAgreed := true;
            0:
              isAgreed := false;
          end;
      end;
      if isAgreed then
      begin
        temp := checkHeader^.compatiblePartListNextElement^.
          compatiblePartListNextElement;
        dispose(checkHeader^.compatiblePartListNextElement);
        checkHeader^.compatiblePartListNextElement := temp;
        ClearScreen();
        writeln('Запись была удалена.');
        sleep(1200);
      end
      else
      begin
        ClearScreen();
        writeln('Вы отказались от удаления записи.');
        sleep(1200);
      end;
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('Введите 0, чтобы перейти к меню списков, или 1 для продолжения удаления: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end
        else
          case checkInt of
            1:
              isNotExitCheck := false;
            0:
              begin
                isNotExitCheck := false;
                isNotExit := false;
              end;
          else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
            end;
          end;
      end;
    end;
  end;
end;

{ EditInListFunctions }
{ function EditInListMenu }
function EditInListMenu(): integer;

var
  checkInput: TString;
  checkErrorCode: integer;
  checkInt: integer;

begin
  checkErrorCode := 1;
  checkInput := '';
  checkInt := 0;
  while ((checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3))) do
  begin
    ClearScreen();
    writeln('Вы выбрали функцию редактирования данных в списке.');
    writeln;
    writeln('Доступные для редактирования списки: ');
    writeln('1. Список комплектующих.');
    writeln('2. Список типов комплектующих.');
    writeln('3. Список совместимых комплектующих.');
    writeln;
    write('Введите номер списка, в котором хотите редактировать(или введите 0, чтобы выйти из функции редактирования): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if ((checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3))) then
    begin
      writeln('Списка с заданным номером не существует. Нажмите для повторного ввода.');
      readln;
    end;
  end;
  result := checkInt;
end;

{ procedure EditInPartList }
procedure EditInPartList(list: PartListType; checkList: PartTypeListType);

var
  isNotExit, isNotExitCheck, isInList, isAgreed, flag1, flag2: boolean;
  findStr: TString;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;
  checkReal: real;

var
  checkHeader1, header: PartListType;
  checkHeader2: PartTypeListType;

begin
  isNotExit := true;
  header := nil;
  checkInt := 0;
  flag2 := false;
  isAgreed := false;
  checkReal := 0;
  while isNotExit do
  begin
    ClearScreen();
    writeln('Нажмите, чтобы вывести список комплектующих и выберите код для редактирования.');
    readln;
    ShowPartList(list);
    isInList := true;
    while isInList do
    begin
      checkErrorCode := 1;
      checkInput := '';
      checkInt := 0;
      while checkErrorCode > 0 do
      begin
        ClearScreen();
        write('Введите код комплектующего(или 0 для выхода): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if checkErrorCode > 0 then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end;
      end;
      if checkInt = 0 then
      begin
        isInList := false;
        isAgreed := false;
      end
      else
      begin
        header := list;
        while (header^.partListInfo.partCode <> checkInt) and
          (header^.partListNextElement <> nil) do
          header := header^.partListNextElement;
        if (header^.partListInfo.partCode <> checkInt) then
        begin
          writeln('Такого комплектующего не существует. Нажммите для повторного ввода.');
          readln;
        end
        else
        begin
          isInList := false;
          isAgreed := true;
        end;
      end;
    end;
    if isAgreed then
    begin
      isInList := true;
      while isInList do
      begin
        flag1 := false;
        flag2 := false;
        while (not flag1) and (not flag2) do
        begin
          ClearScreen();
          write('Введите код типа комплектующего(нажмите для перехода к следующему полю или введите 0 для выхода): ');
          readln(checkInput);
          writeln;
          if checkInput = '' then
            flag2 := true
          else
          begin
            val(string(checkInput), checkInt, checkErrorCode);
            if checkErrorCode = 0 then
              flag1 := true
            else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
            end;
          end;
        end;
        if flag2 then
        begin
          isAgreed := true;
          isInList := false;
        end;
        if (flag1) and (checkInt = 0) then
        begin
          isInList := false;
          isAgreed := false;
        end;
        if (flag1) and (checkInt <> 0) then
        begin
          checkHeader2 := checkList;
          while (checkHeader2^.partTypeListInfo.partTypeCode <> checkInt) and
            (checkHeader2^.partTypeListNextElement <> nil) do
            checkHeader2 := checkHeader2^.partTypeListNextElement;
          if (checkHeader2^.partTypeListInfo.partTypeCode <> checkInt) then
          begin
            writeln('Такого типа комплектующего не существует. Нажммите для повторного ввода.');
            readln;
          end
          else
          begin
            isInList := false;
            isAgreed := true;
          end;
        end;
      end;
      if isAgreed then
      begin
        if not flag2 then
          header^.partListInfo.partTypeCode := checkInt;
        write('Введите имя изготовителя(нажмите для перехода к следующему полю): ');
        readln(checkInput);
        writeln;
        if checkInput <> '' then
          header^.partListInfo.manufacturer := checkInput;
        isInList := true;
        while isInList do
        begin
          write('Введите имя модели(нажмите для перехода к следующему полю): ');
          readln(checkInput);
          writeln;
          if checkInput <> '' then
          begin
            findStr := AnsiLowerCase(Trim(checkInput));
            checkHeader1 := list;
            while (string(LowerCase(checkHeader1^.partListInfo.modelName)) <>
              findStr) and (checkHeader1^.partListNextElement <> nil) do
              checkHeader1 := checkHeader1^.partListNextElement;
            if string(LowerCase(checkHeader1^.partListInfo.modelName)) = findStr
            then
            begin
              writeln('Данная модель уже есть в списке. Нажмите для повторного ввода.');
              readln;
              ClearScreen();
            end
            else
              isInList := false;
          end
          else
            isInList := false;
        end;
        if checkInput <> '' then
          header^.partListInfo.modelName := checkInput;
        write('Введите параметры(нажмите для перехода к следующему полю): ');
        readln(checkInput);
        writeln;
        header^.partListInfo.parameters := checkInput;
        flag1 := false;
        flag2 := false;
        while (not flag1) and (not flag2) do
        begin
          write('Введите цену(нажмите для перехода к следующему полю): ');
          readln(checkInput);
          writeln;
          if checkInput = '' then
            flag1 := true
          else
          begin
            val(string(checkInput), checkReal, checkErrorCode);
            if (checkErrorCode = 0) and (checkReal >= 0) then
              flag2 := true
            else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
              ClearScreen();
            end;
          end;
        end;
        if (flag2) and (not flag1) then
          header^.partListInfo.price := checkReal;
        flag1 := false;
        flag2 := false;
        while (not flag1) and (not flag2) do
        begin
          write('Введите количество(нажмите для перехода к следующему полю): ');
          readln(checkInput);
          writeln;
          if checkInput = '' then
            flag1 := true
          else
          begin
            val(string(checkInput), checkInt, checkErrorCode);
            if (checkErrorCode = 0) and (checkInt >= 0) then
              flag2 := true
            else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
              ClearScreen();
            end;
          end;
        end;
        if (flag2) and (not flag1) then
          header^.partListInfo.availability := checkInt;
        ClearScreen();
        writeln('Запись отредактирована.');
        sleep(1200);
        isNotExitCheck := true;
        while isNotExitCheck do
        begin
          ClearScreen();
          write('Введите 0, чтобы перейти к меню списков, или 1 для продолжения редактирования: ');
          readln(checkInput);
          writeln;
          val(string(checkInput), checkInt, checkErrorCode);
          if (checkErrorCode <> 0) then
          begin
            writeln('Некорректный ввод. Нажмите для повторного ввода.');
            readln;
          end
          else
            case checkInt of
              1:
                isNotExitCheck := false;
              0:
                begin
                  isNotExitCheck := false;
                  isNotExit := false;
                end;
            else
              begin
                writeln('Некорректный ввод. Нажмите для повторного ввода.');
                readln;
              end;
            end;
        end;
      end
      else
      begin
        ClearScreen();
        writeln('Вы отказались от редактирования записи.');
        sleep(1200);
        isNotExit := false;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('Вы отказались от редактирования записи.');
      sleep(1200);
      isNotExit := false;
    end;
  end;
end;

{ procedure EditInPartTypeList }
procedure EditInPartTypeList(list: PartTypeListType);

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

var
  isNotExit, isNotExitCheck, isInList, isAgreed: boolean;
  header: PartTypeListType;

begin
  header := nil;
  isAgreed := false;
  isNotExit := true;
  while isNotExit do
  begin
    ClearScreen();
    writeln('Нажмите, чтобы вывести список типов комплектующих и выберите код для редактирования.');
    readln;
    ShowPartTypeList(list);
    isInList := true;
    while isInList do
    begin
      checkErrorCode := 1;
      checkInput := '';
      checkInt := 0;
      while checkErrorCode > 0 do
      begin
        ClearScreen();
        write('Введите код типа комплектующего(или 0 для выхода): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if checkErrorCode > 0 then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end;
      end;
      if checkInt = 0 then
      begin
        isInList := false;
        isAgreed := false;
      end
      else
      begin
        header := list;
        while (header^.partTypeListInfo.partTypeCode <> checkInt) and
          (header^.partTypeListNextElement <> nil) do
          header := header^.partTypeListNextElement;
        if (header^.partTypeListInfo.partTypeCode <> checkInt) then
        begin
          writeln('Такого типа комплектующего не существует. Нажммите для повторного ввода.');
          readln;
        end
        else
        begin
          isInList := false;
          isAgreed := true;
        end;
      end;
    end;
    if isAgreed then
    begin
      ClearScreen();
      write('Введите название(нажмите для перехода к следующему полю): ');
      readln(checkInput);
      if checkInput <> '' then
        header^.partTypeListInfo.partTypeName := checkInput;
      ClearScreen();
      writeln('Запись отредактирована.');
      sleep(1200);
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('Введите 0, чтобы перейти к меню списков, или 1 для продолжения редактирования: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end
        else
          case checkInt of
            1:
              isNotExitCheck := false;
            0:
              begin
                isNotExitCheck := false;
                isNotExit := false;
              end;
          else
            begin
              writeln('Некорректный ввод. Нажмите для повторного ввода.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('Вы отказались от редактирования записи.');
      sleep(1200);
      isNotExit := false;
    end;
  end;
end;

{ procedure EditInCompatiblePartList }
procedure EditInCompatiblePartList(list: CompatiblePartListType;
  checkList: PartListType);

var
  checkInput: TString;
  checkInt, checkInt1, checkInt2, temp, checkErrorCode: integer;

var
  isNotExit, isNotExitCheck, isInList, isAgreed, flag1, flag2, isInListMain,
    comparator: boolean;
  fieldCode, node: integer;

var
  header1, checkHeader1: CompatiblePartListType;
  checkHeader2: PartListType;

begin
  node := 0;
  isAgreed := false;
  checkInt2 := 0;
  checkInt1 := 0;
  header1 := nil;
  flag2 := false;
  flag1 := false;
  isNotExit := true;
  while isNotExit do
  begin
    ClearScreen();
    writeln('Нажмите, чтобы вывести список совместимых комплектующих.');
    readln;
    ShowCompatiblePartList(list);
    isInList := true;
    while isInList do
    begin
      checkErrorCode := 1;
      while checkErrorCode > 0 do
      begin
        ClearScreen();
        write('Введите код первого комплектующего(или 0 для выхода): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt1, checkErrorCode);
        if checkErrorCode > 0 then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end;
      end;
      if checkInt1 = 0 then
      begin
        isAgreed := false;
        isInList := false;
      end
      else
      begin
        checkErrorCode := 1;
        while checkErrorCode > 0 do
        begin
          write('Введите код второго комплектующего: ');
          readln(checkInput);
          writeln;
          val(string(checkInput), checkInt2, checkErrorCode);
          if checkErrorCode > 0 then
          begin
            writeln('Некорректный ввод. Нажмите для повторного ввода.');
            readln;
            ClearScreen();
          end;
        end;
        if checkInt1 > checkInt2 then
        begin
          temp := checkInt1;
          checkInt1 := checkInt2;
          checkInt2 := temp;
        end;
        header1 := list;
        while ((header1^.compatiblePartListInfo.firstPartCode <> checkInt1) and
          (header1^.compatiblePartListInfo.secondPartCode <> checkInt2)) and
          (header1^.compatiblePartListNextElement <> nil) do
          header1 := header1^.compatiblePartListNextElement;
        if ((header1^.compatiblePartListInfo.firstPartCode <> checkInt1) and
          (header1^.compatiblePartListInfo.secondPartCode <> checkInt2)) then
        begin
          writeln('Данная запись отсутстует в списке. Нажмите для повторного ввода.');
          readln;
        end
        else
        begin
          isInList := false;
          isAgreed := true;
        end;
      end;
    end;
    if isAgreed then
    begin
      checkErrorCode := 1;
      checkInt := 0;
      while (checkErrorCode > 0) and ((checkInt <> 1) or (checkInt <> 2)) do
      begin
        ClearScreen();
        write('Введите, код какого комплектующего хотите редактировать(1 или 2): ');
        readln(checkInput);
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode > 0) and ((checkInt <> 1) or (checkInt <> 2)) then
        begin
          writeln('Некорректный ввод. Нажмите для повторного ввода.');
          readln;
        end;
      end;
      fieldCode := checkInt;
      isInListMain := true;
      while isInListMain do
      begin
        isInList := true;
        while isInList do
        begin
          flag1 := false;
          flag2 := false;
          while (not flag1) and (not flag2) do
          begin
            ClearScreen();
            write('Введите код комплектующего(нажмите для перехода к следующему полю или введите 0 для выхода): ');
            readln(checkInput);
            writeln;
            if checkInput = '' then
              flag2 := true
            else
            begin
              val(string(checkInput), checkInt, checkErrorCode);
              if checkErrorCode = 0 then
                flag1 := true
              else
              begin
                writeln('Некорректный ввод. Нажмите для повторного ввода.');
                readln;
              end;
            end;
          end;
          if flag2 then
          begin
            isAgreed := true;
            isInList := false;
          end;
          if (flag1) and (checkInt = 0) then
          begin
            isInList := false;
            isAgreed := false;
          end;
          if (flag1) and (checkInt <> 0) then
          begin
            checkHeader2 := checkList;
            while (checkHeader2^.partListInfo.partCode <> checkInt) and
              (checkHeader2^.partListNextElement <> nil) do
              checkHeader2 := checkHeader2^.partListNextElement;
            if (checkHeader2^.partListInfo.partCode <> checkInt) then
            begin
              writeln('Такого комплектующего не существует. Нажммите для повторного ввода.');
              readln;
            end
            else
            begin
              isInList := false;
              isAgreed := true;
            end;
          end;
        end;
        if flag2 then
        begin
          isAgreed := true;
          isInListMain := false;
        end;
        if (flag1) and (checkInt = 0) then
        begin
          isAgreed := false;
          isInListMain := false;
        end;
        if (flag1) and (checkInt <> 0) then
        begin
          comparator := false;
          case fieldCode of
            1:
              begin
                node := header1^.compatiblePartListInfo.secondPartCode
                  + checkInt;
                comparator :=
                  (header1^.compatiblePartListInfo.secondPartCode = checkInt);
              end;
            2:
              begin
                node := header1^.compatiblePartListInfo.firstPartCode +
                  checkInt;
                comparator :=
                  (header1^.compatiblePartListInfo.firstPartCode = checkInt);
              end;
          end;
          if comparator then
          begin
            writeln('Комплектующее не может быть совместимо само с собой. Нажмите для повторного ввода.');
            readln;
          end
          else
          begin
            checkHeader1 := list;
            while (node <> (checkHeader1^.compatiblePartListInfo.firstPartCode +
              checkHeader1^.compatiblePartListInfo.secondPartCode)) and
              (checkHeader1^.compatiblePartListNextElement <> nil) do
              checkHeader1 := checkHeader1^.compatiblePartListNextElement;
            if (node = (checkHeader1^.compatiblePartListInfo.firstPartCode +
              checkHeader1^.compatiblePartListInfo.secondPartCode)) then
            begin
              writeln('Такая запись уже есть списке. Нажмите для повторного ввода.');
              readln;
            end
            else
            begin
              isAgreed := true;
              isInListMain := false;
            end;
          end;
        end;
      end;
      if isAgreed then
      begin
        if not flag2 then
          case fieldCode of
            1:
              begin
                if checkInt > header1^.compatiblePartListInfo.secondPartCode
                then
                begin
                  temp := checkInt;
                  checkInt := header1^.compatiblePartListInfo.secondPartCode;
                  header1^.compatiblePartListInfo.secondPartCode := temp;
                end;
                header1^.compatiblePartListInfo.firstPartCode := checkInt;
              end;
            2:
              begin
                if checkInt < header1^.compatiblePartListInfo.firstPartCode then
                begin
                  temp := checkInt;
                  checkInt := header1^.compatiblePartListInfo.firstPartCode;
                  header1^.compatiblePartListInfo.firstPartCode := temp;
                end;
                header1^.compatiblePartListInfo.secondPartCode := checkInt;
              end;
          end;
        ClearScreen();
        writeln('Запись отредактирована.');
        sleep(1200);
        isNotExitCheck := true;
        while isNotExitCheck do
        begin
          ClearScreen();
          write('Введите 0, чтобы перейти к меню списков, или 1 для продолжения редактирования: ');
          readln(checkInput);
          writeln;
          val(string(checkInput), checkInt, checkErrorCode);
          if (checkErrorCode <> 0) then
          begin
            writeln('Некорректный ввод. Нажмите для повторного ввода.');
            readln;
          end
          else
            case checkInt of
              1:
                isNotExitCheck := false;
              0:
                begin
                  isNotExitCheck := false;
                  isNotExit := false;
                end;
            else
              begin
                writeln('Некорректный ввод. Нажмите для повторного ввода.');
                readln;
              end;
            end;
        end;
      end
      else
      begin
        ClearScreen();
        writeln('Вы отказались от редактирования записи.');
        sleep(1200);
        isNotExit := false;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('Вы отказались от редактирования записи.');
      sleep(1200);
      isNotExit := false;
    end;
  end;
end;

{ SpecialFunctions }
{ function SpecialFunctionsMenu }
function SpecialFunctionsMenu(): integer;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

begin
  checkErrorCode := 1;
  checkInput := '';
  checkInt := 0;
  while ((checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 2))) do
  begin
    ClearScreen();
    writeln('Вы выбрали пункт специальных функций.');
    writeln;
    writeln('Доступные специальные функции: ');
    writeln;
    writeln('1. Подбор всех возможных вариантов комплектации компьютера в заданном ценовом диапазоне.');
    writeln('2. Оформление заказа понравившегося варианта.');
    writeln;
    write('Выберите функцию, введя ее номер(0 для выхода): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if ((checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 2))) then
    begin
      writeln('Выбор функции произведен некорректно. Нажмите для повторного ввода.');
      readln;
    end;
  end;
  result := checkInt;
end;

{ function GetCompatiblePartsArray }
function GetCompatiblePartsArray(list: CompatiblePartListType): TCompPartsArr;

  function Search(arr: TcompPartsMtx; code: integer): integer;

  var
    ans, i, c: integer;
    flag: boolean;

  begin
    ans := -1;
    i := 0;
    c := length(arr) - 1;
    flag := true;
    while (i <= c) and (flag) do
      if arr[i][0] = code then
        flag := false
      else
        inc(i);
    if not flag then
      ans := i;
    result := ans;
  end;

var
  cmpPtsMtx: TcompPartsMtx;
  id1, id2, i, min: integer;
  res: TCompPartsArr;

begin
  list := list^.compatiblePartListNextElement;
  while list <> nil do
  begin
    id1 := Search(cmpPtsMtx, list^.compatiblePartListInfo.firstPartCode);
    id2 := Search(cmpPtsMtx, list^.compatiblePartListInfo.secondPartCode);
    if id1 = -1 then
    begin
      SetLength(cmpPtsMtx, length(cmpPtsMtx) + 1);
      SetLength(cmpPtsMtx[length(cmpPtsMtx) - 1],
        length(cmpPtsMtx[length(cmpPtsMtx) - 1]) + 2);
      cmpPtsMtx[length(cmpPtsMtx) - 1][0] :=
        list^.compatiblePartListInfo.firstPartCode;
      cmpPtsMtx[length(cmpPtsMtx) - 1][1] :=
        list^.compatiblePartListInfo.secondPartCode;
    end
    else
    begin
      SetLength(cmpPtsMtx[id1], length(cmpPtsMtx[id1]) + 1);
      cmpPtsMtx[id1][length(cmpPtsMtx[id1]) - 1] :=
        list^.compatiblePartListInfo.secondPartCode;
    end;
    if id2 = -1 then
    begin
      SetLength(cmpPtsMtx, length(cmpPtsMtx) + 1);
      SetLength(cmpPtsMtx[length(cmpPtsMtx) - 1],
        length(cmpPtsMtx[length(cmpPtsMtx) - 1]) + 2);
      cmpPtsMtx[length(cmpPtsMtx) - 1][0] :=
        list^.compatiblePartListInfo.secondPartCode;
      cmpPtsMtx[length(cmpPtsMtx) - 1][1] :=
        list^.compatiblePartListInfo.firstPartCode;
    end
    else
    begin
      SetLength(cmpPtsMtx[id2], length(cmpPtsMtx[id2]) + 1);
      cmpPtsMtx[id2][length(cmpPtsMtx[id2]) - 1] :=
        list^.compatiblePartListInfo.firstPartCode;
    end;
    list := list^.compatiblePartListNextElement;
  end;
  if length(cmpPtsMtx) <> 0 then
  begin
    min := 0;
    for i := 1 to length(cmpPtsMtx) - 1 do
      if (length(cmpPtsMtx[i]) < length(cmpPtsMtx[min])) then
        min := i;
    result := cmpPtsMtx[min];
  end
  else
    result := res;
end;

{ procedure GetAllCombsIndex }
procedure GetAllCombsIndex(var IndexArr: TCompPartsMtx; n, m: integer);

  function NextSet(var arr: TCompPartsArr): boolean;

  var
    k, i, j: integer;
    res: boolean;

  begin
    k := m;
    res := false;
    i := k - 1;
    while (i >= 0) and (not res) do
    begin
      if arr[i] < n - k + i + 1 then
      begin
        inc(arr[i]);
        for j := i + 1 to k - 1 do
          arr[j] := arr[j - 1] + 1;
        res := true;
      end;
      dec(i);
    end;
    result := res;
  end;

  procedure Insert(arr: TCompPartsArr);

  var
    i: integer;

  begin
    SetLength(IndexArr, length(IndexArr) + 1);
    for i := 0 to m - 1 do
    begin
      setLength(IndexArr[length(IndexArr) - 1], length(IndexArr[length(IndexArr) - 1]) + 1);
      IndexArr[length(IndexArr) - 1][length(IndexArr[length(IndexArr) - 1]) - 1] := arr[i];
    end;
  end;

var
  arr: TCompPartsArr;
  i: integer;

begin
  SetLength(arr, n);
  for i := 0 to n - 1 do
    arr[i] := i + 1;
  Insert(arr);
  if n >= m then
    while NextSet(arr) do
      Insert(arr);
end;

{ ExitFunctions }
{ function SaveWithoutChanges }
function SaveWithoutChanges(list1: PartListType; list2: PartTypeListType;
  list3: CompatiblePartListType): boolean;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

var
  executionContinue: boolean;
  temp1: PartListType;
  temp2: PartTypeListType;
  temp3: CompatiblePartListType;

begin
  checkErrorCode := 1;
  checkInt := -1;
  checkInput := '';
  while (checkErrorCode > 0) and ((checkInt <> 0) or (checkInt <> 1)) do
  begin
    ClearScreen();
    writeln('Вы выбрали функцию сохранения без изменений.');
    writeln;
    write('Введите 1, чтобы продолжить, или 0 для выхода из процедуры: ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) and ((checkInt <> 0) or (checkInt <> 1)) then
    begin
      writeln('Некорректный ввод. Нажмите для повторного ввода');
      readln;
    end;
  end;
  if checkInt = 0 then
  begin
    ClearScreen();
    writeln('Вы отказались от выхода из программы.');
    sleep(1200);
    executionContinue := true;
  end
  else
  begin
    while list1^.partListNextElement <> nil do
    begin
      temp1 := list1^.partListNextElement^.partListNextElement;
      dispose(list1^.partListNextElement);
      list1^.partListNextElement := temp1;
    end;
    while list2^.partTypeListNextElement <> nil do
    begin
      temp2 := list2^.partTypeListNextElement^.partTypeListNextElement;
      dispose(list2^.partTypeListNextElement);
      list2^.partTypeListNextElement := temp2;
    end;
    while list3^.compatiblePartListNextElement <> nil do
    begin
      temp3 := list3^.compatiblePartListNextElement^.
        compatiblePartListNextElement;
      dispose(list3^.compatiblePartListNextElement);
      list3^.compatiblePartListNextElement := temp3;
    end;
    executionContinue := false;
  end;
  result := executionContinue;
end;

{ function SaveWithChanges }
function SaveWithChanges(list1: PartListType; list2: PartTypeListType;
  list3: CompatiblePartListType): boolean;

  function FileWriting(path1, path2, path3: string; list1: PartListType;
    list2: PartTypeListType; list3: CompatiblePartListType): boolean;

  var
    partListFile: PartListFileType;
    partTypeListFile: PartTypeListFileType;
    compatiblePartListFile: CompatiblePartListFileType;

  var
    temp1: PartListType;
    temp2: PartTypeListType;
    temp3: CompatiblePartListType;

  begin
{$I-}
    assign(partListFile, path1);
    rewrite(partListFile);
    while list1^.partListNextElement <> nil do
    begin
      write(partListFile, list1^.partListNextElement^.partListInfo);
      temp1 := list1^.partListNextElement^.partListNextElement;
      dispose(list1^.partListNextElement);
      list1^.partListNextElement := temp1;
    end;
    close(partListFile);
    assign(partTypeListFile, path2);
    rewrite(partTypeListFile);
    while list2^.partTypeListNextElement <> nil do
    begin
      write(partTypeListFile, list2^.partTypeListNextElement^.partTypeListInfo);
      temp2 := list2^.partTypeListNextElement^.partTypeListNextElement;
      dispose(list2^.partTypeListNextElement);
      list2^.partTypeListNextElement := temp2;
    end;
    close(partTypeListFile);
    assign(compatiblePartListFile, path3);
    rewrite(compatiblePartListFile);
    while list3^.compatiblePartListNextElement <> nil do
    begin
      write(compatiblePartListFile,
        list3^.compatiblePartListNextElement^.compatiblePartListInfo);
      temp3 := list3^.compatiblePartListNextElement^.
        compatiblePartListNextElement;
      dispose(list3^.compatiblePartListNextElement);
      list3^.compatiblePartListNextElement := temp3;
    end;
    close(compatiblePartListFile);
    result := false;
  end;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

var
  directoryPath, folder_files_name, path1, path2, path3: string;
  error1, error2, error3: integer;
  executionContinue: boolean;

var
  partListFile: PartListFileType;
  partTypeListFile: PartTypeListFileType;
  compatiblePartListFile: CompatiblePartListFileType;

begin
  checkErrorCode := 1;
  checkInt := -1;
  checkInput := '';
  while (checkErrorCode > 0) and ((checkInt <> 0) or (checkInt <> 1)) do
  begin
    ClearScreen();
    writeln('Вы выбрали функцию сохранения с изменениями.');
    writeln;
    write('Введите 1, чтобы продолжить, или 0 для выхода из процедуры: ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) and ((checkInt <> 0) or (checkInt <> 1)) then
    begin
      writeln('Некорректный ввод. Нажмите для повторного ввода');
      readln;
    end;
  end;
  if checkInt = 0 then
  begin
    ClearScreen();
    writeln('Вы отказались от выхода из программы.');
    sleep(1200);
    executionContinue := true;
  end
  else
  begin
    repeat
      ClearScreen();
      writeln('Введите путь, в котором хотите создать папку с файлами:');
      writeln;
      readln(directoryPath);
      writeln;
      if not directoryExists(directoryPath) then
      begin
        writeln('Указанная вами директория не существует. Нажмите для повторного ввода.');
        readln;
      end;
    until directoryExists(directoryPath);
    writeln('Введите имя папки. которую хотите создать: ');
    writeln;
    readln(folder_files_name);
    writeln;
    directoryPath := directoryPath + '\' + folder_files_name;
    path1 := directoryPath + '\' + folder_files_name + '_PartListData.upozn';
    path2 := directoryPath + '\' + folder_files_name +
      '_PartTypeListData.upozn';
    path3 := directoryPath + '\' + folder_files_name +
      '_CompatiblePartListData.upozn';
    if directoryExists(directoryPath) then
    begin
{$I-}
      assignFile(partListFile, path1);
      reset(partListFile);
      error1 := IOResult;
      assignFile(partTypeListFile, path2);
      reset(partTypeListFile);
      error2 := IOResult;
      assignFile(compatiblePartListFile, path3);
      reset(compatiblePartListFile);
      error3 := IOResult;
      closeFile(partListFile);
      closeFile(partTypeListFile);
      closeFile(compatiblePartListFile);
      if (error1 = 0) and (error2 = 0) and (error3 = 0) then
      begin
        checkInput := '';
        checkInt := -1;
        checkErrorCode := 1;
        while (checkErrorCode > 0) and ((checkInt <> 0) or (checkInt <> 1)) do
        begin
          writeln('Папка с введенным названием уже существует.');
          writeln;
          write('Введите 1 для перезаписи данных, иначе 0: ');
          readln(checkInput);
          val(string(checkInput), checkInt, checkErrorCode);
          if (checkErrorCode > 0) and ((checkInt <> 0) or (checkInt <> 1)) then
          begin
            writeln('Некорректный ввод. Нажмите для повторного ввода.');
            readln;
            ClearScreen();
          end;
        end;
        if checkInt = 0 then
        begin
          ClearScreen();
          writeln('Вы отказались от перезаписи.');
          sleep(1200);
          executionContinue := true;
        end
        else
        begin
          executionContinue := FileWriting(path1, path2, path3, list1,
            list2, list3);
          ClearScreen();
          writeln('Данные перезаписаны.');
          sleep(1200);
        end;
      end
      else
      begin
        executionContinue := FileWriting(path1, path2, path3, list1,
          list2, list3);
        ClearScreen();
        writeln('Данные записаны по директории.');
        sleep(1200);

      end;
    end
    else
    begin
      createDir(directoryPath);
      executionContinue := FileWriting(path1, path2, path3, list1,
        list2, list3);
      ClearScreen();
      writeln('Новая папка была создана. Данные записаны.');
      sleep(1200);
    end;
  end;
  result := executionContinue;
end;

{ function MainMenu }
function MainMenu(): integer;

var
  checkInput: TString;
  checkErrorCode: integer;
  checkInt: integer;

begin
  checkErrorCode := 1;
  checkInput := '';
  checkInt := 0;
  while ((checkErrorCode > 0) or ((checkInt < 1) or (checkInt > 10))) do
  begin
    ClearScreen();
    writeln('Меню выбора функций:');
    writeln;
    writeln('1. Чтение данных из файла.');
    writeln('2. Просмотр списков.');
    writeln('3. Сортировка списков.');
    writeln('4. Поиск данных с использованием фильтра.');
    writeln('5. Добавление данных в списки.');
    writeln('6. Удаление данных из списков.');
    writeln('7. Редактирование данных списков.');
    writeln('8. Подбор всех вариантов сборки компьютера в заданном ценовом диапазоне и оформление заказа(в разработке).');
    writeln('9. Выход из программы без сохранения изменений.');
    writeln('10. Выход из программы с сохранением изменений.');
    writeln;
    write('Выберите функцию, введя ее номер: ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if ((checkErrorCode > 0) or ((checkInt < 1) or (checkInt > 10))) then
    begin
      writeln('Выбор функции произведен некорректно. Нажмите для повторного ввода.');
      readln;
    end;
  end;
  result := checkInt;
end;

{ functions codes }
var
  mainMenuCode, showListCode, sortListCode, findInListCode, addToListCode,
    deleteFromListCode, editInListCode, specFunCode: integer;
  mainMenuContinue, isReadFromFile, showListContinue, sortListContinue,
    findInListContinue, addToListContinue, deleteFromListContinue,
    editInListContinue, specFunContinue: boolean;

  { lists declaration }
var
  partList: PartListType;
  partTypeList: PartTypeListType;
  compatiblePartList: CompatiblePartListType;

  { SpecFuncs arrs and lists }
var
  cmpPtsArr: TCompPartsArr;
  IndexMtx: TCompPartsMtx;
  n, m: integer;

begin
  { lists memory allocation }
  new(partList);
  new(partTypeList);
  new(compatiblePartList);

  partList^.partListNextElement := nil;
  partTypeList^.partTypeListNextElement := nil;
  compatiblePartList^.compatiblePartListNextElement := nil;

  partTypeList^.lastID := 0;
  partList^.lastID := 0;

  { init message }
  writeln('Добро пожаловать в каталог комплектующих. Нажмите, чтобы открыть меню.');
  readln;

  { working til exit }
  isReadFromFile := false;
  mainMenuContinue := true;
  while mainMenuContinue do
  begin
    mainMenuCode := MainMenu();
    case mainMenuCode of
      1: { ReadFromFileProcedure }
        ReadFromFiles(partList, partTypeList, compatiblePartList,
          isReadFromFile);
      2: { ShowListFunctions }
        begin
          showListContinue := true;
          while showListContinue do
          begin
            showListCode := ShowListMenu();
            case showListCode of
              0:
                showListContinue := false;
              1:
                ShowPartList(partList);
              2:
                ShowPartTypeList(partTypeList);
              3:
                ShowCompatiblePartList(compatiblePartList);
            end;
          end;
        end;
      3: { SortListFunctions }
        begin
          sortListContinue := true;
          while sortListContinue do
          begin
            sortListCode := SortListMenu();
            case sortListCode of
              0:
                sortListContinue := false;
              1:
                SortPartList(partList);
              2:
                SortPartTypeList(partTypeList);
              3:
                SortCompatiblePartList(compatiblePartList);
            end;
          end;
        end;
      4: { FindInListFunctions }
        begin
          findInListContinue := true;
          while findInListContinue do
          begin
            findInListCode := FindInListMenu();
            case findInListCode of
              0:
                findInListContinue := false;
              1:
                FindInPartList(partList);
              2:
                FindInPartTypeList(partTypeList);
              3:
                FindInCompatiblePartList(compatiblePartList);
            end;
          end;
        end;
      5: { AddToListFunctions }
        begin
          addToListContinue := true;
          while addToListContinue do
          begin
            addToListCode := AddToListMenu();
            case addToListCode of
              0:
                addToListContinue := false;
              1:
                AddToPartList(partList, partTypeList);
              2:
                AddToPartTypeList(partTypeList);
              3:
                AddToCompatiblePartList(compatiblePartList, partList);
            end;
          end;
        end;
      6: { DeleteFromListFunctions }
        begin
          deleteFromListContinue := true;
          while deleteFromListContinue do
          begin
            deleteFromListCode := DeleteFromListMenu();
            case deleteFromListCode of
              0:
                deleteFromListContinue := false;
              1:
                DeleteFromPartList(partList, compatiblePartList);
              2:
                DeleteFromPartTypeList(partList, partTypeList,
                  compatiblePartList);
              3:
                DeleteFromCompatiblePartList(compatiblePartList);
            end;
          end;
        end;
      7: { EditInListFunctions }
        begin
          editInListContinue := true;
          while editInListContinue do
          begin
            editInListCode := EditInListMenu();
            case editInListCode of
              0:
                editInListContinue := false;
              1:
                EditInPartList(partList, partTypeList);
              2:
                EditInPartTypeList(partTypeList);
              3:
                EditInCompatiblePartList(compatiblePartList, partList);
            end;
          end;
        end;
      8: { SpecialFunctions }
        begin
          specFunContinue := true;
          while specFunContinue do
          begin
            specFunCode := SpecialFunctionsMenu();
            case specFunCode of
              0:
                specFunContinue := false;
              1:
                begin
                  cmpPtsArr := GetCompatiblePartsArray(compatiblePartList);
                  if length(cmpPtsArr) = 0 then
                  begin
                    ClearScreen();
                    writeln('Комбинаций не обнаружилось.');
                    sleep(1200);
                  end
                  else
                  begin
                    n := length(cmpPtsArr);
                    for m := 2 to n do
                      GetAllCombsIndex(indexMtx, n, m);
                    ClearScreen();
                    writeln('Комбинации подобраны.');
                    sleep(1200);

                  end;
                end;
            end;
          end;
        end;
      9: { SaveWithoutChanges function }
        mainMenuContinue := SaveWithoutChanges(partList, partTypeList,
          compatiblePartList);
      10: { SaveWithChanges function }
        mainMenuContinue := SaveWithChanges(partList, partTypeList,
          compatiblePartList);
    end;
  end;
  ClearScreen();

  { lists memory disposion }
  dispose(partList);
  dispose(partTypeList);
  dispose(compatiblePartList);

  { bye message }
  writeln('Спасибо, что воспользовались нашим приложением.');
  sleep(930);

end.
