Function Close-OpenFile {
    [cmdletbinding(
        SupportsShouldProcess = $True
    )]
    Param (
        [parameter(ValueFromPipeline=$True)]
        [object]$InputObject
    )
    Process {
        If ($PSCmdlet.ShouldProcess("$($_.Fullname) <$($_.UserName)>", 'Close File')) {
            $Return = [PoshOpenShareFile]::NetFileClose($_.Computername, $_.Id)
        }
    }
}