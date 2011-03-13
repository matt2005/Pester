$pwd = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$pwd\Setup.ps1"
. "$pwd\..\Pester.ps1"

Describe "Create filesystem with directories" {
    
    Setup -Dir "dir1"
    Setup -Dir "dir2"

    It "creates directory when called with no file content" {
        $result = Test-Path "$env:Temp\pester\dir1"
        $result.should.be($true)
    }

    It "creates another directory when called with no file content and doesnt remove first directory" {
        $result = Test-Path "$env:Temp\pester\dir2"
        $result = $result -and (Test-Path "$env:Temp\pester\dir1")
        $result.should.be($true)
    }
}

Describe "Create nested directory structure" {
   
    Setup -Dir "parent/child"

    It "creates parent directory" {
        $result = Test-Path "$env:Temp\pester\parent"
        $result.should.be($true)
    }

    It "creates child directory underneath parent" {
        $result = Test-Path "$env:Temp\pester\parent\child"
        $result.should.be($true)
    }
}

Describe "Create a file with no content" {

    Setup -File "file"

    It "creates file" {
        $result = Test-Path "$env:Temp\pester\file"
        $result.should.be($true)
    }

    It "also has no content" {
        $result = Get-Content "$env:Temp\pester\file"
        $result = ($result -eq $null)
        $result.should.be($true)
    }
}

Describe "Create a file with content" {

    Setup -File "file" "file contents"

    It "creates file" {
        $result = Test-Path "$env:Temp\pester\file"
        $result.should.be($true)
    }

    It "adds content to the file" {
        $result = Get-Content "$env:Temp\pester\file"
        $result.should.be("file contents")
    }
}

