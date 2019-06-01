param (
)

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$BuildNumber = ([int]$env:BUILD_NUMBER) + 1
Invoke-WebRequest "https://gitlab.com/api/v4/projects/$($env:CI_PROJECT_ID)/variables/BUILD_NUMBER" -Headers @{"PRIVATE-TOKEN"=$env:CI_API_TOKEN} -Body @{value=$BuildNumber} -ContentType "application/x-www-form-urlencoded" -Method "PUT" -UseBasicParsing

$year = [System.DateTime]::Now.Year
$month = [System.DateTime]::Now.Month
$day = [System.DateTime]::Now.Day
$packageVer = '{0}.{1}{2:00}.{3}' -f $year, $month, $day, $BuildNumber
$appVer = '{0}.{1}.{2}.{3}' -f $year, $month, $day, $BuildNumber

Invoke-WebRequest "https://gitlab.com/api/v4/projects/$($env:CI_PROJECT_ID)/variables/BUILD_VERSION" -Headers @{"PRIVATE-TOKEN"=$env:CI_API_TOKEN} -Body @{value=$packageVer} -ContentType "application/x-www-form-urlencoded" -Method "PUT" -UseBasicParsing
Invoke-WebRequest "https://gitlab.com/api/v4/projects/$($env:CI_PROJECT_ID)/variables/PACKAGE_VERSION" -Headers @{"PRIVATE-TOKEN"=$env:CI_API_TOKEN} -Body @{value=$appVer} -ContentType "application/x-www-form-urlencoded" -Method "PUT" -UseBasicParsing

Get-ChildItem -Path .\ -Filter *.csproj -Recurse -File | ForEach-Object {
    [string]$filename = $_.FullName
    [xml]$filexml = Get-Content -Path $_.FullName -Encoding UTF8

    Try
    {
        $filexml.Project.PropertyGroup.Version = $ver
        $filexml.Project.PropertyGroup.FileVersion = $ver
    }
    Catch
    {
        Write-Host "No Version or FileVersion properties found in project: $($filename)"
    }

    $filexml.InnerXml | Out-File $_.FullName -Encoding UTF8
}

$packageVer | Out-File "VERSION.txt" -Encoding ASCII -NoNewline

Write-Host "Package Version: $($packageVer)"
Write-Host "Build Version: $($appVer)"
