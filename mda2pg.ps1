param (
    [string]$OutDir
 )

# Get settings from Config.xml.
$xmlSettings = [xml](Get-Content "mda2pg.xml")
$settings = $xmlSettings.Settings

if($settings.Git.CopyToRepo.ToLower() -eq "true") {
	# Delete all files and folder excepts git
	Get-ChildItem -Path $settings.Git.Path -Recurse -Force | Where-Object {$_.FullName -NotMatch ".git"} | Remove-Item -Recurse -Force

	# Copy files to the repo linked to Phonegap
	Copy-Item "$OutDir\*" $settings.Git.Path -Recurse -Exclude "mda2pg.ps1","mda2pg.xml","Cordova.js","cordova_plugins.js","*.sln"
}

# Add changes, commit and push to git repository
Set-Location $settings.Git.Path
git add -A
git commit -m "New build for build.phonegap.com"
Write-Host "Code committed"
git push --all --quiet
Write-Host "Code pushed"

# Get PhoneGap Build access token
$uri = "https://build.phonegap.com/authorize?client_id=" + $settings.PhoneGap.ClientId + "&client_secret=" + $settings.PhoneGap.ClientSecret + "&auth_token=" + $settings.PhoneGap.AuthToken
$result = Invoke-RestMethod -Method POST -Uri $uri
$pgAccess_Token = "?access_token=" + $result.access_token

# PhoneGap Build gets latest code and builds
$uri = "https://build.phonegap.com/api/v1/apps/" + $settings.PhoneGap.AppId + $pgAccess_Token
$json = "data={""pull"":""true""}"
$result = Invoke-RestMethod -Method PUT -Uri $uri -ContentType "multipart/form-data" -Body $json
Write-Host "PhoneGap Build is starting..."

# Wait until PhoneGap Build finish building
do  {
	Start-Sleep -s 2
	$uri = "https://build.phonegap.com/api/v1/apps/" + $settings.PhoneGap.AppId + $pgAccess_Token
	$result = Invoke-RestMethod -Method GET -Uri $uri
}while (($result.status.ios -eq "pending") -or ($result.status.android -eq "pending") -or ($result.status.winphone -eq "pending"))
Write-Host "PhoneGap Build just finished!"

if($settings.Mail.Send.ToLower() -eq "true") {
	# Sending Mail
	if($settings.Mail.Encrypted.ToLower() -eq "true") {
    	$pwd = ConvertTo-SecureString -String $settings.Mail.Password
	}
	else {	
		$pwd = ConvertTo-SecureString $settings.Mail.Password -AsPlainText -Force
	}
	$cred = New-Object System.Management.Automation.PSCredential $settings.Mail.Username,$pwd
	if($settings.Mail.Ssl.ToLower() -eq "true") {
		$ssl = $true
	}
	$param = @{
		SmtpServer = $settings.Mail.Server
		Port = $settings.Mail.Port
		UseSsl = $ssl
		Credential  = $cred
		From = $settings.Mail.From
		To = $settings.Mail.To
		Subject = $settings.Mail.Subject
		Body = $settings.Mail.Body.InnerText
	}
	Send-MailMessage @param
	Write-Host "Email sent!"
}