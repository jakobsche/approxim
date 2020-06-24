unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ActnList, db,
  dbf, TAGraph,
  TADbSource, TASeries;

type

  { TForm1 }

  TForm1 = class(TForm)
    FieldDefRemove: TAction;
    FieldDefDown: TAction;
    FieldDefUp: TAction;
    FieldNew: TAction;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    TableNew: TAction;
    ActionList1: TActionList;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    DataSource1: TDataSource;
    DbChartSource1: TDbChartSource;
    Dbf1: TDbf;
    MainMenu1: TMainMenu;
    procedure FieldDefDownExecute(Sender: TObject);
    procedure FieldDefRemoveExecute(Sender: TObject);
    procedure FieldDefUpExecute(Sender: TObject);
    procedure FieldNewExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TableNewExecute(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

uses Patch, TblNewFm, DataInFm;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Dbf1.FilePath := BuildFileName(GetAppConfigDir(False), 'data');
  if ForceDirectories(Dbf1.FilePath) then begin
    Dbf1.TableName := 'test.dbf';
    with Dbf1.FieldDefs do begin
      Add('X', ftFloat);
      Add('Y', ftFloat);
      Add('Color', ftInteger);
    end;
    Dbf1.CreateTable;
    Dbf1.Open;
    with Dbf1 do begin
      AddIndex('chartx', 'X', [ixPrimary, ixUnique]);

    end;
    Dbf1.AppendRecord([Now, 0, clRed]);
    Dbf1.AppendRecord([Now + 1/24, 1, clRed]);
    {Dbf1.Close;}
    Chart1LineSeries1.Active := True;
  end
end;

procedure TForm1.FieldNewExecute(Sender: TObject);
var
  TypeId: PtrInt;
  NewField: string;
begin
  with TableNewForm do begin
    TypeId := FieldTypeComboBox.ItemIndex;
    NewField := FieldNameEdit.Text;
    if FieldListBox.Items.IndexOfName(NewField) < 0 then
      FieldListBox.Items.AddObject(Format('%s:%s', [NewField, FieldTypeComboBox.Text]), NewFieldDescription(NewField, TFieldType(TypeId), StrToInt(FieldSizeEdit.Text)))
    else ShowMessageFmt('Ein Feld "%s" ist schon vorhanden', [NewField])
  end;
end;

procedure TForm1.FieldDefUpExecute(Sender: TObject);
var
  NewIndex: Integer;
begin
  with TableNewForm.FieldListBox do begin
    NewIndex := ItemIndex - 1;
    Items.Move(ItemIndex, NewIndex);
    ItemIndex := NewIndex;
  end;
end;

procedure TForm1.FieldDefDownExecute(Sender: TObject);
var
  NewIndex: Longint;
begin
  with TableNewForm.FieldListBox do begin
    NewIndex := ItemIndex + 1;
    Items.Move(ItemIndex, NewIndex);
    ItemIndex := NewIndex;
  end;
end;

procedure TForm1.FieldDefRemoveExecute(Sender: TObject);
begin
  with TableNewForm.FieldListBox do begin
    Items.Delete(ItemIndex);
  end;
end;

procedure TForm1.TableNewExecute(Sender: TObject);
begin
  if TableNewForm.ShowModal = mrOK then begin
    Dbf1.Close;
    {Dbf1.Assign(TableNewForm.DataSet); TDbf.AssignTo müßte überschrieben werden
    oder Felder einzeln zuweisen}
    Dbf1.FilePathFull:= TableNewForm.DataSet.FilePathFull;
    Dbf1.FieldDefs := TableNewForm.DataSet.FieldDefs;
    Dbf1.CreateTable;
    TableDataInputForm.ShowModal
  end;
end;

end.

