object frmLeesMidifile: TfrmLeesMidifile
  Left = 0
  Top = 0
  Caption = 'frmLeesMidifile'
  ClientHeight = 579
  ClientWidth = 832
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 832
    Height = 538
    ActivePage = tsAlgemeen
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 828
    ExplicitHeight = 537
    object tsAlgemeen: TTabSheet
      Caption = 'Algemeen'
      object lTracks: TLabel
        Left = 8
        Top = 8
        Width = 32
        Height = 15
        Caption = 'Tracks'
      end
      object lKanalen: TLabel
        Left = 8
        Top = 116
        Width = 42
        Height = 15
        Caption = 'Kanalen'
      end
      object lEvents: TLabel
        Left = 248
        Top = 8
        Width = 34
        Height = 15
        Caption = 'Events'
      end
      object lOverigeEvents: TLabel
        Left = 512
        Top = 8
        Width = 78
        Height = 15
        Caption = 'Overige events'
      end
      object lTeksten: TLabel
        Left = 512
        Top = 288
        Width = 39
        Height = 15
        Caption = 'Teksten'
      end
      object lbTracks: TListBox
        Left = 8
        Top = 24
        Width = 225
        Height = 73
        ItemHeight = 15
        TabOrder = 0
        OnClick = lbTracksClick
      end
      object lbKanalen: TListBox
        Left = 8
        Top = 132
        Width = 225
        Height = 361
        ItemHeight = 15
        TabOrder = 1
        OnClick = lbKanalenClick
      end
      object mNootEvents: TMemo
        Left = 248
        Top = 24
        Width = 249
        Height = 469
        Lines.Strings = (
          'mNootEvents')
        TabOrder = 2
      end
      object mOverigeEvents: TMemo
        Left = 512
        Top = 24
        Width = 281
        Height = 257
        Lines.Strings = (
          'mOverigeEvents')
        TabOrder = 3
      end
      object mTeksten: TMemo
        Left = 512
        Top = 304
        Width = 281
        Height = 189
        Lines.Strings = (
          'mTeksten')
        TabOrder = 4
      end
    end
    object tsOverige: TTabSheet
      Caption = 'Overige'
      ImageIndex = 1
      object lFormaat: TLabel
        Left = 16
        Top = 24
        Width = 47
        Height = 15
        Caption = 'lFormaat'
      end
      object lDivision: TLabel
        Left = 16
        Top = 48
        Width = 45
        Height = 15
        Caption = 'lDivision'
      end
    end
  end
  object pOnder: TPanel
    Left = 0
    Top = 538
    Width = 832
    Height = 41
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 537
    ExplicitWidth = 828
    object bOk: TButton
      Left = 632
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object bCancel: TButton
      Left = 736
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 1
    end
  end
end
