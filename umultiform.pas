unit umultiform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, windows,
  JwaTlHelp32;

type

  { TForm1 }

  harr = array of HWND;

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  Snapshot: THandle;
  pe: TProcessEntry32;
  pids:array of DWORD;
  hws:harr;

implementation

{$R *.lfm}

uses umf2;

{ TForm1 }

procedure GetProcesses;
begin
  form1.listbox1.Items.Clear;
  setlength(pids,0);
  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
  try
    pe.dwSize := SizeOf(pe);
    if Process32First(Snapshot, pe) then
      while Process32Next(Snapshot, pe) do
      begin
        form1.listbox1.Items.Add(pe.szExeFile+' '+inttostr(pe.th32ProcessID));
        setlength(pids,length(pids)+1);
        pids[high(pids)]:=pe.th32ProcessID;
      end;
  finally
    CloseHandle(Snapshot);
  end;
end;


procedure GetAllWindowsFromProcessID(dwProcessID: DWORD; var vhWnds:harr);
var hCurWnd:HWND;
    dwProcID:DWORD;
    wt:array[0..127]of char;
begin
    hCurWnd:=0;
    dwProcID:=0;

    form1.listbox2.Clear;
    setlength(vhWnds,0);

    //wt:='';

    repeat
        hCurWnd:=FindWindowEx(0, hCurWnd, nil, nil);
        GetWindowThreadProcessId(hCurWnd, dwProcID);
        form1.Memo1.Lines.Add(inttostr(hCurWnd)+' - '+inttostr(dwProcID) + '; looking for: '+inttostr(dwProcessID));
        if (dwProcID = dwProcessID) then
        begin
            setlength(vhWnds,length(vhWnds)+1);
            vhWnds[high(vhWnds)]:=hCurWnd;
            if GetWindowText(hCurWnd,wt,128)>0 then
              form1.listbox2.items.add('Found hWnd ' + inttostr(hCurWnd)+': '+wt)
            else
              form1.listbox2.items.add('Found hWnd ' + inttostr(hCurWnd)+': n/a');
        end
    until (hCurWnd = 0);
end;



procedure TForm1.Button1Click(Sender: TObject);
begin
  while form2=nil do
    form2:=TForm2.Create(nil);
  if form2.Visible=false then
    form2.Visible:=true;

  form2.Memo1.Text:=form2.Memo1.Text+'works'+#13#10;

  GetProcesses;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  SendMessage(hws[listbox2.ItemIndex],WM_CLOSE,0,0);
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
  GetAllWindowsFromProcessID(pids[listbox1.itemindex],hws);
end;



end.

