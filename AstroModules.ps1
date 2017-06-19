# NOTES
# Red = Resaults
# Green = Values

$format = @{Expression = {$_.pl_hostname}; Label = "HostStar"}, @{Expression = {$_.pl_letter}; Label = "PlanetName"; align = 'center'}, @{Expression = {$_.pl_discmethod}; Label = "DiscoveryMethod"; align = 'center'},
@{Expression = {$_.pl_pnum}; Label = "PlanetNum"; align = 'center'}, @{Expression = {$_.pl_orbper}; Label = "OrbitPer(E)"; align = 'center'}, @{Expression = {$_.ra_str}; Label = "RA"; align = 'center'}, 
@{Expression = {$_.dec_str}; Label = "DEC"; align = 'center'}, @{Expression = {$_.rowupdate}; Label = "RowUpdate"; align = 'center'}

$TableList = @{
    'Confirmed Planets' = @('Exoplanets', 'Multiexopars')
    'KOI (Cumulative)'  = @('cumulative', 'q1_q17_dr24_koi', 'q1_q16_koi', 'q1_q12_koi', 'q1_q8_koi', 'q1_q6_koi')              
}

function preDefined {
    Write-Host "Pre-defined search queries from caltech.edu"
    Write-Host @"
    1. Confirmed planets in the Kepler field (default columns)
    2. Stars known to host exoplanets listed in ascending order
    3. Confirmed planets that transit their host stars (default columns)
    4. A current list of non-confirmed planet candidates
    5. K2 targets from campaign 9
    6. Confirmed planets in the Mission Star list
    7. All default parameters for one particular KOI or another
    8. All microlensing planets with time series
    9. All planetary candidates smaller than 2Re with equilibrium temperatures between 180-303K
"@

    $input = Read-Host -Prompt "_> "

    switch ($input) {
        1 {$data = Invoke-RestMethod "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?&table=exoplanets&format=JSON&where=pl_kepflag=1"}
        2 {$data = Invoke-RestMethod "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?&table=exoplanets&select=distinct pl_hostname&order=pl_hostname&format=JSON"}
        3 {$data = Invoke-RestMethod "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?&table=exoplanets&format=JSON&where=pl_tranflag=1"}
        4 {$data = Invoke-RestMethod "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?&table=cumulative&format=JSON&where=koi_disposition%20like%20%27CANDIDATE%27"}
        5 {$data = Invoke-RestMethod "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?&table=k2targets&format=JSON&where=k2_campaign=9"}
        6 {$data = Invoke-RestMethod "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?&table=missionstars&format=JSON&where=st_ppnum>0"}
        7 {$data = Invoke-RestMethod "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?&table=koi&format=JSON&where=kepoi_name='K00007.01' OR kepoi_name='K00742.01'"}
        8 {$data = Invoke-RestMethod "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?&table=exoplanets&format=JSON&where=pl_discmethod%20like%20%27Microlensing%27%20and%20st_nts%20%3E%200"}
        9 {$data = Invoke-RestMethod "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?table=cumulative&where=koi_prad%3C2%20and%20koi_teq%3E180%20and%20koi_teq%3C303%20and%20koi_disposition%20like%20%27CANDIDATE%27&format=JSON"}
        q {Menu}
    }

    $data | ft -AutoSize $format | Out-File $PSScriptRoot\OutLog_PreDefined_$($input).txt
    $data | ft -AutoSize $format

    Write-Host @"
    ############################################################
    ## Outlog_PreDefined_$($input).txt created in script root ##
    ############################################################`r`n
"@
    # Opening the text file for the user.
    notepad $PSScriptRoot\OutLog_PreDefined_$($input).txt
}

function planetOverview {
    write-host "Planet Overview"

    $planet = Read-Host -Prompt "Planet Name_> "
    $url = "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?&table=exoplanets&select=pl_hostname,pl_letter,pl_discmethod,pl_orbper,pl_orbsmax,pl_orbincl,pl_bmassj,pl_radj,pl_dens,ra,dec&where=pl_name%20like%20%27$($planet)%27&format=JSON"
    $data = Invoke-RestMethod $url

    $HostName = $data.pl_hostname
    $Letter = $data.pl_letter
    $DiscMeth = $data.pl_discmethod
    $OrbPer = $data.pl_orbper
    $OrbsMax = $data.pl_orbsmax
    $OrbIncl = $data.pl_orbincl
    $Massj = $data.pl_bmassj
    $Radj = $data.pl_radj
    $Dens = $data.pl_dens
    $RA = $data.ra
    $DEC = $data.dec

    $PlanetInfo = @"
################################################################################
                        ##    $($planet)    ##
                        ######################
`r`nGeneral Info on $($planet):
`tPlanet Letter:                     $($Letter)
`tHost Star:                         $($HostName)
`tDicovery Method:                   $($DiscMeth)

Orbit Info on $($planet):
`tOrbit Period (E-Days):             $($OrbPer)
`tOrbit Semi-Major Axis (AU):        $($OrbsMax)
`tOrbit Inclination:                 $($OrbIncl)

Planet Size Info on $($planet):
`tPlanet Mass (Unit: Jupiter):       $($Massj)
`tPlanet Radius (Unit: Jupiter):     $($Radj)
`tPlanet Density:                    $($Dens)

$($planet) location in sky:
`tRight Ascension:                   $($RA)
`tDeclination:                       $($DEC)

################################################################################`r`n
"@ 

    Write-Host $PlanetInfo -ForegroundColor Green
    $PlanetInfo | Out-File -Append "C:\Users\$($env:UserName)\Dropbox\Coding\Powershell\AstroAPI\Planets.txt"

}

function writeOwn {
    $base_url = 'http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?'
    $query = Read-Host -Prompt "Each query component should be seperated with a ; EG: 'table=exoplanets;select=pl_hostname;where=pl_pnum>3'`r`n  _> "

    $query = $query.Replace(";", "&")

    $url = $base_url + $query + "&format=JSON"

    $q_breakdown = $query.Split("&")
    Write-Host "`r`nQuery Breakdown`r`n--------------------"
    foreach ($item in $q_breakdown) {
        $item = $item.Split("=")
        Write-Host "$($item[0]): $($item[1])"
    }

    $data = Invoke-RestMethod $url
    
    $data | ft -AutoSize
    $data | ft -AutoSize | Out-File "C:\Users\$($env:UserName)\Dropbox\Coding\Powershell\AstroAPI\OwnQuery_Outlog.txt"

}

function qWizard {

    Write-Host @"
                                    QWizard
    ----------------------------------------------------------------------------
               For all table, column and data names please see
    http://exoplanetarchive.ipac.caltech.edu/docs/program_interfaces.html#data

            I have tried to make it as easy as I can to create
            your own query without learning the correct syntax

    ----------------------------------------------------------------------------

            Tables are split into categories for ease of use.
            Please select what category you'd like to explore.`r`n
"@
    $iNum = 1
    foreach ($Key in $TableList.Keys) {
        Write-Host "`t$($iNum): $($Key)"
        $iNum += 1
    }

    $Table = Read-Host -Prompt "_> "

    switch ($Table) {
        1 {$TableList.'KOI (Cumulative)'}
        2 {$TableList.'Confirmed Planets'}
    }

    $Table_Sel = Read-Host -Prompt "Please select a table from this catagory _> "
    switch ($Table_Sel) {
        1 {}
    }
}
