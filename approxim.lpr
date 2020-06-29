program approxim;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, dbflaz, sdflaz, tachartlazaruspkg, Unit1, TblNewFm, DataInFm, SrcCfgFm,
  Regressi, CoEdFm
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='Approximator';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TTableNewForm, TableNewForm);
  Application.CreateForm(TTableDataInputForm, TableDataInputForm);
  Application.CreateForm(TChartSourceEditForm, ChartSourceEditForm);
  Application.CreateForm(TCoefficientEditForm, CoefficientEditForm);
  Application.Run;
end.

