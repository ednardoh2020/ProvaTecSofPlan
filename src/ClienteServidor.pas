unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB;

type
  TEnviarARQEmParalelo = class(TThread)
    Private
    protected
      procedure Execute; override;
      procedure EnviarArqEmParalelo;
    public
      constructor Create();
  end;

type
  TServidor = class
  private
    FPath: String;
    intSeq: Integer;
    procedure ApagaPDF;
  public
    constructor Create;
    //Tipo do par�metro n�o pode ser alterado
    function SalvarArquivos(AData: OleVariant): Boolean;
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure btEnviarParaleloClick(Sender: TObject);
  private
    FPath: String;
    FServidor: TServidor;

    function InitDataset: TClientDataset;
  public
  end;

var
  fClienteServidor: TfClienteServidor;

const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i, x: Integer;
begin
  cds := InitDataset;
  ProgressBar.Max      := 0;
  ProgressBar.Position := 0;
  x := 0;
  ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
  for i := 0 to QTD_ARQUIVOS_ENVIAR do
  begin
  inc(x);
    if x <= 5 then
      begin
        cds.Append;
        TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
        cds.Post;
      end
    else
      begin
        FServidor.SalvarArquivos(cds.Data);
        cds.EmptyDataSet;
        cds.Free;
        cds := InitDataset;
        x := 1;
        cds.Append;
        TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
        cds.Post;
      end;

    {$REGION Simula��o de erro, n�o alterar}
    if i = (QTD_ARQUIVOS_ENVIAR/2) then
      FServidor.SalvarArquivos(NULL);
    {$ENDREGION}

    ProgressBar.Position :=i;
    ProgressBar.Refresh;
  end;
  ProgressBar.Max      := 0;
  ProgressBar.Position := 0;
  cds.Free;
end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
var
  EnviarMensagemParalelo : TEnviarARQEmParalelo;
begin

  EnviarMensagemParalelo := TEnviarARQEmParalelo.Create();
  EnviarMensagemParalelo.Execute;

end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i, x: Integer;
begin
  cds := InitDataset;
  ProgressBar.Max      := 0;
  ProgressBar.Position := 0;
  x := 0;
  ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
  for i := 0 to QTD_ARQUIVOS_ENVIAR do
  begin
    inc(x);
    if x <= 5 then
      begin
        cds.Append;
        TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
        cds.Post;
      end
    else
      begin
        FServidor.SalvarArquivos(cds.Data); //descarrega o arquivo
        cds.EmptyDataSet;
        cds.Free;
        cds := InitDataset;
        x := 1;
        cds.Append;
        TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
        cds.Post;
      end;
    ProgressBar.Position :=i;
    ProgressBar.Refresh;
  end;
  ProgressBar.Max      := 0;
  ProgressBar.Position := 0;
  cds.Free;
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  {$IFDEF VER230}  //s� para Delphi5
  FPath := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';
  {$ELSE}
  FPath := ExtractFilePath(ParamStr(0)) + 'pdf.pdf';
  {$ENDIF}
  FServidor := TServidor.Create;
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

{ TServidor }

procedure TServidor.ApagaPDF;
var
  SR: TSearchRec;
  I: integer;
begin
  I := FindFirst(ExtractFilePath(ParamStr(0)) + 'Servidor\*.PDF', faAnyFile, SR);
  while I = 0 do
    begin if (SR.Attr and faDirectory) <> faDirectory then
      if not DeleteFile(ExtractFilePath(ParamStr(0)) + 'Servidor\' + SR.Name) then ShowMessage(ExtractFilePath(ParamStr(0)) + 'Servidor\' + SR.Name);
        I := FindNext(SR);
    end;
end;

constructor TServidor.Create;
begin
  FPath := ExtractFilePath(ParamStr(0)) + 'Servidor\';
  intSeq := 0;
end;

function TServidor.SalvarArquivos(AData: OleVariant): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
  try
    try
      cds := TClientDataSet.Create(nil);
      cds.Data := AData;

      cds.First;

      while not cds.Eof do
        begin

          {$REGION Simula��o de erro, n�o alterar}
          if cds.RecordCount = 0 then
            Exit;
          {$ENDREGION}

          inc(intSeq);
          FileName := FPath + intSeq.ToString + '.pdf';
          if TFile.Exists(FileName) then
            TFile.Delete(FileName);

          TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
          cds.Next;

        end;

      cds.Free; //libera a variavel da memoria

    finally
      Result := True;
    end;
  except
    ApagaPDF;  //se deu erro apaga os arquicos
    fClienteServidor.ProgressBar.Max      := 0; //limpa a barra de progresso
    fClienteServidor.ProgressBar.Position := 0;
    raise;
  end;
end;

{ TEnviarARQEmParalelo }

constructor TEnviarARQEmParalelo.Create;
begin
  inherited Create(True);
  self.FreeOnTerminate := True;
end;

procedure TEnviarARQEmParalelo.EnviarArqEmParalelo;
var
  cds: TClientDataset;
  i,x: Integer;
begin
  with fClienteServidor do
    begin
      cds := InitDataset;
      ProgressBar.Max      := 0;
      fClienteServidor.ProgressBar.Position := 0;
      x := 0;
      ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
      for i := 0 to QTD_ARQUIVOS_ENVIAR do
      begin
        Application.ProcessMessages;
        inc(x);
        if x <= 5 then
          begin
            cds.Append;
            TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
            cds.Post;
          end
        else
          begin
            FServidor.SalvarArquivos(cds.Data); //descarrega o arquivo
            cds.EmptyDataSet;
            cds.Free;
            cds := InitDataset;
            x := 1;
            cds.Append;
            TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
            cds.Post;
          end;
        ProgressBar.Position := i;
      end;
      ProgressBar.Max      := 0;
      ProgressBar.Position := 0;
      cds.Free;
    end;
end;

procedure TEnviarARQEmParalelo.Execute;
begin
  inherited;
  Queue(EnviarArqEmParalelo);
end;

end.
