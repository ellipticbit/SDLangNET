param (
	[Parameter(Mandatory=$true)][int]$IsDebugBuild
)

If ($IsDebugBuild -eq 0) {
	Get-ChildItem -Path .\ServiceInSight.Client\bin\Release -Include *.dll, *.exe -Recurse -File | ForEach-Object {
		$file = $_.FullName 
		& "C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x64\signtool.exe" sign /sm /as /tr http://timestamp.digicert.com /td sha256 /fd sha256 /a $file
	}
} Else {
	Get-ChildItem -Path .\ServiceInSight.Client\bin\Debug -Include *.dll, *.exe -Recurse -File | ForEach-Object {
		$file = $_.FullName 
		& "C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x64\signtool.exe" sign /sm /as /tr http://timestamp.digicert.com /td sha256 /fd sha256 /a $file
	}
}
