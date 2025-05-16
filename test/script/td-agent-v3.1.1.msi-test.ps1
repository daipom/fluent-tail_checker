$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
Set-PSDebug -Trace 1

$msi = "td-agent-3.1.1-0-x64.msi"
Invoke-WebRequest "https://s3.amazonaws.com/packages.treasuredata.com/3/windows/$msi" -OutFile $msi

Start-Process msiexec -ArgumentList "/i", $msi, "/quiet" -Wait

function Test-Cmd([string]$Cmd, [switch]$ExpectFail) {
  cmd.exe /c "call C:\\opt\\td-agent\\td-agent-prompt.bat && $Cmd"

  $exitcode = $LastExitCode
  if ($ExpectFail) {
    if ($exitcode -eq 0) {
      throw "Command failed."
    }
  } else {
    if ($exitcode -ne 0) {
      throw "Command did not fail."
    }
  }
}

Test-Cmd "fluent-gem install pkg/*"
Test-Cmd "fluent-tailcheck --version" 
Test-Cmd "fluent-tailcheck --help"
Test-Cmd "fluent-tailcheck test/data/pos_normal"
Test-Cmd "fluent-tailcheck test/data/pos_normal test/data/pos_duplicate_unwatched_path" -ExpectFail

exit 0
