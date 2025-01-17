unit Threads;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Buttons, System.SyncObjs,
  System.Threading;

type
  TThreadEmParalelo = class(TThread)
    Private
    protected
      procedure Execute; override;
      procedure ThreadEmParalelo;
    public
      constructor Create();
  end;

type
  TfThreads = class(TForm)
    EDT_NumThread: TEdit;
    EDT_Valtmpms: TEdit;
    BTN_Executar: TButton;
    MemResposta: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    ProgressBar: TProgressBar;
    procedure BTN_ExecutarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    intThreadAtiva: Integer;
  public
    { Public declarations }
  end;

var
  fThreads: TfThreads;

implementation

{$R *.dfm}

procedure TfThreads.BTN_ExecutarClick(Sender: TObject);
var
  ExecEmparalelo: TThreadEmParalelo;
begin
  ExecEmparalelo:= TThreadEmParalelo.Create;
  ExecEmparalelo.Execute;
end;

{ TThreadEmParalelo }

constructor TThreadEmParalelo.Create;
begin
  inherited Create(True);
  self.FreeOnTerminate := True;
end;

procedure TThreadEmParalelo.Execute;
begin
  inherited;
  Queue(ThreadEmParalelo);
end;

procedure TThreadEmParalelo.ThreadEmParalelo;
var
  I, intNumThread, intSleep: Integer;
begin
  {---------------------------------------------------}
  {*****************Loop For paralelo*****************}
  {---------------------------------------------------}
  intNumThread                  := 0;
  fThreads.intThreadAtiva       := 0;
  intSleep                      := 0;
  fThreads.ProgressBar.Max      := 0;
  fThreads.ProgressBar.Position := 0;
  intSleep                      := StrToInt(fThreads.EDT_Valtmpms.Text);
  intNumThread                  := StrToInt(fThreads.EDT_NumThread.Text);
  Application.ProcessMessages;
  fThreads.MemResposta.Lines.Clear;
  TTask.Run(procedure
            begin
              TParallel.&For(1, intNumThread,
                             procedure(AIndex: Integer)
                             begin
                               TThread.Queue(TThread.CurrentThread,
                                             procedure
                                             begin
                                               I := 0;
                                               fThreads.intThreadAtiva := AIndex;
                                               fThreads.ProgressBar.Max := intNumThread * 101;
                                               fThreads.ProgressBar.Position := 0;
                                               fThreads.MemResposta.Lines.Add(AIndex.ToString+'� Iniciando processamento');
                                               while I <= 100 do  //conta at� 100
                                                 begin
                                                   I := I + 1;
                                                   fThreads.ProgressBar.Position := intNumThread * I;
                                                   Application.ProcessMessages;
                                                   TThread.Sleep(Random(intSleep));
                                                 end;
                                               fThreads.MemResposta.Lines.Add(AIndex.ToString+'� Processamento finalizado');
                                               fThreads.ProgressBar.Max := 0;
                                               fThreads.ProgressBar.Position := 0;
                                             end);
                             end);
            end);
end;

procedure TfThreads.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if intThreadAtiva < StrToInt(EDT_NumThread.Text) then
    begin
      if Application.MessageBox('Thread ainda est� rodando. Deseja Fechar assim mesmo ? ', 'Informa��o', MB_ICONQUESTION + MB_YESNO) = IDYES then
        Action:=cafree
      else
        Action:=canone;
    end;
end;

end.
