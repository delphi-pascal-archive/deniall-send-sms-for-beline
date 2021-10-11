object Form3: TForm3
  Left = 380
  Top = 249
  BorderStyle = bsDialog
  Caption = #1054#1090#1087#1088#1072#1074#1082#1072' '#1057#1052#1057'..'
  ClientHeight = 56
  ClientWidth = 208
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 193
    Height = 41
    AutoSize = False
    Caption = #1055#1086#1076#1086#1078#1076#1080#1090#1077' '#1087#1086#1078#1072#1083#1091#1081#1089#1090#1072' '#1074#1099#1087#1086#1083#1085#1103#1077#1090#1089#1103' '#1086#1090#1087#1088#1072#1074#1082#1072' '#1057#1052#1057' ...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 35
    Width = 191
    Height = 17
    TabOrder = 0
  end
  object XPManifest1: TXPManifest
    Left = 160
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 48
    Top = 24
  end
end
