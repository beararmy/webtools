###

# Config
$userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:78.0) Gecko/20100101 Firefox/78.0"

# The site URL, then the string that implies no
$negative_sites_to_check = @{
    "https://www.ybs.co.uk/mortgages/95-percent.html"                                              = "for the time being we are currently unable to accept applications above 85% Loan to Value"
    "https://personal.natwest.com/personal/mortgages/offers-and-schemes/95-percent-mortgages.html" = "t currently offer any 95"
    "https://www.hsbc.co.uk/mortgages/first-time-buyers/"                                          = "mortgages at the moment because of the coronavirus outbreak"
    "https://www.barclays.co.uk/mortgages/first-time-buyers/rates/"                                = "These rates are currently unavailable"
}

# The site URL, then the string that implies yes
$positive_sites_to_check = @{
    "https://www.newcastle.co.uk/mortgages/our-mortgage-products/"           = "class=`"table-rates__rate`">95%</td>"
    "https://mortgages.firstdirect.com/mortgage-rates-fees/list-rates"       = "with 95% LTV and interest rate"
    "https://www.leedsbuildingsociety.co.uk/mortgages/fixed-rate-mortgages/" = "`"Max LTV`">95%"
    "https://www.skipton.co.uk/mortgages/first-time-buyers/products"         = "95%"
    "https://www.ibs.co.uk/mortgages/our-mortgage-products/fixed-rate"       = "95%"
    "https://www.postoffice.co.uk/mortgages/fixed-rate"                      = "(95% loan to value)"
}

$json_returning_sites_to_check = @(
    "https://www.nationwide.co.uk/services/toolservice.svc/GetMortgageSelectorRates?buyerType=ftb&loanToValueTier=91&mortgageTerm=25&mortgageAmount=0&depositAmount=29250&additionalBorrowingAmount=0&propertyValue=325000&isHelpToBuy=0&isSaveToBuy=0&isFdm=0&isGreen=0&mortgageType=all&dealPeriod=&productFee=all&_=1597770911201"
    "https://www.coventrybuildingsociety.co.uk/bin/cbs/mortgage/search?tag=buy_a_home&ltv=91"
)

$negative_sites_to_check.GetEnumerator() | ForEach-Object {
    $site = Invoke-WebRequest -Uri $_.key -UserAgent $userAgent -Method Get -UseBasicParsing
    $status = $site.RawContent -match $_.value
    $siteroot = $_.key.Split("/")[2]
    if ($status -eq $true) {
        #Write-Output "For $siteroot, result was $status, so still nothing on offer"
    }
    else {
        Write-Error "Offer found" -CategoryTargetName "Something's on offer!" -ErrorId "Go check out $siteroot"
    }    
}

$positive_sites_to_check.GetEnumerator() | ForEach-Object {
    $site = Invoke-WebRequest -Uri $_.key -UserAgent $userAgent -Method Get -UseBasicParsing
    $status = $site.RawContent -match $_.value
    $siteroot = $_.key.Split("/")[2]
    if ($status -eq $false) {
        #Write-Output "For $siteroot, result was $status, so still nothing on offer"
    }
    else {
        Write-Error "Offer found" -CategoryTargetName "Something's on offer!" -ErrorId "Go check out $siteroot"
    }     
}

foreach ($site in $json_returning_sites_to_check) {
    $result = Invoke-WebRequest -uri $site -UserAgent $userAgent -UseBasicParsing
    $result = ( $result | ConvertFrom-Json)
    if ($result.Rates) {
        $result = $result.Rates
    }
    $siteroot = $site.Split("/")[2]

    if ($result.Count -gt 0) {
        Write-Error "Offer found" -CategoryTargetName "Something's on offer!" -ErrorId "Go check out $siteroot"
    }
    else {
        #Write-Output "For $siteroot, no results, so still nothing on offer"
    }
}
