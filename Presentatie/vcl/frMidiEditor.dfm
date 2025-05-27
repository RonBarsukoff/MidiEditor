object frameMidiEditor: TframeMidiEditor
  Left = 0
  Top = 0
  Width = 950
  Height = 496
  Align = alClient
  TabOrder = 0
  OnMouseWheel = FrameMouseWheel
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 950
    Height = 496
    ActivePage = tsEditor
    Align = alClient
    TabOrder = 0
    object tsEditor: TTabSheet
      Caption = 'Editor'
      object pOnder: TPanel
        Left = 0
        Top = 362
        Width = 942
        Height = 104
        Align = alBottom
        TabOrder = 0
        inline frameToonInfo: TframeObjectInfo
          Left = 1
          Top = 1
          Width = 147
          Height = 102
          Align = alLeft
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitHeight = 102
          inherited lNaam: TLabel
            Width = 147
          end
          inherited sgItems: TStringGrid
            Height = 87
            ExplicitTop = 15
            ExplicitWidth = 147
            ExplicitHeight = 87
          end
        end
        object pEventInfos: TFlowPanel
          Left = 148
          Top = 1
          Width = 793
          Height = 102
          Align = alClient
          TabOrder = 1
        end
      end
      object pPaintbox: TPanel
        Left = 128
        Top = 0
        Width = 814
        Height = 362
        Align = alClient
        TabOrder = 1
        DesignSize = (
          814
          362)
        object pbTonen: TPaintBox
          Left = 1
          Top = 149
          Width = 795
          Height = 195
          Cursor = crSizeWE
          Align = alClient
          Color = clRed
          ParentColor = False
          OnMouseDown = pbTonenMouseDown
          OnMouseMove = pbTonenMouseMove
          OnMouseUp = pbTonenMouseUp
          OnPaint = pbTonenPaint
          ExplicitTop = 120
          ExplicitWidth = 518
          ExplicitHeight = 191
        end
        object shAfspeelwijzer: TShape
          Left = 56
          Top = 0
          Width = 3
          Height = 343
          Anchors = [akLeft, akTop, akBottom]
          Brush.Color = clRed
          Pen.Style = psClear
          Visible = False
          ExplicitHeight = 231
        end
        object pbLiniaal: TPaintBox
          Left = 1
          Top = 1
          Width = 812
          Height = 40
          Align = alTop
          PopupMenu = pmLiniaal
          OnPaint = pbLiniaalPaint
          ExplicitWidth = 527
        end
        object pbEvents: TPaintBox
          Left = 1
          Top = 41
          Width = 812
          Height = 105
          Align = alTop
          Constraints.MinHeight = 24
          OnMouseDown = pbEventsMouseDown
          OnPaint = pbEventsPaint
          ExplicitLeft = 88
          ExplicitTop = 72
          ExplicitWidth = 105
        end
        object Splitter1: TSplitter
          Left = 1
          Top = 146
          Width = 812
          Height = 3
          Cursor = crVSplit
          Align = alTop
          ExplicitWidth = 198
        end
        object sbVerticaal: TScrollBar
          Left = 796
          Top = 149
          Width = 17
          Height = 195
          Align = alRight
          Kind = sbVertical
          PageSize = 0
          TabOrder = 0
          OnChange = sbVerticaalChange
        end
        object sbHorizontaal: TScrollBar
          Left = 1
          Top = 344
          Width = 812
          Height = 17
          Align = alBottom
          PageSize = 0
          TabOrder = 1
          OnChange = sbHorizontaalChange
        end
      end
      object pTracks: TPanel
        Left = 0
        Top = 0
        Width = 128
        Height = 362
        Align = alLeft
        TabOrder = 2
      end
    end
    object tsInfo: TTabSheet
      Caption = 'Info'
      ImageIndex = 1
      DesignSize = (
        942
        466)
      object pTonen: TPanel
        Left = 0
        Top = 0
        Width = 617
        Height = 466
        Align = alLeft
        TabOrder = 0
        DesignSize = (
          617
          466)
        object lTrack: TLabel
          Left = 8
          Top = 2
          Width = 27
          Height = 15
          Caption = 'Stem'
        end
        object cbStem: TComboBox
          Left = 8
          Top = 21
          Width = 217
          Height = 23
          Style = csDropDownList
          TabOrder = 0
          OnChange = cbStemChange
        end
        object sgTonen: TStringGrid
          Left = 8
          Top = 50
          Width = 289
          Height = 407
          Anchors = [akLeft, akTop, akBottom]
          ColCount = 4
          DefaultColWidth = 50
          DefaultRowHeight = 18
          FixedCols = 0
          TabOrder = 1
        end
        object sgEvents: TStringGrid
          Left = 303
          Top = 50
          Width = 306
          Height = 407
          Anchors = [akLeft, akTop, akBottom]
          ColCount = 4
          DefaultColWidth = 50
          DefaultRowHeight = 18
          FixedCols = 0
          TabOrder = 2
        end
      end
      object gbTempoWisselingen: TGroupBox
        Left = 631
        Top = 50
        Width = 233
        Height = 413
        Anchors = [akLeft, akTop, akBottom]
        Caption = 'Tempo wisselingen'
        TabOrder = 1
        object sgTempoWisselingen: TStringGrid
          Left = 2
          Top = 17
          Width = 229
          Height = 394
          Align = alClient
          ColCount = 2
          DefaultRowHeight = 18
          FixedCols = 0
          TabOrder = 0
        end
      end
      object eDivision: TLabeledEdit
        Left = 633
        Top = 21
        Width = 121
        Height = 23
        EditLabel.Width = 42
        EditLabel.Height = 15
        EditLabel.Caption = 'Division'
        TabOrder = 2
        Text = ''
      end
    end
  end
  object pmLiniaal: TPopupMenu
    Left = 468
    Top = 50
    object miGeselecteerdeMoment: TMenuItem
      Caption = 'Geselecteerde moment'
      OnClick = miGeselecteerdeMomentClick
    end
  end
end
