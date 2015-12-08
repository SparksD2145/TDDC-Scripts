<#
    Powershell Template Mixin
    Powershell
#>

# Hashtable of program details.
$PROGRAM = @{
    name = "TITLE";
    description = "DESCRIPTION";
    version = "0.0.0";
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

<# 
    Displays a menu, and returns the result.
    @param [array] $menuItems - The menu items to list.
    @param [hashtable[string]] $menu - Menu hashtable containing various text fields.
        $menu.header.text - If header is specified, it must include text.
        [$menu.header.textColor] - Color of header text, optional.
        [$menu.header.highlightColor] - Color of background behind text, optional.
        $menu.prompt - The prompt to display to the user.

        Colors accepted: Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow,
                            Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White
#>
function __MENU {
    param([hashtable]$menu, [array]$menuItems);
    
    # Check if provided menu items array is empty.
    if (!$menuItems) { return $false }

    # Add a Blank Line to separate.
    __BR;

    # If header was provided, display Header.
    if ($menu.header -and $menu.header.text) {
        
        # Begin building a Write-Host command.
        $headerCMD = "Write-Host ";
        
        # If header's text color was specified, append it to the command.
        if($menu.header.textColor) { $headerCMD += ("-foregroundcolor {0} " -f $menu.header.textColor); }

        # If header's highlight/background color was specified, append it to the command.
        if($menu.header.textColor) { $headerCMD += ("-backgroundcolor {0} " -f $menu.header.highlightColor); }

        # Append Header text.
        $headerCMD += ("{0}" -f $menu.header.text);

        # Display Header
        Invoke-Expression $headerCMD;

        # Add a Blank Line to separate.
        __BR;
    }

    # Display Menu Items
    for($index = 0; $index -lt $menuItems.length; $index++) {
        Write-Host ("{0}.`t{1}" -f ($index + 1), $menuItems[$index]);
    }
    
    # Add a Blank Line to separate.
    __BR;

    # Grab user's choice.
    $choice = Read-Host $menu.prompt;

    # Return $false if the user's selection is out of range.
    if ((($choice - 1) -lt 0) -or ($choice -gt $menuItems.length)) { return $false; }

    return $menuItems[$choice - 1];
}

# Creates a Blank Line (line break).
function __BR {
    Write-Host "";
}

# Clears the console.
function __CLEAR {
    Clear-Host;
}

# Prompts user for data.
function __PROMPT {
    param([string]$prompt, [scriptblock]$evaluate);

    # If no prompt, exit returning false.
    if(!$prompt) { return $false; }

    $result = Read-Host $prompt;

    if (!$evaluate) {
        return $result;
    } else {
        return &$evaluate $result;
            
    }

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
    
    # { program statements here. }
}

# Begin program Execution.
&beginProgram;