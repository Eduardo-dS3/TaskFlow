# Usado pelo instalador: sai com 1 se a porta já estiver em uso, 0 se livre.
# Testa uma conexão local (pega qualquer serviço escutando) e uma reserva
# exclusiva da porta em IPv4 e IPv6.
param([Parameter(Mandatory = $true)][int]$Port)

$used = $false
foreach ($hostAddress in '127.0.0.1', '::1') {
    $family = [Net.IPAddress]::Parse($hostAddress).AddressFamily
    $client = New-Object Net.Sockets.TcpClient $family
    try {
        if ($client.ConnectAsync($hostAddress, $Port).Wait(800)) { $used = $true }
    } catch {
        # Conexão recusada: ninguém escutando nesse endereço.
    } finally {
        $client.Close()
    }
}
foreach ($address in [Net.IPAddress]::Any, [Net.IPAddress]::IPv6Any) {
    $listener = New-Object Net.Sockets.TcpListener $address, $Port
    try {
        $listener.ExclusiveAddressUse = $true
        $listener.Start()
        $listener.Stop()
    } catch {
        $used = $true
    }
}
if ($used) { exit 1 } else { exit 0 }
