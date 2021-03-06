unit UnitMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, Vcl.StdCtrls, sButton,
  Vcl.Menus, IniFiles, sSkinProvider, sSkinManager, sEdit, Vcl.Buttons,
  sSpeedButton, Vcl.ExtCtrls, sPanel, FireDAC.Phys.SQLiteWrapper, acDBGrid;

type
  TForm1 = class(TForm)
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    DataSource1: TDataSource;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    MainMenu1: TMainMenu;
    f1: TMenuItem;
    o1: TMenuItem;
    mSkins: TMenuItem;
    sSkinManager1: TsSkinManager;
    sSkinProvider1: TsSkinProvider;
    mSelectSkin: TMenuItem;
    sPanel1: TsPanel;
    sSpeedButton1: TsSpeedButton;
    sSpeedButton2: TsSpeedButton;
    sSpeedButton3: TsSpeedButton;
    sEdit1: TsEdit;
    FDTransaction1: TFDTransaction;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    sDBGrid1: TsDBGrid;
    sButton1: TsButton;
    procedure AutoColumns(var vdbg: TsDBGrid);
    procedure fsearch(st:string);
    procedure FormCreate(Sender: TObject);
    procedure mSelectSkinClick(Sender: TObject);
    procedure sEdit1Change(Sender: TObject);
    procedure sSpeedButton3Click(Sender: TObject);
    procedure sSpeedButton1Click(Sender: TObject);
    procedure sSpeedButton2Click(Sender: TObject);
    procedure sDBGrid1CellClick(Column: TColumn);
    procedure sDBGrid1DblClick(Sender: TObject);
    procedure sButton1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure sDBGrid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure ru_lower(AFunc: TSQLiteFunctionInstance;
      AInputs: TSQLiteInputs; AOutput: TSQLiteOutput; var AUserData: TObject);
  public
     SQLiteFunction: TFDSQLiteFunction;
     procedure CreateFunc;

    { Public declarations }
  end;

var
  Form1: TForm1;
  BookMark: TBookMark;
  GRDWidth:integer;
  AppPath,SkinName,SkinPath:string;
  oini: TIniFile;
  GRDID:string;

implementation

{$R *.dfm}

uses UnitAdd;

procedure TForm1.AutoColumns(var vdbg: TsDBGrid);
var
	x, y, w: integer;
	MaxWidth: integer;
  s:string;
begin
    if vdbg.DataSource=nil then Exit;
    s:=AppPath+'ConfDBG';
    if not DirectoryExists(s) then CreateDir(s);
    s:=s+'\DBG.cfg';
    if FileExists(s) then

    sDBGrid1.Columns.LoadFromFile(s)
  else   begin
    GRDWidth := 40;
  	if vdbg.DataSource=nil then Exit;
    if not vdbg.DataSource.DataSet.Active then vdbg.DataSource.DataSet.Open;
  	vdbg.Visible:=true;
  	if (vdbg.Visible)and(vdbg.DataSource.DataSet.Active) then
      begin
        with vdbg do
        begin
            Bookmark := DataSource.DataSet.GetBookmark;
            DataSource.DataSet.DisableControls;
            for x := 0 to Columns.Count - 1 do
            begin
              DataSource.DataSet.First;
                  if Columns[x].Title.Caption[1] = '_' then
                  Columns[x].Visible := false;
                  MaxWidth := 0;
              for y := 0 to DataSource.DataSet.RecordCount - 1 do
              begin
                  w := Canvas.TextWidth(Columns[x].Field.AsString);
                  if w > MaxWidth then
                  MaxWidth := w;
                  DataSource1.DataSet.Next;
              end;

              if Canvas.TextWidth(Columns[x].Title.Caption) > MaxWidth then
                MaxWidth := Canvas.TextWidth(Columns[x].Title.Caption);

              Columns[x].Width := MaxWidth + 15;
              GRDWidth := GRDWidth+Columns[x].Width; // ������� ������ �������
            end;
            DataSource.DataSet.GotoBookmark(Bookmark);
            DataSource.DataSet.EnableControls;
        end;
      end;
    end;
end;

 procedure TForm1.fsearch(st:string);
var
  Flags: TReplaceFlags;
	s:string;
begin
  Flags:= [ rfReplaceAll, rfIgnoreCase ];
  st := StringReplace(st, '''', '''''', Flags);
  s := 'select * from one where (ru_lower(field3) like ''%'+st+'%'') or (ru_lower(field4) like ''%'+st+'%'') '+
    'or (ru_lower(field5) like ''%'+st+'%'') order by field3 ';

  FDQuery1.Close;
  FDQuery1.SQL.Clear;
  FDQuery1.SQL.Add(s);
  FDQuery1.OpenOrExecute;
  sDBGrid1.Columns[0].Visible := false;

  AutoColumns(sDBGrid1);
  if GRDID <> '' then  
    sDBGrid1.DataSource.DataSet.Locate('id',GRDID,[loPartialKey]);

  GRDID := FDQuery1.FieldByName('ID').AsString;
end;

procedure TForm1.ru_lower(AFunc: TSQLiteFunctionInstance;
  AInputs: TSQLiteInputs; AOutput: TSQLiteOutput; var AUserData: TObject);
begin
  AOutput.AsString := AInputs[0].AsString.ToLower;
end;

procedure TForm1.CreateFunc;
begin
  SQLiteFunction := TFDSQLiteFunction.Create(nil);
  SQLiteFunction.DriverLink := FDPhysSQLiteDriverLink1;
  SQLiteFunction.FunctionName := 'ru_lower';
  SQLiteFunction.ArgumentsCount := 1;
  SQLiteFunction.OnCalculate := ru_lower;
  SQLiteFunction.Active := True;
end;

procedure TForm1.FormCreate(Sender: TObject);
  var
    s:string;
    mi:TMenuItem;
    sl:TStringList;
    i:integer;
  begin
    Height := 600;
    Width := 800;
    sDBGrid1.Align := alClient;
    sEdit1.Left := Round(sPanel1.Width / 2 - 100);
    sButton1.Left := sPanel1.Width-43;

    sDBGrid1.DataSource := DataSource1;

    AppPath:=ExtractFilePath(Application.ExeName);

    s := AppPath+'DB\sqlitedb.db';
    FDConnection1.DriverName := 'SQLite';
    FDConnection1.Params.Database := s;
    FDConnection1.Connected := true;

    CreateFunc;
  //  s := AppPath+'DB\sqlite3.dll';
  //  FDPhysSQLiteDriverLink1.VendorLib := s;


    s:='';
    fSearch(s);
    sEdit1.Text:='';

    Oini:=TIniFile.Create(AppPath+'option.ini');
    sSkinManager1.SkinDirectory:=AppPath+'skins';
    sSkinManager1.SkinName:=Oini.ReadString('skins','name','');
    sSkinManager1.Active:=true;

    SkinPath := AppPath + 'Skins\';
    sSkinManager1.SkinDirectory := SkinPath;
    oIni := TIniFile.Create(AppPath + 'option.ini');
    SkinName := oIni.ReadString('Skins', 'Name', '');
    sSkinManager1.Active := oIni.ReadBool('Skins', 'Active', true);
    if sSkinManager1.Active then
      if SkinName <> '' then
        sSkinManager1.SkinName := SkinName;
    sl := TStringList.Create;
    sSkinManager1.GetExternalSkinNames(sl);
   for i:=1 to sl.Count-1 do
     begin
       mi:=TMenuItem.Create(mSkins);
       mi.Name:='sm'+IntToStr(i);
       mi.Caption:=sl[i];
       mi.RadioItem:=true;
       mi.AutoCheck:=true;
       if (SkinName=sl[i])and(sSkinManager1.Active) then mi.Checked:=true;
       mi.OnClick:=mSelectSkin.OnClick;
       mSkins.Add(mi);
     end;
 sl.Free;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  sEdit1.Left := Round(sPanel1.Width / 2 - 100);
  sButton1.Left := sPanel1.Width-43;
end;

procedure TForm1.mSelectSkinClick(Sender: TObject);
var
 i:Integer;
 s:String;
begin
    s:='';
  SkinName:=(Sender as TMenuItem).Caption;
  for i := 1 to Length(SkinName) do
    if SkinName[i]<>'&' then s:=s+SkinName[i];
  SkinName:=s;
  if SkinName='��� ����' then
  begin
    sSkinManager1.Active:=false;
    oini:=TIniFile.Create(AppPath+'option.ini');
    oIni.WriteBool('Skins','Active',sSkinManager1.Active);
  end else begin
    sSkinManager1.SkinName:=SkinName;
    sSkinManager1.Active:=true;
    oini:=TIniFile.Create(AppPath+'option.ini');
    oIni.WriteString('Skins','Name',sSkinManager1.SkinName);
    oIni.WriteBool('Skins','Active',sSkinManager1.Active);
  end;

end;

procedure TForm1.sButton1Click(Sender: TObject);
begin
//  ShowMessage(sDBGrid1.DataSource.DataSet.FindField('id').Asstring);

end;

procedure TForm1.sDBGrid1CellClick(Column: TColumn);
begin
  GRDID := FDQuery1.FieldByName('ID').AsString;
end;

procedure TForm1.sDBGrid1DblClick(Sender: TObject);
begin
  sSpeedButton2Click(Self);
end;

procedure TForm1.sDBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  GRDID := FDQuery1.FieldByName('ID').AsString;

  if Key = VK_DELETE then
  begin
    sSpeedButton3Click(Self);
  end;

  if Key = VK_INSERT then
  begin
    sSpeedButton1Click(Self);
  end;

  if Key = VK_RETURN then
  begin
    sSpeedButton2Click(Self);
  end;
end;

procedure TForm1.sEdit1Change(Sender: TObject);

begin
 	fsearch(AnsiLowerCase(sEdit1.Text));
end;

procedure TForm1.sSpeedButton1Click(Sender: TObject);
begin
  Add := TAdd.create(self);
  Add.ShowModal;
  Add.free;
  fsearch(AnsiLowerCase(sEdit1.Text));
end;

procedure TForm1.sSpeedButton2Click(Sender: TObject);
begin
  if GRDID = '' then
  begin
    MessageDlg('������� ����� ������� ������',
    mtWarning,[mbOk], 0);
    abort;
  end;
  Add := TAdd.create(self);
  Add.Caption := '��������������';
  Add.sEdit1.Text := sDBGrid1.DataSource.DataSet.FieldByName('Field3').AsString;
  Add.sEdit2.Text := sDBGrid1.DataSource.DataSet.FieldByName('Field4').AsString;
  Add.sEdit3.Text := sDBGrid1.DataSource.DataSet.FieldByName('Field5').AsString;
  Add.ShowModal;
  Add.free;
  fsearch(AnsiLowerCase(sEdit1.Text));
end;

procedure TForm1.sSpeedButton3Click(Sender: TObject);

  var
    s:string;
    buttonSelected:Integer;
    QueryDel:TFDQuery;

begin

  if GRDID='' then
    begin
      MessageDlg('������� ����� ������� ������',
      mtWarning,[mbOk], 0);
      abort;
    end;

  buttonSelected := MessageDlg('�� ������������� ������ ������� ������?',
  mtConfirmation,[mbYes,mbNo], 0);

  if buttonSelected=6 then
    begin
      QueryDel := TFDQuery.Create(nil);
      QueryDel.Connection := FDConnection1;
      s := 'delete from one where id='+GRDID;
      QueryDel.Sql.Clear;
      QueryDel.Sql.Add(s);
      QueryDel.Execute;
      QueryDel.Close;
      QueryDel.Free;
      sDbGrid1.DataSource.DataSet.Next();
      GRDID := FDQuery1.FieldByName('ID').AsString;
      fsearch(AnsiLowerCase(sEdit1.Text));
    end;

end;

end.
