# Open Port 3306 in Windows Firewall

Windows will block incoming connections to MySQL by default. You need to allow port 3306 through the firewall. 

Click the Windows Start menu, type PowerShell, right-click it, and choose Run as Administrator.

Copy and paste this exact command, then hit Enter:

```powerShell
New-NetFirewallRule -DisplayName "MySQL Remote Access" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3306
```

To check the state:

```powerShell
Get-NetTCPConnection -LocalPort 3306 -State Listen
```

To get the IPv4 Address of your pc:

```powerShell
(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "169.*" -and $_.IPAddress -ne "127.0.0.1"}).IPAddress
```