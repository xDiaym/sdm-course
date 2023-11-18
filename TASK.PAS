unit Task;
interface

uses Objects, DOS;

type PDate = ^TDate;
     TDate = object(TObject)
           DD, MM, YY: word;
           constructor Init(newDD, newMM, newYY: Integer);
           function ToStr(Del: String): String; virtual;
     end;


     PTask = ^TTask;
     TTask = object(TObject)
           Info: PString;
           DeadLine: PDate;
           constructor Init(NewInfo: String;
                        NewDD, newMM, newYY: Integer);
           destructor Done; virtual;
           function ToStr(Del, DelDate: String): String; virtual;
     end;


     PList = ^TList;
     TList = object (TCollection)
           procedure Print; virtual;
     end;

implementation

{---------------------------------------------------------------------------}
{---------------------------------DATE--------------------------------------}
{---------------------------------------------------------------------------}


function IsDate(DD, MM, YY: word): Boolean;
var IsLeapYear: Boolean;
begin
     if YY = 0 then IsDate := False

     else begin
     IsLeapYear := (YY mod 4 = 0) and
                   ((YY mod 100 <> 0) or (YY mod 400 = 0));
       case MM of
            2: IsDate := DD in [1..28 + Ord(IsLeapYear)];
            1, 3, 5, 7, 8, 10, 12: IsDate := DD in [1..31];
            4, 6, 9, 11: IsDate := DD in [1..30];
       else IsDate := False;
       end;
     end;
end;


constructor TDate.Init(newDD, newMM, newYY: Integer);
var temp: word;
begin
     if IsDate(newDD, newMM, newYY) then begin
        DD := word(newDD);
        MM := word(newMM);
        YY := word(newYY);
     end
     else GetDate(YY, MM, DD, temp);
end;

function TDate.ToStr(Del: string): String;
var strDD, strMM, strYY: String;
begin
     str(DD, strDD);
     str(MM, strMM);
     str(YY, strYY);
     ToStr := strDD + Del + strMM + Del + strYY;
end;


{----------------------------------------------------------------------------}
{-----------------------------------TASK-------------------------------------}
{----------------------------------------------------------------------------}


constructor TTask.Init(newInfo: String;
                       newDD, newMM, newYY: Integer);
begin
     Info := NewStr(newInfo);
     DeadLine := New(PDate, Init(newDD, newMM, newYY));
end;

destructor TTask.Done;
begin
     Dispose(Info); Dispose(DeadLine);
end;

function TTask.ToStr(Del, DelDate: string): String;
var InfoStr, TagStr, DeadLineStr: String;
begin
     InfoStr := Info^;
     DeadLineStr := DeadLine^.ToStr(DelDate);

     ToStr := InfoStr + Del + DeadLineStr + Del;
end;


{-------------------------------------------------------------------------}
{-----------------------------------LIST----------------------------------}
{-------------------------------------------------------------------------}

procedure TList.Print;
          procedure CallPrint(P: PTask); far;
          begin
               writeln(P^.ToStr('  ', '.'));
          end;
begin
     ForEach(@CallPrint);
end;

end.
