#
# Checks for file system changes
#
#
param (
    [Parameter(Mandatory = $true)]
    $Target = $1,
    [string] $State = "/integ",
    [bool] $enableDeletedLog = $true,
    [bool] $enableCreatedLog = $false
)
$startTime = get-date
$startTimeStamp = get-date -UFormat "+%Y-%m-%dT%T"
#
$stateFile = "$State/lastrun.state"
$deletedLog = "$State/$startTimeStamp-deleted.log"
$createdLog = "$State/$startTimeStamp-created.log"
#
#
function Write-Log {
    param (
        $msg = $1
    )
    $uformat = get-date -UFormat "+%Y-%m-%dT%T"
    Write-Host "[$uformat] $msg"
}
#
#
Write-Log "Integritoss Startup."
#
# Check if target exists
Write-Log "Crawling target directory [$Target]."
$currentState = (Get-ChildItem -Recurse "$Target" -ErrorAction Stop).FullName
Write-Log ("[{0}] files found in [$Target]." -f $currentState.count)
#
# Check state
Write-Log "Checking if there is state from the last run."
$lastRunState = try {
    Get-Content "$stateFile" -ErrorAction Stop | ConvertFrom-Json
}
catch {
    Write-Log "No prior state recorded! Saving current state. Will compare on the next run."
    New-Item -Path "$stateFile" -ItemType File -Value ($currentState | Convertto-Json)
    Write-Log "Finished."
    exit
}
#
Write-Log "State found. Comparing to last run."
#
# [Start comparison]
# What was created
$wasCreated = $currentState | Where-Object { $_ -notin $lastRunState }
# What was deleted
$wasDeleted = $lastRunState | Where-Object { $_ -notin $currentState }
#
# output findings to stdout
Write-Log ("[{0}] file(s) were Created: {1}" -f $wasCreated.count, ($wasCreated | ConvertTo-Json))
Write-Log ("[{0}] file(s) were Deleted: {1}" -f $wasDeleted.count, ($wasDeleted | ConvertTo-Json))
#
# Update local state for next run
Set-Content -path "$StateFile" -value ($currentState | ConvertTo-Json)
#
# Append deleted items to append log
if ($wasDeleted -and $enableDeletedLog) {
    Add-Content -Path "$deletedLog" -Value ("[{0}]`n$wasDeleted`n" -f (get-date -UFormat "+%Y-%m-%dT%T"))
}
#
# Append created items to append log
if ($wasCreated -and $enableCreatedLog) {
    Add-Content -Path "$createdLog" -Value ("[{0}]`n$wasCreated`n" -f (get-date -UFormat "+%Y-%m-%dT%T"))
}
#
$endTime = get-date
Write-Log ("Finished. Completed in [{0}]s" -f (($endTime - $startTime).TotalSeconds))
#
#
