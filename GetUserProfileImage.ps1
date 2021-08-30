# 資格情報を入力する
$UserCredential = Get-Credential  

# Exchage Onlineを接続する
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

# 次のコマンドを実行します。
Import-PSSession $Session -DisableNameChecking

# ルートパスの指定※＜ローカルのフォルダー＞
$rootPath = "C:\test"

# 写真フォルダー
$imageFolder = "images"
# ログフォルダー
$logFolder = "log"
# ユーザーを指定する設定ファイル
$csvName = "users.csv"

# 絶対パス"$($assoc.Id) - $($assoc.Name) - $($assoc.Owner)"
$imagePath = "$rootPath\$imageFolder\"
$logPath = "$rootPath\$logFolder\"
$csvFile = "$rootPath\$csvName"

# logファイル
$nowDate = Get-Date -Format "yyyyMMdd_HHmmss"
$logName = "log_"+ $nowDate +".txt"
$LogFile = $logPath + $logName

# CSVファイルを読込み
$Users = Import-Csv $csvFile

# imageフォルダーを生成
New-Item -ItemType directory -Path $imagePath -Force
# ログフォルダーを生成
New-Item -ItemType directory -Path $logPath -Force

# logファイルを生成
New-Item -ItemType File -Path $LogFile

Foreach ($user in $Users) {
    $userName = ($user.UserName -Split "@")[0] 
    $path = $imagePath + $userName + ".jpg"
    $photo = Get-Userphoto -identity $user.UserName -ErrorAction SilentlyContinue
    If ($photo.PictureData -ne $null) {
        [io.file]::WriteAllBytes($path, $photo.PictureData)
        $Message="成功"
        $logMessage=[string]$userName + "," + $Message
        Write-Host $logMessage
        Write-Output $logMessage | Out-file $LogFile -append
    }
    else 
    {
        $emptyMessage="無し"
        $logEmptyMessage=[string]$userName + "," + $emptyMessage
        Write-Host $logEmptyMessage
        Write-Output $logEmptyMessage | Out-file $LogFile -append
    }

}

#終了
Remove-PSSession $Session