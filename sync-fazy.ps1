
# sync-fazy.ps1
# Nacita projekty z Caflou a vytvori skratky v _Fazy podla fazy projektu

# Najdi cestu cez wildcard - obchodzi problemy s diakritikou
$ProjectsRoot = (Get-Item "H:\Spo*disky\1_PROJEKTY" -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
if (-not $ProjectsRoot) {
    Write-Host "CHYBA: Nenasiel sa priecinok 1_PROJEKTY na H:\" -ForegroundColor Red
    exit 1
}
$FazyRoot = Join-Path $ProjectsRoot "_Fazy"

# Nacitaj credentials z caflou.env
$envFile = Join-Path $PSScriptRoot "caflou.env"
Get-Content $envFile | ForEach-Object {
    if ($_ -match "^(\w+)=(.+)$") {
        Set-Variable -Name $Matches[1] -Value $Matches[2]
    }
}

# Odstranenie diakritiky cez .NET Unicode normalizaciu
function Strip($s) {
    if (-not $s) { return "" }
    $n = $s.Normalize([System.Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $n.ToCharArray()) {
        $cat = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c)
        if ($cat -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($c)
        }
    }
    return $sb.ToString().ToLower().Trim()
}

# Mapovanie status (bez diakritiky, lowercase) -> priecinok v _Fazy
$StatusMap = @{
    "0_podklady"       = "Studia-Architektura"
    "1_studia"         = "Studia-Architektura"
    "2_sz"             = "Projekcia-SZ"
    "3_dsp"            = "Projekcia-PS"
    "3_ps"             = "Projekcia-PS"
    "4_rp"             = "Projekcia-RP"
    "5_inziniering"    = "Inziniering"
    "6_autorsky dozor" = "Inziniering"
}

# Prepis priecinku podla typu projektu
$TypeMap = @{
    "interier"     = "Studia-Interior"
    "uzemne plany" = "Projekcia-UP"
}

# Vytvor strukturu _Fazy
$FazovePriecinky = @(
    "Studia-Architektura",
    "Studia-Interior",
    "Projekcia-SZ",
    "Projekcia-PS",
    "Projekcia-RP",
    "Projekcia-UP",
    "Inziniering",
    "Archiv"
)

if (-not (Test-Path $FazyRoot)) {
    New-Item -ItemType Directory -Path $FazyRoot -Force | Out-Null
}
foreach ($fp in $FazovePriecinky) {
    $path = Join-Path $FazyRoot $fp
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "Vytvoreny priecinok: $fp" -ForegroundColor Gray
    }
}

# Zmaz stare skratky
Get-ChildItem -Path $FazyRoot -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force

# Nacitaj projekty z Caflou
Write-Host "Nacitavam projekty z Caflou..." -ForegroundColor Cyan
$all = @()
$page = 1
do {
    $uri = "https://app.caflou.com/api/v1/$CAFLOU_ACCOUNT_ID/projects?per=100" + "&page=$page"
    $resp = Invoke-RestMethod -Uri $uri -Headers @{ Authorization = "Bearer $CAFLOU_API_KEY" }
    $all += $resp.results
    $totalPages = [int]$resp.total_pages
    $page++
} while ($page -le $totalPages)

$projekty = $all | Where-Object { -not $_.trash -and -not $_.template }
Write-Host "Nacitanych $($projekty.Count) projektov" -ForegroundColor Green

# Ziskaj zoznam priecinkov projektov
$foldery = Get-ChildItem -Path $ProjectsRoot -Directory -ErrorAction SilentlyContinue |
           Where-Object { $_.Name -notmatch "^_" }

$shell     = New-Object -ComObject WScript.Shell
$spravne   = 0
$nenajdene = @()

foreach ($p in $projekty) {
    $cislo = $p.order_number
    if (-not $cislo) { continue }

    # Urcit cielovy fazovy priecinok
    if ($p.finished) {
        $fazaDir = "Archiv"
    } else {
        $statusKey = Strip($p.project_status_name)
        $typeKey   = Strip($p.project_type_name)
        if ($TypeMap.ContainsKey($typeKey)) {
            $fazaDir = $TypeMap[$typeKey]
        } elseif ($StatusMap.ContainsKey($statusKey)) {
            $fazaDir = $StatusMap[$statusKey]
        } else {
            $nenajdene += "$cislo (neznamy status: $($p.project_status_name))"
            continue
        }
    }

    # Najdi priecinok projektu
    # Caflou pouziva 2-ciferny rok (24-021), priecinky maju 4-ciferny (2024-021-...)
    $cisloPattern = ""
    if ($cislo -match "^(\d{2})-(\d+)$") {
        $rok4    = "20" + $Matches[1]
        $num     = $Matches[2]
        $cisloPattern = "^($rok4-$num|$cislo)\b"
    } else {
        $cisloPattern = "^" + [regex]::Escape($cislo) + "\b"
    }

    $folder = $foldery | Where-Object { $_.Name -match $cisloPattern } | Select-Object -First 1

    if (-not $folder) {
        $nenajdene += "$cislo (priecinok nenajdeny)"
        continue
    }

    # Vytvor skratku .lnk
    $targetDir = Join-Path $FazyRoot $fazaDir
    $lnkPath   = Join-Path $targetDir "$cislo $($p.name).lnk"
    $sc = $shell.CreateShortcut($lnkPath)
    $sc.TargetPath = $folder.FullName
    $sc.Save()
    $spravne++
}

Write-Host ""
Write-Host "Vytvorene skratky: $spravne" -ForegroundColor Green
if ($nenajdene.Count -gt 0) {
    Write-Host "Nenajdene ($($nenajdene.Count)):" -ForegroundColor Yellow
    $nenajdene | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}
Write-Host "Hotovo. Skratky su v: $FazyRoot" -ForegroundColor Cyan
