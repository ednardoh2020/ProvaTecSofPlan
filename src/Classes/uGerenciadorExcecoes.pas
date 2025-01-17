unit uGerenciadorExcecoes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

  type
    TGerenciadorExcecoes = class
  private
    FLogFile : String;
  public
    procedure GravarLog(value : String);
    procedure TrataException(Sender: TObject; E: Exception);
    constructor Create;
  end;

implementation

{ TGerenciadorExcecoes }

constructor TGerenciadorExcecoes.Create;
begin
    FLogFile := ChangeFileExt(ParamStr(0), '.log');
    Application.onException := TrataException;
end;

procedure TGerenciadorExcecoes.GravarLog(value: String);
var
    txtLog : TextFile;
begin
    AssignFile(txtLog, FLogFile);
    if FileExists(FLogFile) then
        Append(txtLog)
    else
        Rewrite(txtLog);
    Writeln(txtLog, FormatDateTime('dd/mm/YY hh:mm:ss - ', now) + value);
    CloseFile(txtLog);
end;

procedure TGerenciadorExcecoes.TrataException(Sender: TObject; E: Exception);
begin
  GravarLog('===============================================================================================');
  if TComponent(Sender) is TForm then
    begin
      GravarLog('Form: ' + TForm(Sender).Name);
      GravarLog('Error: ' + E.ClassName);
      GravarLog('Error: ' + E.Message);
    end
  else
    begin
      GravarLog('Form: ' + TForm(TComponent(Sender).Owner).Name);
      GravarLog('Error: ' + E.ClassName);
      GravarLog('Error: ' + E.Message);
    end;
  GravarLog('===============================================================================================');
  Application.MessageBox(Pchar(E.Message), 'Erro', MB_ICONERROR + MB_OK);
end;

var
  MinhaException : TGerenciadorExcecoes;

initialization;
  MinhaException := TGerenciadorExcecoes.Create;

finalization;
  MinhaException.Free;

end.
