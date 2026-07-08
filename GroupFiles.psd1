@{
    RootModule          = 'GroupFiles.psm1'
    ModuleVersion       = '1.1.0'
    GUID                = '7a978e76-a107-44ec-a1f4-56fd8e0a7ba3'
    Author              = 'MisterY'
    CompanyName         = 'Community'
    Copyright           = '(c) 2026 MisterY. All rights reserved.'
    Description         = 'Groups files into directories based on JSON rules'
    PowerShellVersion   = '6.0'
    CompatiblePSEditions = @('Desktop', 'Core')
    FunctionsToExport   = 'Group-File'
    CmdletsToExport     = @()
    AliasesToExport     = @()

    PrivateData = @{
        PSData = @{
            Tags = @('files', 'organize', 'sort', 'directories', 'utility', 'PSEdition_Desktop', 'PSEdition_Core')
            License = 'https://github.com/Mister128/GroupFileModulePowershell/blob/main/LICENSE'
            ProjectUri = 'https://github.com/Mister128/GroupFileModulePowershell'
        }
    }
}