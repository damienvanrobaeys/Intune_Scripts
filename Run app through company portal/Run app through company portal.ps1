start-process companyportal:ApplicationId=YourAppID
sleep 10
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[System.Windows.Forms.SendKeys]::SendWait("^{i}")
