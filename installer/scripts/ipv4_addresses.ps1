# Usado pelo instalador: grava em -OutFile os IPv4 deste computador na rede
# (um por linha), para mostrar os endereços de acesso no fim da instalação.
param([Parameter(Mandatory = $true)][string]$OutFile)

$addresses = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
        $_.IPAddress -notlike '127.*' -and
        $_.IPAddress -notlike '169.254.*' -and
        $_.AddressState -eq 'Preferred'
    } |
    Sort-Object -Property InterfaceMetric |
    Select-Object -ExpandProperty IPAddress -Unique
Set-Content -Path $OutFile -Value $addresses -Encoding ASCII
