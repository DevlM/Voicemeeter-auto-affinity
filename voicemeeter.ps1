# Vérifier les droits d'administration
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $MyInvocation.MyCommand.Path
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    Exit
}

# Fonction pour définir les priorités et affinités
function Set-ProcessAffinity {
    param (
        [System.Diagnostics.Process]$Process,
        [int]$CpuCore
    )
    try {
        $affinity = [IntPtr]::new([math]::Pow(2, $CpuCore))
        $Process.ProcessorAffinity = $affinity
        $Process.PriorityClass = "High"
        return $true
    } catch {
        Write-Output "Erreur lors de la configuration du processus $($Process.ProcessName): $_"
        return $false
    }
}

# Boucle jusqu'à ce que l'affinité soit appliquée
do {
    $audiodgProcess = Get-Process -Name audiodg -ErrorAction SilentlyContinue
    $voicemeeterProcess = Get-Process | Where-Object { $_.ProcessName -like "*voicemeeter*" }

    if ($null -ne $audiodgProcess -and $null -ne $voicemeeterProcess) {
        $numberOfCores = (Get-WmiObject Win32_ComputerSystem).NumberOfLogicalProcessors
        $lastCore = $numberOfCores - 1

        $audiodgSuccess = Set-ProcessAffinity -Process $audiodgProcess -CpuCore $lastCore
        $voicemeeterSuccess = Set-ProcessAffinity -Process $voicemeeterProcess -CpuCore $lastCore

        if ($audiodgSuccess -and $voicemeeterSuccess) {
            Write-Output "$(Get-Date -Format 'HH:mm:ss') - Configuration appliquée avec succès"
            Start-Sleep -Seconds 3
            # Sortie du script après application réussie
            Exit 0
        }
    } else {
        Write-Output "$(Get-Date -Format 'HH:mm:ss') - En attente des processus audiodg et voicemeeter..."
    }

    # Attendre 10 secondes avant la prochaine tentative
    Start-Sleep -Seconds 10
} while ($true)