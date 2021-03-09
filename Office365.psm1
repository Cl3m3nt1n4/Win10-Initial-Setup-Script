##########
#region Chocolatey
##########

## Install Chocolatey if not already installed
Function InstallChoco {
	Write-Host "Installing chocolatey..."
	$error.clear()
	try { choco feature enable --name=useRememberedArgumentsForUpgrades }
	catch { 
		Write-Host -nonewline "Install chocolatey? (Y/N) "
		$response = read-host
		if ( $response -ne "Y" ) { return; }
		Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	}
	if (!$error) {
		Write-Host "Chocolatey already installed."
	}
}

## Install all packages in Office365.txt
Function InstallChocoPkgs {
	$file = "$psscriptroot\Office365.txt"
	Write-Host "Installing all packages in $file that are not already installed..."
	if (Test-Path $file) {
        $toInstall = @()
        $params = @()
        foreach($line in Get-Content $file){
            $line = $line.split('|')
            $toInstall += $line[0]
            if (!($line[1] -eq "")) {
                $params += $line[1]
            }else {
                $params += ""
            }
        }
		if (!($toInstall.count -eq 0)) {
            $installed = [string[]](choco list --local-only | ForEach {"$_".Split(" ")[0]})
			$notInstalled = $toInstall | Where {$installed -NotContains $_}
			
			if (!($notInstalled.count -eq 0)){
				Write-Host "Found packages in $file that are not installed: $notInstalled"
				Write-Host -NoNewline "Install? (Y/N)"
				$response = read-host
				if ( $response -ne "Y" ) { return; }
				ForEach ($j in $notInstalled) {
                    $i = $toInstall.IndexOf($j)
                    $p = $params[$i]
                    Write-Host choco install $j $p -y 
					Invoke-Expression "choco install $j $p -y"
				}
			}else {
				Write-Host "All packages from $file installed."
			}
		}
	}else {
		Write-Host "Cannot find chocoInstall.txt."
	}
}

##########
#endregion Chocolatey
##########


# Export functions
Export-ModuleMember -Function *
