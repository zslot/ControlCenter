program MC;

uses
  Forms,
  MControl in 'MControl.pas' {frmMissionControl},
  MissionCommunicationU in 'MissionCommunicationU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMissionControl, frmMissionControl);
  Application.Run;
end.
