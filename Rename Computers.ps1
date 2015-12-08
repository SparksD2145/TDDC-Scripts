<#
    Powershell Template Mixin
    Powershell
#>


# Hashtable of program details.
$PROGRAM = @{
    name = "Rename Computers";
    description = "Rename Computers example script.";
    version = "1.0.0";
    author = "Thomas Ibarra, Developer";
};

<# ---- Begin Generic, Reusable Functions ---- #>

<# 
    Display a program Banner to the user.
    @param [hashtable] $program - A hashtable containing relevant details of the program to display in the banner.
        [string] $program.name - Name of the program.
        [string] $program.version - Version of the program.
        [string] $program.description - Description of the program.
        [string[]] $program.contributors - A string array of contributors, ex: @("Thomas Ibarra, Developer")
#>
function __BANNER {
    param([hashtable]$program);

    # Write a blank line to separate.
    __BR;

    # Create a string that matches the length of the program's name with spaces, for fancy title.
    $spacing = "";
    for ($index = 0; $index -lt $program.name.Length; $index++){
        $spacing += " ";
    }

    # Display Fancy-shmancy Title
    Write-Host -ForegroundColor "White"    -BackgroundColor "White" -NoNewline ("      {0}      " -f $spacing);
    Write-Host ("`t{0}" -f $program.description);

    Write-Host -ForegroundColor "DarkBlue" -BackgroundColor "White" -NoNewline ("*   - {0} -   *" -f $program.name);
    Write-Host ("`tVersion {0}" -f $program.version);

    Write-Host -ForegroundColor "White"    -BackgroundColor "White" -NoNewline ("      {0}      " -f $spacing);
    Write-Host ("`tAuthor: {0}" -f $program.author);

    # Write a few blank lines to separate.
    __BR; 
}

# Creates a Blank Line (line break).
function __BR {
    Write-Host "";
}

# Clears the console.
function __CLEAR {
    Clear-Host;
}


<# ------------------------------------------ #>
<# ---- BEGIN PROGRAM-SPECIFIC FUNCTIONS ---- #>
<# ------------------------------------------ #>

function Example {
    param($credentials);

    $tag = "DA";
    $computers = @(
        @{ Name = "COMPUTER1"; NewName = "" },
        @{ Name = "COMPUTER2"; NewName = "" },
        @{ Name = "COMPUTER3"; NewName = "" }
    );
    
    RenameComputers -Credentials $credentials -Computers $computers -Tag $tag -Restart:$false
}

function PingComputers {
    param(
        [array]$Computers
    );
    
    foreach($computer in $Computers){
        __BR;
        ping $computer.Name;
    }
}

function MessageUsers {
    param(
        $Credentials,
        [array]$Computers
    );
    
    foreach($computer in $Computers){
        Invoke-Command -ComputerName $computer.Name -Credential $credentials -ScriptBlock `
            { msg * /V /W "Message from TDDC IT Support:`n`nPlease let Claire Smith know where you are in the building, we are trying to rename your PC.`n`nThanks!" }
    }
}


function RenameComputers {
    param(
        $Credentials,
        [array]$Computers,
        [string]$Tag,
        [switch]$Restart = $false

    );
    
    foreach($computer in $Computers){
        if($restart) {
            Rename-Computer -DomainCredential $Credentials -ComputerName $computer.Name -NewName ($Tag + $computer.NewName) -Restart -Force;
        } else {
            Invoke-Command -ComputerName $computer.Name -Credential $credentials -ScriptBlock { msg * "Message from ---COMPANY_NAME_HERE--- IT Support:`n`nPlease reboot your machine when convenient.`nYou will not be able to log in until you do.`n`nThanks!" }
            Rename-Computer -DomainCredential $Credentials -ComputerName $computer.Name -NewName ($Tag + $computer.NewName);
        }
    }
}


# Initial Run Statements.
function beginProgram {
    # Clear console for legibility.
    __CLEAR;
    __BANNER $PROGRAM;
    
    $user = 'domain\user'
    
    # Grab Credentials
    $passwd = Read-Host -AsSecureString "Password for $user";

    # Convert Credentials
    $credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd

    Example $credentials;
}

# Begin program Execution.
&beginProgram;