object frmGeselecteerdeMoment: TfrmGeselecteerdeMoment
  Left = 0
  Top = 0
  Caption = 'frmGeselecteerdeMoment'
  ClientHeight = 250
  ClientWidth = 313
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object eMoment: TLabeledEdit
    Left = 14
    Top = 19
    Width = 138
    Height = 23
    EditLabel.Width = 122
    EditLabel.Height = 15
    EditLabel.Caption = 'Geselecteerde moment'
    TabOrder = 0
    Text = 'eMoment'
  end
  object eNaarMoment: TLabeledEdit
    Left = 16
    Top = 64
    Width = 136
    Height = 23
    EditLabel.Width = 135
    EditLabel.Height = 15
    EditLabel.Caption = 'Verplaatsen naar moment'
    TabOrder = 1
    Text = 'eNaarMoment'
  end
  object bOk: TButton
    Left = 104
    Top = 184
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object bCancel: TButton
    Left = 200
    Top = 184
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
