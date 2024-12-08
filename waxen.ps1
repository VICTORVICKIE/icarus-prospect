param (
    [string]$SubCommand,
    [string]$HelpArg
)

$ScriptName = $MyInvocation.MyCommand.Name

if ((Get-Command "git.exe" -ErrorAction SilentlyContinue) -eq $null) {
    throw "Git is not in executable path."
}

$IcarusPlayerData = "$env:LOCALAPPDATA\Icarus\Saved\PlayerData"

if (!(Test-Path "$IcarusPlayerData")) {
    throw "Path does not exist: $IcarusPlayerData"
}

$SteamID64 = Get-ChildItem -Path $IcarusPlayerData -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (!($SteamID64)) {
    throw "No SteamID64 present at: $IcarusPlayerData"
}

$IcarusProspects = "$IcarusPlayerData\$($SteamID64.Name)\Prospects"

if (!(Test-Path "$IcarusProspects")) {
    throw "Path does not exist: $IcarusProspects"
}

$IcarusProspectsName = "Sp10.json"

$Github = "https://github.com"
$Repo = "VICTORVICKIE/icarus-prospect"

if (!(Test-Path ".git")) {
    throw "Current directory: $(Get-Location) is not a git repositry."
}

$RemoteOrigin = (git config --get remote.origin.url)

if ($RemoteOrigin -eq $null) {
    Write-Output "[INFO] Adding $RemoteOrigin"
    git remote add origin "$Github/$Repo"
} elseif (!($RemoteOrigin.ToLower().Contains($Repo.ToLower()))) {
    throw "Current repositry is not local branch of remote origin: $Repo"
}

$BackupDir = ".backup"

if (!(Test-Path $BackupDir)) {
    Write-Host "Info: Creating backup directory: $BackupDir" -ForegroundColor Green
    New-Item -Path $BackupDir -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
}

function Get-IST-DateTime {
    param ([System.DateTime]$Date)
    $TimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("India Standard Time")
    $DateTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($Date, $TimeZone.Id)
    return $DateTime
}

function Get-FileName-With-Timestamp {
    param ([System.IO.FileInfo]$File)
    $BaseName = $File.BaseName
    $Extension = $File.Extension
    $FormattedDate = (Get-IST-DateTime ($File.LastWriteTimeUtc)).ToString("yyyy-MM-dd-HH-mm-ss")
    return "$BaseName-$FormattedDate-IST$Extension"
}

function Fly {
    Robocopy "$IcarusProspects" (Get-Location) "$IcarusProspectsName"
    git add $IcarusProspectsName
    $CurrentTime = (Get-IST-DateTime (Get-Date)).ToString("yyyy-MM-dd HH:mm:ss IST")
    git commit -m "Saved at $()" -m "Pushed at $CurrentTime"
    git push origin main
}

function Land {
    git pull origin main
    $BackupFile = Get-Item "$IcarusProspects\$IcarusProspectsName"
    $BackupFileName = Get-FileName-With-Timestamp -File $BackupFile
    Move-Item "$IcarusProspects\$IcarusProspectsName" "$BackupDir\$BackupFileName"
    Robocopy (Get-Location) "$IcarusProspects" "$IcarusProspectsName"
}

$Commands = @{
    "fly"  = { Fly }
    "land" = { Land }
}

$ShortHelpMsgs = @{
    "fly"  = "Pushes `icarus prospect save` from local to github"
    "land" = "Pulls `icarus prospect save` from github to local"
}

$HelpMsgs = @{
    "fly"  = @"
Waxen Help: fly

It copies save file from Icarus saves to current directory,
commits the changes to git with timestamped messages, and then pushes them to github.
"@

    "land" = @"
Waxen Help: land

Backs up the Icarus save file by moving it to a directory with a timestamped name,
then pulls the latest changes from the github, and copies to Icarus saves.
"@
}

function Show-Usage {
    Write-Output "Waxen Help: Available subcommands"
    $MaxLength = ($Commands.Keys | Measure-Object -Property Length -Maximum).Maximum

    foreach ($Key in $Commands.Keys) {
        $PaddedKey = $Key.PadRight($MaxLength)
        Write-Output "    $PaddedKey  : $($ShortHelpMsgs[$Key])"
    }
    Write-Output ""
    Write-Output "Use '$ScriptName help <subcommand>' for specific details."
}

if ($SubCommand -eq "help") {
    if ($HelpArg) {
        if ($HelpMsgs.ContainsKey($HelpArg)) {
            Write-Output $HelpMsgs[$HelpArg]
        } else {
            throw "Unknown subcommand: $HelpArg"
        }
    }
    else { Show-Usage }
} elseif ($Commands.ContainsKey($SubCommand)) {
    & $Commands[$SubCommand]
} else {
    Show-Usage
}
