object frmMissionControl: TfrmMissionControl
  Left = 0
  Top = 0
  Caption = 'Mission Control'
  ClientHeight = 705
  ClientWidth = 868
  Color = clBtnFace
  Constraints.MinWidth = 703
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 868
    Height = 49
    Align = alTop
    TabOrder = 0
    object lblActive: TLabel
      Left = 210
      Top = 19
      Width = 112
      Height = 19
      Caption = 'Out of service'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnStartServer: TButton
      Left = 16
      Top = 13
      Width = 75
      Height = 25
      Caption = 'Start MC'
      TabOrder = 0
      OnClick = btnStartServerClick
    end
    object btnStopServer: TButton
      Left = 110
      Top = 13
      Width = 75
      Height = 25
      Caption = 'Stop MC'
      TabOrder = 1
      OnClick = btnStopServerClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 609
    Width = 868
    Height = 96
    Align = alBottom
    TabOrder = 1
    object GroupBox3: TGroupBox
      Left = 1
      Top = 1
      Width = 866
      Height = 94
      Align = alClient
      Caption = 'Log'
      TabOrder = 0
      object lbInfo: TListBox
        Left = 2
        Top = 15
        Width = 575
        Height = 77
        ItemHeight = 13
        TabOrder = 0
      end
      object lbSimulation: TListBox
        Left = 583
        Top = 15
        Width = 281
        Height = 77
        Align = alRight
        ItemHeight = 13
        TabOrder = 1
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 49
    Width = 265
    Height = 560
    Align = alLeft
    TabOrder = 2
    object GroupBox1: TGroupBox
      Left = 1
      Top = 1
      Width = 263
      Height = 558
      Align = alClient
      Caption = 'Clients'
      TabOrder = 0
      object Panel5: TPanel
        Left = 2
        Top = 15
        Width = 259
        Height = 164
        Align = alTop
        TabOrder = 0
        object Label1: TLabel
          Left = 13
          Top = 126
          Width = 37
          Height = 13
          Caption = 'Create:'
        end
        object btnSwitchOnDemand: TButton
          Left = 103
          Top = 28
          Width = 98
          Height = 25
          Caption = 'Create Switch'
          Enabled = False
          TabOrder = 0
          OnClick = btnSwitchOnDemandClick
        end
        object btnClientStop: TButton
          Left = 103
          Top = 59
          Width = 98
          Height = 25
          Caption = 'Stop'
          Enabled = False
          TabOrder = 1
          OnClick = btnClientStopClick
        end
        object edSwitchNr: TEdit
          Left = 56
          Top = 123
          Width = 41
          Height = 21
          Alignment = taRightJustify
          TabOrder = 2
          Text = '1'
        end
        object btnQuit: TButton
          Left = 103
          Top = 90
          Width = 98
          Height = 25
          Caption = 'Quit'
          TabOrder = 3
          OnClick = btnQuitClick
        end
        object btnCreateSwitches: TButton
          Left = 103
          Top = 121
          Width = 98
          Height = 25
          Caption = 'Switches'
          TabOrder = 4
          OnClick = btnCreateSwitchesClick
        end
      end
      object sgClients: TStringGrid
        Left = 2
        Top = 179
        Width = 259
        Height = 377
        Align = alClient
        ColCount = 4
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
        TabOrder = 1
      end
    end
  end
  object Panel4: TPanel
    Left = 265
    Top = 49
    Width = 603
    Height = 560
    Align = alClient
    TabOrder = 3
    object GroupBox2: TGroupBox
      Left = 1
      Top = 1
      Width = 601
      Height = 558
      Align = alClient
      Caption = 'Switches'
      TabOrder = 0
      object Panel6: TPanel
        Left = 2
        Top = 15
        Width = 597
        Height = 186
        Align = alTop
        TabOrder = 0
        object Label2: TLabel
          Left = 11
          Top = 14
          Width = 51
          Height = 13
          Caption = 'Controller:'
        end
        object edControllerIp: TEdit
          Left = 75
          Top = 11
          Width = 93
          Height = 21
          TabOrder = 0
          Text = '192.168.42.128'
        end
        object edControllerPort: TEdit
          Left = 174
          Top = 11
          Width = 41
          Height = 21
          TabOrder = 1
          Text = '6633'
        end
        object btnRefresh: TButton
          Left = 2
          Top = 155
          Width = 375
          Height = 25
          Caption = 'R E F R E S H'
          TabOrder = 2
          OnClick = btnRefreshClick
        end
        object btnSaveToCsv: TButton
          Left = 383
          Top = 155
          Width = 201
          Height = 25
          Caption = 'Save to CSV'
          TabOrder = 3
          OnClick = btnSaveToCsvClick
        end
        object gpSelectedSwitch: TGroupBox
          Left = 382
          Top = 2
          Width = 201
          Height = 143
          Caption = 'Selected Switch'
          TabOrder = 4
          object btnHello: TButton
            Left = 98
            Top = 18
            Width = 98
            Height = 25
            Caption = 'Hello send'
            TabOrder = 0
            OnClick = btnHelloClick
          end
          object btnGetReceived: TButton
            Left = 3
            Top = 18
            Width = 89
            Height = 25
            Caption = 'Get Received'
            TabOrder = 1
            OnClick = btnGetReceivedClick
          end
          object btnSetId: TButton
            Left = 98
            Top = 49
            Width = 97
            Height = 25
            Caption = 'Set ID'
            TabOrder = 2
            OnClick = btnSetIdClick
          end
          object btnGetMeantime: TButton
            Left = 3
            Top = 49
            Width = 89
            Height = 25
            Caption = 'Get Meantime'
            TabOrder = 3
            OnClick = btnGetMeantimeClick
          end
          object btnSetController: TButton
            Left = 98
            Top = 80
            Width = 97
            Height = 27
            Caption = 'Set Controller'
            Enabled = False
            TabOrder = 4
            OnClick = btnSetControllerClick
          end
          object btnGetPpS: TButton
            Left = 3
            Top = 80
            Width = 89
            Height = 25
            Caption = 'Get P/S'
            TabOrder = 5
            OnClick = btnGetPpSClick
          end
          object btnSwitchStart: TButton
            Left = 3
            Top = 113
            Width = 57
            Height = 25
            Caption = 'Start'
            TabOrder = 6
            OnClick = btnSwitchStartClick
          end
          object btnSwitchStop: TButton
            Left = 70
            Top = 113
            Width = 60
            Height = 25
            Caption = 'Stop'
            TabOrder = 7
            OnClick = btnSwitchStopClick
          end
          object btnSwitchQuit: TButton
            Left = 136
            Top = 113
            Width = 62
            Height = 25
            Caption = 'Quit'
            TabOrder = 8
            OnClick = btnSwitchQuitClick
          end
        end
        object gpAllSwitches: TGroupBox
          Left = 3
          Top = 38
          Width = 373
          Height = 106
          Caption = 'All Switches'
          TabOrder = 5
          object Label3: TLabel
            Left = 149
            Top = 22
            Width = 11
            Height = 13
            Caption = 'us'
          end
          object btnStartAll: TButton
            Left = 7
            Top = 14
            Width = 75
            Height = 25
            Caption = 'Start'
            TabOrder = 0
            OnClick = btnStartAllClick
          end
          object btnStopAll: TButton
            Left = 7
            Top = 45
            Width = 75
            Height = 25
            Caption = 'Stop'
            TabOrder = 1
            OnClick = btnStopAllClick
          end
          object edBatchDelay: TEdit
            Left = 88
            Top = 18
            Width = 57
            Height = 21
            Alignment = taRightJustify
            TabOrder = 2
            Text = '0'
          end
          object btnBatchDelay: TButton
            Left = 166
            Top = 16
            Width = 75
            Height = 25
            Caption = 'Set Delay'
            TabOrder = 3
            OnClick = btnBatchDelayClick
          end
          object btnSimulationStart: TButton
            Left = 8
            Top = 78
            Width = 137
            Height = 25
            Caption = 'Start Simulation'
            TabOrder = 4
            OnClick = btnSimulationStartClick
          end
          object btnSetSession: TButton
            Left = 166
            Top = 47
            Width = 75
            Height = 25
            Caption = 'Set Session'
            TabOrder = 5
            OnClick = btnSetSessionClick
          end
          object edSession: TEdit
            Left = 88
            Top = 45
            Width = 57
            Height = 21
            Alignment = taRightJustify
            TabOrder = 6
            Text = '1'
          end
          object btnStopSimulation: TButton
            Left = 166
            Top = 78
            Width = 146
            Height = 25
            Caption = 'Stop Simulation'
            TabOrder = 7
            OnClick = btnStopSimulationClick
          end
        end
      end
      object sgSwitches: TStringGrid
        Left = 2
        Top = 201
        Width = 597
        Height = 355
        Align = alClient
        ColCount = 10
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
        TabOrder = 1
        RowHeights = (
          24
          24)
      end
    end
  end
  object dlgSaveCSV: TSaveDialog
    Left = 376
    Top = 8
  end
  object tmrSimulation: TTimer
    Enabled = False
    OnTimer = tmrSimulationTimer
    Left = 448
    Top = 8
  end
end
