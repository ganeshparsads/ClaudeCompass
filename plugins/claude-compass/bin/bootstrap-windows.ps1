param(
  [string]$VaultPath = "$HOME\Documents\ClaudeCompassVault"
)

$ErrorActionPreference = "Stop"
$CompassHome = "$HOME\.claude\claude-compass"
$BackupDir = "$CompassHome\backups\$(Get-Date -Format yyyyMMdd-HHmmss)"

function Write-Compass($Message) {
  Write-Host "[ClaudeCompass] $Message" -ForegroundColor Cyan
}

function Test-Command($Name) {
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

Write-Compass "Starting Windows bootstrap."
New-Item -ItemType Directory -Force -Path $CompassHome, $BackupDir, "$VaultPath\ClaudeCompass" | Out-Null

if (-not (Test-Command winget)) {
  Write-Warning "winget is required for automatic Windows app installs. Install App Installer from Microsoft Store, then rerun."
  exit 1
}

if (-not (Test-Command node)) {
  Write-Compass "Installing Node.js."
  winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
}

if (-not (Test-Command python)) {
  Write-Compass "Installing Python."
  winget install Python.Python.3.12 --accept-package-agreements --accept-source-agreements
}

if (-not (Test-Command obsidian)) {
  Write-Compass "Installing Obsidian."
  winget install Obsidian.Obsidian --accept-package-agreements --accept-source-agreements
}

if (-not (Test-Command ccusage)) {
  Write-Compass "Installing ccusage."
  npm install -g ccusage
}

if (-not (Test-Command graphify)) {
  Write-Compass "Attempting Graphify install. This is optional and setup will continue if Graphify is unavailable."
  try {
    pip install --user graphify
  } catch {
    Write-Warning "Graphify is not available through pip. Skipping Graphify and continuing setup."
  }
}

if (-not (Test-Command codegraph)) {
  Write-Compass "Installing CodeGraph."
  npm install -g "@colbymchenry/codegraph"
}
if (Test-Command codegraph) {
  Write-Compass "Wiring CodeGraph MCP server into Claude Code."
  try { codegraph install } catch { Write-Warning "CodeGraph MCP wiring did not complete. Run: codegraph install" }
}

$CavemanMarker = "$CompassHome\.caveman-installed"
if (-not (Test-Path $CavemanMarker)) {
  Write-Compass "Installing Caveman (output-token compression skill). Auto-detects Claude Code."
  try {
    irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex
    Get-Date | Set-Content -Path $CavemanMarker
  } catch {
    Write-Warning "Caveman install did not complete. See https://github.com/JuliusBrussee/caveman"
  }
}

if (-not (Test-Command headroom)) {
  Write-Compass "Installing Headroom (input/context compression)."
  if (Test-Command uv) {
    try { uv tool install --python 3.13 "headroom-ai[all]" } catch { Write-Warning "uv could not install Headroom." }
  } else {
    try { pip install --user "headroom-ai[all]" } catch { Write-Warning "pip could not install Headroom." }
  }
}
if (Test-Command headroom) {
  Write-Compass "Wiring Headroom MCP server into Claude Code."
  try { headroom mcp install } catch { Write-Warning "Headroom MCP wiring did not complete. Run: headroom mcp install" }
}

@"
# ClaudeCompass Vault

This vault folder is used by ClaudeCompass for session summaries, project decisions, and durable notes.

Created: $(Get-Date)
"@ | Set-Content -Path "$VaultPath\ClaudeCompass\README.md"

Write-Compass "Installed. You may still need to approve Windows security prompts and enable the Obsidian Local REST API plugin."
