function Get-DefaultConfig {
    <#
    .SYNOPSIS
        Returns the default configuration structure.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    return @{
        Rules = @(
            @{
                Extensions          = @(".png", ".jpeg", ".jpg")
                AllowedDirectories  = @("picture", "pictures", "images")
                DefaultDirectory    = "images"
            },
            @{
                Extensions          = @(".css")
                AllowedDirectories  = @("css", "styles")
                DefaultDirectory    = "styles"
            },
            @{
                Extensions          = @(".js")
                AllowedDirectories  = @("js", "scripts")
                DefaultDirectory    = "scripts"
            },
            @{
                Extensions          = @(".html")
                AllowedDirectories  = @("html", "pages")
                DefaultDirectory    = "pages"
            }
        )
    }
}