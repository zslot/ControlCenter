unit MControl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdContext, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdTCPServer, MissionCommunicationU, ExtCtrls, Grids;

const
   SIMULATION_STEPS        = 5;
   SIMULATION_CREATE       = 0;
   SIMULATION_SET          = 1;
   SIMULATION_START        = 2;
   SIMULATION_READ         = 3;
   SIMULATION_STOP         = 4;

   DELAY_CREATE   = 10 * 1000;
   DELAY_SET      =  3 * 1000;
   DELAY_START    =  5 * 1000;
   DELAY_READ     =  5 * 1000;
   DELAY_STOP     = 10 * 1000;

const
   MAX_SIMULATION_SESSIONS = 5;


type
  TfrmMissionControl = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    GroupBox3: TGroupBox;
    lbInfo: TListBox;
    btnStartServer: TButton;
    btnStopServer: TButton;
    lblActive: TLabel;
    Panel3: TPanel;
    Panel4: TPanel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Panel5: TPanel;
    Panel6: TPanel;
    btnSwitchOnDemand: TButton;
    btnClientStop: TButton;
    edSwitchNr: TEdit;
    Label1: TLabel;
    btnQuit: TButton;
    sgClients: TStringGrid;
    sgSwitches: TStringGrid;
    Label2: TLabel;
    edControllerIp: TEdit;
    edControllerPort: TEdit;
    btnRefresh: TButton;
    btnSaveToCsv: TButton;
    dlgSaveCSV: TSaveDialog;
    btnCreateSwitches: TButton;
    gpSelectedSwitch: TGroupBox;
    btnHello: TButton;
    btnGetReceived: TButton;
    btnSetId: TButton;
    btnGetMeantime: TButton;
    btnSetController: TButton;
    btnGetPpS: TButton;
    btnSwitchStart: TButton;
    btnSwitchStop: TButton;
    btnSwitchQuit: TButton;
    gpAllSwitches: TGroupBox;
    btnStartAll: TButton;
    btnStopAll: TButton;
    edBatchDelay: TEdit;
    btnBatchDelay: TButton;
    Label3: TLabel;
    btnSimulationStart: TButton;
    tmrSimulation: TTimer;
    btnSetSession: TButton;
    edSession: TEdit;
    btnStopSimulation: TButton;
    lbSimulation: TListBox;
    procedure btnStartServerClick(Sender: TObject);
    procedure btnStopServerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnHelloClick(Sender: TObject);
    procedure btnSwitchOnDemandClick(Sender: TObject);
    procedure btnClientStopClick(Sender: TObject);
    procedure btnSwitchStopClick(Sender: TObject);
    procedure btnSwitchStartClick(Sender: TObject);
    procedure btnSwitchQuitClick(Sender: TObject);
    procedure btnQuitClick(Sender: TObject);
    procedure btnSetIdClick(Sender: TObject);
    procedure btnGetReceivedClick(Sender: TObject);
    procedure btnGetMeantimeClick(Sender: TObject);
    procedure btnGetPpSClick(Sender: TObject);
    procedure btnSetControllerClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnSaveToCsvClick(Sender: TObject);
    procedure btnCreateSwitchesClick(Sender: TObject);
    procedure btnStartAllClick(Sender: TObject);
    procedure btnStopAllClick(Sender: TObject);
    procedure btnBatchDelayClick(Sender: TObject);
    procedure btnSimulationStartClick(Sender: TObject);
    procedure tmrSimulationTimer(Sender: TObject);
    procedure btnSetSessionClick(Sender: TObject);
    procedure btnStopSimulationClick(Sender: TObject);
  private
    { Private-Deklarationen }
    intSimulationStep : Integer;
    procedure Save();
  public
    { Public-Deklarationen }
    procedure DefragmentLists();
    procedure UpdateList(const paStrIp: String; const paStrPort: String; const paIntParam: Integer; var paMsPayload: TMemoryStream);
    function StrToFloatc(const strString: String):Double;
  end;

var
  frmMissionControl: TfrmMissionControl;
  FTestContext : TIdContext;
  FClientTestContext : TIdContext;
  FFileAll: TextFile;
  FFileGrafic: TextFile;
  FIsSimulationStarted : Boolean;
  FCurrentSession : Integer;
implementation

{$R *.dfm}

procedure TfrmMissionControl.btnQuitClick(Sender: TObject);
var tmpComObj : TMCComObj;
begin
   //MissionControlServer.SendClientQuit(FClientTestContext);
   if Assigned(frmMissionControl.sgClients.Objects[0,frmMissionControl.sgClients.Selection.Top]) then begin
      tmpComObj := TMCComObj(frmMissionControl.sgClients.Objects[0,frmMissionControl.sgClients.Selection.Top]);
      if tmpComObj.Active then begin
         MissionControlServer.SendQuit(tmpComObj.AContext);
         tmpComObj.Active := false;
      end;
   end;
   frmMissionControl.DefragmentLists;
end;

procedure TfrmMissionControl.btnRefreshClick(Sender: TObject);
var i: Integer;
    tmpComObj : TMCComObj;
begin
   for i:= 1 to sgSwitches.RowCount - 1 do begin
      if Assigned(sgSwitches.Objects[0,i]) then begin
         tmpComObj := TMCComObj(sgSwitches.Objects[0,i]);
         if Assigned(tmpComObj.AContext.Connection) then begin
            if tmpComObj.AContext.Connection.Connected then begin
              MissionControlServer.SendGet(tmpComObj.AContext,PACKET_RECEIVED);
              MissionControlServer.SendGet(tmpComObj.AContext,PACKET_MEANTIME);
              MissionControlServer.SendGet(tmpComObj.AContext,PACKET_P_SECOND);
              MissionControlServer.SendGet(tmpComObj.AContext,PACKET_VAR);
              MissionControlServer.SendGet(tmpComObj.AContext,USLEEP_BATCHPROCESS);
              MissionControlServer.SendGet(tmpComObj.AContext,SESSION_ID);
            end;
         end;
      end;
   end;
end;

procedure TfrmMissionControl.btnBatchDelayClick(Sender: TObject);
var i : Integer;
    tmpComObj : TMCComObj;
    strDelay : String;
begin
   for i:= 1 to sgSwitches.RowCount - 1 do begin
      if Assigned(sgSwitches.Objects[0,i]) then begin
         tmpComObj := TMCComObj(sgSwitches.Objects[0,i]);
         if tmpComObj.AContext.Connection.Connected then begin
            strDelay := IntToStr(StrToIntDef(edBatchDelay.Text,0));
            edBatchDelay.Text := strDelay;
            MissionControlServer.SendSet(tmpComObj.AContext,USLEEP_BATCHPROCESS,strDelay);
         end;
      end;
   end;
end;

procedure TfrmMissionControl.btnClientStopClick(Sender: TObject);
begin
   //MissionControlServer.SendClientStop(FClientTestContext, strtoInt(edSwitchNr.Text));

end;

procedure TfrmMissionControl.btnCreateSwitchesClick(Sender: TObject);
var tmpComObj : TMCComObj;
    i: Integer;
    intCount : Integer;
begin
   if Assigned(frmMissionControl.sgClients.Objects[0,frmMissionControl.sgClients.Selection.Top]) then begin
      tmpComObj := TMCComObj(frmMissionControl.sgClients.Objects[0,frmMissionControl.sgClients.Selection.Top]);
      if tmpComObj.Active then begin
         intCount := StrToIntDef(edSwitchNr.Text,0);
         for i := 1 to intCount do begin
            MissionControlServer.SendCreateNewSwitch(tmpComObj.AContext);
         end;
      end;
   end;
end;

procedure TfrmMissionControl.btnGetMeantimeClick(Sender: TObject);
var tmpComObj : TMCComObj;
begin
   if Assigned(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]) then begin
      tmpComObj := TMCComObj(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]);
      if tmpComObj.Active then begin
         //MissionControlServer.SendGetMeantime(tmpComObj.AContext);
         MissionControlServer.SendGet(tmpComObj.AContext,PACKET_MEANTIME);
      end;
   end;
end;

procedure TfrmMissionControl.btnGetPpSClick(Sender: TObject);
var tmpComObj : TMCComObj;
begin
   if Assigned(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]) then begin
      tmpComObj := TMCComObj(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]);
      if tmpComObj.Active then begin
         //MissionControlServer.SendGetPS(tmpComObj.AContext);
         MissionControlServer.SendGet(tmpComObj.AContext,PACKET_P_SECOND);
      end;
   end;
end;

procedure TfrmMissionControl.btnGetReceivedClick(Sender: TObject);
var tmpComObj : TMCComObj;
begin
   if Assigned(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]) then begin
      tmpComObj := TMCComObj(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]);
      if tmpComObj.Active then begin
         //MissionControlServer.SendGetReceived(tmpComObj.AContext);
         MissionControlServer.SendGet(tmpComObj.AContext,PACKET_RECEIVED);
      end;
   end;
end;

procedure TfrmMissionControl.btnHelloClick(Sender: TObject);
var tmpComObj : TMCComObj;
begin
   //MissionControlServer.SendHello(FTestContext);
   if Assigned(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]) then begin
      tmpComObj := TMCComObj(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]);
      if tmpComObj.Active then begin
         MissionControlServer.SendHello(tmpComObj.AContext);
      end;
   end;
end;

procedure TfrmMissionControl.btnSaveToCsvClick(Sender: TObject);
var
   fCSV : TextFile;
   i,j : Integer;
begin
   dlgSaveCSV.Filter := 'CSV file|*.csv';
   dlgSaveCSV.InitialDir := GetCurrentDir;
   dlgSaveCSV.DefaultExt := 'csv';
   dlgSaveCSV.FilterIndex := 1;
   if dlgSaveCSV.Execute then begin
      if FileExists(dlgSaveCSV.FileName) then begin
         if MessageDlg('Überschreiben?',mtCustom,[mbYes, mbNo],0) = mrNo  then begin
            Exit;
         end;
      end;
      AssignFile(fCSV,dlgSaveCSV.FileName);
      Rewrite(fCSV);
      for i:= 1 to sgSwitches.RowCount - 2 do begin
         for j := 1 to sgSwitches.ColCount - 2 do begin
            Write(fCSV, sgSwitches.Cells[j,i]+';');
         end;
         Writeln(fCSV,'');
      end;
   end;
   Flush(fCSV);
   CloseFile(fCSV);
end;

procedure TfrmMissionControl.btnSetControllerClick(Sender: TObject);
var i : Integer;
    tmpComObj : TMCComObj;
    strIP, strPort : String;
begin
   for i:= 1 to sgSwitches.RowCount - 1 do begin
      if Assigned(sgSwitches.Objects[0,i]) then begin
         tmpComObj := TMCComObj(sgSwitches.Objects[0,i]);
         if tmpComObj.AContext.Connection.Connected then begin
           strIP   := edControllerIp.Text;
           strPort := edControllerPort.Text;
           MissionControlServer.SendSet(tmpComObj.AContext,CONTROLLER_IP,strIP);
           MissionControlServer.SendSet(tmpComObj.AContext,CONTROLLER_PORT,strPort);
         end;
      end;
   end;
end;

procedure TfrmMissionControl.btnSetIdClick(Sender: TObject);
var tmpComObj : TMCComObj;
begin
    if Assigned(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]) then begin
      tmpComObj := TMCComObj(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]);
      if tmpComObj.Active then begin
         tmpComObj.ID := MissionControlServer.SendSetId(tmpComObj.AContext);
         //showmessage('ID: '+inttostr(tmpComObj.ID));
      end;
   end;
end;

procedure TfrmMissionControl.btnSetSessionClick(Sender: TObject);
var i : Integer;
    tmpComObj : TMCComObj;
    strSession : String;
begin
   for i:= 1 to sgSwitches.RowCount - 1 do begin
      if Assigned(sgSwitches.Objects[0,i]) then begin
         tmpComObj := TMCComObj(sgSwitches.Objects[0,i]);
         if tmpComObj.AContext.Connection.Connected then begin
            strSession := IntToStr(StrToIntDef(edSession.Text,0));
            edSession.Text := strSession;
            MissionControlServer.SendSet(tmpComObj.AContext,SESSION_ID,strSession);
         end;
      end;
   end;
end;

procedure TfrmMissionControl.btnSimulationStartClick(Sender: TObject);
var
   i: Integer;
begin
    FIsSimulationStarted := true;

    dlgSaveCSV.Filter := 'CSV file|*.csv';
    dlgSaveCSV.InitialDir := GetCurrentDir;
    dlgSaveCSV.DefaultExt := 'csv';
    dlgSaveCSV.FilterIndex := 1;
    dlgSaveCSV.Title := 'ALL-CSV';
    if dlgSaveCSV.Execute then begin
      if FileExists(dlgSaveCSV.FileName) then begin
         if MessageDlg('Überschreiben?',mtCustom,[mbYes, mbNo],0) = mrNo  then begin
            Exit;
         end;
      end;
      AssignFile(FFileAll,dlgSaveCSV.FileName);
      Rewrite(FFileAll);
      Writeln(FFileAll, 'ID;IP;Port;Activ;P.rcv;RTTmean;P/s;VAR;Delay,Session');
    end;
    dlgSaveCSV.Title := 'Graphic-CSV';
    if dlgSaveCSV.Execute then begin
      if FileExists(dlgSaveCSV.FileName) then begin
         if MessageDlg('Überschreiben?',mtCustom,[mbYes, mbNo],0) = mrNo  then begin
            Exit;
         end;
      end;
      AssignFile(FFileGrafic,dlgSaveCSV.FileName);
      Rewrite(FFileGrafic);
      Writeln(FFileGrafic, 'Count_SW;P_rcv;RTTmean;P/S;Ca;Delay');
    end;

    intSimulationStep := 0;
    tmrSimulation.Enabled := true;


end;

procedure TfrmMissionControl.btnStartAllClick(Sender: TObject);
var i: Integer;
    tmpComObj : TMCComObj;
begin
   for i:= 1 to sgSwitches.RowCount - 1 do begin
      if Assigned(sgSwitches.Objects[0,i]) then begin
         tmpComObj := TMCComObj(sgSwitches.Objects[0,i]);
         if Assigned(tmpComObj.AContext.Connection) then begin
            if tmpComObj.AContext.Connection.Connected then begin
              MissionControlServer.SendStart(tmpComObj.AContext);
            end;
         end;
      end;
   end;
end;

procedure TfrmMissionControl.btnStartServerClick(Sender: TObject);
begin
   lbInfo.Clear;
   MissionControlServer.start(16005);
   if (MissionControlServer.Active) then begin
       lblActive.Caption := 'Active';
       lblActive.Font.Color := clGreen;
   end;
   btnStartServer.Enabled := false;
   btnStopServer.Enabled := true;
end;

procedure TfrmMissionControl.btnStopAllClick(Sender: TObject);
var i: Integer;
    tmpComObj : TMCComObj;
begin
   for i:= 1 to sgSwitches.RowCount - 1 do begin
      if Assigned(sgSwitches.Objects[0,i]) then begin
         tmpComObj := TMCComObj(sgSwitches.Objects[0,i]);
         if Assigned(tmpComObj.AContext.Connection) then begin
            if tmpComObj.AContext.Connection.Connected then begin
              MissionControlServer.SendStop(tmpComObj.AContext);
            end;
         end;
      end;
   end;
end;

procedure TfrmMissionControl.btnStopServerClick(Sender: TObject);
begin
    MissionControlServer.Stop;
   if (not MissionControlServer.Active) then begin
      lblActive.Caption := 'Out of service';
      lblActive.Font.Color := clMaroon;
   end;
   btnStopServer.Enabled := False;
   btnStartServer.Enabled := true;
   //MissionControlServer.Destroy;
end;

procedure TfrmMissionControl.btnStopSimulationClick(Sender: TObject);
begin
   tmrSimulation.Enabled := false;
   if FIsSimulationStarted then begin
      FIsSimulationStarted := false;
   end;
   Flush(FFileAll);
   Flush(FFileGrafic);
   CloseFile(FFileAll);
   CloseFile(FFileGrafic);

end;

procedure TfrmMissionControl.btnSwitchOnDemandClick(Sender: TObject);
var tmpComObj : TMCComObj;
begin
   //MissionControlServer.SendCreateNewSwitch(FClientTestContext);
   if Assigned(frmMissionControl.sgClients.Objects[0,frmMissionControl.sgClients.Selection.Top]) then begin
      tmpComObj := TMCComObj(frmMissionControl.sgClients.Objects[0,frmMissionControl.sgClients.Selection.Top]);
      if tmpComObj.Active then begin
         MissionControlServer.SendCreateNewSwitch(tmpComObj.AContext);
      end;

   end;
end;

procedure TfrmMissionControl.btnSwitchQuitClick(Sender: TObject);
var tmpComObj: TMCComObj;
begin
   if Assigned(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]) then begin
      tmpComObj := TMCComObj(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]);
      if tmpComObj.Active then begin
         MissionControlServer.SendQuit(tmpComObj.AContext);
         tmpComObj.Active := false;
      end;
   end;
   frmMissionControl.DefragmentLists;
   //MissionControlServer.SendQuit(FTestContext);
end;

procedure TfrmMissionControl.btnSwitchStartClick(Sender: TObject);
begin
   MissionControlServer.SendStart(FTestContext);
end;

procedure TfrmMissionControl.btnSwitchStopClick(Sender: TObject);
var tmpComObj: TMCComObj;
begin
   if Assigned(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]) then begin
      tmpComObj := TMCComObj(frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.Selection.Top]);
      if tmpComObj.Active then begin
         MissionControlServer.SendStop(tmpComObj.AContext);
      end;
   end;
   //MissionControlServer.SendStop(FTestContext);
end;

procedure TfrmMissionControl.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if MissionControlServer.Active then begin
      MissionControlServer.Stop;
   end;
end;

procedure TfrmMissionControl.FormCreate(Sender: TObject);
begin
   btnStopServer.Enabled := false;
   MissionControlServer := TCPServer.Create;
   FIsSimulationStarted := false;
   FCurrentSession :=  0;

   // lists
   sgClients.Cells[0,0] :=  '#';
   sgClients.Cells[1,0] :=  'IP';
   sgClients.Cells[2,0] :=  'Port';
   sgClients.Cells[3,0] :=  'Activ';

   sgSwitches.Cells[0,0] :=  'ID';
   sgSwitches.Cells[1,0] :=  'IP';
   sgSwitches.Cells[2,0] :=  'Port';
   sgSwitches.Cells[3,0] :=  'Activ';

   sgSwitches.Cells[4,0] :=  'PackRcv.';
   sgSwitches.Cells[5,0] :=  'Meantime';
   sgSwitches.Cells[6,0] :=  'P/S';
   sgSwitches.Cells[7,0] :=  'VAR';
   sgSwitches.Cells[8,0] :=  'Delay';
   sgSwitches.Cells[9,0] :=  'Session';


end;


procedure TfrmMissionControl.tmrSimulationTimer(Sender: TObject);
begin
   if FCurrentSession > MAX_SIMULATION_SESSIONS then begin

      btnStopSimulation.Click;

   end;

   if FIsSimulationStarted then begin
     case intSimulationStep of
     SIMULATION_CREATE  :
        begin
           tmrSimulation.Enabled := False;
           lbSimulation.Items.Add('1. Create Switch');
           btnCreateSwitches.Click; //testen mit einem Switch
           tmrSimulation.Interval := DELAY_CREATE;
           tmrSimulation.Enabled := True;
        end;
     SIMULATION_SET     :
        begin
          tmrSimulation.Enabled := False;
          lbSimulation.Items.Add('2. Send settings');
          btnBatchDelay.Click;
          tmrSimulation.Interval := DELAY_SET;

          inc(FCurrentSession);
          edSession.Text := IntToStr(FCurrentSession);
          btnSetSession.Click;
          tmrSimulation.Enabled := True;
        end;
     SIMULATION_START   :
        begin
           tmrSimulation.Enabled := False;
           lbSimulation.Items.Add('3. Start');
           btnStartAll.Click;
           tmrSimulation.Interval := DELAY_START;
           tmrSimulation.Enabled := True;
        end;
     SIMULATION_READ    :
        begin
           tmrSimulation.Enabled := False;
           lbSimulation.Items.Add('4. Read');
           btnRefresh.Click;
           tmrSimulation.Interval := DELAY_READ;
           tmrSimulation.Enabled := True;
        end;
     SIMULATION_STOP    :
        begin
           tmrSimulation.Enabled := False;
           lbSimulation.Items.Add('5. Stop');
           btnStopAll.Click;
           tmrSimulation.Interval := DELAY_STOP;
           tmrSimulation.Interval := 10 * 1000 + FCurrentSession * 1000;
           Save();
           tmrSimulation.Enabled := True;
        end;
     end;

     intSimulationStep := (intSimulationStep + 1) mod  SIMULATION_STEPS;
   end;
end;

procedure TfrmMissionControl.DefragmentLists();
var i: Integer;
    intLastFree : Integer;
    tmpComObj : TMCComObj;
begin

   for i := 1 to sgSwitches.RowCount do begin
      if Assigned(sgSwitches.Objects[0,i]) then begin
         //tmpComObj := TMCComObj(sgSwitches.Objects[0,i]);
         if TMCComObj(sgSwitches.Objects[0,i]).Active then begin
            sgSwitches.Cells[3,i] := 'YES';
         end else begin
            sgSwitches.Cells[3,i] := 'no';
         end;
      end else begin
         sgSwitches.Cells[3,i] := 'no';
      end;
   end;
   for i := 1 to sgClients.RowCount do begin
      if Assigned(sgClients.Objects[0,i]) then begin
         //tmpComObj := TMCComObj(sgClients.Objects[0,i]);
         if TMCComObj(sgClients.Objects[0,i]).Active then begin
            sgClients.Cells[3,i] := 'YES';
         end else begin
            sgClients.Cells[3,i] := 'no';
         end;
      end else begin
         sgClients.Cells[3,i] := 'no';
      end;
   end;
   Application.ProcessMessages;

end;

procedure TfrmMissionControl.UpdateList(const paStrIp: String; const paStrPort: String; const paIntParam: Integer; var paMsPayload: TMemoryStream);
var i: Integer;
    tmpComObj : TMCComObj;
    strPayload: AnsiString;
    strPeerIp, strPeerPort : String;
begin
   strPayload :=  TStreamMethods.StreamToString(paMsPayload, paMsPayload.Size);
   for i:= 1 to sgSwitches.RowCount-1  do begin
      if Assigned(sgSwitches.Objects[0,i]) then begin
         tmpComObj := TMCComObj(sgSwitches.Objects[0,i]);
         strPeerIp := tmpComObj.AContext.Binding.PeerIP;
         strPeerPort := inttostr(tmpComObj.AContext.Binding.PeerPort);
         if ( (strPeerIp = paStrIp) and (strPeerPort = paStrPort) ) then begin
            case paIntParam of
               PACKET_RECEIVED :  sgSwitches.Cells[4,i] := strPayload;
               //PACKET_SENT     :  sgSwitches.Cells[5,i] := strPayload;
               PACKET_MEANTIME :  sgSwitches.Cells[5,i] := strPayload;
               PACKET_P_SECOND :  sgSwitches.Cells[6,i] := strPayload;
               PACKET_VAR      :  sgSwitches.Cells[7,i] := strPayload;
               USLEEP_BATCHPROCESS :  sgSwitches.Cells[8,i] := strPayload;
               SESSION_ID      :   sgSwitches.Cells[9,i] := strPayload;
               //default         :  sgSwitches.Cells[7,i] := strPayload;//Showmessage('Not Found: '+ String(strPayload));
            end;
            break;
         end;
      end;
   end;
end;

procedure TfrmMissionControl.Save();
var
   i,j: Integer;
   count     : Integer;
   sum_p_rcv : Integer;
   sum_mean  : Double;
   sum_pps   : Double;
   sum_Ca    : Double;
   sum_delay : Double;
   p_rcv     : Double;
   mean      : Double;
   pps       : Double;
   Ca        : Double;
   delay     : Double;


begin
    //Write All
    for i:= 1 to sgSwitches.RowCount - 2 do begin
       for j := 0 to sgSwitches.ColCount - 1 do begin
          Write(FFileAll, sgSwitches.Cells[j,i]+';');
       end;
       Writeln(FFileAll,'');
    end;

    count     := 0;
    sum_p_rcv := 0;
    sum_mean  := 0;
    sum_pps   := 0;
    sum_Ca    := 0;
    sum_delay := 0;

    //Write Graphics
    for i:= 1 to sgSwitches.RowCount - 2 do begin
        if ( (sgSwitches.Cells[9,i] = IntToStr(FCurrentSession))
           and ( Trim( sgSwitches.Cells[8,i] )<>'-nan' )
           and ( Trim( sgSwitches.Cells[7,i])<>'-nan' )
           and ( Trim( sgSwitches.Cells[6,i])<>'-nan' )
           and ( Trim( sgSwitches.Cells[5,i])<>'-nan' )
           and ( Trim( sgSwitches.Cells[4,i])<>'-nan' )
           ) then begin
           count     :=  count +1;
           sum_p_rcv :=  sum_p_rcv + StrToInt(sgSwitches.Cells[4,i]);
           sum_mean  :=  sum_mean  + StrToFloatc(sgSwitches.Cells[5,i]);
           sum_pps   :=  sum_pps   + StrToFloatc(sgSwitches.Cells[6,i]);
           sum_Ca    :=  sum_Ca    + (sqrt(StrToFloatc(sgSwitches.Cells[7,i]))/StrToFloatc(sgSwitches.Cells[5,i]));
           sum_delay :=  sum_delay + StrToFloatc(sgSwitches.Cells[8,i]);
        end
    end;
    if count>0 then  begin
      p_rcv :=  sum_p_rcv  /  count ;
      mean  :=  sum_mean   /  count ;
      pps   :=  sum_pps    /  count ;
      Ca    :=  sum_Ca     /  count ;
      delay :=  sum_delay  /  count ;
      Writeln(FFileGrafic, Inttostr(count)+';'+FloattoStr(p_rcv)+';'+FloattoStr(mean)+';'+FloattoStr(pps)+';'+FloattoStr(Ca)+';'+FloattoStr(delay));
    end;
end;

function TfrmMissionControl.StrToFloatc(const strString: String):Double;
var strTmp : String;
begin
   strTmp := StringReplace(strString,'.',',',[rfReplaceAll]);
   result := StrToFloat(strTmp);
end;



end.
