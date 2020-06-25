unit SrcCfgFm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls,
  Buttons;

type

  { TChartSourceEditForm }

  TChartSourceEditForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    XFieldComboBox: TComboBox;
    YFieldComboBox: TComboBox;
    ColorFieldComboBox: TComboBox;
    TextFieldComboBox: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    function GetFieldColor: string;
    function GetFieldText: string;
    function GetFieldX: string;
    function GetFieldY: string;
  public
    property FieldX: string read GetFieldX;
    property FieldY: string read GetFieldY;
    property FieldColor: string read GetFieldColor;
    property FieldText: string read GetFieldText;
  end;

var
  ChartSourceEditForm: TChartSourceEditForm;

implementation

uses Unit1;

{$R *.lfm}

{ TChartSourceEditForm }

procedure TChartSourceEditForm.FormCreate(Sender: TObject);
begin

end;

function TChartSourceEditForm.GetFieldColor: string;
begin
  Result := ColorFieldComboBox.Text;
end;

function TChartSourceEditForm.GetFieldText: string;
begin
  Result := TextFieldComboBox.Text;
end;

function TChartSourceEditForm.GetFieldX: string;
begin
  Result := XFieldComboBox.Text;
end;

function TChartSourceEditForm.GetFieldY: string;
begin
  Result := YFieldComboBox.Text;
end;

end.

