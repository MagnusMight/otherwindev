function Figuringout {
   $home = David
    $Buka = Buka
    if ($Home -like $Buka){
        Write-Host "Buka likes David"
        exit 0
    }
    else{
        Write-host "David likes buka"
        exit 1
    }
}

Figuringout 

# Function to fetch a random joke from the Chuck Norris API
function Get-RandomJoke {
    $url = "https://api.chucknorris.io/jokes/random"
    $joke = Invoke-RestMethod -Uri $url
    $joke.value
}

# Display a Chuck Norris joke
Write-Host "Here's a Chuck Norris joke for you:"
Get-RandomJoke