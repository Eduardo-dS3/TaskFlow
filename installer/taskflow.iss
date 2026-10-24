; Instalador do TaskFlow para Windows (Inno Setup 6).
;
; Não compile este arquivo direto: use installer\build_installer.ps1, que gera
; o app web, baixa o PocketBase e o WinSW e monta a pasta StageDir.
;
; O que a instalação faz:
;   - copia o servidor (PocketBase), o app web e as regras do banco;
;   - cria o banco em C:\ProgramData\TaskFlow com o administrador padrão
;     (usuário "sa", senha "256318");
;   - registra o serviço "TaskFlow" (inicia com o Windows e reinicia sozinho
;     em caso de falha) e libera a porta no firewall;
;   - mostra os endereços de acesso pela rede.
;
; Instalação silenciosa:
;   TaskFlow-Setup.exe /VERYSILENT /SUPPRESSMSGBOXES /PORT=8090
; Desinstalação silenciosa apagando os dados:
;   unins000.exe /VERYSILENT /DELETEDATA=1

#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif
#ifndef StageDir
  #define StageDir "..\build\installer\stage"
#endif
#ifndef OutputDir
  #define OutputDir "..\build\installer"
#endif

#define AppName "TaskFlow"
#define ServiceId "TaskFlow"
#define DefaultPort "8090"

[Setup]
AppId={{B3F3ECC5-2D47-4F84-B5C6-6214DA745E1B}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppName}
VersionInfoVersion={#AppVersion}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir={#OutputDir}
OutputBaseFilename=TaskFlow-Setup-{#AppVersion}
SetupIconFile=taskflow.ico
UninstallDisplayIcon={app}\taskflow.ico
UninstallDisplayName={#AppName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
; O serviço é parado pelo próprio script antes de copiar os arquivos.
CloseApplications=no
SetupLogging=yes

[Languages]
Name: "ptbr"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "firewall"; Description: "Liberar a porta no Firewall do Windows (acesso pelos outros computadores da rede)"
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Dirs]
Name: "{commonappdata}\{#AppName}"
Name: "{commonappdata}\{#AppName}\logs"

[InstallDelete]
; Arquivos de versões anteriores que não existem mais na nova.
Type: filesandordirs; Name: "{app}\pb_public"
Type: filesandordirs; Name: "{app}\pb_hooks"
Type: filesandordirs; Name: "{app}\pb_migrations"

[Files]
Source: "{#StageDir}\pocketbase.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\TaskFlowService.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\pb_public\*"; DestDir: "{app}\pb_public"; Excludes: "*.symbols"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#StageDir}\pb_hooks\*"; DestDir: "{app}\pb_hooks"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#StageDir}\pb_migrations\*"; DestDir: "{app}\pb_migrations"; Flags: ignoreversion
Source: "{#StageDir}\licenses\*"; DestDir: "{app}\licenses"; Flags: ignoreversion
Source: "LEIAME.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "taskflow.ico"; DestDir: "{app}"; Flags: ignoreversion
; Usados só durante a instalação.
Source: "scripts\port_in_use.ps1"; Flags: dontcopy
Source: "scripts\ipv4_addresses.ps1"; Flags: dontcopy

[INI]
Filename: "{app}\TaskFlow.url"; Section: "InternetShortcut"; Key: "URL"; String: "http://localhost:{code:GetPort}/"
Filename: "{app}\TaskFlow.url"; Section: "InternetShortcut"; Key: "IconFile"; String: "{app}\taskflow.ico"
Filename: "{app}\TaskFlow.url"; Section: "InternetShortcut"; Key: "IconIndex"; String: "0"
Filename: "{app}\Painel do servidor.url"; Section: "InternetShortcut"; Key: "URL"; String: "http://localhost:{code:GetPort}/_/"
Filename: "{app}\Painel do servidor.url"; Section: "InternetShortcut"; Key: "IconFile"; String: "{app}\taskflow.ico"
Filename: "{app}\Painel do servidor.url"; Section: "InternetShortcut"; Key: "IconIndex"; String: "0"

[Icons]
Name: "{group}\TaskFlow"; Filename: "{app}\TaskFlow.url"; IconFilename: "{app}\taskflow.ico"
Name: "{group}\Painel do servidor TaskFlow"; Filename: "{app}\Painel do servidor.url"; IconFilename: "{app}\taskflow.ico"
Name: "{group}\Pasta de dados do TaskFlow"; Filename: "{commonappdata}\{#AppName}"
Name: "{group}\Leia-me do TaskFlow"; Filename: "{app}\LEIAME.txt"
Name: "{group}\Desinstalar o TaskFlow"; Filename: "{uninstallexe}"
Name: "{commondesktop}\TaskFlow"; Filename: "{app}\TaskFlow.url"; IconFilename: "{app}\taskflow.ico"; Tasks: desktopicon

[Registry]
Root: HKLM; Subkey: "Software\{#AppName}"; ValueType: string; ValueName: "Port"; ValueData: "{code:GetPort}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\{#AppName}"; ValueType: string; ValueName: "DataDir"; ValueData: "{commonappdata}\{#AppName}"
Root: HKLM; Subkey: "Software\{#AppName}"; ValueType: string; ValueName: "Version"; ValueData: "{#AppVersion}"

[Run]
Filename: "http://localhost:{code:GetPort}/"; Description: "Abrir o TaskFlow no navegador"; Flags: shellexec postinstall skipifsilent nowait

[UninstallRun]
Filename: "{sys}\net.exe"; Parameters: "stop {#ServiceId}"; Flags: runhidden waituntilterminated; RunOnceId: "StopService"
Filename: "{app}\TaskFlowService.exe"; Parameters: "uninstall"; Flags: runhidden waituntilterminated; RunOnceId: "RemoveService"
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule name=""{#AppName}"""; Flags: runhidden waituntilterminated; RunOnceId: "RemoveFirewallRule"

[UninstallDelete]
Type: files; Name: "{app}\TaskFlow.url"
Type: files; Name: "{app}\Painel do servidor.url"
Type: files; Name: "{app}\TaskFlowService.xml"

[Code]
const
  ServiceKey = 'SYSTEM\CurrentControlSet\Services\{#ServiceId}';
  SettingsKey = 'Software\{#AppName}';
  NewLine = #13#10;

var
  PortPage: TInputQueryWizardPage;
  FreshInstall: Boolean;
  ServerReady: Boolean;

function DataDir: String;
begin
  Result := ExpandConstant('{commonappdata}\{#AppName}');
end;

function AppDir: String;
begin
  Result := ExpandConstant('{app}');
end;

function PowerShellExe: String;
begin
  Result := ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe');
end;

function SavedPort: String;
begin
  if not RegQueryStringValue(HKLM, SettingsKey, 'Port', Result) then
    Result := '';
end;

function InitialPort: String;
begin
  Result := ExpandConstant('{param:PORT|}');
  if Result = '' then
    Result := SavedPort;
  if Result = '' then
    Result := '{#DefaultPort}';
end;

function GetPort(Param: String): String;
begin
  Result := Trim(PortPage.Values[0]);
end;

function IsValidPort(Value: String): Boolean;
var
  Number: Integer;
begin
  Number := StrToIntDef(Value, -1);
  Result := (Number >= 1) and (Number <= 65535) and (IntToStr(Number) = Value);
end;

function ServiceExists: Boolean;
begin
  Result := RegKeyExists(HKLM, ServiceKey);
end;

function RunHidden(FileName, Params: String): Integer;
begin
  if not Exec(FileName, Params, '', SW_HIDE, ewWaitUntilTerminated, Result) then
    Result := -1;
  Log(Format('Executado: %s %s (código %d)', [FileName, Params, Result]));
end;

function RunScript(Name, Params: String): Integer;
begin
  ExtractTemporaryFile(Name);
  Result := RunHidden(PowerShellExe,
    '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' +
    ExpandConstant('{tmp}\') + Name + '" ' + Params);
end;

// A porta está ocupada por outro programa? A do próprio TaskFlow (numa
// atualização) não conta: o serviço é parado antes da cópia dos arquivos.
function PortTaken(Port: String): Boolean;
begin
  if (Port = SavedPort) and ServiceExists then
    Result := False
  else
    Result := RunScript('port_in_use.ps1', '-Port ' + Port) = 1;
end;

function PortProblem(Port: String): String;
begin
  Result := '';
  if not IsValidPort(Port) then
    Result := 'Informe uma porta entre 1 e 65535.'
  else if PortTaken(Port) then
    Result := 'A porta ' + Port + ' já está em uso por outro programa. ' +
      'Escolha outra porta (por exemplo, 8091).';
end;

procedure InitializeWizard;
begin
  PortPage := CreateInputQueryPage(wpSelectTasks,
    'Porta de acesso',
    'Em qual porta o TaskFlow vai atender?',
    'Os computadores da rede vão abrir o TaskFlow pelo endereço ' +
    'http://IP-DESTE-SERVIDOR:PORTA. Mantenha a porta padrão ({#DefaultPort}) ' +
    'a menos que ela já esteja em uso por outro programa.');
  PortPage.Add('Porta:', False);
  PortPage.Values[0] := InitialPort;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Problem: String;
begin
  Result := True;
  if CurPageID = PortPage.ID then
  begin
    Problem := PortProblem(GetPort(''));
    if Problem <> '' then
    begin
      MsgBox(Problem, mbError, MB_OK);
      Result := False;
    end;
  end;
end;

// Cópia do banco antes de atualizar (e antes das migrations da nova versão).
procedure BackupDatabase;
var
  Source, Target: String;
begin
  Source := DataDir + '\pb_data\';
  Target := DataDir + '\atualizacoes\' +
    GetDateTimeString('yyyy-mm-dd_hh-nn-ss', '-', '-') + '\';
  if not ForceDirectories(Target) then
    exit;
  CopyFile(Source + 'data.db', Target + 'data.db', False);
  if FileExists(Source + 'data.db-wal') then
    CopyFile(Source + 'data.db-wal', Target + 'data.db-wal', False);
  if FileExists(Source + 'auxiliary.db') then
    CopyFile(Source + 'auxiliary.db', Target + 'auxiliary.db', False);
  Log('Cópia do banco antes da atualização: ' + Target);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := PortProblem(GetPort(''));
  if Result <> '' then
    exit;
  if ServiceExists then
    RunHidden(ExpandConstant('{sys}\net.exe'), 'stop {#ServiceId}');
  FreshInstall := not FileExists(DataDir + '\pb_data\data.db');
  if not FreshInstall then
    BackupDatabase;
end;

function XmlEscape(Value: String): String;
begin
  Result := Value;
  StringChangeEx(Result, '&', '&amp;', True);
  StringChangeEx(Result, '<', '&lt;', True);
  StringChangeEx(Result, '>', '&gt;', True);
end;

// Configuração do WinSW: o PocketBase atende em todas as interfaces (IPv4 e
// IPv6) na porta escolhida, com os dados em C:\ProgramData\TaskFlow.
procedure WriteServiceConfig;
var
  App, Data: String;
  Lines: TArrayOfString;
begin
  App := XmlEscape(AppDir);
  Data := XmlEscape(DataDir);
  SetArrayLength(Lines, 20);
  Lines[0] := '<service>';
  Lines[1] := '  <id>{#ServiceId}</id>';
  Lines[2] := '  <name>{#AppName}</name>';
  Lines[3] := '  <description>Servidor do TaskFlow: banco de dados, API e app web.</description>';
  Lines[4] := '  <executable>' + App + '\pocketbase.exe</executable>';
  Lines[5] := '  <arguments>serve --http=:' + GetPort('') +
    ' --dir="' + Data + '\pb_data" --publicDir="' + App + '\pb_public"' +
    ' --hooksDir="' + App + '\pb_hooks" --migrationsDir="' + App + '\pb_migrations"' +
    ' --hooksWatch=false --dev=false --automigrate=false</arguments>';
  Lines[6] := '  <workingdirectory>' + App + '</workingdirectory>';
  Lines[7] := '  <startmode>Automatic</startmode>';
  Lines[8] := '  <delayedAutoStart>true</delayedAutoStart>';
  Lines[9] := '  <onfailure action="restart" delay="10 sec"/>';
  Lines[10] := '  <onfailure action="restart" delay="30 sec"/>';
  Lines[11] := '  <onfailure action="restart" delay="60 sec"/>';
  Lines[12] := '  <resetfailure>1 hour</resetfailure>';
  Lines[13] := '  <stoptimeout>20 sec</stoptimeout>';
  Lines[14] := '  <logpath>' + Data + '\logs</logpath>';
  Lines[15] := '  <log mode="roll-by-size">';
  Lines[16] := '    <sizeThreshold>10240</sizeThreshold>';
  Lines[17] := '    <keepFiles>8</keepFiles>';
  Lines[18] := '  </log>';
  Lines[19] := '</service>';
  SaveStringsToUTF8File(AppDir + '\TaskFlowService.xml', Lines, False);
end;

// Aplica as migrations: cria o banco, as tabelas e o administrador padrão
// numa instalação nova, ou atualiza o esquema de uma instalação existente.
function RunMigrations: Boolean;
begin
  Result := RunHidden(ExpandConstant('{cmd}'),
    '/c ""' + AppDir + '\pocketbase.exe" migrate up' +
    ' --dir="' + DataDir + '\pb_data"' +
    ' --migrationsDir="' + AppDir + '\pb_migrations"' +
    ' --hooksDir="' + AppDir + '\pb_hooks" --hooksWatch=false --dev=false' +
    ' >> "' + DataDir + '\logs\instalacao.log" 2>&1"') = 0;
end;

// Banco, anexos e backups: acesso só para administradores e para o serviço.
procedure ProtectDataDir;
begin
  RunHidden(ExpandConstant('{sys}\icacls.exe'),
    '"' + DataDir + '" /inheritance:r' +
    ' /grant:r *S-1-5-32-544:(OI)(CI)F /grant:r *S-1-5-18:(OI)(CI)F /Q');
end;

procedure ConfigureFirewall;
var
  Netsh: String;
begin
  Netsh := ExpandConstant('{sys}\netsh.exe');
  RunHidden(Netsh, 'advfirewall firewall delete rule name="{#AppName}"');
  if WizardIsTaskSelected('firewall') then
    RunHidden(Netsh, 'advfirewall firewall add rule name="{#AppName}"' +
      ' dir=in action=allow protocol=TCP localport=' + GetPort('') +
      ' program="' + AppDir + '\pocketbase.exe" profile=any enable=yes');
end;

function StartService: Boolean;
var
  Wrapper: String;
begin
  Wrapper := AppDir + '\TaskFlowService.exe';
  if not ServiceExists then
    RunHidden(Wrapper, 'install');
  Result := RunHidden(Wrapper, 'start') = 0;
end;

function ServerResponds: Boolean;
var
  Http: Variant;
begin
  Result := False;
  try
    Http := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    Http.SetTimeouts(1000, 1000, 2000, 2000);
    Http.Open('GET', 'http://127.0.0.1:' + GetPort('') + '/api/health', False);
    Http.Send('');
    Result := Http.Status = 200;
  except
    Result := False;
  end;
end;

function WaitForServer: Boolean;
var
  Attempt: Integer;
begin
  for Attempt := 1 to 60 do
  begin
    if ServerResponds then
    begin
      Result := True;
      exit;
    end;
    Sleep(500);
  end;
  Result := False;
end;

procedure SetupServer;
begin
  WizardForm.StatusLabel.Caption := 'Preparando o banco de dados...';
  WriteServiceConfig;
  if not RunMigrations then
  begin
    SuppressibleMsgBox('Não foi possível preparar o banco de dados. Detalhes em ' +
      DataDir + '\logs\instalacao.log', mbError, MB_OK, IDOK);
    exit;
  end;
  ProtectDataDir;
  WizardForm.StatusLabel.Caption := 'Configurando o firewall...';
  ConfigureFirewall;
  WizardForm.StatusLabel.Caption := 'Iniciando o servidor do TaskFlow...';
  ServerReady := StartService and WaitForServer;
  if not ServerReady then
    SuppressibleMsgBox('O serviço TaskFlow foi instalado, mas o servidor não ' +
      'respondeu. Veja os registros em ' + DataDir + '\logs.', mbError, MB_OK, IDOK);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    SetupServer;
end;

function NetworkUrls: String;
var
  OutFile: String;
  Addresses: TStringList;
  I: Integer;
begin
  Result := '';
  OutFile := ExpandConstant('{tmp}\enderecos.txt');
  RunScript('ipv4_addresses.ps1', '-OutFile "' + OutFile + '"');
  Addresses := TStringList.Create;
  try
    if FileExists(OutFile) then
      Addresses.LoadFromFile(OutFile);
    for I := 0 to Addresses.Count - 1 do
      if Trim(Addresses[I]) <> '' then
        Result := Result + '    http://' + Trim(Addresses[I]) + ':' + GetPort('') + NewLine;
  finally
    Addresses.Free;
  end;
  if Result = '' then
    Result := '    http://IP-DESTE-SERVIDOR:' + GetPort('') + NewLine;
end;

function FinishMessage: String;
begin
  if not ServerReady then
  begin
    Result := 'A instalação terminou, mas o servidor não respondeu. ' +
      'Veja os registros em ' + DataDir + '\logs e o Leia-me no menu Iniciar.';
    exit;
  end;
  Result := 'O TaskFlow está rodando como serviço do Windows e inicia junto com o computador.' +
    NewLine + NewLine + 'Neste computador:' + NewLine +
    '    http://localhost:' + GetPort('') + NewLine + NewLine +
    'Nos outros computadores da rede:' + NewLine + NetworkUrls + NewLine;
  if FreshInstall then
    Result := Result + 'Entre com o usuário sa e a senha 256318 e troque a senha ' +
      'em Configurações.'
  else
    Result := Result + 'Atualização concluída: os dados e os usuários foram mantidos.';
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpFinished then
  begin
    WizardForm.FinishedLabel.Caption := FinishMessage;
    WizardForm.FinishedLabel.AdjustHeight;
    WizardForm.RunList.Top := WizardForm.FinishedLabel.Top +
      WizardForm.FinishedLabel.Height + ScaleY(12);
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  DeleteData: Boolean;
begin
  if (CurUninstallStep <> usPostUninstall) or not DirExists(DataDir) then
    exit;
  if UninstallSilent then
    DeleteData := ExpandConstant('{param:DELETEDATA|0}') = '1'
  else
    DeleteData := MsgBox('Apagar também os dados do TaskFlow (tarefas, anexos e ' +
      'backups) em ' + DataDir + '?' + NewLine + NewLine +
      'Escolha "Não" para manter os dados e reaproveitá-los numa nova instalação.',
      mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES;
  if DeleteData then
    DelTree(DataDir, True, True, True);
end;
