uses Task, Objects, Drivers, Views, Menus, Dialogs, App;

{---------------------------------------------------------------------------}
{--------------------------------RENDERING----------------------------------}
{---------------------------------------------------------------------------}


type
  TDoList = object(TApplication)
    procedure InitMenuBar; virtual;
    procedure InitDeskTop; virtual;
    procedure InitStatusLine; virtual;

    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AddTask;
    procedure ClearAll; virtual;
  end;

  PMainWindow = ^TMainWindow;
  TMainWindow = object(TDialog)
    constructor Init(var Bounds: TRect);
    procedure MakeInterior(Bounds: TRect);
  end;

  PInterior = ^TInterior;
  TInterior = object(TListViewer)
    List: PList;
    constructor Init(var Bounds: TRect; AScrollBar: PScrollBar; NewList: PList);
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure SelectItem(Item: Integer); virtual;
  end;

  PNewDialog = ^TNewDialog;
  TNewDialog = object(TDialog)
    function GetPalette: PPalette; virtual;
  end;

  AddDialogData = record
    InputTaskLine: String[100];
    InputDateLine: String[10];
  end;


{-----------------------------------VAR--------------------------------------}


const
  cmClearAll = 100;
  cmAddTask = 200;
  cmSortByTime = 101;

var
  L: PList;
  LineCount: Integer;
  DefaultDate: TDate;
  DefaultDialogData: AddDialogData;
  NewDialogData: AddDialogData;


{-----------------------------TNewDialog-----------------------------------}


function TNewDialog.GetPalette: PPalette;
const
  CNewDialog = #1#3#30#0#0#1#2#30#0#15#15#17#0#15#3#30#0#0#15#17;
  PNewDialog: string[Length(CNewDialog)] = CNewDialog;
begin
      GetPalette := @PNewDialog;
end;


{-------------------------------TInterior------------------------------------}


constructor TInterior.Init(var Bounds: TRect; AScrollBar: PScrollBar;
            NewList: PList);
begin
   TListViewer.Init(Bounds, 1, nil, AScrollBar);
   List := NewList; Range := L^.Count;
end;

procedure TInterior.Draw;
begin
     Range := L^.Count;
     TListViewer.Draw;
end;

function TInterior.GetPalette: PPalette;
const
  CInterior = #1#3#17;
  PInterior: string[Length(CInterior)] = CInterior;
begin
      GetPalette := @PInterior;
end;

function TInterior.GetText(Item: Integer; MaxLen: Integer): String;
var
  Answer: String;
  T: PTask;
begin
     if (Item >= MaxLen) then GetText := 'Add new task...'
     else begin
        GetText := 'Add new task...';
        T := List^.At(Item);
        Answer := T^.Info^;
        Answer := Answer + ' ' + T^.DeadLine^.ToStr('.');
        GetText := Answer;
     end;
end;

procedure TInterior.SelectItem(Item: Integer);
var T: PTask;
begin
   L^.AtDelete(Item);
end;

{-------------------------------TMainWindow----------------------------------}


constructor TMainWindow.Init (var Bounds: TRect);
begin
    TWindow.Init(Bounds, 'To Do List', 1);
    MakeInterior(Bounds);
end;


procedure TMainWindow.MakeInterior(Bounds: TRect);
var
  R: TRect;
  ScrollBar: PScrollBar;
  Interior : PInterior;
begin
    R.Assign(Bounds.B.X - 2, Bounds.A.Y + 1 , Bounds.B.X - 1, Bounds.B.Y -1);
    ScrollBar := New(PScrollBar, Init(R));
    Insert(ScrollBar);

    R.Assign(Bounds.A.X + 1, Bounds.A.Y + 1, Bounds.B.X - 2, Bounds.B.Y -1);
    Interior := New(PInterior, Init(R, ScrollBar, L));
    Insert(Interior);
end;


{-----------------------------------TDoList----------------------------------}


procedure TDoList.InitMenuBar;
var R: TRect;
begin
   GetExtent(R);
   R.B.Y := R.A.Y + 1;

   MenuBar := New(PMenuBar, Init(R, NewMenu(
        NewItem('~A~dd Task', 'Alt-A', kbAltA, cmAddTask, hcNoContext,
        NewSubMenu('~S~ort', hcNoContext, NewMenu(
           NewItem('Time', 'Alt-T', kbAltT, cmSortByTime, hcNoContext, nil)),
        nil))
   )));
end;


procedure TDoList.InitDeskTop;
var
  R: TRect;
  Window: PMainWindow;
begin
    inherited InitDeskTop;
    GetExtent(R); R.B.Y := R.B.Y - 2;
    Window := New(PMainWindow, Init(R));
    DeskTop^.Insert(Window);
end;


procedure TDoList.InitStatusLine;
var R: TRect;
begin
    GetExtent(R);
    R.A.Y := R.B.Y - 1;
    StatusLine := New(PStatusLine, Init(R,
      NewStatusDef(0, $FFFF,
        NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
        NewStatusKey('~Alt-C~ Clear All', kbAltC, cmClearAll,
        nil)),
      nil)
        ));
end;


procedure TDoList.HandleEvent(var Event: TEvent);
begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmAddTask: AddTask;
      cmClearAll: ClearAll;
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;


{------------------------------SUPPORT--FUNCTIONS----------------------------}


procedure InsertTask;
var
  Info: string;

  DD, MM, YY: integer;
  StrDD, StrMM, StrYY: String;
  TempInt: Integer;

  index, flag: integer;
  TempStr, HelpStr: string;

begin
    Info := NewDialogData.InputTaskLine;
    TempStr := NewDialogData.InputDateLine;
    HelpStr := ''; flag := 1;

    for index := 1 to Length(TempStr) do begin
        if (TempStr[index] = '.') then begin
           case flag of
            1: StrDD := HelpStr;
            2: StrMM := HelpStr;
           end;
           HelpStr := ''; flag := flag + 1;
        end
        else HelpStr := HelpStr + TempStr[index];
    end;
    StrYY := HelpStr;

    Val(StrDD, DD, TempInt);
    Val(StrMM, MM, TempInt);
    Val(StrYY, YY, TempInt);

    L^.Insert(New(PTask, Init(Info, DD, MM, YY)));

end;


{--------------------------------------------------------------------------}


procedure TDoList.AddTask;
var
  Dialog: PNewDialog;
  R: TRect; Bruce: PView;
  C: Word;
begin
   R.Assign(0, 0, 45, 11);
   R.Move(22, 7);
   Dialog := New(PNewDialog, Init(R, 'New Task'));
   with Dialog^ do
   begin
        R.Assign(2, 3, 43, 4);
        Bruce := New(PInputLine, Init(R, 100));
        Insert(Bruce);
        R.Move(0, -1);
        Insert(New(PLabel, Init(R, 'Enter your task', Bruce)));
        R.Assign(2, 6, 43, 7);
        Bruce := New(PInputLine, Init(R, 10));
        Insert(Bruce);
        R.Move(0, -1);
        Insert(New(PLabel, Init(R, 'Enter your deadline in form dd.mm.yyyy', Bruce)));
        R.Assign(10, 8, 20, 10);
        Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
        R.Move(13, 0);
        Insert(New(PButton, Init(R,
        'Cancel', cmCancel, bfNormal)));
    end;

   Dialog^.SetData(DefaultDialogData);
   C := ExecView(Dialog);
   if C = cmOk then begin
        Dialog^.GetData(NewDialogData);
        InsertTask;
        Draw;
   end;

   Dispose(Dialog, Done);
end;


procedure TDoList.ClearAll;
var
  R: TRect; Dialog: PNewDialog;
  C: Word;
begin
    R.Assign(0, 0, 30, 5); R.Move(25, 7);
    Dialog := New(PNewDialog, Init(R, 'Are you sure?'));

    with Dialog^ do begin
         R.Assign(3, 2, 13, 4);
         Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
         R.Move(13, 0);
         Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
    end;
    C := ExecView(Dialog);

    if C = cmOk then begin
        L^.DeleteAll;
        Draw;
    end;

    Dispose(Dialog, Done);
end;


{------------------------------------MAIN------------------------------------}


var ToDoList: TDoList;
begin
   L := New(PList, Init(10,5));

   {L^.Insert(New(PTask, Init(True, 'love', 1, 1, 2001)));
   L^.Insert(New(Ptask, Init(False, 'die', 1, 2, 2002)));
   L^.Insert(New(PTask, Init(True, 'robots', 1, 3, 2003)));
   }

   with DefaultDialogData do begin
        InputTaskLine := 'Sign ";" isnt allowed';
        DefaultDate.Init(0, 0, 0);
        InputDateLine := DefaultDate.ToStr('.');
   end;

   ToDoList.Init;
   ToDoList.Run;
   ToDoList.Done;

end.
