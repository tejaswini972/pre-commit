#
# Source: DotJim blog (http://dandraka.com)
# Jim Andrakakis, July 2022
#
Clear-Host
$ErrorActionPreference='Stop'
 
# ===== Change here =====
$listOfExtensions=@('*.ps1')
$listOfSecretNodes=@('username','password','clientid','secret','connectionstring')
$acceptableString='lalala'
# ===== Change here =====
 
$codePath = (Get-Item -Path $PSScriptRoot).Parent.Parent.FullName
 
$errorList=New-Object -TypeName 'System.Collections.ArrayList'
 
foreach($ext in $listOfExtensions) {
    $list = Get-ChildItem -Path $codePath -Recurse -Filter $ext
 
    foreach($file in $list) {
        $fileName = $file.FullName
        if ($fileName.Contains('\bin\')) {
            continue
        }
        Write-Host "Checking $fileName for secrets"
        $script= Get-Content -Path $fileName
        foreach($secretName in $listOfSecretNodes) {
            $nodes = $script.SelectNodes("//*[contains(local-name(), '$secretName')]")
            foreach($node in $nodes) {
                if ($node.InnerText.ToLowerInvariant() -ne $acceptableString) {
                    $str = "[$fileName] $($node.Name) contains text other than '$acceptableString', please replace this with $acceptableString before commiting."
                    $errorList.Add($str) | Out-Null
                    Write-Warning $str
                }
            }
        }
    }
}
 
if ($errorList.Count -gt 0) {
    Write-Error 'Commit cancelled, please correct before commiting.'
}
