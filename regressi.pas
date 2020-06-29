unit Regressi;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Polynomials, TACustomSource;

type

  TCoefficientSelector = (csValue, csMin, csMax);

  { TCoefficient }

  TCoefficient = class(TObject)
  private
    FStartMin, FStartMax: Extended;
    function GetValue: Extended;
    procedure SetStartMax(AValue: Extended);
    procedure SetStartMin(AValue: Extended);
  public
    Min, Max: Extended;
    CoefficientSelector: TCoefficientSelector;
    procedure Reset;
    property StartMin: Extended read FStartMin write SetStartMin;
    property StartMax: Extended read FStartMax write SetStartMax;
    property Value: Extended read GetValue;
  end;


  { TApproximator }

  TApproximator = class(TComponent)
  private
    FCoefficientList: TList;
    FSource: TCustomChartSource;
    FTolerance: Extended;
    function AvgIntervalLength: Extended;
    function GetCoefficientCount: Integer;
    function GetCoefficientRecords(AnIndex: Integer): TCoefficient;
    function GetCoefficients(AnIndex: Integer): Extended;
    procedure Calculate(AnIndex: Integer); overload; {Bisektionsschritt für 1 Koeffizient}
    procedure SetCoefficientCount(AValue: Integer); virtual;
    property CoefficientList: TList read FCoefficientList;
  protected
    function ApprFct(X: Extended): Extended virtual; abstract;
    procedure CreateCoefficientList(ACount: Integer); {im Konstruktor aufrufen}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function SquareSum: Extended;
    procedure ApprFuncCalculate(const AX: Double; out AY: Double); {Ereignis für
      TChartFuncSeries.OnCalculate}
    procedure Calculate; overload; {Bisektion}
    property CoefficientCount: Integer read GetCoefficientCount write SetCoefficientCount;
    property Coefficients[AnIndex: Integer]: Extended read GetCoefficients;
    property CoefficientRecords[AnIndex: Integer]: TCoefficient read GetCoefficientRecords;
  published
    property Source: TCustomChartSource read FSource write FSource;
    property Tolerance: Extended read FTolerance write FTolerance;
  end;

  { TPolynomialApproximator }

  TPolynomialApproximator = class(TApproximator)
  private
    FPolynomial: TPolynomial;
    function GetDegree: Integer;
    function GetPolynomial: TPolynomial;
    procedure SetDegree(AValue: Integer);
    procedure SetCoefficientCount(AValue: Integer); override;
  public
    destructor Destroy; override;
  published
    property Degree: Integer read GetDegree write SetDegree;
  end;

implementation

{ TCoefficient }

procedure TCoefficient.SetStartMax(AValue: Extended);
begin
  if FStartMax=AValue then Exit;
  FStartMax:=AValue;
  Max := AValue
end;

function TCoefficient.GetValue: Extended;
begin
  case CoefficientSelector of
    csValue: Result := (Max - Min) / 2;
    csMin: Result := Min;
    csMax: Result := Max;
  end;
end;

procedure TCoefficient.SetStartMin(AValue: Extended);
begin
  if FStartMin=AValue then Exit;
  FStartMin:=AValue;
  Min := AValue
end;

procedure TCoefficient.Reset;
begin
  CoefficientSelector := csValue;
  Min := StartMin;
  Max := StartMax;
end;

{ TPolynomialApproximator }

function TPolynomialApproximator.GetDegree: Integer;
begin
  Result := GetPolynomial.Degree
end;

function TPolynomialApproximator.GetPolynomial: TPolynomial;
begin
  if not Assigned(FPolynomial) then begin
    FPolynomial := TPolynomial.Create;
    FPolynomial.Degree := Degree
  end;
  Result := FPolynomial
end;

procedure TPolynomialApproximator.SetDegree(AValue: Integer);
begin
  if AValue = GetPolynomial.Degree then Exit;
  GetPolynomial.Degree := AValue;
  CoefficientCount := AValue + 1;
end;

procedure TPolynomialApproximator.SetCoefficientCount(AValue: Integer);
begin
  inherited SetCoefficientCount(AValue);
  Degree := AValue - 1
end;

destructor TPolynomialApproximator.Destroy;
begin
  FPolynomial.Free;
  inherited Destroy;
end;

{ TApproximator }

function TApproximator.AvgIntervalLength: Extended;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to CoefficientCount - 1 do
    Result := Result + CoefficientRecords[i].Max - CoefficientRecords[i].Min;
  Result := Result / CoefficientCount
end;

function TApproximator.GetCoefficientCount: Integer;
begin
  if not Assigned(FCoefficientList) then Result := 0
  else Result := CoefficientList.Count
end;

function TApproximator.GetCoefficientRecords(AnIndex: Integer): TCoefficient;
begin
  Pointer(Result) := CoefficientList[AnIndex]
end;

function TApproximator.GetCoefficients(AnIndex: Integer): Extended;
begin
  Result := CoefficientRecords[AnIndex].Value
end;

procedure TApproximator.Calculate(AnIndex: Integer);
var
  y1, y2: Extended;
begin
  with CoefficientRecords[AnIndex] do begin
    CoefficientSelector := csMin;
    y1 := SquareSum;
    CoefficientSelector := csMax;
    y2 := SquareSum;
    CoefficientSelector := csValue;
    if y1 > y2 then Min := Value
    else Max := Value;
  end;
end;

procedure TApproximator.SetCoefficientCount(AValue: Integer);
var
  i: Integer;
begin
  if AValue = GetCoefficientCount then Exit;
  if not Assigned(FCoefficientList) then CreateCoefficientList(AValue)
  else
    with FCoefficientList do
      if AValue < Count then
        for i := Count - 1 downto AValue do begin
          TCoefficient(Items[i]).Free;
          Count := AValue
        end
      else for i := Count to AValue do Add(TCoefficient.Create)
end;

procedure TApproximator.CreateCoefficientList(ACount: Integer);
var
  i: Integer;
begin
  FCoefficientList := TList.Create;
  FCoefficientList.Count := ACount;
  for i := 0 to FCoefficientList.Count - 1 do
    FCoefficientList[i] := TCoefficient.Create;
end;

constructor TApproximator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TApproximator.Destroy;
var
  i: Integer;
begin
  if Assigned(FCoefficientList) then begin
    for i := FCoefficientList.Count - 1 downto 0 do begin
      TCoefficient(FCoefficientList.Items[i]).Free;
      FCoefficientList.Delete(i);
    end;
    FCoefficientList.Free;
  end;
  inherited Destroy;
end;

function TApproximator.SquareSum: Extended;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Source.Count - 1 do
    Result := Result + Sqr(Source.Item[i]^.Y - ApprFct(Source.Item[i]^.X))
end;

procedure TApproximator.ApprFuncCalculate(const AX: Double; out AY: Double);
begin
  AY := ApprFct(AX)
end;

procedure TApproximator.Calculate;
{https://de.wikipedia.org/wiki/Bisektion}
var
  i: Integer;
begin
  for i := 0 to CoefficientCount - 1 do CoefficientRecords[i].Reset;
  repeat
    for i := 0 to CoefficientCount - 1 do Calculate(i);
  until AvgIntervalLength < Tolerance;
end;

end.

