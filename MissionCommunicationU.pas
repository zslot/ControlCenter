unit MissionCommunicationU;

interface
uses

   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
   IdTCPServer, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, 
   {INDY10}
   IdCustomTCPServer, IdContext, IdTask,
   {ENDE INDY10}
   WinSock , NB30
   //Trotz dem IdAntiFreeze friert es, wenn ein Fehler auftritt.
   //, IdAntiFreeze
   ;

const  PASSWORD     = 'PASS';
const  COM_VERSION  =    11 ;

const //command
   LOGIN_REQUEST_		 	=    1;
   LOGIN_OK_					=    2;
   LOGIN_CLIENT_REQUEST_ = 3;
   QUIT_              =    4;

	 HELLO_							=    5;

	 GET_							  =   11;
	 SET_	     					=   12;

   CREATE_NEW_SWITCH_ =   21;

	 START_							=   60;
	 STOP_		 				  =   61;
	 RESTART_						=   62;

	 GET_FILE_ 					=   80;
	 SEND_FILE_					=   81;


const //param
	ID 				            =   1;
  SESSION_ID            =   2;

  CONTROLLER_IP	        =  11;
	CONTROLLER_PORT		    =  12;


	PACKET_RECEIVED       =  51;
	PACKET_SENT			      =  52;
	PACKET_MEANTIME       =  53;
  PACKET_P_SECOND       =  54;
  PACKET_VAR            =  55;

  USLEEP_BATCHPROCESS   =  61;


const //error
	NO_ERROR_OK           =   100;

	COMMAND_NOT_RECOGNIZED =  104;
	COMMAND_NOT_READY      =  105;

	PARAMETER_NOT_RECOGNIZED = 114;
	PARAMETER_WRONG          = 115;


type TCriticalQueryEvent = procedure(Sender: TObject; var paBoAllowed: Boolean) of object;

type TSpecialFunction = procedure (Sender: Tobject; AContext: TIdContext; var uintCommand: word; var  uintError: Word; var intPayloadLength: cardinal; var msPayload: TMemoryStream) of object;    //

type TMCComObj = class
private
public
   IP       : String;
   Port     : Integer;
   AContext : TIdContext;
   Active   : Boolean;
   ID       : Integer;
end;


// TCP Server
type TCPServer = class(TIdTCPServer)

   private
      FOnShutdownQuery      :  TCriticalQueryEvent;
      FOnRebootQuery        :  TCriticalQueryEvent;
      FOnLogoffQuery        :  TCriticalQueryEvent;
      FOnPoweroffQuery        :  TCriticalQueryEvent;
      FOnProgramRestartQuery:  TCriticalQueryEvent;

      FOnCheckShutdownQuery      :  TCriticalQueryEvent;
      FOnCheckRebootQuery        :  TCriticalQueryEvent;
      FOnCheckProgramRestartQuery:  TCriticalQueryEvent;
      FOnCheckLogoffQuery        :  TCriticalQueryEvent;
      FOnCheckPoweroffQuery      :  TCriticalQueryEvent;

      FOnSpecialFunction             : TSpecialFunction;
      FOnHeartbeatIMAlliveMessage    : TSpecialFunction;
      FOnHeartbetProgramStateMessage : TSpecialFunction;

      procedure CommandPicker(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
      procedure Wellcome(AContext: TIdContext); //Cypher, in the future
      procedure GetCommand(AContext: TIdContext);

      //Commands
      procedure LoginRequest__(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
      procedure LoginClientRequest_(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
      procedure Hello__       (AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
      procedure Get__         (AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
      procedure Set__         (AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
      procedure Start__       (AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
      procedure Stop__        (AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
      procedure Restart__     (AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
      procedure GetFile__     (AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
      procedure SendFile__    (AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
      procedure Quit__        (AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);

      procedure ReturnedPacketReceived(AContext: TIdContext; var uintError: SmallInt; msPayload: TMemoryStream);
      procedure ReturnedPacketSent(AContext: TIdContext; var uintError: SmallInt; msPayload: TMemoryStream);
      procedure ReturnedMeantime(AContext: TIdContext; var uintError: SmallInt; msPayload: TMemoryStream);
      procedure ReturnedPPSecond(AContext: TIdContext; var uintError: SmallInt; msPayload: TMemoryStream);

   public
      Constructor Create; overload;

      function CommandChecker(intCommand: integer): boolean;
      procedure SendCommand(AContext: TIdContext ;  var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
      procedure SendStream(AContext: TIdContext ;  var msPayload : TMemoryStream);

      procedure Start(Port:integer);
      procedure Stop();
      procedure SendHello(AContext: TIdContext);
      procedure SendCreateNewSwitch(AContext: TIdContext);
      procedure SendStop(AContext: TIdContext);
      procedure SendStart(AContext: TIdContext);
      procedure SendQuit(AContext: TIdContext);
      procedure SendClientStop(AContext: TIdContext; const paIntSwitchNr: Integer);
      procedure SendClientQuit(AContext: TIdContext);
      function SendSetId(AContext: TIdContext): Integer;
      function SendGetReceived(AContext: TIdContext): Int64;
      function SendGetMeantime(AContext: TIdContext): Int64;
      function SendGetPS(AContext: TIdContext): Int64;

      procedure SendSet(AContext: TIdContext; const paIntParam: Smallint; const paStrValue: String);
      procedure SendGet(AContext: TIdContext; const paIntParam: Smallint);

      property OnShutdownQuery : TCriticalQueryEvent read FOnShutdownQuery  write FOnShutdownQuery;
      property OnRebootQuery  : TCriticalQueryEvent read FOnRebootQuery   write FOnRebootQuery;
      property OnLogoffQuery  : TCriticalQueryEvent read FOnLogoffQuery   write FOnLogoffQuery;
      property OnProgramRestartQuery: TCriticalQueryEvent read FOnProgramRestartQuery write FOnProgramRestartQuery;

      property OnCheckShutdownQuery : TCriticalQueryEvent read FOnCheckShutdownQuery  write FOnCheckShutdownQuery;
      property OnCheckRebootQuery  : TCriticalQueryEvent read FOnCheckRebootQuery   write FOnCheckRebootQuery;
      property OnCheckLogoffQuery  : TCriticalQueryEvent read FOnCheckLogoffQuery   write FOnCheckLogoffQuery;
      property OnCheckProgramRestartQuery: TCriticalQueryEvent read FOnCheckProgramRestartQuery write FOnCheckProgramRestartQuery;
      property OnCheckPoweroffQuery: TCriticalQueryEvent read FOnCheckPoweroffQuery write FOnCheckPoweroffQuery;

      property OnSpecialFunction :  TSpecialFunction read FOnSpecialFunction write FOnSpecialFunction;

   end;



type TStreamMethods = class

   public
      class procedure StringToStream(const paStrString : AnsiString ; var PaStream : TMemoryStream; const paBoClearStream : Boolean = true);  Overload;
      class function  StreamToString(var paStream : TMemoryStream ;  const paIntLength : cardinal): AnsiString;
      class procedure BooleanToStream(const paBoBoolean : Boolean; var paStream : TMemoryStream);
      class function  StreamToBoolean(var paStream : TMemoryStream): Boolean;

      class function CommandToString(const paIntCommand: Integer): AnsiString;
      class function ParamToString(const paIntCommand: Integer): AnsiString;
      class function ErrorToString(const paIntCommand: Integer): AnsiString;
   end;



//#############################################################################server############################################

var MissionControlServer : TCPServer;
    FGlobalID : Integer;

implementation

Uses MControl;

{------------------------------------------------------------------------------------------------------------
 Prozedur:     TCPServer.Create
 Autor:        zsolt
 Beschreibung: TCPServer Constructor.
 Argumente:
 Rückgabewert: None
------------------------------------------------------------------------------------------------------------}
constructor TCPServer.Create();
begin
   inherited Create();
   Self.OnExecute := GetCommand;
   Self.OnConnect := Wellcome;
end;


{------------------------------------------------------------------------------------------------------------
 Prozedur:     TCPServer.Start
 Autor:        zsolt
 Beschreibung: Startet den Server.
 Argumente:    Port:integer
 Rückgabewert: None
------------------------------------------------------------------------------------------------------------}
procedure TCPServer.Start(Port:integer);
begin
   try
      self.defaultport := Port;
      self.Active := true;
   except
      On E: Exception do begin
         E.Message := 'TCPServer.Start: '+ E.Message;
         Raise;
      end;
   end;
end;


{------------------------------------------------------------------------------------------------------------
 Prozedur:     TCPServer.Stop
 Autor:        zsolt
 Beschreibung: Stoppt den Server.
 Argumente:
 Rückgabewert: None
------------------------------------------------------------------------------------------------------------}
procedure TCPServer.Stop();
begin
   try
      self.active := false;
   except
      On E: Exception do begin
         E.Message := 'TCPServer.Stop: ' + E.Message;
         Raise;
      end;
   end;
   self.Destroy;

end;

{------------------------------------------------------------------------------------------------------------
 Prozedur:     TCPServer.GetCommand
 Autor:        zsolt
 Beschreibung: Command an Server.
 Argumente:    AContext: TIdContext
 Rückgabewert: None
------------------------------------------------------------------------------------------------------------}
procedure TCPServer.GetCommand(AContext: TIdContext);
var
   uintVersion : SmallInt;
   uintCommand : SmallInt;
   uintParam   : SmallInt;
   uintError   : SmallInt;
   intPayloadLength : LongInt;
   msPayload : TMemoryStream;
begin
   //showmessage(inttostr(AContext.Binding.PeerPort));
   //FTestContext := AContext;
   msPayload :=  TMemoryStream.Create;
   frmMissionControl.lbInfo.Items.Add('GET COMMAND:');
   try
      //read version
      uintVersion := AContext.Connection.IOHandler.ReadSmallInt;
      frmMissionControl.lbInfo.Items.Add('-GET-Ver:'+ inttostr(uintVersion));
      //read command
      uintCommand := AContext.Connection.IOHandler.ReadSmallInt;
      frmMissionControl.lbInfo.Items.Add('-GET-Command:'+ TStreamMethods.CommandToString(uintCommand));
      //check command
      if (CommandChecker(uintCommand)) then begin
         frmMissionControl.lbInfo.Items.Add('-GET-CommandCeck OK');
         //read param
         uintParam   := AContext.Connection.IOHandler.ReadSmallInt;
         frmMissionControl.lbInfo.Items.Add('-GET-Param:'+ inttostr(uintParam));
         //read error
         uintError   := AContext.Connection.IOHandler.ReadSmallInt;
         frmMissionControl.lbInfo.Items.Add('-GET-Error:'+ inttostr(uintError));
         //read payload length
         intPayloadLength := AContext.Connection.IOHandler.ReadLongInt;
         frmMissionControl.lbInfo.Items.Add('-GET-PayloadLength:'+ inttostr(intPayloadLength));
         //read payload
         msPayload.Position := 0;
         AContext.Connection.IOHandler.ReadStream(msPayload,intPayloadLength);
         msPayload.Position := 0;
         //send to command
         CommandPicker(AContext, uintVersion, uintCommand, uintParam, uintError, intPayloadLength, msPayload);
      end else begin
         frmMissionControl.lbInfo.Items.Add('-GET-CommandCeck FAILED');
         AContext.Connection.Disconnect;
      end;
   except
      On E: Exception do begin
         E.Message := 'TCPServer.GetCommand: '+ E.Message;
         frmMissionControl.lbInfo.Items.Add(E.Message);
         Raise;
      end;
   end;

   msPayload.Free;
end;




{------------------------------------------------------------------------------------------------------------
 Prozedur:     TCPServer.CommandPicker
 Autor:        zsolt
 Beschreibung: Command forwarding.
 Argumente:    AContext: TIdContext; var uintCommand, uintError: Word; var intPayload: cardinal; var msPayload: TMemoryStream
 Rückgabewert: None
------------------------------------------------------------------------------------------------------------}
procedure TCPServer.CommandPicker(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
begin
   case uintCommand of
     LOGIN_REQUEST_           : LoginRequest__(AContext, uintVersion, uintCommand, uintParam, uintError, intPayloadLength, msPayload);
     LOGIN_CLIENT_REQUEST_    : LoginClientRequest_(AContext, uintVersion, uintCommand, uintParam, uintError, intPayloadLength, msPayload);
     QUIT_                    : Quit__        (AContext, uintVersion, uintCommand, uintParam, uintError, intPayloadLength, msPayload);
     HELLO_                   : Hello__       (AContext, uintVersion, uintCommand, uintParam, uintError, intPayloadLength, msPayload);
     GET_                     : Get__         (AContext, uintVersion, uintCommand, uintParam, uintError, intPayloadLength, msPayload);
     SET_                     : Set__         (AContext, uintVersion, uintCommand, uintParam, uintError, intPayloadLength, msPayload);
     START_                   : Start__       (AContext, uintVersion, uintCommand, uintParam, uintError, intPayloadLength, msPayload);
     STOP_                    : Stop__        (AContext, uintVersion, uintCommand, uintParam, uintError, intPayloadLength, msPayload);
     RESTART_                 : Restart__     (AContext, uintVersion, uintCommand, uintParam, uintError, intPayloadLength, msPayload);
     GET_FILE_                : GetFile__     (AContext, uintVersion, uintCommand, uintParam, uintError, intPayloadLength, msPayload);
     SEND_FILE_		            : SendFile__    (AContext, uintVersion, uintCommand, uintParam, uintError, intPayloadLength, msPayload);
   else
      //SendCommandNotRecognized(AContext);
   end;
end;

procedure TCPServer.Wellcome(AContext: TIdContext);
begin
   try
      AContext.Connection.IOHandler.Writeln('SERVERHELLO');
   except
      On E: Exception do begin
         E.Message := 'TCPServer.Wellcome: ' + E.Message;
         Raise;
      end;
   end;
end;

{------------------------------------------------------------------------------------------------------------
 Prozedur:     TCPServer.CommandChecker
 Autor:        zsolt
 Beschreibung: Prüft ob der Command existiert.
 Argumente:    intCommand: integer
 Rückgabewert: boolean
------------------------------------------------------------------------------------------------------------}
function TCPServer.CommandChecker(intCommand: integer): boolean;
begin
   case intCommand of
      LOGIN_REQUEST_: result:=true;
      LOGIN_CLIENT_REQUEST_ : result:=true;
      QUIT_         : result:=true;
      HELLO_        : result:=true;
      GET_          : result:=true;
      SET_          : result:=true;
      START_        : result:=true;
      STOP_         : result:=true;
      RESTART_      : result:=true;
      GET_FILE_     : result:=true;
      SEND_FILE_	  : result:=true;
   else
      result := False;
   end;
end;



{------------------------------------------------------------------------------------------------------------
 Prozedur:     TCPServer.SendCommand
 Autor:        zsolt
 Beschreibung: Sendet ein Command mit Daten
 Argumente:    AContext: TIdContext; var uintCommand: word; var uintError: Word; var intPayloadLength: cardinal; var msPayload: TMemoryStream
 Rückgabewert: None
------------------------------------------------------------------------------------------------------------}
procedure TCPServer.SendCommand(AContext: TIdContext ; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
var
   intVersion: SmallInt;
   msMessageHeader: TMemoryStream;
   intSize : Integer;
begin
   try
      //write version
      {intVersion := COM_VERSION;
      AContext.Connection.IOHandler.Write(intVersion);
      //  var intPayloadLength: LongInt ; var msPayload : TMemoryStream
      //write command
      AContext.Connection.IOHandler.Write(uintCommand);
      //write param
      AContext.Connection.IOHandler.Write(uintParam);
      //write error
      AContext.Connection.IOHandler.Write(uintError);
      //write payload length
      AContext.Connection.IOHandler.Write(intPayloadLength);;
      //write payload
      if intPayloadLength > 0 then begin
         msPayload.Position := 0;
         AContext.Connection.IOHandler.Write(msPayload,intPayloadLength);
         msPayload.Position := 0;
      end;
      }
      msMessageHeader := TMemoryStream.Create;
      try
         msMessageHeader.Position := 0;
         intVersion := COM_VERSION;
         msMessageHeader.Write(intVersion,sizeof(intVersion));
         msMessageHeader.Write(uintCommand,SizeOf(uintCommand));
         msMessageHeader.Write(uintParam,SizeOf(uintParam));
         msMessageHeader.Write(uintError,SizeOf(uintError));
         msMessageHeader.Write(intPayloadLength,SizeOf(intPayloadLength));
         msMessageHeader.Position := 0;
         AContext.Connection.IOHandler.Write(msMessageHeader, msMessageHeader.Size);
         if intPayloadLength > 0 then begin
            msPayload.Position := 0;
            AContext.Connection.IOHandler.Write(msPayload,intPayloadLength);
            msPayload.Position := 0;
         end;
      finally
         msMessageHeader.Destroy;
      end;
   except
      On E: Exception do begin
         E.Message := 'TCPServer.SendCommand: ' + E.Message;
         Raise;
      end;
   end;
end;




procedure TCPServer.SendStream(AContext: TIdContext ;  var msPayload : TMemoryStream);
begin
   msPayload.Position := 0;
   try
      AContext.Connection.IOHandler.Write(msPayload,msPayload.Size);
   except
      on e: Exception do begin
         Showmessage('');

      end;
   end;
end;


{------------------------------------------------------------------------------------------------------------
 Prozedur:     TCPServer.ClientQuit
 Autor:        zsolt
 Beschreibung: Der Klient sendet ein Quit Command.
 Argumente:    AContext: TIdContext; var uintCommand: word; var uintError: Word; var intPayloadLength: cardinal; var msPayload: TMemoryStream
 Rückgabewert: None
------------------------------------------------------------------------------------------------------------}
procedure TCPServer.Quit__(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
begin
   AContext.Connection.Disconnect;
end;



procedure TCPServer.LoginRequest__(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
var
   strPass: AnsiString;
   intLength : Integer;
   intResponseCommand : SmallInt;
   msResponsePayload: TMemoryStream;
   strPassword: PChar;
   chrNull : Char;
   tmpConObj : TMCComObj;
   intID : Integer;
   strIP, strPort : String;
begin
   FTestContext := AContext;        //erreichbarkeit über den Knopf
   frmMissionControl.lbInfo.Items.Add('-SW-LOGIN  REQUEST');
   frmMissionControl.lbInfo.Items.Add('-SW-Version:'+ inttostr(uintVersion));
   frmMissionControl.lbInfo.Items.Add('-SW-Command:'+ TStreamMethods.CommandToString(uintCommand));
   frmMissionControl.lbInfo.Items.Add('-SW-Param:'+  TStreamMethods.ParamToString(uintParam));
   frmMissionControl.lbInfo.Items.Add('-SW-Error:'+  TStreamMethods.ErrorToString(uintError));
   strPass := TStreamMethods.StreamToString(msPayload,intPayloadLength);
   frmMissionControl.lbInfo.Items.Add('-SW-Payload:'+strPass);
   if ((uintVersion = COM_VERSION) and (uintError = NO_ERROR_OK) and (strPass = PASSWORD)) then begin
      frmMissionControl.lbInfo.Items.Add('-SW-Authentication OK!');
      intLength := 0;
      intResponseCommand := LOGIN_OK_;
      msResponsePayload := TMemoryStream.Create;
      strPassword := StrAlloc(sizeof(PASSWORD)+1);
      try
         TStreamMethods.StringToStream(PASSWORD,msResponsePayload);
         TStreamMethods.StringToStream(#0,msResponsePayload,false); // '\0'-ended, don't clear
         //StrCopy(strPassword,PASSWORD);
         //msResponsePayload.Clear;
         //msResponsePayload.Write(strPassword, Sizeof(strPassword));
         //chrNull := #0;
         //msResponsePayload.Write(chrNull, 1);
         //msResponsePayload.Position := 0;
         intLength := msResponsePayload.Size;
         SendCommand(AContext,intResponseCommand,uintParam,uintError,intLength,msResponsePayload);

         //SetID command, da der Switch eine Globalen ID kriegt
         intId := SendSetId(AContext);

         strIP  := frmMissionControl.edControllerIp.Text;
         strPort:= frmMissionControl.edControllerPort.Text;

         //SetController IP,Port
         SendSet(AContext,CONTROLLER_IP,strIP);
         SendSet(AContext,CONTROLLER_PORT,strPort);


         //Insert into list
         tmpConObj := TMCComObj.Create;
         tmpConObj.IP := AContext.Connection.Socket.Binding.PeerIP;
         tmpConObj.Port := AContext.Connection.Socket.Binding.PeerPort;
         tmpConObj.AContext := AContext;
         tmpConObj.Active := true;
         frmMissionControl.sgSwitches.Objects[0,frmMissionControl.sgSwitches.RowCount-1] := tmpConObj;
         frmMissionControl.sgSwitches.Cells[0,frmMissionControl.sgSwitches.RowCount-1] := IntToStr(intID);//IntToStr(frmMissionControl.sgSwitches.RowCount-1);
         frmMissionControl.sgSwitches.Cells[1,frmMissionControl.sgSwitches.RowCount-1] := tmpConObj.IP;
         frmMissionControl.sgSwitches.Cells[2,frmMissionControl.sgSwitches.RowCount-1] := IntToStr(tmpConObj.Port);
         frmMissionControl.sgSwitches.RowCount := frmMissionControl.sgSwitches.RowCount + 1;

         //List defragmentation
         frmMissionControl.DefragmentLists;
      finally
         msResponsePayload.Destroy;
         StrDispose(strPassword);
      end;
   end;
end;

procedure TCPServer.LoginClientRequest_(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
var
   strPass: AnsiString;
   intLength : Integer;
   intResponseCommand : SmallInt;
   msResponsePayload: TMemoryStream;
   strPassword: PChar;
   chrNull : Char;
   tmpConObj : TMCComObj;
begin
   FClientTestContext := AContext;        //erreichbarkeit über den Knopf
   frmMissionControl.lbInfo.Items.Add('-CLI-LOGIN CLIENT REQUEST');
   frmMissionControl.lbInfo.Items.Add('-CLI-Version:'+ inttostr(uintVersion));
   frmMissionControl.lbInfo.Items.Add('-CLI-Command:'+ TStreamMethods.CommandToString(uintCommand));
   frmMissionControl.lbInfo.Items.Add('-CLI-Param:'+  TStreamMethods.ParamToString(uintParam));
   frmMissionControl.lbInfo.Items.Add('-CLI-Error:'+  TStreamMethods.ErrorToString(uintError));
   strPass := TStreamMethods.StreamToString(msPayload,intPayloadLength);
   frmMissionControl.lbInfo.Items.Add('-CLI-Payload:'+strPass);
   if ((uintVersion = COM_VERSION) and (uintError = NO_ERROR_OK) and (strPass = PASSWORD)) then begin
      frmMissionControl.lbInfo.Items.Add('-CLI-Authentication Client OK!');
      intLength := 0;
      intResponseCommand := LOGIN_OK_;
      msResponsePayload := TMemoryStream.Create;
      strPassword := StrAlloc(sizeof(PASSWORD)+1);
      try
         TStreamMethods.StringToStream(PASSWORD,msResponsePayload);
         TStreamMethods.StringToStream(#0,msResponsePayload,false); // '\0'-ended, don't clear
         //StrCopy(strPassword,PASSWORD);
         //msResponsePayload.Clear;
         //msResponsePayload.Write(strPassword, Sizeof(strPassword));
         //chrNull := #0;
         //msResponsePayload.Write(chrNull, 1);
         //msResponsePayload.Position := 0;
         intLength := msResponsePayload.Size;
         SendCommand(AContext,intResponseCommand,uintParam,uintError,intLength,msResponsePayload);

         //Insert into list
         tmpConObj := TMCComObj.Create;
         tmpConObj.IP := AContext.Connection.Socket.Binding.PeerIP;
         tmpConObj.Port := AContext.Connection.Socket.Binding.PeerPort;
         tmpConObj.AContext := AContext;
         tmpConObj.Active := true;
         frmMissionControl.sgClients.Objects[0,frmMissionControl.sgClients.RowCount-1] := tmpConObj;
         frmMissionControl.sgClients.Cells[0,frmMissionControl.sgClients.RowCount-1] := IntToStr(frmMissionControl.sgClients.RowCount-1);
         frmMissionControl.sgClients.Cells[1,frmMissionControl.sgClients.RowCount-1] := tmpConObj.IP;
         frmMissionControl.sgClients.Cells[2,frmMissionControl.sgClients.RowCount-1] := IntToStr(tmpConObj.Port);
         frmMissionControl.sgClients.RowCount := frmMissionControl.sgClients.RowCount + 1;

         //List defragmentation
         frmMissionControl.DefragmentLists;
      finally
         msResponsePayload.Destroy;
         StrDispose(strPassword);
      end;
   end;
end;


procedure TCPServer.Hello__(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
begin


end;



procedure TCPServer.Get__(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
begin
   case uintParam of
      //PACKET_RECEIVED  :  ReturnedPacketReceived(AContext, uintError, msPayload);
	    //PACKET_SENT			 :  ReturnedPacketSent(AContext, uintError, msPayload);
	    //PACKET_MEANTIME  :  ReturnedMeantime(AContext, uintError, msPayload);
      //PACKET_P_SECOND  :  ReturnedPPSecond(AContext, uintError, msPayload);
      PACKET_RECEIVED  : frmMissionControl.UpdateList(AContext.Binding.PeerIP, IntToStr(AContext.Binding.PeerPort),PACKET_RECEIVED, msPayload);
      PACKET_SENT			 : frmMissionControl.UpdateList(AContext.Binding.PeerIP, IntToStr(AContext.Binding.PeerPort),PACKET_SENT, msPayload);
      PACKET_MEANTIME  : frmMissionControl.UpdateList(AContext.Binding.PeerIP, IntToStr(AContext.Binding.PeerPort),PACKET_MEANTIME, msPayload);
      PACKET_P_SECOND  : frmMissionControl.UpdateList(AContext.Binding.PeerIP, IntToStr(AContext.Binding.PeerPort),PACKET_P_SECOND, msPayload);
      PACKET_VAR       : frmMissionControl.UpdateList(AContext.Binding.PeerIP, IntToStr(AContext.Binding.PeerPort),PACKET_VAR, msPayload);
      USLEEP_BATCHPROCESS : frmMissionControl.UpdateList(AContext.Binding.PeerIP, IntToStr(AContext.Binding.PeerPort),USLEEP_BATCHPROCESS, msPayload);
      SESSION_ID       : frmMissionControl.UpdateList(AContext.Binding.PeerIP, IntToStr(AContext.Binding.PeerPort),SESSION_ID, msPayload);


   end;
end;

procedure TCPServer.Set__(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);
begin

end;

procedure TCPServer.Start__(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);

begin

end;

procedure TCPServer.Stop__(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);

begin

end;

procedure TCPServer.Restart__(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);

begin

end;

procedure TCPServer.GetFile__(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);

begin

end;
procedure TCPServer.SendFile__(AContext: TIdContext ; var uintVersion: SmallInt; var uintCommand: SmallInt; var uintParam: SmallInt; var uintError: SmallInt; var intPayloadLength: LongInt ; var msPayload : TMemoryStream);

begin

end;


procedure TCPServer.ReturnedPacketReceived(AContext: TIdContext; var uintError: SmallInt; msPayload: TMemoryStream);
var
   strPayload : String;
begin
   strPayload := TStreamMethods.StreamToString(msPayload,msPayload.Size);
   //showmessage('Payload: '+strPayload);
end;

procedure TCPServer.ReturnedPacketSent(AContext: TIdContext; var uintError: SmallInt; msPayload: TMemoryStream);
var
   strPayload : String;
begin
   strPayload := TStreamMethods.StreamToString(msPayload,msPayload.Size);
   //showmessage('Payload: '+strPayload);
end;

procedure TCPServer.ReturnedMeantime(AContext: TIdContext; var uintError: SmallInt; msPayload: TMemoryStream);
var
   strPayload : String;
begin
  strPayload := TStreamMethods.StreamToString(msPayload,msPayload.Size);
  //showmessage('Payload: '+strPayload);
end;

procedure TCPServer.ReturnedPPSecond(AContext: TIdContext; var uintError: SmallInt; msPayload: TMemoryStream);
var
   strPayload : String;
begin
   strPayload := TStreamMethods.StreamToString(msPayload,msPayload.Size);
   //showmessage('Payload: '+strPayload);
end;


{=================================== S E N D ====================================================}

procedure TCPServer.SendHello(AContext: TIdContext);
var
   intVersion: SmallInt;
   intCommand: SmallInt;
   intParam  : SmallInt;
   intError  : SmallInt;
   intLength : Integer;
   msPayload : TMemoryStream;

begin
    msPayload := TMemoryStream.Create;
    try
       intCommand:= HELLO_;
       intParam  := ID;
       intError  := NO_ERROR_OK;
       intLength := 0;
       SendCommand(AContext,intCommand,intParam,intError,intLength,msPayload);
     finally
       msPayload.Destroy;
    end;
end;

procedure TCPServer.SendCreateNewSwitch(AContext: TIdContext);
var
   intVersion: SmallInt;
   intCommand: SmallInt;
   intParam  : SmallInt;
   intError  : SmallInt;
   intLength : Integer;
   msPayload : TMemoryStream;

begin
    msPayload := TMemoryStream.Create;
    try
       intCommand:= CREATE_NEW_SWITCH_;
       intParam  := 1;
       intError  := NO_ERROR_OK;
       intLength := 0;
       SendCommand(AContext,intCommand,intParam,intError,intLength,msPayload);
     finally
       msPayload.Destroy;
    end;
end;


procedure TCPServer.SendClientStop(AContext: TIdContext; const paIntSwitchNr: Integer);
var
   intVersion: SmallInt;
   intCommand: SmallInt;
   intParam  : SmallInt;
   intError  : SmallInt;
   intLength : Integer;
   msPayload : TMemoryStream;

begin
    msPayload := TMemoryStream.Create;
    try
       intCommand:= STOP_;
       intParam  := 1;
       intError  := NO_ERROR_OK;
       intLength := 0;
       SendCommand(AContext,intCommand,intParam,intError,intLength,msPayload);
     finally
       msPayload.Destroy;
    end;
end;

procedure TCPServer.SendClientQuit(AContext: TIdContext);
var
   intVersion: SmallInt;
   intCommand: SmallInt;
   intParam  : SmallInt;
   intError  : SmallInt;
   intLength : Integer;
   msPayload : TMemoryStream;

begin
    msPayload := TMemoryStream.Create;
    try
       intCommand:= QUIT_;
       intParam  := 1;
       intError  := NO_ERROR_OK;
       intLength := 0;
       SendCommand(AContext,intCommand,intParam,intError,intLength,msPayload);
     finally
       msPayload.Destroy;
    end;
end;

function TCPServer.SendSetId(AContext: TIdContext): Integer;
var
   intVersion: SmallInt;
   intCommand: SmallInt;
   intParam  : SmallInt;
   intError  : SmallInt;
   intLength : Integer;
   msPayload : TMemoryStream;

begin
    result := 0;
    msPayload := TMemoryStream.Create;
    try
       intCommand:= SET_;
       intParam  := ID;
       intError  := NO_ERROR_OK;
       intLength := 0;
       inc(FGlobalID);
       result := FGlobalID;
       TStreamMethods.StringToStream(intToStr(FGlobalID),msPayload);
       TStreamMethods.StringToStream(#0,msPayload,false); // '\0'-ended, don't clear
       intLength := msPayload.Size;
       //SendCommand(AContext,intResponseCommand,uintParam,uintError,intLength,msResponsePayload);
       SendCommand(AContext,intCommand,intParam,intError,intLength,msPayload);

     finally
       msPayload.Destroy;
    end;
end;

function TCPServer.SendGetReceived(AContext: TIdContext): Int64;
var
   intVersion: SmallInt;
   intCommand: SmallInt;
   intParam  : SmallInt;
   intError  : SmallInt;
   intLength : Integer;
   msPayload : TMemoryStream;

begin
    result := 0;
    msPayload := TMemoryStream.Create;
    try
       intCommand:= GET_;
       intParam  := PACKET_RECEIVED;
       intError  := NO_ERROR_OK;
       intLength := 0;
       SendCommand(AContext,intCommand,intParam,intError,intLength,msPayload);
       //Receive answer

     finally
       msPayload.Destroy;
    end;
end;

function TCPServer.SendGetPS(AContext: TIdContext): Int64;
var
   intVersion: SmallInt;
   intCommand: SmallInt;
   intParam  : SmallInt;
   intError  : SmallInt;
   intLength : Integer;
   msPayload : TMemoryStream;

begin
    result := 0;
    msPayload := TMemoryStream.Create;
    try
       intCommand:= GET_;
       intParam  := PACKET_P_SECOND;
       intError  := NO_ERROR_OK;
       intLength := 0;
       SendCommand(AContext,intCommand,intParam,intError,intLength,msPayload);
       //Receive answer

     finally
       msPayload.Destroy;
    end;
end;

function TCPServer.SendGetMeantime(AContext: TIdContext): Int64;
var
   intVersion: SmallInt;
   intCommand: SmallInt;
   intParam  : SmallInt;
   intError  : SmallInt;
   intLength : Integer;
   msPayload : TMemoryStream;

begin
    result := 0;
    msPayload := TMemoryStream.Create;
    try
       intCommand:= GET_;
       intParam  := PACKET_MEANTIME;
       intError  := NO_ERROR_OK;
       intLength := 0;
       SendCommand(AContext,intCommand,intParam,intError,intLength,msPayload);
       //Receive answer

     finally
       msPayload.Destroy;
    end;
end;

procedure TCPServer.SendSet(AContext: TIdContext; const paIntParam: Smallint; const paStrValue: String);
var
   intVersion: SmallInt;
   intCommand: SmallInt;
   intError  : SmallInt;
   intParam  : SmallInt;
   intLength : Integer;
   msPayload : TMemoryStream;

begin
    msPayload := TMemoryStream.Create;
    try
       intCommand:= SET_;
       intError  := NO_ERROR_OK;
       intParam  := paIntParam;
       TStreamMethods.StringToStream(paStrValue,msPayload);
       TStreamMethods.StringToStream(#0,msPayload,false); // '\0'-ended, don't clear
       intLength := msPayload.Size;

       SendCommand(AContext,intCommand,intParam,intError,intLength,msPayload);
     finally
       msPayload.Destroy;
    end;
end;


procedure TCPServer.SendGet(AContext: TIdContext; const paIntParam: Smallint);
var
   intVersion: SmallInt;
   intCommand: SmallInt;
   intError  : SmallInt;
   intParam  : SmallInt;
   intLength : Integer;
   msPayload : TMemoryStream;

begin
    msPayload := TMemoryStream.Create;
    try
       intCommand:= GET_;
       intParam  := paIntParam;
       intError  := NO_ERROR_OK;
       intLength := 0;
       SendCommand(AContext,intCommand,intParam,intError,intLength,msPayload);
       //showmessage('Sned to PeerPort: '+ IntToStr(Acontext.Binding.PeerPort));
     finally
       msPayload.Destroy;
    end;
end;


procedure TCPServer.SendStop(AContext: TIdContext);
var
   intVersion: SmallInt;
   intCommand: SmallInt;
   intParam  : SmallInt;
   intError  : SmallInt;
   intLength : Integer;
   msPayload : TMemoryStream;
begin
    msPayload := TMemoryStream.Create;
    try
       intCommand:= STOP_;
       intParam  := 1;
       intError  := NO_ERROR_OK;
       intLength := 0;
       SendCommand(AContext,intCommand,intParam,intError,intLength,msPayload);
     finally
       msPayload.Destroy;
    end;
end;

procedure TCPServer.SendStart(AContext: TIdContext);
var
   intVersion: SmallInt;
   intCommand: SmallInt;
   intParam  : SmallInt;
   intError  : SmallInt;
   intLength : Integer;
   msPayload : TMemoryStream;
begin
    msPayload := TMemoryStream.Create;
    try
       intCommand:= START_;
       intParam  := 1;
       intError  := NO_ERROR_OK;
       intLength := 0;
       SendCommand(AContext,intCommand,intParam,intError,intLength,msPayload);
     finally
       msPayload.Destroy;
    end;
end;

procedure  TCPServer.SendQuit(AContext: TIdContext);
var
   intVersion: SmallInt;
   intCommand: SmallInt;
   intParam  : SmallInt;
   intError  : SmallInt;
   intLength : Integer;
   msPayload : TMemoryStream;
begin
    msPayload := TMemoryStream.Create;
    try
       intCommand:= QUIT_;
       intParam  := 1;
       intError  := NO_ERROR_OK;
       intLength := 0;
       SendCommand(AContext,intCommand,intParam,intError,intLength,msPayload);
     finally
       msPayload.Destroy;
    end;
end;



{ StreamMethods }
//###############################################################################################################################



{------------------------------------------------------------------------------------------------------------
 Prozedur:     TStreamMethods.BooleanToStream
 Autor:        zsolt
 Beschreibung: Schreibt der Boolean auf Stream
 Argumente:    var paBoBoolean: Boolean; var paStream: TMemoryStream
 Rückgabewert: None
------------------------------------------------------------------------------------------------------------}
class procedure TStreamMethods.BooleanToStream(const paBoBoolean: Boolean; var paStream: TMemoryStream);
var
   uintByteTrue : byte;
   uintByteFalse : byte;
begin
    uintByteTrue := 255;
    uintByteFalse := 0;
    if (paBoBoolean) then begin
       paStream.WriteBuffer(uintByteTrue,1);
    end else begin
       paStream.WriteBuffer(uintByteFalse,1);
    end;
end;

{------------------------------------------------------------------------------------------------------------
 Prozedur:     TStreamMethods.StreamToBoolean
 Autor:        zsolt
 Beschreibung: Liest ein byte form Stream und erstell ein Boolean.
 Argumente:    var paStream, paStream: TMemoryStream
 Rückgabewert: None
------------------------------------------------------------------------------------------------------------}
class function TStreamMethods.StreamToBoolean(var paStream: TMemoryStream): Boolean;
var
   uintByteTrue : byte;
   uintByteFalse : byte;
   uintReadFrom : byte;
   e : Exception;
begin
    uintByteTrue := 255;
    uintByteFalse := 0;
    paStream.ReadBuffer(uintReadFrom, 1);
    if (uintReadFrom= uintByteTrue) then begin
       result := true;
    end else if (uintReadFrom= uintByteFalse) then begin
       result := false;
    end else begin
       Raise Exception.Create('StreamToBoolean: This is not a Boolean!');
    end;

end;

{------------------------------------------------------------------------------------------------------------
 Prozedur:     TStreamMethods.StreamToString
 Autor:        zsolt
 Beschreibung: Erstellt ein String von Stream.
 Argumente:    var paStream: TMemoryStream; var paStrString: String; var paIntLength: cardinal
 Rückgabewert: None
------------------------------------------------------------------------------------------------------------}
class function TStreamMethods.StreamToString(var paStream: TMemoryStream; const paIntLength: cardinal):AnsiString;
var
   pcTmp     : PChar;
   strReturn : AnsiString;
   i: Integer;
begin
   setlength(strReturn,paIntLength);
   paStream.Position := 0;
   paStream.ReadBuffer(strReturn[1],paIntLength);
   for i := 1 to length(strReturn) do begin
      if strReturn[i]=#0 then begin
         strReturn[i] := ' ';
      end;
      strReturn := Trim(strReturn);
   end;
   result := strReturn;

   //pcTmp := StrAlloc(paIntLength);
   //try
   //  paStream.ReadBuffer(pcTmp,paIntLength);
   //  result := AnsiString(PcTmp);
   //finally
   //   StrDispose(pcTmp);
   //end;

end;

{------------------------------------------------------------------------------------------------------------
 Prozedur:     TStreamMethods.StringToStream
 Autor:        zsolt
 Beschreibung: Schreibt der String auf Stream.
 Argumente:    var paStrString: String; var PaStream: TMemoryStream
 Rückgabewert: None
------------------------------------------------------------------------------------------------------------}
class procedure TStreamMethods.StringToStream(const paStrString: AnsiString;  var paStream: TMemoryStream; const paBoClearStream : Boolean = true);
begin
   if (paBoClearStream = true) then begin
      PaStream.Clear;
   end;
   PaStream.WriteBuffer(paStrString[1],length(paStrString));

end;


class function TStreamMethods.CommandToString(const paIntCommand: Integer): AnsiString;
begin
   case paIntCommand of
      LOGIN_REQUEST_: result:='LOGIN_REQUEST_';
      LOGIN_CLIENT_REQUEST_ : result:= 'LOGIN_CLIENT_REQUEST_';
      QUIT_         : result:='QUIT_         ';
      HELLO_        : result:='HELLO_        ';
      GET_          : result:='GET_          ';
      SET_          : result:='SET_          ';
      START_        : result:='START_        ';
      STOP_         : result:='STOP_         ';
      RESTART_      : result:='RESTART_      ';
      GET_FILE_     : result:='GET_FILE_     ';
      SEND_FILE_	  : result:='SEND_FILE_    ';
   else
      result := 'UNRECOGNIZED COMMAND!!!';
   end;
end;

class function TStreamMethods.ParamToString(const paIntCommand: Integer): AnsiString;
begin
   case paIntCommand of
      ID                   :result:='ID              ';
      PACKET_RECEIVED      :result:='PACKET_RECEIVED ';
      PACKET_SENT          :result:='PACKET_SENT     ';
      PACKET_MEANTIME      :result:='PACKET_MEANTIME ';
   else
      result := 'UNRECOGNIZED COMMAND!!!';
   end;
end;

class function TStreamMethods.ErrorToString(const paIntCommand: Integer): AnsiString;
begin
   case paIntCommand of
     NO_ERROR_OK                 :result:='NO_ERROR_OK               ';
     COMMAND_NOT_RECOGNIZED      :result:='COMMAND_NOT_RECOGNIZED    ';
     COMMAND_NOT_READY           :result:='COMMAND_NOT_READY         ';
     PARAMETER_NOT_RECOGNIZED    :result:='PARAMETER_NOT_RECOGNIZED  ';
     PARAMETER_WRONG             :result:='PARAMETER_WRONG           ';
   else
      result := 'UNRECOGNIZED COMMAND!!!';
   end;
end;

initialization
  FGlobalID := 0;

finalization


end.
