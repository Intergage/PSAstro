<#
Notes
### THIS IS TO FORMAT THE OUTPUT FILE
* $format = @{Expression={$_.pl_hostname};Label="HostStar"}, @{Expression={$_.pl_letter};Label="PlanetName";align='center'}, @{Expression={$_.pl_discmethod};Label="DiscoveryMethod";align='center'},
* @{Expression={$_.pl_pnum};Label="PlanetNum";align='center'}, @{Expression={$_.pl_orbper};Label="OrbitPer(E)";align='center'}, @{Expression={$_.ra_str};Label="RA";align='center'}, 
* @{Expression={$_.dec_str};Label="DEC";align='center'}, @{Expression={$_.rowupdate};Label="RowUpdate";align='center'}

* $data | select pl_hostname, pl_letter, pl_discmethod, pl_pnum, pl_orbper, ra_str, dec_str, rowupdate | sort pl_hostname | ft $format | Out-File $PSScriptRoot\preDefined-Out.txt
###


#>


. C:\Users\$env:UserName\Dropbox\Coding\Powershell\AstroAPI\AstroModules.ps1

Write-Host @"
`r`n`t###################################################
`t## Welcome to the Exo-Planet Archive API Search" ##
`t###################################################`r`n
"@
function Menu{
    $cont = $True
    while($cont){
        Write-Host @"
    `thttp://exoplanetarchive.ipac.caltech.edu

        1. Pre-Defeined Search Queries
        2. Write Own Query
        3. QWizard
        4. Planet Overview`r`n
"@

            $input = Read-Host -Prompt "`t_> "

            switch ($input.ToLower()) {
                1 {preDefined}
                2 {writeOwn}
                3 {qWizard}
                4 {planetOverview}
                q {Write-Host "Bye"; $cont = $false}
                }
        }

}

Menu
