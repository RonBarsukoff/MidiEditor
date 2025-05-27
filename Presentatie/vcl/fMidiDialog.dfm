object frmMidiDialog: TfrmMidiDialog
  Left = 0
  Top = 0
  Caption = 'frmMidiDialog'
  ClientHeight = 206
  ClientWidth = 386
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lMidiInDevice: TLabel
    Left = 16
    Top = 16
    Width = 29
    Height = 13
    Caption = 'Midi in'
  end
  object lMidiOutDevice: TLabel
    Left = 16
    Top = 69
    Width = 37
    Height = 13
    Caption = 'Midi out'
  end
  object lIngespeeldeToon: TLabel
    Left = 312
    Top = 64
    Width = 85
    Height = 13
    Caption = 'lIngespeeldeToon'
  end
  object lMelding: TLabel
    Left = 16
    Top = 168
    Width = 38
    Height = 13
    Caption = 'lMelding'
  end
  object cbMidiInDevices: TComboBox
    Left = 16
    Top = 32
    Width = 297
    Height = 21
    TabOrder = 0
    Text = 'cbMidiInDevices'
  end
  object cbMidiOutDevices: TComboBox
    Left = 16
    Top = 85
    Width = 297
    Height = 21
    TabOrder = 1
    Text = 'cbMidiOutDevices'
  end
  object bOk: TButton
    Left = 136
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object bCancel: TButton
    Left = 238
    Top = 128
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object cbTestMidiOut: TCheckBox
    Left = 328
    Top = 87
    Width = 97
    Height = 17
    Caption = 'Test'
    TabOrder = 4
    OnClick = cbTestMidiOutClick
  end
  object cbTestMidiIn: TCheckBox
    Left = 328
    Top = 34
    Width = 97
    Height = 17
    Caption = 'Test'
    TabOrder = 5
    OnClick = cbTestMidiInClick
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 200
    OnTimer = Timer1Timer
    Left = 32
    Top = 128
  end
end
