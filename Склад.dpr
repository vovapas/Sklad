program Склад;

uses
  Vcl.Forms,
  UnitMain in 'UnitMain.pas' {Form1},
  UnitAdd in 'UnitAdd.pas' {Add};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TAdd, Add);
  Application.Run;
end.
