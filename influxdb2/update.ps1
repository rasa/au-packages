import-module au

$releases = 'https://portal.influxdata.com/downloads'

function global:au_SearchReplace {
   @{
        ".\legal\VERIFICATION.txt" = @{
          "(?i)(\s+x64:).*"            = "`${1} $($Latest.URL64)"
          "(?i)(checksum64:).*"        = "`${1} $($Latest.Checksum64)"
        }
    }
}

function global:au_BeforeUpdate { Get-RemoteFiles -Purge -NoSuffix }

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing

    $re      = '(?<=wget )https://.+?/influxdb2-[0-9.]+-windows-amd64\.zip'
    $download_page.Content -match $re | Out-Null
    $url = $Matches[0]
    $version = $url -split '[-_]' | select -First 1 -Skip 1

    @{
        Version = $version
        URL64   = $url
    }
}


if ($MyInvocation.InvocationName -ne '.') { # run the update only if script is not sourced
    update -ChecksumFor none
}
