object fThreads: TfThreads
  Left = 0
  Top = 0
  Caption = 'fThreads'
  ClientHeight = 437
  ClientWidth = 510
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 152
    Top = 16
    Width = 89
    Height = 13
    Caption = 'N'#250'mero de Thread'
  end
  object Label2: TLabel
    Left = 152
    Top = 64
    Width = 157
    Height = 13
    Caption = 'Valor de tempo em milissegundos'
  end
  object EDT_NumThread: TEdit
    Left = 152
    Top = 32
    Width = 241
    Height = 21
    TabOrder = 0
    Text = '100'
  end
  object EDT_Valtmpms: TEdit
    Left = 152
    Top = 80
    Width = 241
    Height = 21
    TabOrder = 1
    Text = '1000'
  end
  object BTN_Executar: TButton
    Left = 152
    Top = 120
    Width = 241
    Height = 25
    Caption = 'Executar Thread'
    TabOrder = 2
    OnClick = BTN_ExecutarClick
  end
  object MemResposta: TMemo
    Left = 0
    Top = 167
    Width = 510
    Height = 247
    Align = alBottom
    Lines.Strings = (
      '')
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object ProgressBar: TProgressBar
    AlignWithMargins = True
    Left = 3
    Top = 417
    Width = 504
    Height = 17
    Align = alBottom
    TabOrder = 4
    ExplicitLeft = -2
    ExplicitTop = 420
  end
end
