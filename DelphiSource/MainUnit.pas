unit MainUnit;

interface

uses
  Winapi.Windows,Winapi.Messages,System.SysUtils,System.Variants,System.Classes,
  Vcl.Graphics,Vcl.Controls,Vcl.Forms,Vcl.Dialogs,Vcl.StdCtrls,Vcl.Buttons,
  System.Types;

type
  TMainForm = class(TForm)
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SaveDialog1: TSaveDialog;
    Memo1: TMemo;
    procedure SpeedButton1Click(Sender: TObject);
    procedure BuildMOS(version: Byte);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
   MOS: TByteDynArray;
  public
  end;

var
  MainForm: TMainForm;

{ROM layout, MOS 3.20

 ROM     ROM   Memory
Address Number Address Contents
-------------------------------------------------
&00000         &C000   MOS 3.20
&04000    9    &8000   DFS 2.24 + SRAM 1.04
&07900    9    &B900   spare
&08000   10    &8000   ViewSheet B1.0
&0C000   11    &8000   EDIT 1.00
&0FFF8   11    &BFF8   spare
&10000   12    &8000   BASIC 4.00
&14000   13    &8000   ADFS 1.50
&18000   14    &8000   VIEW B3.0
&1BA00   14    &BA00   MOS code
&1C000   15    &8000   TERMINAL 1.20 + TUBE & MOS code
&1F8DF   15    &B8DF   spare
&1F900   15    &B900   Character set
All code between locations &4000 and &1BA00 in the system ROM (location &BA00 in
ROM 14) can be completely replaced. Additional code can be put at the end of ROM
9 at location &B900 (&07900 in the system ROM).}

{ROM layout, MOS 3.50

MOS 3.50 juggles the code around even more, using the spare space at the end of
the DFS ROM for the MOS code that originally shared the VIEW ROM which has got
bigger, sharing disk access code between DFS and ADFS, and shifting SRAM into
the MOS ROM.
 ROM     ROM   Memory
Address Number Address Contents
-------------------------------------------------
&00000         &C000   MOS 3.50
&04000    9    &8000   DFS 2.45
&06E44    9    &AE44   spare
&06F00    9    &AF00   MOS code
&08000   10    &8000   ViewSheet B1.01
&0BFE6   10    &BFE6   spare
&0C000   11    &8000   EDIT 1.50
&0FED8   11    &BED8   spare
&10000   12    &8000   BASIC 4.32
&14000   13    &8000   ADFS 2.03
&17E5F   13    &BE5F   spare
&17F8E   13    &BF8E   BASIC relocation table
&18000   14    &8000   VIEW B3.30
&1C000   15    &8000   TERMINAL 1.20 + TUBE, SRAM & MOS code
&1F900   15    &B900   Character set
All code between locations &4000 and &06EFF and between &08000 and &1C000 in the
system ROM can be completely replaced. DFS and ADFS share code and must be in
ROM slots four places apart so they can be switched between with EOR #4.}

implementation

{$R *.dfm}

procedure TMainForm.FormShow(Sender: TObject);
 function ReadString(offset: Cardinal): String;
 begin
  dec(offset);
  Result:='';
  repeat
   inc(offset);
   if (MOS[offset]>31) and (MOS[offset]<127) then
    Result:=Result+chr(MOS[offset]);
  until MOS[offset]=0;
 end;
var
 R : TResourceStream;
 rom: Byte;
 x,romoffset,mosoffset : Integer;
 S,copyright,version : String;
begin
 R:=TResourceStream.Create(hInstance,'MOS',RT_RCDATA);
 R.Position:=0;
 SetLength(MOS,R.Size);
 R.ReadBuffer(MOS[0],R.Size);
 R.Free;
 mosoffset:=0;
 repeat
  //MOS Title string is at $2001 (Acorn MOS)
  Memo1.Lines.Add('Title string: '+ReadString(mosoffset+$2001));
  //MOS Version string is at $2F72 (OS3.20) or $2ED5 (OS3.50)
  if chr(MOS[mosoffset+$2F73])='O' then
   S:=ReadString(mosoffset+$2F73);
  if chr(MOS[mosoffset+$2ED5])='M' then
   S:=ReadString(mosoffset+$2ED5);
  Memo1.Lines.Add('Reported OS: '+S);
  for rom:=15 downto 9 do
  begin
   romoffset:=mosoffset+(rom-8)*$4000;
   //ROM Name at <offseet>+$09, terminated by $00
   S:=ReadString(romoffset+$09);
   x:=romoffset+MOS[romoffset+$07]+1;
   //Optional version string follows ROM name, terminated by $00
   version:='';
   if x<>romoffset+Length(S)+$09+1 then
    version:=' '+ReadString(romoffset+$09+Length(S)+1);
   //Copyright string is pointed to by <offset>+$07, terminated by $00
   copyright:=' '+ReadString(x);
   //And must start (C)
   if Copy(copyright,2,3)<>'(C)' then copyright:='';
   S:=S+version+copyright;
   Memo1.Lines.Add('ROM '+IntToHex(rom,2)+': '+S);
  end;
  inc(mosoffset,$20000);
  Memo1.Lines.Add('------------------------------------------------------------------');
 until mosoffset>=Length(MOS);
end;

procedure TMainForm.SpeedButton1Click(Sender: TObject);
begin
 BuildMOS(2);
end;

procedure TMainForm.SpeedButton2Click(Sender: TObject);
begin
 BuildMOS(0);
end;

procedure TMainForm.SpeedButton3Click(Sender: TObject);
begin
 BuildMOS(1);
end;

procedure TMainForm.BuildMOS(version: Byte);
var
 NewMOS: TByteDynArray;
 F : TFileStream;
 R : TResourceStream;
 S : String;
 i : Cardinal;
begin
{
 version
 0       : MOS 3.20 with BASIC Editor in ROM 11 (in place of Edit)
 1       : MOS 3.50 with BASIC Editor in ROM 11 (in place of Edit)
 2       : MOS 3.20 & MOS 3.50 with MMFS and BASIC Editor in ROM 10 and 11
}
 SetLength(NewMOS,Length(MOS));
 for i:=0 to Length(MOS)-1 do NewMOS[i]:=MOS[i];
 R:=TResourceStream.Create(hInstance,'MMFS',RT_RCDATA);
 if version=2 then
 begin
  R.Position:=0;
  R.ReadBuffer(NewMOS[$08000],R.Size);
  R.Position:=0;
  R.ReadBuffer(NewMOS[$28000],R.Size);
 end;
 R.Free;
 R:=TResourceStream.Create(hInstance,'THEBE',RT_RCDATA);
 if (version=0) or (version=2) then
 begin
  R.Position:=0;
  R.ReadBuffer(NewMOS[$0C000],R.Size);
 end;
 if (version=1) or (version=2) then
 begin
  R.Position:=0;
  R.ReadBuffer(NewMOS[$2C000],R.Size);
 end;
 R.Free;
 NewMOS[$22002]:=ord('c');
 NewMOS[$22003]:=ord('o');
 NewMOS[$22004]:=ord('r');
 NewMOS[$22005]:=ord('n');
 case version of
  0: S:='NewMOS320.BIN';
  1: S:='NewMOS350.BIN';
  2: S:='NewMOS.BIN';
 end;
 SaveDialog1.FileName:=S;
 if SaveDialog1.Execute then
 begin
  F:=TFileStream.Create(SaveDialog1.FileName,fmCreate);
  case version of
   0: F.Write(NewMOS[0],$20000);
   1: F.Write(NewMOS[$20000],$20000);
   2: F.Write(NewMOS[0],Length(NewMOS));
  end;
  F.Free;
 end;
end;

end.
