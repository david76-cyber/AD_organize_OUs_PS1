# Load Active Directory module
Import-Module ActiveDirectory

# Set the path to your CSV file
$csvPath = "C:\Users\Administrator\Desktop\users.csv"

# Import the CSV
$users = Import-Csv -Path $csvPath

# Loop through each user
foreach ($user in $users) {
    # Construct the OU path (assuming OUs are under the domain root)
    # Change 'yourdomain.com' to your actual domain
    $ouPath = "OU=$($user.OU),DC=david,DC=com"

    # Construct the name and display name
    $name = "$($user.FirstName) $($user.LastName)"
    $samAccountName = $user.Username

    # Optional: Check if user already exists
    if (Get-ADUser -Filter "SamAccountName -eq '$samAccountName'" -ErrorAction SilentlyContinue) {
        Write-Host "User $samAccountName already exists. Skipping..." -ForegroundColor Yellow
        continue
    }

    # Create the user
    New-ADUser `
        -Name $name `
        -GivenName $user.FirstName `
        -Surname $user.LastName `
        -SamAccountName $samAccountName `
        -UserPrincipalName "$samAccountName@david.com" `
        -DisplayName $name `
        -Path $ouPath `
        -Department $user.Department `
        -AccountPassword (ConvertTo-SecureString "P@ssword123!" -AsPlainText -Force) `
        -Enabled $true `
        -ChangePasswordAtLogon $true

    Write-Host "Created user: $name in $ouPath" -ForegroundColor Green
}
