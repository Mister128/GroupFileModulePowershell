BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "../GroupFiles.psd1"
    Import-Module $modulePath -Force
}

AfterAll {
    Remove-Module GroupFile -ErrorAction SilentlyContinue
}

Describe "Group-File" {
    BeforeEach {
        $script:testDir = New-Item -Path "TestDrive:/TestFolder_$(Get-Random)" -ItemType Directory -Force
        Push-Location $script:testDir.FullName

        $script:testConfig = @{
            Rules = @(
                @{
                    Extensions          = @(".png", ".jpeg", ".jpg")
                    AllowedDirectories  = @("picture", "pictures", "images")
                    DefaultDirectory    = "pictures"
                },
                @{
                    Extensions          = @(".css")
                    AllowedDirectories  = @("css")
                    DefaultDirectory    = "css"
                },
                @{
                    Extensions          = @(".js")
                    AllowedDirectories  = @("js", "scripts")
                    DefaultDirectory    = "js"
                },
                @{
                    Extensions          = @(".html")
                    AllowedDirectories  = @("html")
                    DefaultDirectory    = "html"
                }
            )
        }

        Mock -ModuleName GroupFiles Get-GroupFileConfig {
            return $script:testConfig | ConvertTo-Json -Depth 5 | ConvertFrom-Json
        }
    }

    AfterEach {
        Get-ChildItem -Path $script:testDir.FullName -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Pop-Location
    }

    Context "Basic functionality" {
        It "Should sort files into existing directories" {
            New-Item "test.png"  -ItemType File -Force | Out-Null
            New-Item "test.jpeg" -ItemType File -Force | Out-Null
            New-Item "picture"   -ItemType Directory -Force | Out-Null

            Group-File

            "picture/test.png"  | Should -Exist
            "picture/test.jpeg" | Should -Exist
            "test.png"          | Should -Not -Exist
            "test.jpeg"         | Should -Not -Exist
        }

        It "Should handle multiple file types" {
            New-Item "style.css"  -ItemType File -Force | Out-Null
            New-Item "script.js"  -ItemType File -Force | Out-Null
            New-Item "index.html" -ItemType File -Force | Out-Null
            New-Item "css"        -ItemType Directory -Force | Out-Null
            New-Item "js"         -ItemType Directory -Force | Out-Null
            New-Item "html"       -ItemType Directory -Force | Out-Null

            Group-File

            "css/style.css"   | Should -Exist
            "js/script.js"    | Should -Exist
            "html/index.html" | Should -Exist
            "style.css"       | Should -Not -Exist
            "script.js"       | Should -Not -Exist
            "index.html"      | Should -Not -Exist
        }

        It "Should be case-insensitive for extensions" {
            New-Item "test.PNG" -ItemType File -Force | Out-Null
            New-Item "test.JPG" -ItemType File -Force | Out-Null
            New-Item "picture"  -ItemType Directory -Force | Out-Null

            Group-File

            "picture/test.PNG" | Should -Exist
            "picture/test.JPG" | Should -Exist
            "test.PNG"         | Should -Not -Exist
            "test.JPG"         | Should -Not -Exist
        }

        It "Should pick the first existing AllowedDirectory" {
            New-Item "test.png"   -ItemType File -Force | Out-Null
            New-Item "pictures"   -ItemType Directory -Force | Out-Null

            Group-File

            "pictures/test.png" | Should -Exist
            "test.png"          | Should -Not -Exist
        }

        It "Should skip directories starting with a dot" {
            New-Item "test.png"  -ItemType File -Force | Out-Null
            New-Item ".picture"  -ItemType Directory -Force | Out-Null
            New-Item "pictures"  -ItemType Directory -Force | Out-Null

            Group-File

            "pictures/test.png" | Should -Exist
            ".picture/test.png" | Should -Not -Exist
        }
    }

    Context "With -Force parameter" {
        It "Should create DefaultDirectory if no AllowedDirectory exists" {
            New-Item "test.png"  -ItemType File -Force | Out-Null
            New-Item "test.jpeg" -ItemType File -Force | Out-Null

            Group-File -Force

            "pictures/test.png"  | Should -Exist
            "pictures/test.jpeg" | Should -Exist
            "test.png"           | Should -Not -Exist
            "test.jpeg"          | Should -Not -Exist
        }

        It "Should overwrite existing files with -Force" {
            New-Item "test.png"        -ItemType File -Force | Out-Null
            New-Item "picture"         -ItemType Directory -Force | Out-Null
            Set-Content "picture/test.png" -Value "old content"

            Group-File -Force

            "picture/test.png" | Should -Exist
            "test.png"         | Should -Not -Exist
            Get-Content "picture/test.png" | Should -BeNullOrEmpty
        }
    }

    Context "Without -Force parameter" {
        It "Should NOT overwrite existing files" {
            New-Item "test.png"            -ItemType File -Force | Out-Null
            Set-Content "test.png" -Value "new content"
            New-Item "picture"             -ItemType Directory -Force | Out-Null
            Set-Content "picture/test.png" -Value "old content"

            Group-File

            "test.png" | Should -Exist
            Get-Content "test.png" | Should -Be "new content"
            Get-Content "picture/test.png" | Should -Be "old content"
        }

        It "Should warn and skip files when no target directory exists" {
            New-Item "test.png" -ItemType File -Force | Out-Null

            Group-File -WarningVariable warnings 3>$null

            "test.png" | Should -Exist
            $warnings | Should -Not -BeNullOrEmpty
        }
    }

    Context "With -Only parameter" {
        It "Should only process specified file extensions" {
            New-Item "style.css" -ItemType File -Force | Out-Null
            New-Item "script.js" -ItemType File -Force | Out-Null
            New-Item "test.png"  -ItemType File -Force | Out-Null
            New-Item "css"       -ItemType Directory -Force | Out-Null
            New-Item "js"        -ItemType Directory -Force | Out-Null

            Group-File -Only ".css"

            "css/style.css" | Should -Exist
            "style.css"     | Should -Not -Exist
            "script.js"     | Should -Exist
            "test.png"      | Should -Exist
        }

        It "Should process multiple specified extensions" {
            New-Item "style.css" -ItemType File -Force | Out-Null
            New-Item "script.js" -ItemType File -Force | Out-Null
            New-Item "test.png"  -ItemType File -Force | Out-Null
            New-Item "css"       -ItemType Directory -Force | Out-Null
            New-Item "js"        -ItemType Directory -Force | Out-Null

            Group-File -Only ".css", ".js"

            "css/style.css" | Should -Exist
            "js/script.js"  | Should -Exist
            "style.css"     | Should -Not -Exist
            "script.js"     | Should -Not -Exist
            "test.png"      | Should -Exist
        }

        It "Should be case-insensitive for -Only parameter" {
            New-Item "style.css" -ItemType File -Force | Out-Null
            New-Item "css"       -ItemType Directory -Force | Out-Null

            Group-File -Only ".CSS"

            "css/style.css" | Should -Exist
        }
    }

    Context "Path parameter" {
        It "Should work with custom path" {
            $customPath = New-Item -Path "TestDrive:/CustomPath_$(Get-Random)" -ItemType Directory -Force
            New-Item "$($customPath.FullName)/test.png" -ItemType File -Force | Out-Null
            New-Item "$($customPath.FullName)/picture"  -ItemType Directory -Force | Out-Null

            Group-File -Path $customPath.FullName

            "$($customPath.FullName)/picture/test.png" | Should -Exist
            "$($customPath.FullName)/test.png"         | Should -Not -Exist
        }

        It "Should throw on non-existent path" {
            { Group-File -Path "TestDrive:/DoesNotExist" } | Should -Throw
        }
    }

    Context "Edge cases" {
        It "Should do nothing when no files exist" {
            New-Item "picture" -ItemType Directory -Force | Out-Null

            { Group-File } | Should -Not -Throw
        }

        It "Should ignore files without matching rules" {
            New-Item "readme.md" -ItemType File -Force | Out-Null
            New-Item "data.xyz"  -ItemType File -Force | Out-Null

            Group-File

            "readme.md" | Should -Exist
            "data.xyz"  | Should -Exist
        }
    }
}