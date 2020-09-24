<#
.SYNOPSIS
   PHP-Unit alias, make easier to run phpunit on command line
.AUTHOR
   Christophe AVONTURE
.EXAMPLE

    Display the help screen
    powershell .\php-unit.ps1 -help

    Run the script
    powershell .\php-unit.ps1
#>
param (
    # Show the help screen
    [switch] $help = $false,
    [parameter(Position=0, Mandatory=$false)][String]$path="tests",
    [parameter(Position=1, Mandatory=$false)][String]$filter=""
)
begin {

    # Force variable declaration
    Set-StrictMode -Version 2.0

    # Name of the tool to run
    Set-Variable TOOL -option Constant -value "phpunit"

    # Repository from where to download the tool
    Set-Variable REPOSITORY -option Constant -value "https://github.com/sebastianbergmann/phpunit"

    # Binary of the tool that should be retrieved on the system
    Set-Variable BINARY -option Constant -value "vendor\bin\phpunit.bat"

    # Configuration file
    Set-Variable CONFIGURATION -option Constant -value "phpunit.xml"

    # Path to the script that we'll use (f.i. vendor\bin\phpunit)
    $global:bin = ""

    # Path to the configuration file if there is one (f.i phpunit.xml)
    $global:config = ""

    # Full name of this script
    $global:me = ""

    <#
    .SYNOPSIS
        Display the help screen
    .OUTPUTS
        void
    #>
    function showHelp() {

        Write-Host " $TOOL - utility" -ForegroundColor Green

        Write-Host $(
            "`n Usage: $TOOL [-help] <path>`n"
        ) -ForegroundColor Cyan

        Write-Host $(
            " -help           Show this screen`n"
        )

        Write-Host $(
            " <path>          Name of a folder (like 'tests\core') or a file (like 'tests\api\check.php'); default is 'tests'`n"
        )
        Write-Host $(
            " <filter>        Optional, if mentioned, name of f.i. a function to execute. Same as the --filter option of phpunit.`n"
        )
        Write-Host $("Some examples`n-------------`n")
        Write-Host $("phpunit                               ") -ForegroundColor Cyan -NoNewline
        Write-Host $("run every tests present in the tests sub-folder (no folder was mentioned so, " +
            "by default, folder name is tests),")
        Write-Host $("phpunit tests\api                     ") -ForegroundColor Cyan -NoNewline
        Write-Host $("run every tests in the tests\api folder,")
        Write-Host $("phpunit tests\api testNameOfAFunction ") -ForegroundColor Cyan -NoNewline
        Write-Host $("browse any tests in the tests\api folder and only run the testNameOfAFunction function,")
        Write-Host $("phpunit tests\webservices\consume.php ") -ForegroundColor Cyan -NoNewline
        Write-Host $("run any tests present in the tests\webservices\consume.php file.")

        return
    }

     <#
    .SYNOPSIS
        Retrieve the executable (f.i. the phpunit binary)
    .OUTPUTS
        void
    #>
    function getBinary() {
        # Binary to use
        $currentDir = "$(Get-Location)"

        if (Test-Path -Path "$currentDir\$BINARY" -PathType Leaf) {
            # Installed as a local dependency of the project
            $global:bin = "$currentDir\$BINARY"
        }

        if ([string]::IsNullOrEmpty($global:bin)) {
            # Check if installed as a global dependency
            if (Test-Path -Path "$($env:APPDATA)\composer\$BINARY" -PathType Leaf) {
                $global:bin = "$($env:APPDATA)\composer\$BINARY"
            }
        }

        if ([string]::IsNullOrEmpty($global:bin)) {
            Write-Host "Sorry $TOOL is missing on your system" -ForegroundColor Red
            Write-Host $("Please install it from $REPOSITORY")
            exit 99
        }

    }

    <#
    .SYNOPSIS
        Retrieve the configuration file (f.i. phpunit.xml)
    .OUTPUTS
        void
    #>
    function getConfiguration() {
        # Binary to use
        $currentDir = "$(Get-Location)"

        if (Test-Path -Path "$currentDir\.config\$CONFIGURATION" -PathType Leaf) {
            # Configuration file retrieved in the project structure, .config subfolder
            $global:config = "$currentDir\.config\$CONFIGURATION"
        }

        if ([string]::IsNullOrEmpty($global:config)) {
            # Check if the configuration can be retrieved in the project root structure
            if (Test-Path -Path "$currentDir\$CONFIGURATION" -PathType Leaf) {
                $global:config = "$currentDir\$CONFIGURATION"
            }
        }

        if ([string]::IsNullOrEmpty($global:config)) {
            Write-Host "No configuration file retrieved" -ForegroundColor Gray
        } else {
            $global:config = "--configuration $global:config"
        }
    }

    function doJob() {

        Write-Host $(
            " ===============`n" +
            " = Run $TOOL =`n" +
            " ===============`n"
        )

        Write-Host " Running $($global:me)`n" -ForegroundColor Cyan

        getBinary
        getConfiguration

        Write-Host $(" Binary: $global:bin `n Config: $global:config`n Path:   $path") -ForegroundColor DarkGray

        if (-not ([string]::IsNullOrEmpty($filter))) {
            $filter = "--filter '$filter'"
            Write-Host $(" Filter: $filter`n") -ForegroundColor DarkGray
        }

        Write-Host $("`n Start:  $global:bin $global:config $path $filter`n") -ForegroundColor Yellow

        $startTime = (Get-Date)
        Start-Process "$global:bin" -ArgumentList "$global:config $path $filter" -NoNewWindow -Wait
        $endTime = (Get-Date)

        Write-Host $("`n Unit tests duration: {0:mm} min {0:ss} sec" -f ($endTime-$startTime)) -ForegroundColor Green

        return
    }

    #region Entry point
    if ($help) {
        showHelp
        exit
    }

    $global:me = "$($PSScriptRoot)\$($MyInvocation.MyCommand.Name)"

    doJob

    #endregion Entry point
}
