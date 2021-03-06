function Get-Checksum
{
    process
    {
        if ($_ -eq $null)
        {
            $sumstring = $null
        }
        else
        {
			$paramType = ($_.GetType().NameSpace + "." + $_.GetType().Name)
			# $DebugPreference = [System.Management.Automation.ActionPreference]::Continue
			Write-Debug ("`$_ type is $paramType")
			# $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
			if ($paramType -eq "System.String")
			{
				$fileItem = (get-item $_)
			}
			else
			{
				$fileItem = $_
			}
		
            $sumstring = checksum( $fileItem)
        }
        @{File=$fileItem.FullName; MD5Hash=$sumstring; LastWriteTime=$fileItem.LastWriteTime} `
			| New-HashObject
    }
}

# -----------------------------------------------------  checksum  -----------------------------------------------------

function checksum( $aFile, $aCryptoProvider)
#
# Simple function not following Verb-Noun name format because it doesn't process the pipeline.  Intended to be called by
# a function that DOES process the pipeline.
#
{
    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
    try
    {
        if ($aCryptoProvider -eq $null)
        {
            $csp = new-object System.Security.Cryptography.MD5CryptoServiceProvider
        }
        else
        {
            $csp = $aCryptoProvider
        }
		$paramType = ($aFile.GetType().NameSpace + "." + $aFile.GetType().Name)
		# $DebugPreference = [System.Management.Automation.ActionPreference]::Continue
		Write-Debug ("`$aFile type is $paramType")
		# $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
		if ($paramType -eq "System.String")
		{
			$stream = (get-item $aFile).OpenRead()
		}
		else
		{
			$stream = $aFile.OpenRead()
		}
        $hashbytev = $csp.ComputeHash($stream)
        $sumstring = ""
        foreach ($byte in $hashbytev) 
        { 
            $sumstring += $byte.ToString("x2")
        }
    }
    finally
    {
		$ErrorActionPreference = $oldErrorActionPreference
        if ($stream -ne $null)
        {
            $stream.close() | Out-Null
        }
    }
	return $sumstring
}
