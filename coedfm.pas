unit CoEdFm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, Buttons;

type

  { TCoefficientEditForm }

  TCoefficientEditForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    StringGrid1: TStringGrid;
  private
    FCoefficientCount, FDegree: Integer;
    procedure SetCoefficientCount(AValue: Integer);
    procedure SetDegree(AValue: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    property Degree: Integer read FDegree write SetDegree;
    property CoefficientCount: Integer read FCoefficientCount write SetCoefficientCount;
  end;

var
  CoefficientEditForm: TCoefficientEditForm;

implementation

{$R *.lfm}

{ TCoefficientEditForm }

procedure TCoefficientEditForm.SetCoefficientCount(AValue: Integer);
var
  i: Integer;
begin
  if AValue = FCoefficientCount then Exit;
  StringGrid1.RowCount := AValue + 1;
  FCoefficientCount := AValue;
  for i := 1 to AValue do StringGrid1.Cells[0, i] := IntToStr(i - 1);
end;

procedure TCoefficientEditForm.SetDegree(AValue: Integer);
begin
  if AValue = FDegree then Exit;
  CoefficientCount := AValue + 1
end;

constructor TCoefficientEditForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CoefficientCount := 1;
end;

end.

