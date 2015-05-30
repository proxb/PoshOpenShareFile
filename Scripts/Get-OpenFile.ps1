Function Get-OpenFile {
    <#
    #>
    [OutputType('System.Io.File.OpenFile')]
    [cmdletbinding()]
    Param(
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$Computername = $env:COMPUTERNAME,
        [parameter(ValueFromPipelineByPropertyName=$True)]
        [string]$Username
    )
    Begin {
        $MAX_PREFERRED_LENGTH = -1
        [int]$ReadEntries = 0
        [int]$TotalEntries = 0
        $Buffer = [intptr]::Zero        
    }
    Process {
        ForEach ($Computer in $Computername) {
            $Return = [PoshOpenShareFile]::NetFileEnum(
                $Computer,
                $Null,
                $Username,
                3,
                [ref]$Buffer,
                $MAX_PREFERRED_LENGTH,
                [ref]$ReadEntries,
                [ref]$TotalEntries,
                [intptr]::Zero
            )
            If ($Return -eq 0) {
                $CurrentFile = New-Object FILE_INFO_3
                For ($i=0; $i -lt $ReadEntries; $i++) {
                    $Pointer = New-Object IntPtr -ArgumentList ($Buffer.ToInt64() + $i * [System.Runtime.InteropServices.Marshal]::SizeOf($CurrentFile))
                    $CurrentFile = [System.Runtime.InteropServices.Marshal]::PtrToStructure($Pointer, [type][FILE_INFO_3])
                    $Object = [pscustomobject]@{
                        Computername = $Computer
                        Fullname = $CurrentFile.fi3_pathname
                        UserName = $CurrentFile.fi3_username
                        Permission = ConvertTo-Permission -PermissionFlag $CurrentFile.fi3_permission
                        ID = "0x{0:x}" -f $CurrentFile.fi3_id
                        NumLocks = $CurrentFile.fi3_num_locks
                    }
                    $Object.pstypenames.insert(0,'System.Io.File.OpenFile')
                    $Object
                }
            } Else {
                Write-Warning "$($Computer): Issue occurred reading open files! <$($Return)>"
            }
        }
    }
}