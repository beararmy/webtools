$uri = "https://www.bsac.com/events/"
$classname = "grid-cell u-md-size1of2 u-lg-size1of4"
$coursesToIgnore = "x"
$userAgent = "x"
$page = 1
$usefulstuff = ""
$VerbosePreference = "Continue"


$output = @()
$response = Invoke-WebRequest -Uri "$uri`?p=$page"
$usefulstuff += $response.ParsedHtml.body.getElementsByClassName($classname) | Select-Object *innertext*
$page++

while ($finalpage -eq $false) {
    $usefulstuff += $response.ParsedHtml.body.getElementsByClassName($classname) | Select-Object *innertext*
    $page++
    $finalpage = $response.Content.Contains("sorry")
}

foreach ($row in $usefulstuff) {
    $row.innerText | ForEach-Object {
        $title = $row.innerText.Split("`r`n")[2]
        $datesLoc = $row.innerText.Split("`r`n")[4]
        $datesLoc = $datesLoc.Replace("00:00:00.0 ", "")
        
        if ($row.innerText -like "*£*") {
            # Fix Prices
            $price = $row.innerText.Split("`r`n")[6]

            if ($price -like "*Free*") {
                $price = "Free"
            }
            $price = $price.Replace("Prices from: ", "")
        }
        else {
            $price = "Titties"
        }
        
        $dates, $location = $datesLoc -split "[^0-9- ]", 2
        
        $location = $datesLoc -replace "[0-9- ]"
        
        # Add to the object
        $output += New-Object -TypeName psobject -Property @{Title = $title; Dates = $dates; Location = $location; Price = $price }
    }
}

$output