object OptionsForm: TOptionsForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #35373#23450
  ClientHeight = 351
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  ShowHint = True
  OnCreate = FormCreate
  TextHeight = 21
  object PageControl: TPageControl
    Left = 7
    Top = 0
    Width = 609
    Height = 289
    ActivePage = TabSheet1
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
      object LinkTagsGroupBox: TGroupBox
        Left = 0
        Top = 0
        Width = 601
        Height = 169
        Align = alTop
        Caption = #30011#20687#12522#12531#12463#12479#12464'(&T)'
        TabOrder = 0
        object LinkTagsRadioGroup: TRadioGroup
          Left = 2
          Top = 23
          Width = 175
          Height = 144
          Align = alLeft
          Items.Strings = (
            #12510#12540#12463#12480#12454#12531#26041#24335
            #29420#33258#12479#12464)
          TabOrder = 0
          OnClick = LinkTagsRadioGroupClick
        end
        object LinkTagOptionsPageControl: TPageControl
          Left = 177
          Top = 23
          Width = 422
          Height = 144
          ActivePage = TabSheet3
          Align = alClient
          TabOrder = 1
          object TabSheet2: TTabSheet
            Caption = 'TabSheet2'
            object ExMarkdownLabel: TLabel
              Left = 20
              Top = 42
              Width = 4
              Height = 21
            end
            object Label1: TLabel
              Left = 16
              Top = 8
              Width = 106
              Height = 21
              Caption = #12522#12531#12463#12469#12531#12503#12523#65306
            end
          end
          object TabSheet3: TTabSheet
            Caption = 'TabSheet3'
            ImageIndex = 1
            object LinkTagSampleLabel: TLabel
              Left = 35
              Top = 68
              Width = 141
              Height = 21
              Caption = 'LinkTagSampleLabel'
            end
            object Label2: TLabel
              Left = 10
              Top = 41
              Width = 106
              Height = 21
              Caption = #12522#12531#12463#12469#12531#12503#12523#65306
            end
            object LinkStartTagEdit: TEdit
              Left = 10
              Top = 4
              Width = 121
              Height = 29
              TabOrder = 0
              OnChange = LinkStartTagEditChange
            end
            object LinkEndTagEdit: TEdit
              Left = 208
              Top = 3
              Width = 121
              Height = 29
              TabOrder = 1
              OnChange = LinkStartTagEditChange
            end
          end
        end
      end
      object GroupBox1: TGroupBox
        Left = 0
        Top = 169
        Width = 601
        Height = 105
        Align = alTop
        Caption = #25277#20986#30011#20687'(&S)'
        TabOrder = 1
        ExplicitLeft = 16
        ExplicitTop = 176
        ExplicitWidth = 185
        object ExcludeSmallImagesCheckBox: TCheckBox
          Left = 24
          Top = 40
          Width = 333
          Height = 17
          Caption = #23567#12373#12394#30011#20687#12399#38500#22806#12377#12427'(&E)'
          TabOrder = 0
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 310
    Width = 624
    Height = 41
    Align = alBottom
    TabOrder = 1
    object BitBtn1: TBitBtn
      Left = 448
      Top = 8
      Width = 75
      Height = 25
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 0
    end
    object BitBtn2: TBitBtn
      Left = 536
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Cancel'
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 1
    end
  end
end
