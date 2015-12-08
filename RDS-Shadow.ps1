<#
    Locate and Control Terminal Users
    Powershell
#>

# Hashtable of program details.
$PROGRAM = @{
    name = "RDS-Shadow";
    description = "Shadows RDS Terminal sessions.";
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

# Find a User to Control!
function FindUserOnTerminal {
    # Servers by Number
    $servers = ("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15");
    
    # Rename the Servers the lazy way.
    for($index = 0; $index -lt $servers.length; $index++){ $servers[$index] = 'SERVERPREFIX' + $servers[$index]; }
    
    # Ask who should befall our spell.
    $queriedUser= Read-Host "Who is the user you wish to control?";
    
    # If no user was given, exit.
    if ( $queriedUser.length -le 0) { exit; }
    
    Echo "Looking for: $queriedUser";
    
    # Replace spaces in between names with period.
    $queriedUser = $queriedUser -replace "\s","\.";

    # Amass potential clients from each server.
    $USERS = @();
    ForEach ( $server in $servers ) {
    
        # Query current server for users.
        $queryResults = (qwinsta /server:$server | foreach { (($_.trim() -replace "\s+",","))} | ConvertFrom-Csv);
        
        # Check Each User.
        ForEach ($queryResult in $queryResults) {
            $RDPUser = $queryResult.USERNAME;
            $sessionNumber= $queryResult.ID;
            
            
            # Is this a valid user?
            If (($RDPUser -match "[a-z]") -and ($RDPUser -ne $NULL)){ 
               
                # Is this like the user we want?
                If($queryResult.USERNAME -match $queriedUser){
                
                    # Grab the user's qualified information.
                    $user = @{ 
                        name = $queryResult.username;
                        session = @{
                            id = $queryResult.ID;
                            name = $queryResult.sessionname;
                            server = $server;
                        };
                    };
                    
                    # Add users to growing collection.
                    $USERS += $user;
                    
                    # Show the first user found.
                    Echo ("Found: {0} on server {1} in session {2}." -f $user.name, $server, $user.session.id);
                }
            }
        }
    }
    
    If ($users.length -gt 1) {
        AskWhichUserOnTerminal $USERS;
    } elseif ($users.length -eq 1) { 
        ControlUserOnTerminal $USERS[0];
    } else {
        Echo "No users were found.";
        Start-Sleep -milliseconds 500;

        &FindUserOnTerminal
    }
}

<# 
    * Determines which of multiple users we should control.
    * @param [hashtable] $user - User table of the aflicted user.
#>
function AskWhichUserOnTerminal {
    param([array]$users);
    
    Echo "Multiple Users found for query:";
    Echo "";
    
    # Display all users.
    for($index = 0; $index -lt $users.length; $index++) {
        Echo ("{0}. `t{1}" -f ($index + 1), $users[$index].name);
    }
    
    Echo "";
    
    # Ask which index is correct user.
    $id = Read-Host ("ID of user?");
    
    # If blank, return to find user screen. Otherwise try to control the user.
    if ($id -match "[0-9]+") {
        ControlUserOnTerminal $users[($id - 1)];
    } else {
        FindUserOnTerminal;
    }   
}

<# 
    * Initiates control of the user.
    * @param [hashtable] $user - User table of the aflicted user.
#>
function ControlUserOnTerminal{
    param([hashtable]$user);

    $server = $user.session.server;
    $session = $user.session.id;
    
    # Ask what level of control the controller desires.
    $Control  =  Read-Host ("Control {0}`? (Yes or No, will shadow if no):" -f $user.name);
    
    # If Control Level is unspecified, exit.
    if($Control.length -le 0) { FindUserOnTerminal; exit; }
            
    if($Control -match "(Y|y)(E|e)?(S|s)?\!?") { 
        mstsc /v:"$server" /shadow:"$session" /control /noConsentPrompt
    } else {
        mstsc /v:"$server" /shadow:"$session" /noConsentPrompt
    }
}

# Initial Run Statements.
function beginProgram {
    # Clear console for legibility.
    __CLEAR;
    __BANNER $PROGRAM;
    
    &FindUserOnTerminal;
}

# Begin program Execution.
&beginProgram;