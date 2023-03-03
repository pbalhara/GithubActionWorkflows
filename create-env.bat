@echo off

REM Get the PROCESSOR_ARCHITECTURE
set arch=x86_64
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
  set arch=x86
)

REM Install the GitHub CLI if it's not already installed
if not exist "%ProgramFiles%\GitHub CLI\gh.exe" (
    rem Download the latest version of the GitHub CLI for Windows
    echo Downloading the latest version of the GitHub CLI...
    curl -L -o gh.zip https://github.com/cli/cli/releases/latest/download/gh_${{ arch }}_windows.zip
    
    rem Extract the GitHub CLI zip file to a temporary directory
    mkdir %TEMP%\gh
    tar -xzf gh.zip -C %TEMP%\gh

    rem Install the GitHub CLI to the system
    xcopy /Y %TEMP%\gh\gh_*_windows\gh.exe %SystemRoot%\System32
    xcopy /Y %TEMP%\gh\gh_*_windows\gh-completion.bash %SystemRoot%\System32\drivers\etc

    rem Add the GitHub CLI directory to the system's PATH
    setx /M PATH "%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0;%SystemRoot%\System32\OpenSSH;C:\Program Files\GitHub CLI"

    echo GitHub CLI has been installed and added to the system PATH.
)

echo "asd"

rem Check if jq is already installed
where jq >nul 2>nul
if %errorlevel% equ 0 (
  echo jq is already installed.
) else (
  rem Download the latest version of jq for Windows
  echo Downloading the latest version of jq...
  curl -L -o jq.exe https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe

  rem Create a directory for jq and move the executable
  mkdir C:\jq
  move jq.exe C:\jq

  rem Add jq to the system's PATH environment variable
  setx /M PATH "%PATH%;C:\jq"

  echo jq has been installed and added to the system PATH.
)


REM Authenticate with GitHub and fetch the secrets
gh auth login
@REM set SECRETS=$(gh secret list -e LOCAL --json | jq -r '.[].name')

@REM REM Loop over the secrets and write them to the .env file
@REM (for %%s in (%SECRETS%) do (
@REM     set SECRET_VALUE=$(curl -s -H "Authorization: Bearer %GITHUB_TOKEN%" https://api.github.com/repos/your-username/your-repo/actions/secrets/%%s | jq -r '.secret.value')
@REM     echo %%s=%%SECRET_VALUE%%
@REM )) > .env

set GH_ENV_NAME=$(curl -s -H "Authorization: Bearer %GITHUB_TOKEN%" https://api.github.com/repos/your-username/your-repo/actions/secrets/ENV_NAME | jq -r '.secret.value')
set GH_SECRET_2=$(curl -s -H "Authorization: Bearer %GITHUB_TOKEN%" https://api.github.com/repos/your-username/your-repo/actions/secrets/SECRET_2 | jq -r '.secret.value')

REM Write the secrets to the .env file
echo ENV_NAME=%GH_ENV_NAME% > .env
echo GH_SECRET_2=%GH_SECRET_2% >> .env


echo .env file created.

exit /b

