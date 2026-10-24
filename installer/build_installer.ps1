# Gera o instalador do TaskFlow (build\installer\TaskFlow-Setup-<versão>.exe).
#
# Uso, na raiz do projeto:
#   powershell -ExecutionPolicy Bypass -File installer\build_installer.ps1
#
# Etapas: build do app web, download do PocketBase e do WinSW (com conferência
# do SHA-256), montagem da pasta do instalador e compilação com o Inno Setup.
# Se o Inno Setup não estiver instalado, ele é baixado em modo portátil para
# build\tools (sem mexer no sistema).
param(
    # Reaproveita o build\web existente.
    [switch]$SkipWebBuild,
    # Caminho do ISCC.exe, se estiver num local fora do padrão.
    [string]$IsccPath = $env:ISCC
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$PocketBaseVersion = '0.40.5'
$PocketBaseSha256 = 'd0980d1f3a8097ff4c03a876e8c98f3008a83c0d42cc03b636bc92b2d4788d1c'
$WinSWVersion = '2.12.0'
$WinSWSha256 = 'b5066b7bbdfba1293e5d15cda3caaea88fbeab35bd5b38c41c913d492aadfc4f'
$InnoVersion = '6.7.3'
$InnoSha256 = '9c73c3bae7ed48d44112a0f48e66742c00090bdb5bef71d9d3c056c66e97b732'

$root = Split-Path -Parent $PSScriptRoot
$work = Join-Path $root 'build\installer'
$cache = Join-Path $work 'cache'
$stage = Join-Path $work 'stage'
$tools = Join-Path $root 'build\tools'

function Step([string]$message) {
    Write-Host ''
    Write-Host "==> $message" -ForegroundColor Cyan
}

function Get-Verified([string]$url, [string]$file, [string]$sha256) {
    if (-not (Test-Path $file)) {
        Write-Host "Baixando $url"
        Invoke-WebRequest -Uri $url -OutFile "$file.part" -UseBasicParsing
        Move-Item "$file.part" $file -Force
    }
    $actual = (Get-FileHash $file -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $sha256) {
        Remove-Item $file -Force
        throw "SHA-256 inesperado para $file ($actual). Download corrompido ou adulterado."
    }
}

function Find-Iscc {
    $candidates = @(
        $IsccPath,
        (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe'),
        (Join-Path $env:ProgramFiles 'Inno Setup 6\ISCC.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe'),
        (Join-Path $tools 'innosetup\ISCC.exe')
    )
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) { return $candidate }
    }
    Step "Inno Setup não encontrado: instalando a versão $InnoVersion em modo portátil"
    $setup = Join-Path $cache "innosetup-$InnoVersion.exe"
    $tag = 'is-' + $InnoVersion.Replace('.', '_')
    Get-Verified "https://github.com/jrsoftware/issrc/releases/download/$tag/innosetup-$InnoVersion.exe" $setup $InnoSha256
    $target = Join-Path $tools 'innosetup'
    $process = Start-Process -FilePath $setup -Wait -PassThru -ArgumentList @(
        '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/CURRENTUSER',
        '/PORTABLE=1', '/NOICONS', "/DIR=`"$target`""
    )
    $iscc = Join-Path $target 'ISCC.exe'
    if ($process.ExitCode -ne 0 -or -not (Test-Path $iscc)) {
        throw "Falha ao instalar o Inno Setup (código $($process.ExitCode))."
    }
    return $iscc
}

$pubspec = Get-Content (Join-Path $root 'pubspec.yaml') -Raw
if ($pubspec -notmatch '(?m)^version:\s*(\d+\.\d+\.\d+)') {
    throw 'Versão não encontrada no pubspec.yaml.'
}
$version = $Matches[1]
Write-Host "TaskFlow $version"

New-Item -ItemType Directory -Force $cache, $tools | Out-Null

if (-not $SkipWebBuild) {
    Step 'Gerando o app web (flutter build web)'
    Push-Location $root
    try {
        & flutter build web --release --no-web-resources-cdn "--dart-define=APP_VERSION=$version"
        if ($LASTEXITCODE -ne 0) { throw 'Falha no flutter build web.' }
    } finally {
        Pop-Location
    }
}
$web = Join-Path $root 'build\web'
if (-not (Test-Path (Join-Path $web 'index.html'))) {
    throw 'build\web não encontrado. Rode sem -SkipWebBuild.'
}

Step "Baixando o PocketBase $PocketBaseVersion e o WinSW $WinSWVersion"
$pbZip = Join-Path $cache "pocketbase_${PocketBaseVersion}_windows_amd64.zip"
Get-Verified "https://github.com/pocketbase/pocketbase/releases/download/v$PocketBaseVersion/pocketbase_${PocketBaseVersion}_windows_amd64.zip" $pbZip $PocketBaseSha256
$winsw = Join-Path $cache "WinSW-$WinSWVersion.NET461.exe"
Get-Verified "https://github.com/winsw/winsw/releases/download/v$WinSWVersion/WinSW.NET461.exe" $winsw $WinSWSha256

Step 'Montando os arquivos do instalador'
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force $stage | Out-Null
$pbExtract = Join-Path $cache 'pocketbase'
if (Test-Path $pbExtract) { Remove-Item $pbExtract -Recurse -Force }
Expand-Archive $pbZip -DestinationPath $pbExtract
Copy-Item (Join-Path $pbExtract 'pocketbase.exe') $stage
Copy-Item $winsw (Join-Path $stage 'TaskFlowService.exe')
Copy-Item $web (Join-Path $stage 'pb_public') -Recurse
Copy-Item (Join-Path $root 'server\pb_hooks') (Join-Path $stage 'pb_hooks') -Recurse
Copy-Item (Join-Path $root 'server\pb_migrations') (Join-Path $stage 'pb_migrations') -Recurse
$licenses = Join-Path $stage 'licenses'
Copy-Item (Join-Path $PSScriptRoot 'licenses') $licenses -Recurse
Copy-Item (Join-Path $root 'assets\fonts\LICENSE-Roboto.txt') (Join-Path $licenses 'Roboto-LICENSE.txt')
# Licenças do Flutter e dos pacotes Dart usados pelo app.
Copy-Item (Join-Path $web 'assets\NOTICES') (Join-Path $licenses 'Flutter-e-pacotes-NOTICES.txt')

Step 'Compilando o instalador (Inno Setup)'
$iscc = Find-Iscc
& $iscc "/DAppVersion=$version" "/DStageDir=$stage" "/DOutputDir=$work" (Join-Path $PSScriptRoot 'taskflow.iss')
if ($LASTEXITCODE -ne 0) { throw "Falha na compilação do instalador (código $LASTEXITCODE)." }

$setupExe = Join-Path $work "TaskFlow-Setup-$version.exe"
$size = [Math]::Round((Get-Item $setupExe).Length / 1MB, 1)
Step "Pronto: $setupExe ($size MB)"
