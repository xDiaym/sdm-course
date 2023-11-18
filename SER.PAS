uses Task, Objects;

{---------------------------------------------------------------------------}
{-------------------------------SERIALISATION-------------------------------}
{---------------------------------------------------------------------------}

                                  {IN LIST}

type SplitString = array[1..4] of String;


procedure SplitTasks(var SplitStr: SplitString; Str: String);
var TempStr: String;
    i, Index: Integer;
begin
    TempStr := ''; Index := 1;

    for i := 1 to Length(Str) do begin
        if (Index > 4) then break;
        if (Str[i] = ';') or (i = Length(Str)) then begin
           SplitStr[Index] := TempStr;
           Index := Index + 1;
           TempStr := '';
        end else TempStr := TempStr + Str[i];
    end;
end;


procedure FillList (Str: String; var L: PList);
var newCheck: Boolean;
    newInfo: String;
    newDD, newMM, newYY: Integer;
    SplitStr: SplitString;

    temp: Integer;
begin
    for temp := 1 to 4 do SplitStr[temp] := 'n';
    SplitTasks(SplitStr, Str);

    newInfo := SplitStr[1];

    Val(SplitStr[2], newDD, temp);
    Val(SplitStr[3], newMM, temp);
    Val(SplitStr[4], newYY, temp);

    L^.Insert(New(PTask, Init(newInfo, newDD, newMM, newYY)));
end;

function GetList (FileName: String): PList;
var F: text;
    Str: String;
    L: PList;

    i: Integer;
begin
     L := New(PList, Init(10, 5));

     Assign(F, FileName);
     Reset(F);
       while not EoF(F) do begin
             readln(F, Str);
             FillList(Str, L);
       end;
     Close(F);

     GetList := L;
end;

                                {FROM LIST}

procedure PutList(FileName: String; var L: PList);
var F: text;
    T: PTask;
    i: Integer;

begin
    Assign(F, FileName);
    Rewrite(F);

    for i := 0 to (L^.Count - 1) do begin
        T := L^.At(i);
        writeln(F, T^.ToStr(';', ';'));
    end;
    writeln(F, 'buy eggs;12;12;2001;');
    Close(F);

    Dispose(L, Done);
end;
{------------------------------MAIN PROGRAMM--------------------------------}

const FileName = 'LOG.TXT';

var List: PList;

begin
     List := GetList(FileName);
     PutList(FileName, List);
end.
