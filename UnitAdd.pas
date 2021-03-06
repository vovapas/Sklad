unit UnitAdd;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sButton, sEdit,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TAdd = class(TForm)
    sButton1: TsButton;
    sEdit1: TsEdit;
    sEdit2: TsEdit;
    sEdit3: TsEdit;
    procedure sButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sEdit2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Add: TAdd;

implementation

{$R *.dfm}

uses UnitMain;

procedure TAdd.FormShow(Sender: TObject);
begin
  Add.sEdit1.SetFocus;
end;

procedure TAdd.sButton1Click(Sender: TObject);

  var
  s:string;
  QueryAdd:TFDQuery;
  Flags: TReplaceFlags;

  begin
    Flags:= [ rfReplaceAll, rfIgnoreCase ];
    sEdit1.Text := StringReplace(sEdit1.Text, '''', '''''', Flags);
    sEdit2.Text := StringReplace(sEdit2.Text, '''', '''''', Flags);
    sEdit3.Text := StringReplace(sEdit3.Text, '''', '''''', Flags);

    if Add.Caption = '��������������' then
      s := 'update one set field3 = '''+sEdit1.Text+''', field4 = '''+sEdit2.Text+''', field5='''+sEdit3.Text+''' '+
        'where id = ' + GRDID
    else
      s:='insert into one(field3, field4, field5) values'+
        '('''+sEdit1.Text+''', '''+sEdit2.Text+''', '''+sEdit3.Text+''')';

    QueryAdd := TFDQuery.Create(nil);
    QueryAdd.Connection := Form1.FDConnection1;
    QueryAdd.Sql.Clear;
    QueryAdd.Sql.Add(s);
    QueryAdd.Execute;
    QueryAdd.Close;
    QueryAdd.Free;
    close;
  end;

procedure TAdd.sEdit2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    sButton1Click(Self);
  end;
end;

end.
