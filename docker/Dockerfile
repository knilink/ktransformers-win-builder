# escape=`

# https://learn.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2022
# Use the latest Windows Server Core 2022 image.
FROM mcr.microsoft.com/windows/servercore:ltsc2022 as base
# install choco
RUN powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"



FROM base as cudatookit
# https://community.chocolatey.org/packages/cuda#versionhistory
ARG CUDA_VERSION
RUN choco install -y cuda --version %CUDA_VERSION%




FROM base

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2022
RUN `
    # Download the Build Tools bootstrapper.
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe `
    `
    # Install Build Tools with the Microsoft.VisualStudio.Workload.AzureBuildTools workload, excluding workloads and components with known issues.
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
    --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    --add Microsoft.VisualStudio.Component.VC.CMake.Project `
    --add Microsoft.VisualStudio.Component.Windows11SDK.22621 `
    || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
    `
    # Cleanup
    && del /q vs_buildtools.exe

ENV DISTUTILS_USE_SDK=1

# Install build tools
RUN choco install -y git --cache C:/cache
# https://community.chocolatey.org/packages/python#versionhistory
ARG PYTHON_VERSION
RUN choco install -y python --version=%PYTHON_VERSION% --cache C:/cache

RUN pip install setuptools wheel packaging ninja --cache-dir C:/cache

# install pytorch
# https://pytorch.org/get-started/locally/
ARG TORCH_INDEX_URL
RUN pip3 install torch --index-url %TORCH_INDEX_URL% --cache-dir C:/cache


ARG CUDA_PATH
COPY --from=cudatookit ${CUDA_PATH} ${CUDA_PATH}

ENV CUDA_PATH=${CUDA_PATH}

# Create a hardcoded script using PowerShell
RUN powershell -Command "Out-File -FilePath C:\entrypoint.bat -Encoding ASCII -InputObject \"call `\"C:/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/Common7/Tools/VsDevCmd.bat`\" -arch=amd64`npowershell.exe -NoLogo -ExecutionPolicy Bypass %*\""


# Define the entry point for the docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["entrypoint.bat"]
