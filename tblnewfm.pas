unit TblNewFm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs, StdCtrls, Db, Dbf,
  Buttons;

type

  TFieldDescription = class(TComponent)
  private
    FFieldName: string;
    FFieldType: TFieldType;
    FFieldSize: Integer;
  published
    property FieldName: string read FFieldName write FFieldName;
    property FieldType: TFieldType read FFieldType write FFieldType;
    property FieldSize: Integer read FFieldSize write FFieldSize;
  end;


type

  { TTableNewForm }

  TTableNewForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    TableTypeComboBox: TComboBox;
    FieldSizeEdit: TEdit;
    FieldTypeComboBox: TComboBox;
    FieldNameEdit: TEdit;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    FieldListBox: TListBox;
    Label5: TLabel;
    TableNameEdit: TEdit;
    Label1: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure FieldListBoxSelectionChange(Sender: TObject; User: boolean);
    procedure FormCreate(Sender: TObject);
  private
    FDataSet: TDbf;
    function GetDataSet: TDbf;

  public
    function NewFieldDescription(AName: string; AType: TFieldType; ASize: Integer): TFieldDescription;
    property DataSet: TDbf read GetDataSet;
  end;

var
  TableNewForm: TTableNewForm;

implementation

uses Unit1;

{$R *.lfm}

{ TTableNewForm }

procedure TTableNewForm.FormCreate(Sender: TObject);
var
  Id: PtrInt;
begin
  with TableTypeComboBox do begin
    Id := 3; Items.AddObject('dBase III+', TObject(Id));
    Id := 4; Items.AddObject('dBase IV', TObject(Id));
    Id := 7; Items.AddObject('Visual dBase VII', TObject(Id));
    Id := 25; Items.AddObject('Fox Pro', TObject(Id));
    ItemIndex := 2
  end;
  with FieldListBox do begin
    Items.NameValueSeparator:=':';
  end;
end;

function TTableNewForm.GetDataSet: TDbf;
begin
  if not Assigned(FDataSet) then begin
    FDataSet := TDbf.Create(Self);
    FDataSet.FilePath := Form1.Dbf1.FilePath;
  end;
  Result := FDataSet;
end;

function TTableNewForm.NewFieldDescription(AName: string; AType: TFieldType;
  ASize: Integer): TFieldDescription;
begin
  Result := TFieldDescription.Create(Self);
  Result.FieldName := AName;
  Result.FieldType := AType;
  Result.FieldSize := ASize;
end;

procedure TTableNewForm.FieldListBoxSelectionChange(Sender: TObject;
  User: boolean);
var
  En: Boolean;
begin
  with Sender as TListBox do begin
    En := ItemIndex >= 0;
    with Form1 do begin
      FieldDefUp.Enabled := En and (ItemIndex > 0) ;
      FieldDefDown.Enabled := En and (ItemIndex < Items.Count - 1);
      FieldDefRemove.Enabled := En;
    end;
  end
end;

procedure TTableNewForm.BitBtn1Click(Sender: TObject);
var
  FD: TFieldDescription;
  i: Integer;
begin
  DataSet.TableLevel := PtrInt(TableTypeComboBox.Items.Objects[TableTypeComboBox.ItemIndex]);
  DataSet.TableName := TableNameEdit.Text;
  DataSet.FieldDefs.Clear;
  for i := 0 to FieldListBox.Items.Count - 1 do begin
    FD := FieldListBox.Items.Objects[i] as TFieldDescription;
    DataSet.FieldDefs.Add(FD.FieldName, FD.FieldType, FD.FieldSize);
  end;
end;

end.

