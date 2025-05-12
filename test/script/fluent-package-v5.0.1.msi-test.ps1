$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
Set-PSDebug -Trace 1

$msi = "fluent-package-5.0.1-x64.msi"
Invoke-WebRequest "https://s3.amazonaws.com/packages.treasuredata.com/5/windows/$msi" -OutFile $msi

Start-Process msiexec -ArgumentList "/i", $msi, "/quiet" -Wait

function Test-Cmd([string]$Cmd, [switch]$ExpectFail) {
  cmd.exe /c "call C:\\opt\\fluent\\fluent-package-prompt.bat && $Cmd"

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
Test-Cmd "tailcheck --version"
Test-Cmd "tailcheck --help"
Test-Cmd "tailcheck test/data/pos_normal"
Test-Cmd "tailcheck test/data/pos_normal test/data/pos_duplicate_unwatched_path" -ExpectFail

exit 0
