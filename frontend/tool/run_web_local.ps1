param(
    [string]$GoogleClientId = "",
    [string]$ApiBaseUrl = "http://localhost:8080/api",
    [string]$WebHostname = "localhost",
    [int]$WebPort = 5050,
    [string]$FlutterBin = "flutter"
)

$ErrorActionPreference = "Stop"

# Optional: fill this once to run the script without typing the client id.
$DefaultGoogleClientId = ""

if ([string]::IsNullOrWhiteSpace($GoogleClientId)) {
    $GoogleClientId = $env:GOOGLE_CLIENT_ID
}

if ([string]::IsNullOrWhiteSpace($GoogleClientId)) {
    $GoogleClientId = $DefaultGoogleClientId
}

if ([string]::IsNullOrWhiteSpace($GoogleClientId)) {
    Write-Error "GOOGLE_CLIENT_ID is required. Set `$DefaultGoogleClientId in this file or pass -GoogleClientId."
}

$frontendDir = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $frontendDir

& $FlutterBin run `
    -d chrome `
    --web-hostname $WebHostname `
    --web-port $WebPort `
    --dart-define=API_BASE_URL=$ApiBaseUrl `
    --dart-define=GOOGLE_CLIENT_ID=$GoogleClientId