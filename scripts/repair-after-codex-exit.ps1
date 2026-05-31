[CmdletBinding()]
param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }),
    [int]$TimeoutSeconds = 600
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$logPath = Join-Path $CodexHome "malou-repair-after-codex-exit.log"
$deadline = (Get-Date).AddSeconds($TimeoutSeconds)

function Write-RepairLog {
    param([Parameter(Mandatory = $true)][string]$Message)
    $line = "{0:s} {1}" -f (Get-Date), $Message
    Add-Content -LiteralPath $logPath -Value $line
}

function Get-CodexDesktopProcess {
    Get-Process -ErrorAction SilentlyContinue |
        Where-Object {
            $_.ProcessName -ceq "Codex" -and
            $_.Path -like "*\WindowsApps\OpenAI.Codex_*\app\Codex.exe"
        }
}

Write-RepairLog "Waiting for Codex Desktop to exit."

while (Get-CodexDesktopProcess) {
    if ((Get-Date) -gt $deadline) {
        Write-RepairLog "Timed out while Codex Desktop was still running."
        exit 1
    }

    Start-Sleep -Seconds 2
}

Write-RepairLog "Codex Desktop is closed. Repairing Malou mobile sync state."
& (Join-Path $PSScriptRoot "check-mobile-sync.ps1") -CodexHome $CodexHome -Repair *>&1 |
    ForEach-Object { Write-RepairLog $_.ToString() }

Write-RepairLog "Repair-after-exit finished."
