# Script from http://poshcode.org/?show=928
function Get-VMHostWSManInstance {
        param (
        [Parameter(Mandatory=$TRUE,HelpMessage="VMHosts to probe")]
        [VMware.VimAutomation.Client20.VMHostImpl[]]
        $VMHost,
     
        [Parameter(Mandatory=$TRUE,HelpMessage="Class Name")]
        [string]
        $class,
     
        [switch]
        $ignoreCertFailures,
     
        [System.Management.Automation.PSCredential]
        $credential=$null
        )
     
        $omcBase = "http://schema.omc-project.org/wbem/wscim/1/cim-schema/2/"
        $dmtfBase = "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/"
        $vmwareBase = "http://schemas.vmware.com/wbem/wscim/1/cim-schema/2/"
     
        if ($ignoreCertFailures) {
                $option = New-WSManSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
        } else {
                $option = New-WSManSessionOption
        }
        foreach ($H in $VMHost) {
                if ($credential -eq $null) {
                        $hView = $H | Get-View -property Value
                        $ticket = $hView.AcquireCimServicesTicket()
                        $password = convertto-securestring $ticket.SessionId -asplaintext -force
                        $credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $ticket.SessionId, $password
                }
                $uri = "https`://" + $h.Name + "/wsman"
                if ($class -cmatch "^CIM") {
                        $baseUrl = $dmtfBase
                } elseif ($class -cmatch "^OMC") {
                        $baseUrl = $omcBase
                } elseif ($class -cmatch "^VMware") {
                        $baseUrl = $vmwareBase
                } else {
                        throw "Unrecognized class"
                }
                Get-WSManInstance -Authentication basic -ConnectionURI $uri -Credential $credential -Enumerate -Port 443 -UseSSL -SessionOption $option -ResourceURI "$baseUrl/$class"
        }
}

$sVcenter = ""
$sVcUser = ""
$sVcPassword = ""
$sHostName = ""

Connect-VIserver -Server $sVcenter -User $sVcUser  -Password $sVcPassword

Get-VMHostWSManInstance -VMHost (Get-VMHost $sHostName) -ignoreCertFailures -class OMC_IPMIIPProtocolEndpoint