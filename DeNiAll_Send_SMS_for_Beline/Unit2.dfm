object Form2: TForm2
  Left = 358
  Top = 227
  BorderStyle = bsDialog
  Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1082#1086#1085#1090#1072#1082#1090
  ClientHeight = 126
  ClientWidth = 234
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 3
    Width = 25
    Height = 13
    Caption = #1048#1084#1103':'
  end
  object Label2: TLabel
    Left = 8
    Top = 43
    Width = 48
    Height = 13
    Caption = #1058#1077#1083#1077#1092#1086#1085':'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 87
    Width = 217
    Height = 30
    Shape = bsTopLine
  end
  object BitBtn1: TBitBtn
    Left = 80
    Top = 96
    Width = 75
    Height = 25
    TabOrder = 0
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object DBEdit1: TDBEdit
    Left = 16
    Top = 19
    Width = 201
    Height = 21
    DataField = 'sName'
    DataSource = Form1.DataSource1
    TabOrder = 1
  end
  object DBEdit2: TDBEdit
    Left = 16
    Top = 59
    Width = 201
    Height = 21
    DataField = 'sPhone'
    DataSource = Form1.DataSource1
    TabOrder = 2
  end
end
