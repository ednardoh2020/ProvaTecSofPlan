unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfMain = class(TForm)
    btDatasetLoop: TButton;
    btThreads: TButton;
    btStreams: TButton;
    procedure btDatasetLoopClick(Sender: TObject);
    procedure btStreamsClick(Sender: TObject);
    procedure btThreadsClick(Sender: TObject);
  private
  public
  end;

var
  fMain: TfMain;

implementation

uses
  DatasetLoop, ClienteServidor, uGerenciadorExcecoes, Threads;

{$R *.dfm}

procedure TfMain.btDatasetLoopClick(Sender: TObject);
begin
  fDatasetLoop.Show;
end;

procedure TfMain.btStreamsClick(Sender: TObject);
begin
  fClienteServidor.Show;
end;

procedure TfMain.btThreadsClick(Sender: TObject);
begin
  fThreads := TfThreads.Create(Self);
  fThreads.Show;
end;

end.
