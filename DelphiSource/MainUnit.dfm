object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Acorn MOS'
  ClientHeight = 432
  ClientWidth = 545
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton1: TSpeedButton
    Left = 8
    Top = 8
    Width = 97
    Height = 22
    Caption = 'Build 2Mbit MOS'
    OnClick = SpeedButton1Click
  end
  object SpeedButton2: TSpeedButton
    Left = 8
    Top = 36
    Width = 97
    Height = 22
    Caption = 'Build MOS 3.20'
    OnClick = SpeedButton2Click
  end
  object SpeedButton3: TSpeedButton
    Left = 8
    Top = 64
    Width = 97
    Height = 22
    Caption = 'Build MOS 3.50'
    OnClick = SpeedButton3Click
  end
  object Memo1: TMemo
    Left = 111
    Top = 8
    Width = 426
    Height = 417
    TabOrder = 0
  end
  object SaveDialog1: TSaveDialog
    Left = 40
    Top = 104
  end
end
