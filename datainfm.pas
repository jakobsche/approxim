unit DataInFm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBCtrls, DBGrids;

type

  { TTableDataInputForm }

  TTableDataInputForm = class(TForm)
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
  private

  public

  end;

var
  TableDataInputForm: TTableDataInputForm;

implementation

{$R *.lfm}

end.

