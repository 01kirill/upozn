program Project1;

{$APPTYPE CONSOLE}
{$R *.res}

{ used units and modules }
uses
  System.SysUtils, Windows;

{ types }
type
  TString = string[20];

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

  { special functions }

  TRealArr = array of real;
  TCombInt = array of integer;
  TCombCombint = array of TCombInt;
  TCombCombCombInt = array of TCombCombint;
  TComb = array of PartListDataType;
  TCombs = array of TComb;

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
  writeln('�� ������� ������� ������ ������ �� ������.');
  writeln;
  if isReadFromFile then
  begin
    writeln('������ �� ������ ��� ���� ��������. ��������� ������ ����������.');
    sleep(1200);
  end
  else
  begin
    if (list2^.partTypeListNextElement <> nil) then
    begin
      writeln('� ������� ��� ������� ������. �������� ������ �������� ���������� ������.');
      writeln;
      checkInput := '';
      checkErrorCode := 1;
      while checkErrorCode > 0 do
      begin
        write('������� 1, ����� ��������� ������ �� ������, ����� ������� 0: ');
        readln(checkInput);
        writeln;
        val(String(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode > 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
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
      writeln('�� ���������� �� �������� ������.');
      sleep(1200);
    end
    else
    begin
      repeat
        writeln('������� ���������� ���� � �����, ������� ����� ��������� ����� �� ��������(��� ������� ��� ������).');
        writeln;
        readln(directoryPath);
        writeln;
        if (not directoryExists(directoryPath)) and (directoryPath <> '') then
        begin
          writeln('����� ���������� �� ����������. ������� ��� ���������� �����.');
          readln;
          ClearScreen();
        end;
      until (directoryExists(directoryPath)) or (directoryPath = '');
      if directoryPath = '' then
      begin
        ClearScreen();
        writeln('�� ���������� �� �������� ������.');
        sleep(1200);
      end
      else
      begin
        repeat
          writeln('������� ��� �����(��� ������� ��� ������): ');
          writeln;
          readln(folder_files_name);
          writeln;
          if (not directoryExists(directoryPath + '\' + folder_files_name)) and
            (folder_files_name <> '') then
          begin
            writeln('����� ����� �� ����������. ������� ��� ���������� �����.');
            readln;
            ClearScreen();
          end;
        until (directoryExists(directoryPath + '\' + folder_files_name)) or
          (folder_files_name = '');
        if folder_files_name = '' then
        begin
          ClearScreen();
          writeln('�� ���������� �� �������� ������.');
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
            writeln('� ��������� ���������� ����������� �����.');
            writeln;
            writeln('�������, ����� ����������.');
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
            writeln('������ ��������.');
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
    writeln('�� ������� ������� ��������� �������.');
    writeln;
    writeln('��������� ��� ��������� ������: ');
    writeln('1. ������ �������������.');
    writeln('2. ������ ����� �������������.');
    writeln('3. ������ ����������� �������������.');
    writeln;
    write('������� ����� ������, ������� ������ �����������(��� ������� 0, ����� ����� �� ������� ���������): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3)) then
    begin
      writeln('������ � �������� ������� �� ����������. ������� ��� ���������� �����.');
      readln;
    end;
  end;
  result := checkInt;
end;

{ procedure ShowPartList }
procedure ShowPartList(list: PartListType);

begin
  ClearScreen();
  writeln('������ �������������.');
  writeln;
  writeln('-----------------------------------------------------------------------------------------------------------------------------------------');
  writeln('| ��� �������������� | ��� ���� �������������� |    ������������    |       ������       |      ���������     |   ����   |  ����������  |');
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
  writeln('�������, ����� ����������.');
  readln;
end;

{ procedure ShowPartTypeList }
procedure ShowPartTypeList(list: PartTypeListType);

begin
  ClearScreen();
  writeln('������ ����� �������������.');
  writeln;
  writeln('------------------------------------------------');
  writeln('| ��� ���� �������������� |      ��������      |');
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
  writeln('�������, ����� ����������.');
  readln;
end;

{ procedure ShowCompatiblePartList }
procedure ShowCompatiblePartList(list: CompatiblePartListType);

begin
  ClearScreen();
  writeln('������ ����������� �������������.');
  writeln;
  writeln('-----------------------------------------------------------');
  writeln('| ��� ������� �������������� | ��� ������� �������������� |');
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
  writeln('�������, ����� ����������.');
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
    writeln('�� ������� ������� ���������� �������.');
    writeln;
    writeln('��������� ��� ���������� ������: ');
    writeln('1. ������ �������������.');
    writeln('2. ������ ����� �������������.');
    writeln('3. ������ ����������� �������������.');
    writeln;
    write('������� ����� ������, ������� ������ �����������(��� ������� 0, ����� ����� �� ������� ����������): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3)) then
    begin
      writeln('������ � �������� ������� �� ����������. ������� ��� ���������� �����.');
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
    writeln('��������� ���� ��� ����������: ');
    writeln;
    writeln('1. ��� ��������������.');
    writeln('2. ��� ���� ��������������.');
    writeln('3. �������������.');
    writeln('4. ��� ������.');
    writeln('5. ����.');
    writeln('6. ����������.');
    writeln;
    write('������� ����� ����: ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) or ((checkInt < 1) or (checkInt > 6)) then
    begin
      writeln('��������� ���� �� ����������. ������� ��� ���������� �����.');
      readln;
    end;
  end;
  if not((list = nil) or (list^.partListNextElement = nil)) then
    SortPartListElements(list, checkInt);
  ClearScreen();
  writeln('������ ������������.');
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
    writeln('��������� ���� ��� ����������: ');
    writeln;
    writeln('1. ��� ���� ��������������.');
    writeln('2. ��������.');
    writeln;
    write('������� ����� ����: ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) or ((checkInt < 1) or (checkInt > 2)) then
    begin
      writeln('��������� ���� �� ����������. ������� ��� ���������� �����.');
      readln;
    end;
  end;
  if not((list = nil) or (list^.partTypeListNextElement = nil)) then
    SortPartTypeListElements(list, checkInt);
  ClearScreen();
  writeln('������ ������������.');
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
    writeln('��������� ���� ��� ����������: ');
    writeln;
    writeln('1. ��� ������� ��������������.');
    writeln('2. ��� ������� ��������������.');
    writeln;
    write('������� ����� ����: ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) or ((checkInt < 1) or (checkInt > 2)) then
    begin
      writeln('��������� ���� �� ����������. ������� ��� ���������� �����.');
      readln;
    end;
  end;
  if not((list = nil) or (list^.compatiblePartListNextElement = nil)) then
    SortCompatiblePartListElements(list, checkInt);
  ClearScreen();
  writeln('������ ������������.');
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
    writeln('�� ������� ������� ������ ������ � �������.');
    writeln;
    writeln('��������� ��� ������ ������: ');
    writeln('1. ������ �������������.');
    writeln('2. ������ ����� �������������.');
    writeln('3. ������ ����������� �������������.');
    writeln;
    write('������� ����� ������,� ������� ������ �������� �����(��� ������� 0, ����� ����� �� ������� ������): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3)) then
    begin
      writeln('������ � �������� ������� �� ����������. ������� ��� ���������� �����.');
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
      writeln('��������� ���� ��� ������: ');
      writeln;
      writeln('1. ��� ��������������.');
      writeln('2. ��� ���� ��������������.');
      writeln('3. �������������.');
      writeln('4. ��� ������.');
      writeln;
      write('������� ����� ����(������� 0 ��� ������): ');
      readln(checkInput);
      writeln;
      val(string(checkInput), checkInt, checkErrorCode);
      if (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 4)) then
      begin
        writeln('��������� ���� �� ����������. ������� ��� ���������� �����.');
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
                  write('������� ��� ��������������: ');
                2:
                  write('������� ��� ���� ��������������: ');
              end;
              readln(checkInput);
              writeln;
              val(string(checkInput), checkInt, checkErrorCode);
              if (checkErrorCode > 0) or (checkInt = 0) then
              begin
                writeln('������������ ����. ������� ��� ���������� �����.');
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
                  write('������� ��� ������������: ');
                4:
                  write('������� ��� ������: ');
              end;
              readln(checkInput);
              writeln;
              if (checkInput = '') then
              begin
                writeln('������������ ����. ������� ��� ���������� �����.');
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
            writeln('������� ������.');
            writeln;
            writeln('-----------------------------------------------------------------------------------------------------------------------------------------');
            writeln('| ��� �������������� | ��� ���� �������������� |    ������������    |       ������       |      ���������     |   ����   |  ����������  |');
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
        writeln('������ �� �������.');
      writeln;
      writeln('�������, ����� ����������.');
      readln;
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('������� 0, ����� ������� � ���� �������, ��� 1 ��� ����������� ������: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if checkErrorCode > 0 then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('�� ���������� �� ������.');
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
      writeln('��������� ���� ��� ������: ');
      writeln;
      writeln('1. ��� ���� ��������������.');
      writeln('2. ��������.');
      writeln;
      write('������� ����� ����(������� 0 ��� ������): ');
      readln(checkInput);
      writeln;
      val(string(checkInput), checkInt, checkErrorCode);
      if (checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 2)) then
      begin
        writeln('��������� ���� �� ����������. ������� ��� ���������� �����.');
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
              write('������� ��� ���� ��������������: ');
              readln(checkInput);
              writeln;
              val(string(checkInput), checkInt, checkErrorCode);
              if (checkErrorCode > 0) or (checkInt = 0) then
              begin
                writeln('������������ ����. ������� ��� ���������� �����.');
                readln;
              end;
            end;
          end;
        2:
          begin
            while checkInput = '' do
            begin
              ClearScreen();
              write('������� ��������: ');
              readln(checkInput);
              writeln;
              if checkInput = '' then
              begin
                writeln('������������ ����. ������� ��� ���������� �����.');
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
            writeln('������� ������.');
            writeln;
            writeln('------------------------------------------------');
            writeln('| ��� ���� �������������� |      ��������      |');
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
        writeln('������ �� �������.');
      writeln;
      writeln('�������, ����� ����������.');
      readln;
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('������� 0, ����� ������� � ���� �������, ��� 1 ��� ����������� ������: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('�� ���������� �� ������.');
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
      write('������� ��� ��������������(������� 0 ��� ������): ');
      readln(checkInput);
      writeln;
      val(string(checkInput), checkInt, checkErrorCode);
      if (checkErrorCode > 0) then
      begin
        writeln('������������ ����. ������� ��� ���������� �����.');
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
            writeln('������� ������.');
            writeln;
            writeln('-----------------------------------------------------------');
            writeln('| ��� ������� �������������� | ��� ������� �������������� |');
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
        writeln('������ �� �������.');
      writeln;
      writeln('�������, ����� ����������.');
      readln;
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('������� 0, ����� ������� � ���� �������, ��� 1 ��� ����������� ������: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if checkErrorCode <> 0 then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('�� ���������� �� ������.');
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
    writeln('�� ������� ������� ���������� ������ � �������.');
    writeln;
    writeln('��������� ��� ���������� ������ ������: ');
    writeln('1. ������ �������������.');
    writeln('2. ������ ����� �������������.');
    writeln('3. ������ ����������� �������������.');
    writeln;
    write('������� ����� ������,� ������� ������ �������� ����������(��� ������� 0, ����� ����� �� ������� ����������): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if ((checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3))) then
    begin
      writeln('������ � �������� ������� �� ����������. ������� ��� ���������� �����.');
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
    writeln('�������, ����� ������������ � ���������� ������ �������������.');
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
        write('������� ��� ���� �������������(��� ������� 0, ����� ����� �� ������ �������): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode > 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
          writeln('������ ���� �������������� �� ����������. ������� ��� ���������� �����.');
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
        write('������� ��� ������������: ');
        readln(checkInput);
        writeln;
        if (checkInput = '') then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
          write('������� ��� ������: ');
          readln(checkInput);
          writeln;
          if (checkInput = '') then
          begin
            writeln('������������ ����. ������� ��� ���������� �����.');
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
          writeln('������ ������ ��� ���� � ������. ������� ��� ���������� �����.');
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
        write('������� ��������� ������: ');
        readln(checkInput);
        writeln;
        if (checkInput = '') then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
        write('������� ����: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkReal, checkErrorCode);
        if (checkErrorCode > 0) or (checkReal < 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
        write('������� ����������: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode > 0) or (checkInt < 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
          readln;
          ClearScreen();
        end;
      end;
      list^.partListInfo.availability := checkInt;
      ClearScreen();
      writeln('������ ���� ��������� � ������.');
      sleep(1200);
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('������� 0, ����� ������� � ���� �������, ��� 1 ��� ����������� ����������: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('�� ���������� �� ���������� ������.');
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
        write('������� �������� ���� �������������(��� ������� 0 ��� ������ �� �������): ');
        readln(checkInput);
        writeln;
        if (checkInput = '') and (checkInput <> '0') then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
          writeln('������ ������� ��� ���� � ������. ������� ��� ���������� �����.');
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
      writeln('������ ���� ��������� � ������.');
      sleep(1200);
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('������� 0, ����� ������� � ���� �������, ��� 1 ��� ����������� ����������: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('�� ���������� �� ���������� ������.');
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
    writeln('�������, ����� ������������ �� ������� �������������.');
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
        write('������� ��� ������� ��������������: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt1, checkErrorCode);
        if (checkErrorCode > 0) or (checkInt1 = 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
          readln;
        end
      end;
      checkInput := '';
      checkErrorCode := 1;
      checkInt2 := 0;
      while (checkErrorCode > 0) or (checkInt1 = 0) do
      begin
        write('������� ��� ������� ��������������: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt2, checkErrorCode);
        if (checkErrorCode > 0) or (checkInt2 = 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
          readln;
          ClearScreen();
        end
      end;
      checkInput := '';
      checkErrorCode := 1;
      while checkErrorCode > 0 do
      begin
        ClearScreen();
        write('����� ����������� ����������, ������� 1, ����� 0: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          if ((checkInt <> 0) or (checkInt <> 1)) then
          begin
            writeln('������������ ����. ������� ��� ���������� �����.');
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
          writeln('������ ������ ��� ���� � ������. ������� ��� ���������� �����.');
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
            writeln('�������������� � ����� ����� �� ����������. ������� ��� ���������� �����.');
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
              writeln('�������������� � ����� ����� �� ����������. ������� ��� ���������� �����.');
              readln;
            end
            else if checkInt1 = checkInt2 then
            begin
              writeln('������������� �� ����� ���� ����������� ���� � �����. ������� ��� ���������� �����.');
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
      writeln('������ ���� ��������� � ������.');
      sleep(1200);
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('������� 0, ����� ������� � ���� �������, ��� 1 ��� ����������� ����������: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('�� ���������� �� ���������� ������.');
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
    writeln('�� ������� ������� �������� ������ �� �������.');
    writeln;
    writeln('��������� ��� �������� ������: ');
    writeln('1. ������ �������������.');
    writeln('2. ������ ����� �������������.');
    writeln('3. ������ ����������� �������������.');
    writeln;
    write('������� ����� ������, �� �������� ������ �������(��� ������� 0, ����� ����� �� ������� ��������): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if ((checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3))) then
    begin
      writeln('������ � �������� ������� �� ����������. ������� ��� ���������� �����.');
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
  while isNotExit do
  begin
    ClearScreen();
    writeln('�� ������� ������� ����� ������� ������.');
    writeln;
    writeln('�� ����� ��������� �������� ������, ����� � ���������� ������ �� ��� ��� ��������.');
    readln;
    ShowPartList(list);
    isInList := true;
    while isInList do
    begin
      checkInput := '';
      checkInt := 0;
      checkErrorCode := 1;
      while (checkErrorCode > 0) do
      begin
        ClearScreen();
        write('������� ��� ��������������(��� 0 ��� ������ �� �������): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode > 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
          writeln('�������������� � ��������� ����� �� ����������. ������� ��� ���������� �����.');
          readln;
        end;
      end;
    end;
    if checkInt = 0 then
    begin
      ClearScreen();
      writeln('�� ���������� �� �������� ������.');
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
        write('�������� ������ ����� ������� �������� ������� �� ������ �������. ��� ������������� �������� ������� 1, ����� 0: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          if ((checkInt <> 0) or (checkInt <> 1)) then
          begin
            writeln('������������ ����. ������� ��� ���������� �����.');
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
        writeln('������ ���� �������.');
        sleep(1200);
      end
      else
      begin
        ClearScreen();
        writeln('�� ���������� �� �������� ������.');
        sleep(1200);
      end;
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('������� 0, ����� ������� � ���� �������, ��� 1 ��� ����������� ��������: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
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
  while isNotExit do
  begin
    ClearScreen();
    writeln('�� ������� ������� ����� ������� ������.');
    writeln;
    writeln('�� ����� ��������� �������� ������, ����� � ���������� ������ �� ��� ��� ��������.');
    readln;
    ShowPartTypeList(list);
    isInList := true;
    while isInList do
    begin
      checkInput := '';
      checkInt := 0;
      checkErrorCode := 1;
      while (checkErrorCode > 0) do
      begin
        ClearScreen();
        write('������� ��� ���� ��������������(��� 0, ����� ����� �� �������): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode > 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
          writeln('������ ���� �������������� �� ����������. ������� ��� ���������� �����.');
          readln;
        end;
      end;
    end;
    if checkInt = 0 then
    begin
      ClearScreen();
      writeln('�� ���������� �� ���������� ������.');
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
        write('�������� ������ ����� ������� �������� ������� �� ������ �������. ��� ������������� �������� ������� 1, ����� 0: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          if ((checkInt <> 0) or (checkInt <> 1)) then
          begin
            writeln('������������ ����. ������� ��� ���������� �����.');
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
        writeln('������ ���� �������.');
        sleep(1200);
      end
      else
      begin
        ClearScreen();
        writeln('�� ���������� �� �������� ������.');
        sleep(1200);
      end;
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('������� 0, ����� ������� � ���� �������, ��� 1 ��� ����������� ��������: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
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
  while isNotExit do
  begin
    ClearScreen();
    writeln('�� ������� ������� ����� ������� ������.');
    writeln;
    writeln('�� ����� ��������� �������� ������, ����� � ���������� ������ �� ��� ��� ��������.');
    readln;
    ShowCompatiblePartList(list);
    isInList := true;
    while isInList do
    begin
      checkInput := '';
      checkInt1 := 0;
      checkErrorCode := 1;
      while (checkErrorCode > 0) do
      begin
        ClearScreen();
        write('������� ��� ������� ��������������(��� 0 ��� ������ �� �������): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt1, checkErrorCode);
        if (checkErrorCode > 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
          write('������� ��� ������� ��������������: ');
          readln(checkInput);
          writeln;
          val(string(checkInput), checkInt2, checkErrorCode);
          if (checkErrorCode > 0) or (checkInt2 = 0) then
          begin
            writeln('������������ ����. ������� ��� ���������� �����.');
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
          writeln('������ ������ ���������� � ������. ������� ��� ���������� �����.');
          readln;
        end
        else
          isInList := false;
      end;
    end;
    if checkInt1 = 0 then
    begin
      ClearScreen();
      writeln('�� ���������� �� ��������.');
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
        write('��� ������������� �������� ������� 1, ����� 0: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          if ((checkInt <> 0) or (checkInt <> 1)) then
          begin
            writeln('������������ ����. ������� ��� ���������� �����.');
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
        writeln('������ ���� �������.');
        sleep(1200);
      end
      else
      begin
        ClearScreen();
        writeln('�� ���������� �� �������� ������.');
        sleep(1200);
      end;
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('������� 0, ����� ������� � ���� �������, ��� 1 ��� ����������� ��������: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
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
    writeln('�� ������� ������� �������������� ������ � ������.');
    writeln;
    writeln('��������� ��� �������������� ������: ');
    writeln('1. ������ �������������.');
    writeln('2. ������ ����� �������������.');
    writeln('3. ������ ����������� �������������.');
    writeln;
    write('������� ����� ������, � ������� ������ �������������(��� ������� 0, ����� ����� �� ������� ��������������): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if ((checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3))) then
    begin
      writeln('������ � �������� ������� �� ����������. ������� ��� ���������� �����.');
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
    writeln('�������, ����� ������� ������ ������������� � �������� ��� ��� ��������������.');
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
        write('������� ��� ��������������(��� 0 ��� ������): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if checkErrorCode > 0 then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
          writeln('������ �������������� �� ����������. �������� ��� ���������� �����.');
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
          write('������� ��� ���� ��������������(������� ��� �������� � ���������� ���� ��� ������� 0 ��� ������): ');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
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
            writeln('������ ���� �������������� �� ����������. �������� ��� ���������� �����.');
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
        write('������� ��� ������������(������� ��� �������� � ���������� ����): ');
        readln(checkInput);
        writeln;
        if checkInput <> '' then
          header^.partListInfo.manufacturer := checkInput;
        isInList := true;
        while isInList do
        begin
          write('������� ��� ������(������� ��� �������� � ���������� ����): ');
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
              writeln('������ ������ ��� ���� � ������. ������� ��� ���������� �����.');
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
        write('������� ���������(������� ��� �������� � ���������� ����): ');
        readln(checkInput);
        writeln;
        if checkInput <> '' then
          header^.partListInfo.parameters := checkInput;
        flag1 := false;
        flag2 := false;
        while (not flag1) and (not flag2) do
        begin
          write('������� ����(������� ��� �������� � ���������� ����): ');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
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
          write('������� ����������(������� ��� �������� � ���������� ����): ');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
              readln;
              ClearScreen();
            end;
          end;
        end;
        if (flag2) and (not flag1) then
          header^.partListInfo.availability := checkInt;
        ClearScreen();
        writeln('������ ���������������.');
        sleep(1200);
        isNotExitCheck := true;
        while isNotExitCheck do
        begin
          ClearScreen();
          write('������� 0, ����� ������� � ���� �������, ��� 1 ��� ����������� ��������������: ');
          readln(checkInput);
          writeln;
          val(string(checkInput), checkInt, checkErrorCode);
          if (checkErrorCode <> 0) then
          begin
            writeln('������������ ����. ������� ��� ���������� �����.');
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
                writeln('������������ ����. ������� ��� ���������� �����.');
                readln;
              end;
            end;
        end;
      end
      else
      begin
        ClearScreen();
        writeln('�� ���������� �� �������������� ������.');
        sleep(1200);
        isNotExit := false;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('�� ���������� �� �������������� ������.');
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
    writeln('�������, ����� ������� ������ ����� ������������� � �������� ��� ��� ��������������.');
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
        write('������� ��� ���� ��������������(��� 0 ��� ������): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if checkErrorCode > 0 then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
          writeln('������ ���� �������������� �� ����������. �������� ��� ���������� �����.');
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
      write('������� ��������(������� ��� �������� � ���������� ����): ');
      readln(checkInput);
      if checkInput <> '' then
        header^.partTypeListInfo.partTypeName := checkInput;
      ClearScreen();
      writeln('������ ���������������.');
      sleep(1200);
      isNotExitCheck := true;
      while isNotExitCheck do
      begin
        ClearScreen();
        write('������� 0, ����� ������� � ���� �������, ��� 1 ��� ����������� ��������������: ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode <> 0) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
              writeln('������������ ����. ������� ��� ���������� �����.');
              readln;
            end;
          end;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('�� ���������� �� �������������� ������.');
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
    writeln('�������, ����� ������� ������ ����������� �������������.');
    readln;
    ShowCompatiblePartList(list);
    isInList := true;
    while isInList do
    begin
      checkErrorCode := 1;
      while checkErrorCode > 0 do
      begin
        ClearScreen();
        write('������� ��� ������� ��������������(��� 0 ��� ������): ');
        readln(checkInput);
        writeln;
        val(string(checkInput), checkInt1, checkErrorCode);
        if checkErrorCode > 0 then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
          write('������� ��� ������� ��������������: ');
          readln(checkInput);
          writeln;
          val(string(checkInput), checkInt2, checkErrorCode);
          if checkErrorCode > 0 then
          begin
            writeln('������������ ����. ������� ��� ���������� �����.');
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
          writeln('������ ������ ���������� � ������. ������� ��� ���������� �����.');
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
        write('�������, ��� ������ �������������� ������ �������������(1 ��� 2): ');
        readln(checkInput);
        val(string(checkInput), checkInt, checkErrorCode);
        if (checkErrorCode > 0) and ((checkInt <> 1) or (checkInt <> 2)) then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
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
            write('������� ��� ��������������(������� ��� �������� � ���������� ���� ��� ������� 0 ��� ������): ');
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
                writeln('������������ ����. ������� ��� ���������� �����.');
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
              writeln('������ �������������� �� ����������. �������� ��� ���������� �����.');
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
            writeln('������������� �� ����� ���� ���������� ���� � �����. ������� ��� ���������� �����.');
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
              writeln('����� ������ ��� ���� ������. ������� ��� ���������� �����.');
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
        writeln('������ ���������������.');
        sleep(1200);
        isNotExitCheck := true;
        while isNotExitCheck do
        begin
          ClearScreen();
          write('������� 0, ����� ������� � ���� �������, ��� 1 ��� ����������� ��������������: ');
          readln(checkInput);
          writeln;
          val(string(checkInput), checkInt, checkErrorCode);
          if (checkErrorCode <> 0) then
          begin
            writeln('������������ ����. ������� ��� ���������� �����.');
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
                writeln('������������ ����. ������� ��� ���������� �����.');
                readln;
              end;
            end;
        end;
      end
      else
      begin
        ClearScreen();
        writeln('�� ���������� �� �������������� ������.');
        sleep(1200);
        isNotExit := false;
      end;
    end
    else
    begin
      ClearScreen();
      writeln('�� ���������� �� �������������� ������.');
      sleep(1200);
      isNotExit := false;
    end;
  end;
end;

{ special functions }
function EnterPrice(ToRefresh: boolean): real;

var
  checkInput: TString;
  checkReal, checkErrorCode: integer;

begin
  checkErrorCode := 1;
  checkReal := -1;
  while (checkErrorCode > 0) and (checkReal < 0) do
  begin
    ClearScreen();
    if ToRefresh then
      writeln('������� ������� ��������.')
    else
    begin
      writeln('����� ���������� � ����������� �������.');
      writeln;
      writeln('��� ������ ���������� ������� ������������. ��� ����� ������� ������� ��������.');
    end;
    writeln;
    write('������� ��������: ');
    readln(checkInput);
    val(checkInput, checkReal, checkErrorCode);
    if (checkErrorCode > 0) and (checkReal < 0) then
    begin
      writeln('������������ ����. ������� ��� ���������� �����.');
      readln;
    end;
  end;
  result := checkReal;
end;

function ToRefreshFun(): boolean;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;
  res: boolean;

begin
  res := false;
  checkErrorCode := 1;
  checkInt := -1;

  while (checkErrorCode > 0) and ((checkInt <> 0) or (checkInt <> 1)) do
  begin
    ClearScreen();
    writeln('���������� ��� ���������. ������� ������������? 1 - ��, 0 - ���.');
    readln(checkInput);
    val(checkInput, checkInt, checkErrorCode);
    if (checkErrorCode > 0) and ((checkInt <> 0) or (checkInt <> 1)) then
      writeln('������������ ����. ������� ��� ���������� �����.');
  end;
  case checkInt of
    1:
      res := true;
    0:
      res := false;
  end;
  result := res;
end;

procedure GetAllComputerConfigs(price: real; ToShow: boolean;
  list: CompatiblePartListType; list1: PartListType; var OrderSums: TRealArr;
  var CombsToShow, CombsToBuy: TCombs);

  procedure findCombinations(arr: TCombInt; start, endd: integer;
    var current: TCombInt; var res: TCombCombint);

  var
    i: integer;

  begin
    if length(current) = endd then
    begin
      setLength(res, length(res) + 1);
      res[length(res) - 1] := current;
    end
    else
    begin
      for i := start to length(arr) - 1 do
      begin
        setLength(current, length(current) + 1);
        current[length(current) - 1] := arr[i];
        findCombinations(arr, i + 1, endd, current, res);
        setLength(current, length(current) - 1);
      end;
    end;
  end;

  function findAllCombinations(arr: TCombInt; n: integer): TCombCombint;

  var
    res: TCombCombint;
    current: TCombInt;

  begin
    findCombinations(arr, 0, n, current, res);
    result := res;
  end;

  function Search(arr: TCombCombint; code: integer): integer;

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
  tempSwapArr, buffsum: TCombInt;
  tempArr, buffArr: TCombCombint;
  id1, id2, i, j, k, tempSwap, cnt: integer;
  combsArr: TCombCombint;
  header: CompatiblePartListType;
  header1: PartListType;
  flag: boolean;
  sum: real;

begin
  header := list;
  header1 := list1;
  list := list^.compatiblePartListNextElement;
  while list <> nil do
  begin
    id1 := Search(tempArr, list^.compatiblePartListInfo.firstPartCode);
    id2 := Search(tempArr, list^.compatiblePartListInfo.secondPartCode);
    if id1 = -1 then
    begin
      setLength(tempArr, length(tempArr) + 1);
      setLength(tempArr[length(tempArr) - 1],
        length(tempArr[length(tempArr) - 1]) + 2);
      tempArr[length(tempArr) - 1][0] :=
        list^.compatiblePartListInfo.firstPartCode;
      tempArr[length(tempArr) - 1][1] :=
        list^.compatiblePartListInfo.secondPartCode;
    end
    else
    begin
      setLength(tempArr[id1], length(tempArr[id1]) + 1);
      tempArr[id1][length(tempArr[id1]) - 1] :=
        list^.compatiblePartListInfo.secondPartCode;
    end;
    if id2 = -1 then
    begin
      setLength(tempArr, length(tempArr) + 1);
      setLength(tempArr[length(tempArr) - 1],
        length(tempArr[length(tempArr) - 1]) + 2);
      tempArr[length(tempArr) - 1][0] :=
        list^.compatiblePartListInfo.secondPartCode;
      tempArr[length(tempArr) - 1][1] :=
        list^.compatiblePartListInfo.firstPartCode;
    end
    else
    begin
      setLength(tempArr[id2], length(tempArr[id2]) + 1);
      tempArr[id2][length(tempArr[id2]) - 1] :=
        list^.compatiblePartListInfo.firstPartCode;
    end;
    list := list^.compatiblePartListNextElement;
  end;
  for i := 0 to length(tempArr) - 2 do
    for j := i + 1 to length(tempArr) - 1 do
      if (tempArr[j][0] < tempArr[i][0]) then
      begin
        tempSwapArr := tempArr[j];
        tempArr[j] := tempArr[i];
        tempArr[i] := tempSwapArr;
      end;

  for k := 0 to length(tempArr) - 1 do
    for i := 0 to length(tempArr[k]) - 2 do
      for j := i + 1 to length(tempArr[k]) - 1 do
        if tempArr[k][j] < tempArr[k][i] then
        begin
          tempSwap := tempArr[k][j];
          tempArr[k][j] := tempArr[k][i];
          tempArr[k][i] := tempSwap;
        end;

  for i := 0 to length(tempArr) - 1 do
  begin
    for j := 3 to length(tempArr[i]) do
    begin
      buffArr := findAllCombinations(tempArr[i], j);
      for k := 0 to length(buffArr) - 1 do
      begin
        setLength(combsArr, length(combsArr) + 1);
        combsArr[length(combsArr) - 1] := buffArr[k];
      end;
    end;
  end;

  for i := 0 to length(combsArr) - 2 do
    for j := i + 1 to length(combsArr) - 1 do
      if (length(combsArr[j]) < length(combsArr[i])) then
      begin
        tempSwapArr := combsArr[i];
        combsArr[i] := combsArr[j];
        combsArr[j] := tempSwapArr;
      end;

  for i := 0 to length(combsArr) - 2 do
    for j := i + 1 to length(combsArr) - 1 do
      for k := 0 to length(combsArr[i]) - 1 do
        if (length(combsArr[j]) = length(combsArr[i])) then
        begin
          if (combsArr[j][k] < combsArr[i][k]) then
          begin
            tempSwapArr := combsArr[i];
            combsArr[i] := combsArr[j];
            combsArr[j] := tempSwapArr;
          end;
        end;

  i := 0;
  while i < length(combsArr) - 1 do
  begin
    if length(combsArr[i]) = length(combsArr[i + 1]) then
    begin
      k := 0;
      flag := false;
      for j := 0 to length(combsArr[i + 1]) - 1 do
      begin
        if combsArr[i][k] <> combsArr[i + 1][j] then
          flag := true;
        inc(k);
      end;
      if not flag then
        delete(combsArr, i + 1, 1)
      else
        inc(i);
    end
    else
      inc(i);
  end;

  i := 0;
  while i < length(combsArr) do
  begin
    cnt := 0;
    for j := 0 to length(combsArr[i]) - 2 do
      for k := j + 1 to length(combsArr[i]) - 1 do
        inc(cnt);
    for j := 0 to length(combsArr[i]) - 2 do
      for k := j + 1 to length(combsArr[i]) - 1 do
      begin
        list := header^.compatiblePartListNextElement;
        while (list <> nil) do
        begin
          if ((list^.compatiblePartListInfo.firstPartCode = combsArr[i][j]) and
            (list^.compatiblePartListInfo.secondPartCode = combsArr[i][k])) then
            dec(cnt);
          list := list^.compatiblePartListNextElement
        end;
      end;
    if cnt <> 0 then
      delete(combsArr, i, 1)
    else
      inc(i);
  end;
  list := header^.compatiblePartListNextElement;
  while list <> nil do
  begin
    setLength(CombsToShow, length(CombsToShow) + 1);
    setLength(CombsToShow[length(CombsToShow) - 1], 2);
    list1 := header1^.partListNextElement;
    while list1 <> nil do
    begin
      if list1^.partListInfo.partCode = list^.compatiblePartListInfo.firstPartCode
      then
        CombsToShow[length(CombsToShow) - 1][0] := list1^.partListInfo;
      list1 := list1^.partListNextElement;
    end;
    list1 := header1^.partListNextElement;
    while list1 <> nil do
    begin
      if list1^.partListInfo.partCode = list^.compatiblePartListInfo.secondPartCode
      then
        CombsToShow[length(CombsToShow) - 1][1] := list1^.partListInfo;
      list1 := list1^.partListNextElement;
    end;
    list := list^.compatiblePartListNextElement;
  end;
  for i := 0 to length(combsArr) - 1 do
  begin
    setLength(CombsToShow, length(CombsToShow) + 1);
    setLength(CombsToShow[length(CombsToShow) - 1], length(combsArr[i]));
    for j := 0 to length(combsArr[i]) - 1 do
    begin
      list1 := header1^.partListNextElement;
      while list1 <> nil do
      begin
        if list1^.partListInfo.partCode = combsArr[i][j] then
          CombsToShow[length(CombsToShow) - 1][j] := list1^.partListInfo;
        list1 := list1^.partListNextElement;
      end;
    end;
  end;
  for i := 0 to length(CombsToShow) - 1 do
  begin
    flag := false;
    sum := 0;
    for j := 0 to length(CombsToShow[i]) - 1 do
    begin
      if CombsToShow[i][j].availability = 0 then
        flag := true;
      sum := sum + CombsToShow[i][j].price;
    end;
    if (not flag) and (sum <= price + 0.000001) then
    begin
      setLength(CombsToBuy, length(CombsToBuy) + 1);
      setLength(OrderSums, length(OrderSums) + 1);
      OrderSums[length(OrderSums) - 1] := sum;
      CombsToBuy[length(CombsToBuy) - 1] := CombsToShow[i];
    end;
  end;
  if ToShow then
    if length(CombsToShow) = 0 then
    begin
      ClearScreen();
      writeln('�� ������� ��������� ����������.');
      sleep(1200);
    end
    else
    begin
      ClearScreen();
      writeln('���������� ���������.');
      sleep(1200);
    end;
end;

procedure ShowConfigs(CombsToShow: TCombs);

var
  Fl: textFile;
  i, j: integer;
  path: string;

begin
  if length(CombsToShow) = 0 then
  begin
    ClearScreen();
    writeln('���������� ���.');
    sleep(1200);
  end
  else
  begin
    ClearScreen();
    writeln('����������� ����������.');
    writeln;
    writeln('-------------------------------------------------------------------------------------------------------------------------------------------------');
    writeln('|   N   | ��� �������������� | ��� ���� �������������� |    ������������    |       ������       |      ���������     |   ����   |  ����������  |');
    writeln('-------------------------------------------------------------------------------------------------------------------------------------------------');
    for i := 0 to length(CombsToShow) - 1 do
    begin
      for j := 0 to length(CombsToShow[i]) - 1 do
        writeln('| ', (i + 1):6, '|', CombsToShow[i][j].partCode:20, '|',
          CombsToShow[i][j].partTypeCode:25, '|', CombsToShow[i][j].manufacturer
          :20, '|', CombsToShow[i][j].modelName:20, '|',
          CombsToShow[i][j].parameters:20, '|', CombsToShow[i][j].price:10:2,
          '|', CombsToShow[i][j].availability:14, '|');
      writeln('-------------------------------------------------------------------------------------------------------------------------------------------------');
    end;
    writeln('�������, ����� ����������.');
    readln;
    repeat
      ClearScreen();
      writeln('������� ���������� ��� ������ �����(��� �������, ����� �� ����������).');
      writeln;
      readln(path);
      writeln;
      if not directoryExists(path) and (path <> '') then
      begin
        writeln('������������ ����. ������� ��� ���������� �����.');
        readln;
      end;
    until (path = '') or (directoryExists(path));
    if path = '' then
    begin
      ClearScreen;
      writeln('�� ���������� �� ������ � ����.');
      sleep(1200);
    end
    else
    begin
      path := path + '\ShowedCombinations_upozn.txt';
      assignFile(Fl, path);
      rewrite(Fl);
      ClearScreen();
      writeln(Fl, '����������� ����������.');
      writeln(Fl);
      writeln(Fl,
        '-------------------------------------------------------------------------------------------------------------------------------------------------');
      writeln(Fl,
        '|   N   | ��� �������������� | ��� ���� �������������� |    ������������    |       ������       |      ���������     |   ����   |  ����������  |');
      writeln(Fl,
        '-------------------------------------------------------------------------------------------------------------------------------------------------');
      for i := 0 to length(CombsToShow) - 1 do
      begin
        for j := 0 to length(CombsToShow[i]) - 1 do
          writeln(Fl, '| ', (i + 1):6, '|', CombsToShow[i][j].partCode:20, '|',
            CombsToShow[i][j].partTypeCode:25, '|',
            CombsToShow[i][j].manufacturer:20, '|', CombsToShow[i][j].modelName
            :20, '|', CombsToShow[i][j].parameters:20, '|',
            CombsToShow[i][j].price:10:2, '|',
            CombsToShow[i][j].availability:14, '|');
        writeln(Fl,
          '-------------------------------------------------------------------------------------------------------------------------------------------------');
      end;
      closeFile(Fl);
      ClearScreen;
      writeln('������ �������� � ��������� ����.');
      sleep(1200);
    end;
  end;
end;

procedure MakeOrder(CombsToBuy: TCombs; list: PartListType;
  OrderSums: TRealArr);

var
  Fl: textFile;
  path: string;
  i, j: integer;
  checkInput: TString;
  checkInt, checkErrorCode: integer;
  header: PartListType;

begin
  header := list;
  if length(CombsToBuy) = 0 then
  begin
    ClearScreen;
    writeln('��������� � ������ ���������� ���.');
    sleep(1200);
  end
  else
  begin
    ClearScreen();
    writeln('����������� ����������, ��������� ��� ������.');
    writeln;
    writeln('---------------------------------------------------------------------------------------------------------------------------------------------------------');
    writeln('|   N   | ��� �������������� | ��� ���� �������������� |    ������������    |       ������       |      ���������     |   ����   |  ���-��  |   �����   |');
    writeln('---------------------------------------------------------------------------------------------------------------------------------------------------------');
    for i := 0 to length(CombsToBuy) - 1 do
    begin
      for j := 0 to length(CombsToBuy[i]) - 1 do
        writeln('| ', (i + 1):6, '|', CombsToBuy[i][j].partCode:20, '|',
          CombsToBuy[i][j].partTypeCode:25, '|', CombsToBuy[i][j].manufacturer
          :20, '|', CombsToBuy[i][j].modelName:20, '|',
          CombsToBuy[i][j].parameters:20, '|', CombsToBuy[i][j].price:10:2, '|',
          CombsToBuy[i][j].availability:9, '|', OrderSums[i]:12:2, '|');
      writeln('---------------------------------------------------------------------------------------------------------------------------------------------------------');
    end;
    writeln('�������, ����� ����������.');
    readln;
    ClearScreen;
    checkErrorCode := -1;
    checkInt := -1;
    while (checkErrorCode > 0) or
      ((checkInt < 0) or (checkInt > length(CombsToBuy))) do
    begin
      ClearScreen;
      write('������� ����� �������������� ������(��� 0 ��� ������): ');
      readln(checkInput);
      writeln;
      val(checkInput, checkInt, checkErrorCode);
      if (checkErrorCode > 0) or
        ((checkInt < 0) or (checkInt > length(CombsToBuy))) then
      begin
        writeln('������������ ����. ������� ��� ���������� �����.');
        readln;
      end;
    end;
    if checkInt = 0 then
    begin
      ClearScreen();
      writeln('�� ���������� �� ������.');
      sleep(1200);
    end
    else
    begin
      ClearScreen();
      writeln('��� �����.');
      writeln;
      writeln('---------------------------------------------------------------------------------------------------------------------------------------------------------');
      writeln('|   N   | ��� �������������� | ��� ���� �������������� |    ������������    |       ������       |      ���������     |   ����   |  ���-��  |   �����   |');
      writeln('---------------------------------------------------------------------------------------------------------------------------------------------------------');
      i := checkInt - 1;
      for j := 0 to length(CombsToBuy[i]) - 1 do
      begin
        CombsToBuy[i][j].availability := 1;
        writeln('| ', (i + 1):6, '|', CombsToBuy[i][j].partCode:20, '|',
          CombsToBuy[i][j].partTypeCode:25, '|', CombsToBuy[i][j].manufacturer
          :20, '|', CombsToBuy[i][j].modelName:20, '|',
          CombsToBuy[i][j].parameters:20, '|', CombsToBuy[i][j].price:10:2, '|',
          CombsToBuy[i][j].availability:9, '|', OrderSums[i]:12:2, '|');
      end;
      writeln('---------------------------------------------------------------------------------------------------------------------------------------------------------');
      writeln;
      writeln('����� ������: ', OrderSums[i]:0:2);
      writeln;
      writeln('�������, ����� ����������.');
      readln;
      repeat
        ClearScreen();
        writeln('������� ���������� ��� ������ �����(��� �������, ����� �� ����������).');
        writeln;
        readln(path);
        writeln;
        if not directoryExists(path) and (path <> '') then
        begin
          writeln('������������ ����. ������� ��� ���������� �����.');
          readln;
        end;
      until (path = '') or (directoryExists(path));
      if path = '' then
      begin
        ClearScreen;
        writeln('�� ���������� �� ������ � ����.');
        sleep(1200);
      end
      else
      begin
        for j := 0 to length(CombsToBuy[i]) - 1 do
        begin
          list := header^.partListNextElement;
          while list <> nil do
          begin
            if list^.partListInfo.partCode = CombsToBuy[i][j].partCode then
              dec(list^.partListInfo.availability);
            list := list^.partListNextElement
          end;
        end;
        path := path + '\PurshasedCombination_upozn.txt';
        assignFile(Fl, path);
        rewrite(Fl);
        writeln(Fl, '��� �����.');
        writeln(Fl);
        writeln(Fl,
          '---------------------------------------------------------------------------------------------------------------------------------------------------------');
        writeln(Fl,
          '|   N   | ��� �������������� | ��� ���� �������������� |    ������������    |       ������       |      ���������     |   ����   |  ���-��  |   �����   |');
        writeln(Fl,
          '---------------------------------------------------------------------------------------------------------------------------------------------------------');
        i := checkInt - 1;
        for j := 0 to length(CombsToBuy[i]) - 1 do
        begin
          CombsToBuy[i][j].availability := 1;
          writeln(Fl, '| ', (i + 1):6, '|', CombsToBuy[i][j].partCode:20, '|',
            CombsToBuy[i][j].partTypeCode:25, '|', CombsToBuy[i][j].manufacturer
            :20, '|', CombsToBuy[i][j].modelName:20, '|',
            CombsToBuy[i][j].parameters:20, '|', CombsToBuy[i][j].price:10:2,
            '|', CombsToBuy[i][j].availability:9, '|', OrderSums[i]:12:2, '|');
        end;
        writeln(Fl,
          '---------------------------------------------------------------------------------------------------------------------------------------------------------');
        writeln(Fl);
        writeln(Fl, '����� ������: ', OrderSums[i]:0:2);
        closeFile(Fl);
        ClearScreen;
        writeln('������ �������� � ��������� ����.');
        sleep(1200);
      end;
    end;
  end;
end;

function SpecFunsMenu(): integer;

var
  checkInput: TString;
  checkInt, checkErrorCode: integer;

begin
  checkErrorCode := 1;
  checkInput := '';
  checkInt := 0;
  while ((checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3))) do
  begin
    ClearScreen();
    writeln('�� ������� ����� ����������� �������.');
    writeln;
    writeln('��������� ����������� �������: ');
    writeln;
    writeln('1. ������ ���� ��������� ��������� ������������ ���������� � �������� ������� ���������.');
    writeln('2. ���������� ������ �������������� ��������.');
    writeln('3. �������� ����������� ����������.');
    writeln;
    write('�������� �������, ����� �� �����(0 ��� ������): ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if ((checkErrorCode > 0) or ((checkInt < 0) or (checkInt > 3))) then
    begin
      writeln('����� ������� ���������� �����������. ������� ��� ���������� �����.');
      readln;
    end;
  end;
  result := checkInt;
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
    writeln('�� ������� ������� ���������� ��� ���������.');
    writeln;
    write('������� 1, ����� ����������, ��� 0 ��� ������ �� ���������: ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) and ((checkInt <> 0) or (checkInt <> 1)) then
    begin
      writeln('������������ ����. ������� ��� ���������� �����');
      readln;
    end;
  end;
  if checkInt = 0 then
  begin
    ClearScreen();
    writeln('�� ���������� �� ������ �� ���������.');
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
    writeln('�� ������� ������� ���������� � �����������.');
    writeln;
    write('������� 1, ����� ����������, ��� 0 ��� ������ �� ���������: ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if (checkErrorCode > 0) and ((checkInt <> 0) or (checkInt <> 1)) then
    begin
      writeln('������������ ����. ������� ��� ���������� �����');
      readln;
    end;
  end;
  if checkInt = 0 then
  begin
    ClearScreen();
    writeln('�� ���������� �� ������ �� ���������.');
    sleep(1200);
    executionContinue := true;
  end
  else
  begin
    repeat
      ClearScreen();
      writeln('������� ����, � ������� ������ ������� ����� � �������:');
      writeln;
      readln(directoryPath);
      writeln;
      if not directoryExists(directoryPath) then
      begin
        writeln('��������� ���� ���������� �� ����������. ������� ��� ���������� �����.');
        readln;
      end;
    until directoryExists(directoryPath);
    writeln('������� ��� �����. ������� ������ �������: ');
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
          writeln('����� � ��������� ��������� ��� ����������.');
          writeln;
          write('������� 1 ��� ���������� ������, ����� 0: ');
          readln(checkInput);
          val(string(checkInput), checkInt, checkErrorCode);
          if (checkErrorCode > 0) and ((checkInt <> 0) or (checkInt <> 1)) then
          begin
            writeln('������������ ����. ������� ��� ���������� �����.');
            readln;
            ClearScreen();
          end;
        end;
        if checkInt = 0 then
        begin
          ClearScreen();
          writeln('�� ���������� �� ����������.');
          sleep(1200);
          executionContinue := true;
        end
        else
        begin
          executionContinue := FileWriting(path1, path2, path3, list1,
            list2, list3);
          ClearScreen();
          writeln('������ ������������.');
          sleep(1200);
        end;
      end
      else
      begin
        executionContinue := FileWriting(path1, path2, path3, list1,
          list2, list3);
        ClearScreen();
        writeln('������ �������� �� ����������.');
        sleep(1200);
      end;
    end
    else
    begin
      createDir(directoryPath);
      executionContinue := FileWriting(path1, path2, path3, list1,
        list2, list3);
      ClearScreen();
      writeln('����� ����� ���� �������. ������ ��������.');
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
    writeln('���� ������ �������:');
    writeln;
    writeln('1. ������ ������ �� �����.');
    writeln('2. �������� �������.');
    writeln('3. ���������� �������.');
    writeln('4. ����� ������ � �������������� �������.');
    writeln('5. ���������� ������ � ������.');
    writeln('6. �������� ������ �� �������.');
    writeln('7. �������������� ������ �������.');
    writeln('8. ������ ���� ��������� ������ ���������� � �������� ������� ��������� � ���������� ������(� ����������).');
    writeln('9. ����� �� ��������� ��� ���������� ���������.');
    writeln('10. ����� �� ��������� � ����������� ���������.');
    writeln;
    write('�������� �������, ����� �� �����: ');
    readln(checkInput);
    writeln;
    val(string(checkInput), checkInt, checkErrorCode);
    if ((checkErrorCode > 0) or ((checkInt < 1) or (checkInt > 10))) then
    begin
      writeln('����� ������� ���������� �����������. ������� ��� ���������� �����.');
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

  { specFuns variables }
var
  price: real;
  ToRefresh: boolean;
  CombsToShow, CombsToBuy: TCombs;
  OrderSums: TRealArr;

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
  writeln('����� ���������� � ������� �������������. �������, ����� ������� ����.');
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
          ToRefresh := false;
          price := EnterPrice(ToRefresh);
          setLength(OrderSums, 0);
          setLength(CombsToShow, 0);
          setLength(CombsToBuy, 0);
          GetAllComputerConfigs(price, true, compatiblePartList, partList,
            OrderSums, CombsToShow, CombsToBuy);
          specFunContinue := true;
          while specFunContinue do
          begin
            specFunCode := SpecFunsMenu();
            case specFunCode of
              0:
                begin
                  setLength(OrderSums, 0);
                  setLength(CombsToShow, 0);
                  setLength(CombsToBuy, 0);
                  specFunContinue := false;
                end;
              1:
                begin
                  ToRefresh := ToRefreshFun();
                  if ToRefresh then
                  begin
                    price := EnterPrice(ToRefresh);
                    setLength(OrderSums, 0);
                    setLength(CombsToShow, 0);
                    setLength(CombsToBuy, 0);
                    GetAllComputerConfigs(price, true, compatiblePartList,
                      partList, OrderSums, CombsToShow, CombsToBuy);
                  end;
                end;
              2:
                begin
                  MakeOrder(CombsToBuy, partList, OrderSums);
                  setLength(OrderSums, 0);
                  setLength(CombsToShow, 0);
                  setLength(CombsToBuy, 0);
                  GetAllComputerConfigs(price, false, compatiblePartList,
                    partList, OrderSums, CombsToShow, CombsToBuy);
                end;
              3:
                ShowConfigs(CombsToShow);
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
  writeln('�������, ��� ��������������� ����� �����������.');
  sleep(930);

end.
