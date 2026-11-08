function Remove-UnusedBuildNetworks([string[]]$ProjectNames) {
    $PSNativeCommandUseErrorActionPreference = $false

    foreach ($projectName in $ProjectNames | Select-Object -Unique) {
        $networkName = "${projectName}_default"
        $networks = @(& docker.exe network ls --filter "label=com.docker.compose.project=$projectName" --format '{{.Name}}')
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Could not list Docker networks for $projectName."
            continue
        }
        if ($networkName -notin $networks) {
            continue
        }

        $containerCount = & docker.exe network inspect $networkName --format '{{len .Containers}}'
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Could not inspect Docker network $networkName."
            continue
        }
        if ($containerCount -ne "0") {
            Write-Warning "Leaving Docker network $networkName in place because containers are attached."
            continue
        }

        & docker.exe network rm $networkName
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Could not remove Docker network $networkName."
        }
    }
}
