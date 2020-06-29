unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ActnList, db,
  dbf, SdfData, Regressi, TAGraph,
  TADbSource, TASeries, Classes, TACustomSource, TAFuncSeries;

type

  { TForm1 }

  TForm1 = class(TForm)
    ApproximationPolynomial: TAction;
    Chart1: TChart;
    Chart1FuncSeries1: TFuncSeries;
    Chart1LineSeries1: TLineSeries;
    ChartCopy: TAction;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    ApproximationPolynomialItem: TMenuItem;
    OpenDialog1: TOpenDialog;
    TableOpen: TAction;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    TableEdit: TAction;
    FieldDefRemove: TAction;
    FieldDefDown: TAction;
    FieldDefUp: TAction;
    FieldNew: TAction;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    TableNew: TAction;
    ActionList1: TActionList;
    DataSource1: TDataSource;
    DbChartSource1: TDbChartSource;
    Dbf1: TDbf;
    MainMenu1: TMainMenu;
    procedure ApproximationPolynomialExecute(Sender: TObject);
    procedure ChartCopyExecute(Sender: TObject);
    procedure FieldDefDownExecute(Sender: TObject);
    procedure FieldDefRemoveExecute(Sender: TObject);
    procedure FieldDefUpExecute(Sender: TObject);
    procedure FieldNewExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TableEditExecute(Sender: TObject);
    procedure TableNewExecute(Sender: TObject);
    procedure TableOpenExecute(Sender: TObject);
  private

  public
    PA: TPolynomialApproximator;
  end;

var
  Form1: TForm1;

implementation

uses CoEdFm, Patch, TblNewFm, DataInFm, dbf_common, SrcCfgFm;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Dbf1.FilePath := BuildFileName(GetAppConfigDir(False), 'data');
  OpenDialog1.InitialDir := Dbf1.FilePath;
  if ForceDirectories(Dbf1.FilePath) then begin

  end;
  PA := TPolynomialApproximator.Create(Self);
end;

procedure TForm1.TableEditExecute(Sender: TObject);
begin
  TableDataInputForm.ShowModal
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

procedure TForm1.ChartCopyExecute(Sender: TObject);
begin
  Chart1.CopyToClipboardBitmap;
end;

procedure TForm1.ApproximationPolynomialExecute(Sender: TObject);
var
  i: Integer;
begin
  PA.Degree := StrToInt(InputBox('Grad des Polynoms', 'Grad: ', '0'));
  CoefficientEditForm.Degree := PA.Degree;
  if CoefficientEditForm.ShowModal = mrOK then
    with PA do begin
      for i := 0 to CoefficientCount - 1 do
        with CoefficientRecords[i] do begin
          StartMin := StrToFloat(CoefficientEditForm.StringGrid1.Cells[1, i + 1]);
          StartMax := StrToFloat(CoefficientEditForm.StringGrid1.Cells[2, i + 1])
        end;
      Calculate
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
      DBChartSource1.BeginUpdate;
      if TableNewForm.ShowModal = mrOK then begin
        Dbf1.Close;
        if Dbf1.FieldCount > 0 then Dbf1.ClearFields;
        Dbf1.FilePath := TableNewForm.DataSet.FilePath;
        Dbf1.TableName := TableNewForm.DataSet.TableName;
        Dbf1.FieldDefs := TableNewForm.DataSet.FieldDefs;
        Dbf1.CreateTable;
        repeat
          try
            Dbf1.Open;
            TableDataInputForm.ShowModal;
            Dbf1.Close;
            TableEdit.Enabled := True;
            with ChartSourceEditForm do begin
              MaxIndex := Dbf1.FieldDefs.Count - 1;
              XFieldComboBox.Items.Clear;
              for i := 0 to MaxIndex do
                XFieldComboBox.Items.Add(Dbf1.FieldDefs[i].Name);
              YFieldComboBox.Items := XFieldComboBox.Items;
              ColorFieldComboBox.Items := XFieldComboBox.Items;
              TextFieldComboBox.Items := XFieldComboBox.Items;
            end;
            if ChartSourceEditForm.ShowModal = mrOK then begin
              DBChartSource1.FieldX := ChartSourceEditForm.FieldX;
              Chart1.BottomAxis.Title.Caption:= ChartSourceEditForm.FieldX;
              DBChartSource1.FieldY := ChartSourceEditForm.FieldY;
              Chart1.LeftAxis.Title.Caption := ChartSourceEditForm.FieldY;
              DBChartSource1.FieldColor := ChartSourceEditForm.FieldColor;
              DBChartSource1.FieldText := ChartSourceEditForm.FieldText;
              Dbf1.Close;
              Dbf1.IndexDefs.Clear;
              Dbf1.Open;
              Dbf1.AddIndex('X', DBChartSource1.FieldX, []);
              Dbf1.IndexName := 'X';
              Chart1LineSeries1.Source := DBChartSource1;
              Chart1.Title.Text.Text := Dbf1.TableName;
            end;
            NoError := True;
          except
            on E: EYCountError do begin
              ShowMessage(E.Message);
            end;
          end;
        until NoError;
      end;
      DBChartSource1.EndUpdate;
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

procedure TForm1.TableOpenExecute(Sender: TObject);
var
  i, MaxIndex: Integer;
begin
  DBChartSource1.BeginUpdate;
  if OpenDialog1.Execute then begin
    Dbf1.Close;
    Dbf1.FilePath := ExtractFilePath(OpenDialog1.FileName);
    Dbf1.TableName := ExtractFileName(OpenDialog1.FileName);
    Dbf1.Open;
    with ChartSourceEditForm do begin
      MaxIndex := Dbf1.FieldDefs.Count - 1;
      XFieldComboBox.Items.Clear;
      for i := 0 to MaxIndex do
        XFieldComboBox.Items.Add(Dbf1.FieldDefs[i].Name);
      YFieldComboBox.Items := XFieldComboBox.Items;
      ColorFieldComboBox.Items := XFieldComboBox.Items;
      TextFieldComboBox.Items := XFieldComboBox.Items;
    end;
    if ChartSourceEditForm.ShowModal = mrOK then begin
      DBChartSource1.FieldX := ChartSourceEditForm.FieldX;
      Chart1.BottomAxis.Title.Caption := ChartSourceEditForm.FieldX;
      DBChartSource1.FieldY := ChartSourceEditForm.FieldY;
      Chart1.LeftAxis.Title.Caption:= ChartSourceEditForm.FieldY;
      DBChartSource1.FieldColor := ChartSourceEditForm.FieldColor;
      DBChartSource1.FieldText := ChartSourceEditForm.FieldText;
      Dbf1.IndexDefs.Clear;
      Dbf1.Open;
      Dbf1.AddIndex('X', DBChartSource1.FieldX, []);
      Dbf1.IndexName := 'X';
      Chart1LineSeries1.Source := DbChartSource1;
      Chart1.Title.Text.Text := Dbf1.TableName;
      TableEdit.Enabled := True;
    end;
  end;
  DBChartSource1.EndUpdate;
end;

end.

