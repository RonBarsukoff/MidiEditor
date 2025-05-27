object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Midi editor (vcl)'
  ClientHeight = 524
  ClientWidth = 813
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  TextHeight = 13
  object pStatusBar: TPanel
    Left = 0
    Top = 492
    Width = 813
    Height = 32
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 491
    ExplicitWidth = 809
    object lMidiStatus: TLabel
      Left = 32
      Top = 2
      Width = 51
      Height = 13
      Caption = 'lMidiStatus'
    end
  end
  object pcEditors: TPageControl
    Left = 0
    Top = 0
    Width = 813
    Height = 492
    Align = alClient
    TabOrder = 1
    OnChange = pcEditorsChange
    ExplicitWidth = 809
    ExplicitHeight = 491
  end
  object MainMenu1: TMainMenu
    Left = 176
    Top = 48
    object miBestand: TMenuItem
      Caption = 'Bestand'
      object miOpen: TMenuItem
        Caption = 'Open'
        OnClick = miOpenClick
      end
      object miBewaarAls: TMenuItem
        Caption = 'Bewaar als'
        OnClick = miBewaarAlsClick
      end
      object miOpenMidiBestand: TMenuItem
        Caption = 'Open midi bestand'
        OnClick = miOpenMidiBestandClick
      end
      object miBewaarAlsMidibestand: TMenuItem
        Caption = 'Bewaar als midi bestand'
        OnClick = miBewaarAlsMidibestandClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object miAfsluiten: TMenuItem
        Caption = 'Afsluiten'
        OnClick = miAfsluitenClick
      end
    end
    object miAfspelen: TMenuItem
      Caption = 'Afspelen'
      OnClick = miAfspelenClick
    end
    object miInstellingen: TMenuItem
      Caption = 'Instellingen'
      object miMidi: TMenuItem
        Caption = 'Midi'
        OnClick = miMidiClick
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Midi|*.mid'
    Left = 280
    Top = 168
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Midi|*.mid'
    Left = 388
    Top = 168
  end
end
