# Define the JDK path
$env:JAVA_HOME="G:/jdk-17/"
$env:ANDROID_SDK_ROOT=$PSScriptRoot
$env:ANDROID_AVD_HOME=$PSScriptRoot

# Define the URL and the output file name
$url = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$outputFile = "$PSScriptRoot\cmdline-tools.zip"
$extractedFolder = "$PSScriptRoot\cmdline-tools"

# Download and extract the zip file only if the folder doesn't already exist
if (-Not (Test-Path $extractedFolder)) {
    # Download the zip file
    Invoke-WebRequest -Uri $url -OutFile $outputFile

    # Extract the zip file to the current directory
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($outputFile, $PSScriptRoot)

    # Remove the zip file after extraction
    Remove-Item $outputFile
}

# Run all them commands

$env
& "$PSScriptRoot\cmdline-tools\bin\sdkmanager.bat" --sdk_root=.
& "$PSScriptRoot\cmdline-tools\bin\sdkmanager.bat" --sdk_root=. --install "platform-tools"
& "$PSScriptRoot\cmdline-tools\bin\sdkmanager.bat" --sdk_root=. --install "platforms;android-32"
& "$PSScriptRoot\cmdline-tools\bin\sdkmanager.bat" --sdk_root=. --install "system-images;android-32;google_apis_playstore;x86_64"
& echo "no" | & "$PSScriptRoot\cmdline-tools\bin\avdmanager.bat" create avd -n emu -k "system-images;android-32;google_apis_playstore;x86_64"


# Define the path to the .ini file
$iniFilePath = "$PSScriptRoot\emu.avd\config.ini"

# Define the replacement lines
$replacementLines = @(
    "image.sysdir.1=$PSScriptRoot\system-images\android-32\google_apis_playstore\x86_64\",
    "PlayStore.enabled=yes",
    "hw.lcd.height=1920",
    "hw.lcd.width=1080"
)

# Read the content of the .ini file
$content = Get-Content $iniFilePath

# Iterate through each line in the content
$newContent = $content | ForEach-Object {
    # Check if the line matches any of the patterns to be replaced
    foreach ($replacementLine in $replacementLines) {
        if ($_ -match "^\s*($($replacementLine.Split('=')[0]))=.*") {
            # Replace the line with the new line
            $replacementLine
            return
        }
    }
    # Otherwise, keep the original line
    $_
}

# Write the modified content back to the .ini file
$newContent | Set-Content $iniFilePath



$env
& ".\emulator\emulator.exe" -avd emu
