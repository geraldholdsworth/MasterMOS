program MasterMOS;

{$MODE Delphi}

{$R *.dres}

uses
  Forms, Interfaces,
  MainUnit in 'MainUnit.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
