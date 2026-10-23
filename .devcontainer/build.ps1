param(
    [string]$ConfigDirectory = "test",
    [string]$ComponentsDirectory = "components",
    [string[]]$Versions = @("stable", "beta", "dev"),
    [string]$Image,
    [string]$ComponentSource
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$composeFile = Join-Path $PSScriptRoot "docker-compose.yml"
$workspaceContainerPath = "/workspaces/component"
$docker = Get-Command docker.exe -ErrorAction SilentlyContinue

if (-not $docker) {
    throw "docker.exe was not found. Install or start Docker Desktop, then retry."
}

$configDirectoryPath = Join-Path $repoRoot $ConfigDirectory
if (-not (Test-Path -LiteralPath $configDirectoryPath -PathType Container)) {
    throw "Configuration directory was not found: $configDirectoryPath"
}

$componentsDirectoryPath = Join-Path $repoRoot $ComponentsDirectory
if (-not (Test-Path -LiteralPath $componentsDirectoryPath -PathType Container)) {
    throw "Components directory was not found: $componentsDirectoryPath"
}

$configDirectoryPath = (Resolve-Path -LiteralPath $configDirectoryPath).Path
$componentsDirectoryPath = (Resolve-Path -LiteralPath $componentsDirectoryPath).Path
$repoRootPrefix = $repoRoot.TrimEnd('\') + '\'
foreach ($path in @($configDirectoryPath, $componentsDirectoryPath)) {
    if (
        -not $path.Equals($repoRoot, [System.StringComparison]::OrdinalIgnoreCase) -and
        -not $path.StartsWith($repoRootPrefix, [System.StringComparison]::OrdinalIgnoreCase)
    ) {
        throw "Build paths must stay inside the repository: $path"
    }
}

$configs = @(
    Get-ChildItem -LiteralPath $configDirectoryPath -Recurse -File |
        Where-Object {
            $_.Extension -in @(".yaml", ".yml") -and
            $_.FullName -notmatch '[\\/]\.esphome[\\/]' -and
            $_.Name -notmatch '\.local-build-[0-9a-f-]+\.'
        } |
        Sort-Object FullName
)

if ($configs.Count -eq 0) {
    throw "No .yaml or .yml files were found under $configDirectoryPath."
}

if (-not $ComponentSource) {
    $remote = & git.exe -C $repoRoot remote get-url origin
    if ($LASTEXITCODE -ne 0) {
        throw "Could not read the origin Git remote. Pass -ComponentSource owner/repository explicitly."
    }

    $githubRemote = [regex]::Match(
        ($remote | Select-Object -First 1),
        '(?:github\.com[:/])(?<owner>[^/]+)/(?<repository>[^/]+?)(?:\.git)?$',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
    if (-not $githubRemote.Success) {
        throw "The origin remote is not a GitHub URL. Pass -ComponentSource owner/repository explicitly."
    }

    $ComponentSource = "$($githubRemote.Groups['owner'].Value)/$($githubRemote.Groups['repository'].Value)"
}

if ($ComponentSource -notmatch '^[^/]+/[^/]+$') {
    throw "ComponentSource must use the GitHub owner/repository format."
}

$relativeComponentsPath = $componentsDirectoryPath.Substring($repoRoot.TrimEnd('\').Length).TrimStart('\')
$componentContainerPath = "$workspaceContainerPath/$($relativeComponentsPath.Replace('\', '/'))"
$projectHashProvider = [System.Security.Cryptography.SHA256]::Create()
try {
    $projectHash = [System.BitConverter]::ToString(
        $projectHashProvider.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($repoRoot.ToLowerInvariant()))
    ).Replace("-", "").Substring(0, 8).ToLowerInvariant()
}
finally {
    $projectHashProvider.Dispose()
}
$projectSlug = [regex]::Replace(
    (Split-Path -Leaf $repoRoot).ToLowerInvariant(),
    '[^a-z0-9_-]',
    '-'
)
$projectName = "component-$projectSlug-$projectHash"
$sourcePattern = [regex]::new(
    '^(?<indent>[ \t]*)-\s*source:\s*["'']?github://' +
        [regex]::Escape($ComponentSource) +
        '(?:@[^\s"''#]+)?["'']?\s*(?:#.*)?$',
    [System.Text.RegularExpressions.RegexOptions]::Multiline
)
$utf8WithoutBom = [System.Text.UTF8Encoding]::new($false)
$stagedConfigs = @()
$previousImage = $env:ESPHOME_IMAGE
$images = if ($Image) {
    @($Image)
}
else {
    @($Versions | ForEach-Object { "ghcr.io/esphome/esphome:$_" })
}

if ($images.Count -eq 0) {
    throw "Select at least one ESPHome image with -Versions or -Image."
}

try {
    foreach ($config in $configs) {
        $content = [System.IO.File]::ReadAllText($config.FullName)
        $newline = if ($content.Contains("`r`n")) { "`r`n" } else { "`n" }
        $localContent = $sourcePattern.Replace(
            $content,
            [System.Text.RegularExpressions.MatchEvaluator]{
                param($match)

                $indent = $match.Groups["indent"].Value
                "$indent- source:$newline$indent    type: local$newline$indent    path: $componentContainerPath"
            }
        )

        $stagedPath = Join-Path $config.DirectoryName (
            "$($config.BaseName).local-build-$([guid]::NewGuid().ToString()).$($config.Extension.TrimStart('.'))"
        )
        [System.IO.File]::WriteAllText($stagedPath, $localContent, $utf8WithoutBom)
        $stagedConfigs += $stagedPath
    }

    $configDirectoryRelativePath = $configDirectoryPath.Substring($repoRoot.TrimEnd('\').Length).TrimStart('\')
    $containerConfigDirectory = "$workspaceContainerPath/$($configDirectoryRelativePath.Replace('\', '/'))"

    foreach ($image in $images) {
        $env:ESPHOME_IMAGE = $image

        foreach ($stagedPath in $stagedConfigs) {
            $relativePath = $stagedPath.Substring($repoRoot.TrimEnd('\').Length).TrimStart('\')
            $containerConfigPath = "$workspaceContainerPath/$($relativePath.Replace('\', '/'))"
            Write-Output "Compiling $containerConfigPath with $image"
            & docker.exe compose --project-name $projectName --file $composeFile run --pull missing --rm --no-deps `
                --workdir $containerConfigDirectory esphome esphome compile $containerConfigPath

            if ($LASTEXITCODE -ne 0) {
                throw "Compile failed for $containerConfigPath with $image (exit code $LASTEXITCODE)."
            }
        }
    }
}
finally {
    $env:ESPHOME_IMAGE = $previousImage

    foreach ($stagedPath in $stagedConfigs) {
        if (Test-Path -LiteralPath $stagedPath) {
            Remove-Item -LiteralPath $stagedPath -Force
        }
    }
}

Write-Output "All $($configs.Count) YAML files compiled successfully with $($images -join ', ')."
