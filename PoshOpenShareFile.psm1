$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

#region Build Pinvoke
#region Module Builder
$Domain = [AppDomain]::CurrentDomain
$DynAssembly = New-Object System.Reflection.AssemblyName('PoshOpenShareFileAssembly')
$AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run) # Only run in memory
$ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('PoshOpenShareFile', $False)
#endregion Module Builder

#region Structs
$Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
$ctor = [System.Runtime.InteropServices.MarshalAsAttribute].GetConstructor(@([System.Runtime.InteropServices.UnmanagedType]))
$CustomAttribute = [System.Runtime.InteropServices.UnmanagedType]::LPWStr
$CustomAttributeBuilder = New-Object System.Reflection.Emit.CustomAttributeBuilder -ArgumentList $ctor, $CustomAttribute 
#region FILE_INFO_3 STRUCT
$STRUCT_TypeBuilder = $ModuleBuilder.DefineType('FILE_INFO_3', $Attributes, [System.ValueType], 8)
[void]$STRUCT_TypeBuilder.DefineField('fi3_id', [int], 'Public')
[void]$STRUCT_TypeBuilder.DefineField('fi3_permission', [int], 'Public')
[void]$STRUCT_TypeBuilder.DefineField('fi3_num_locks', [int], 'Public')
$PathNameField = $STRUCT_TypeBuilder.DefineField('fi3_pathname', [string], 'Public')
$PathNameField.SetCustomAttribute($CustomAttributeBuilder)
$UserNameField = $STRUCT_TypeBuilder.DefineField('fi3_username', [string], 'Public')
$UserNameField.SetCustomAttribute($CustomAttributeBuilder)
[void]$STRUCT_TypeBuilder.CreateType()
#endregion FILE_INFO_3 STRUCT
#endregion Structs

#region Initialize Type Builder
$TypeBuilder = $ModuleBuilder.DefineType('PoshOpenShareFile', 'Public, Class')
#endregion Initialize Type Builder

#region Methods
#region NetFileEnum METHOD
$PInvokeMethod = $TypeBuilder.DefineMethod(
    'NetFileEnum', #Method Name
    [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
    [int], #Method Return Type
    [Type[]] @(
        [string],                 # servername
        [string],                 # basepath
        [string],                 # username
        [int],                    # level
        [intptr].MakeByRefType(), # buffer
        [int],                    # maxlength
        [int].MakeByRefType(),    # entriesread
        [int].MakeByRefType(),    # totalentries
        [intptr]                  # resume_handle
    ) #Method Parameters
)
$DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
$FieldArray = [Reflection.FieldInfo[]] @(
    [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
    [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError'),
    [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling'),
    [Runtime.InteropServices.DllImportAttribute].GetField('CharSet')
)

$FieldValueArray = [Object[]] @(
    'NetFileEnum', #CASE SENSITIVE!!
    $True,
    $True,
    [System.Runtime.InteropServices.CharSet]::Unicode
)

$SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder(
    $DllImportConstructor,
    @('netapi32.dll'),
    $FieldArray,
    $FieldValueArray
)

$PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
#endregion NetFileEnum METHOD

#region NetFileClose METHOD
$PInvokeMethod = $TypeBuilder.DefineMethod(
    'NetFileClose', #Method Name
    [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
    [int], #Method Return Type
    [Type[]] @(
        [string], # servername
        [int]     # id
    ) #Method Parameters
)
$DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
$FieldArray = [Reflection.FieldInfo[]] @(
    [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
    [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
    [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling'),
    [Runtime.InteropServices.DllImportAttribute].GetField('CharSet')
)

$FieldValueArray = [Object[]] @(
    'NetFileClose', #CASE SENSITIVE!!
    $True,
    $True,
    [System.Runtime.InteropServices.CharSet]::Unicode
)

$SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder(
    $DllImportConstructor,
    @('netapi32.dll'),
    $FieldArray,
    $FieldValueArray
)

$PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
#endregion NetFileClose METHOD
#endregion Methods

#region Create Type
[void]$TypeBuilder.CreateType()
#endregion Create Type

#region Private Functions
Function ConvertTo-Permission {
    Param ($PermissionFlag)
    $List = New-Object System.Collections.ArrayList
    Switch ($PermissionFlag) {
        ($PermissionFlag -BOR 0x00000001)  {[void]$List.Add('FILE_READ')}
        ($PermissionFlag -BOR 0x00000002)  {[void]$List.Add('FILE_WRITE')}
        ($PermissionFlag -BOR 0x00000004)  {[void]$List.Add('FILE_CREATE')}
        ($PermissionFlag -BOR 0x00000008)  {[void]$List.Add('ACCESS_EXEC')}
        ($PermissionFlag -BOR 0x00000010)  {[void]$List.Add('ACCESS_DELETE')}
        ($PermissionFlag -BOR 0x00000020)  {[void]$List.Add('ACCESS_ATRIB')}
        ($PermissionFlag -BOR 0x00000040)  {[void]$List.Add('ACCESS_PERM')}
    }
    $List -join '+'
}    
#endregion Private Functions

#region Load Public Functions
Try {
    Get-ChildItem "$ScriptPath\Scripts" -Filter *.ps1 | Select -Expand FullName | ForEach {
        $Function = Split-Path $_ -Leaf
        . $_
    }
} Catch {
    Write-Warning ("{0}: {1}" -f $Function,$_.Exception.Message)
    Continue
}
#endregion Load Public Functions

#region Aliases
New-Alias -Name gop -Value Get-OpenFile
New-Alias -Name cop -Value Close-OpenFile
#endregion Aliases

#region Load Type and Format Files
## Update-FormatData "$ScriptPath\TypeData\PoshFileHandle.Format.ps1xml"
#endregion Load Type and Format Files

Export-ModuleMember -Alias * -Function '*-OpenFile'