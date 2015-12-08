&AskWho;

function AskWho {
    # Ask who should befall our spell.
    $queriedUser= Read-Host "You are reseting the password of whom?";
    
    # If no user was given, exit.
    if ( $queriedUser.length -le 0) { AskWho; }

    &AllocateUsers($queriedUser);
}
function AllocateUsers {
    param([string]$userString);

    # Replace spaces in between names with period.
    #$userString = $userString -replace "\s","\.";

    # Allocate Users
    $users = Get-ADUser -Filter * | `
                Where { $_.SamAccountName -match $userString } | `
                Sort -Property Name

    ECHO $users;
    
    If ($users.length -gt 1) {
        &AskWhichUser $users;

    } elseif ($users.length -eq 1) { 
        &ResetPassword $users[0];

    } else {
        Echo "No users were found.";
        Start-Sleep -milliseconds 500;

        &AskWho;
    }
}

function AskWhichUser {
    param([array]$users);
    
    Echo "Multiple Users found for query:";
    Echo "";
    
    # Display all users.
    for($index = 0; $index -lt $users.length; $index++) {
        Echo ("{0}. `t{1}" -f ($index + 1), $users[$index].Name);
    }
    
    Echo "";
    
    # Ask which index is correct user.
    $id = Read-Host ("ID of user?");
    
    # If blank, return to find user screen. Otherwise try to control the user.
    if ($id -match "[0-9]+") {
        &ResetPassword $users[($id - 1)];
    } else {
        &AskWho;
    }   
}
function ResetPassword {
    param([object]$user);

    $defaultPassword = ConvertTo-SecureString "ThisIsADefaultPasswordThatMustBeChanged" -asPlainText -Force;

    Set-ADAccountPassword $user.DistinguishedName -Reset -NewPassword $defaultPassword -PassThru | Echo
    Set-ADUser $user -ChangePasswordAtLogon $true

    Echo "Password Reset!"
}