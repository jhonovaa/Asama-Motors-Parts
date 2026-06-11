$ErrorActionPreference = "Stop"
try {
    $SmtpClient = new-object system.net.mail.smtpClient
    $SmtpClient.Host = 'smtp.gmail.com'
    $SmtpClient.Port = 587
    $SmtpClient.EnableSsl = $true
    $SmtpClient.Credentials = New-Object System.Net.NetworkCredential('asamaadmim@gmail.com', 'Sa31478.')
    $SmtpClient.Send('asamaadmim@gmail.com', 'asamaadmim@gmail.com', 'Test', 'Test')
    Write-Host "Success!"
} catch {
    Write-Host "Failed!"
    Write-Host $_.Exception.Message
    if ($_.Exception.InnerException) {
        Write-Host "Inner: " $_.Exception.InnerException.Message
    }
}
