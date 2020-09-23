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
    [parameter(Position=0, Mandatory=$false)][String]$path="tests"
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

    <#
    .SYNOPSIS
        Display the help screen
    .OUTPUTS
        void
    #>
    function showHelp() {

        Write-Host " $TOOL - utility" -ForegroundColor Green

        Write-Host $(
            "`n Usage: php-unit [-help] <path>`n"
        ) -ForegroundColor Cyan

        Write-Host $(
            " -help           Show this screen`n"
        )

        Write-Host $(
            " <path>          Name of a folder (like 'tests\core') or a file (like 'tests\api\check.php'); default is 'tests'`n"
        )

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

        getBinary
        getConfiguration

        Write-Host $(" Binary: $global:bin `n Config: $global:config`n Path:   $path`n") -ForegroundColor DarkGray

        Start-Process "$global:bin" -ArgumentList "$global:config $path" -NoNewWindow -Wait

        return
    }

    #region Entry point
    if ($help) {
        showHelp
        exit
    }

    doJob
    #endregion Entry point
}
