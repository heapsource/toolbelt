[Setup]
AppName=Nuvado
AppVersion=<%= version %>
DefaultDirName={pf}\Nuvado
DefaultGroupName=Nuvado
Compression=lzma2
SolidCompression=yes
OutputBaseFilename=<%= File.basename(t.name, ".exe") %>
OutputDir=<%= File.dirname(t.name) %>
ChangesEnvironment=yes
UsePreviousSetupType=no
AlwaysShowComponentsList=no
SignTool=Standard

; For Ruby expansion ~ 32MB (installed) - 12MB (installer)
ExtraDiskSpaceRequired=20971520

[Types]
Name: client; Description: "Full Installation";
Name: custom; Description: "Custom Installation"; flags: iscustom

[Components]
Name: "toolbelt"; Description: "Nuvado Toolbelt"; Types: "client custom"
Name: "toolbelt/client"; Description: "Nuvado Client"; Types: "client custom"; Flags: fixed
Name: "toolbelt/git"; Description: "Git and SSH"; Types: "client custom"; Check: "not IsProgramInstalled('git.exe')"
Name: "toolbelt/git"; Description: "Git and SSH"; Check: "IsProgramInstalled('git.exe')"

[Files]
Source: "nuvado\*.*"; DestDir: "{app}"; Flags: recursesubdirs; Components: "toolbelt/client"
Source: "installers\rubyinstaller.exe"; DestDir: "{tmp}"; Components: "toolbelt/client"
Source: "installers\git.exe"; DestDir: "{tmp}"; Components: "toolbelt/git"

[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: "expandsz"; ValueName: "NuvadoPath"; \
  ValueData: "{app}"
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: "expandsz"; ValueName: "Path"; \
  ValueData: "{olddata};{app}\bin"; Check: NeedsAddPath(ExpandConstant('{app}\bin'))
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: "expandsz"; ValueName: "Path"; \
  ValueData: "{olddata};{pf}\git\cmd"; Check: NeedsAddPath(ExpandConstant('{pf}\git\cmd'))

[Run]
Filename: "{tmp}\rubyinstaller.exe"; Parameters: "/verysilent /noreboot /nocancel /noicons /dir=""{app}/ruby-1.9.2"""; \
  Flags: shellexec waituntilterminated; StatusMsg: "Installing Ruby"; Components: "toolbelt/client"
Filename: "{tmp}\git.exe"; Parameters: "/silent /nocancel /noicons"; \
  Flags: shellexec waituntilterminated; StatusMsg: "Installing Git"; Components: "toolbelt/git"

[Code]

function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath)
  then begin
    Result := True;
    exit;
  end;
  // look for the path with leading and trailing semicolon
  // Pos() returns 0 if not found
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;

function IsProgramInstalled(Name: string): boolean;
var
  ResultCode: integer;
begin
  Result := Exec(Name, 'version', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;
