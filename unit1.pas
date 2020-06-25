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

uses Patch, TblNewFm, DataInFm, dbf_common, TACustomSource, SrcCfgFm;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Dbf1.FilePath := BuildFileName(GetAppConfigDir(False), 'data');
  if ForceDirectories(Dbf1.FilePath) then begin
    {Dbf1.TableName := 'test.dbf';
    with Dbf1.FieldDefs do begin
      Add('X', ftFloat);
      Add('Y', ftFloat);
      {Add('Color', ftInteger);}
    end;
    Dbf1.CreateTable;
    Dbf1.Open;
    with Dbf1 do begin
      AddIndex('chartx', 'X', [ixPrimary, ixUnique]);

    end;
    Dbf1.AppendRecord([Now, 0, clRed]);
    Dbf1.AppendRecord([Now + 1/24, 1, clRed]);
    {Dbf1.Close;}
    Chart1LineSeries1.Active := True;}
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
var
  NoError: Boolean;
  i, MaxIndex: Integer;
begin
  NoError := False;
  repeat
    try
      if TableNewForm.ShowModal = mrOK then begin
        Dbf1.Close;
        Dbf1.FilePath := TableNewForm.DataSet.FilePath;
        Dbf1.TableName := TableNewForm.DataSet.TableName;
        Dbf1.FieldDefs := TableNewForm.DataSet.FieldDefs;
        Dbf1.CreateTable;
        repeat
          try
            Dbf1.Open;
            TableDataInputForm.ShowModal;
            Dbf1.Close;
            with ChartSourceEditForm do begin
              MaxIndex := Dbf1.FieldDefs.Count - 1;
              for i := 0 to MaxIndex do
                XFieldComboBox.Items.Add(Dbf1.FieldDefs[i].Name);
              YFieldComboBox.Items := XFieldComboBox.Items;
              ColorFieldComboBox.Items := XFieldComboBox.Items;
              TextFieldComboBox.Items := XFieldComboBox.Items;
            end;
            if ChartSourceEditForm.ShowModal = mrOK then begin
              DBChartSource1.FieldX := ChartSourceEditForm.FieldX;
              DBChartSource1.FieldY := ChartSourceEditForm.FieldY;
              DBChartSource1.FieldColor := ChartSourceEditForm.FieldColor;
              DBChartSource1.FieldText := ChartSourceEditForm.FieldText;
              Dbf1.IndexDefs.Clear;
              Dbf1.Open;
              Dbf1.AddIndex('X', DBChartSource1.FieldX, []);
              Dbf1.IndexName := 'X';
              Chart1LineSeries1.Source := DBChartSource1;
            end;
            NoError := True;
          except
            on E: EYCountError do begin
              ShowMessage(E.Message);
            end;
          end;
        until NoError;
      end;
    except
      on E: EDbfError do begin
        ShowMessage(E.Message);
        NoError := False
      end;
      else begin
        raise;
      end;
    end
  until NoError;
end;

end.

