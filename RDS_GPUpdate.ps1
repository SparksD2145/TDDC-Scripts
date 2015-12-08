<#
    Powershell Template Mixin
    Powershell
#>


# Hashtable of program details.
$PROGRAM = @{
    name = "RDS GPUpdate";
    description = "RDS Group Policy Updater";
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

# { Program Functions Here }

# Initial Run Statements.
function beginProgram {
    # Clear console for legibility.
    __CLEAR;
    __BANNER $PROGRAM;
    
    $adminUser = "user\domain";
    
    # Grab Credentials
    $passwd = Read-Host -AsSecureString "Password for $adminUser";

    # Convert Credentials
    $credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $adminUser,$passwd

    # Grab Servers by UID
    $servers = ("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15");
    
    # Rename the Servers the lazy way.
    for($index = 0; $index -lt $servers.length; $index++){ $servers[$index] = 'SERVERPREFIX' + $servers[$index]; }

    foreach ($server in $servers) {
        __BR;
        
        Echo "Running GPUPDATE on $server";

        Invoke-Command -ComputerName $server -Credential $credentials -ScriptBlock { gpupdate /force }

        __BR;
    }
}

# Begin program Execution.
&beginProgram;