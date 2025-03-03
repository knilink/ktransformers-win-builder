param (
  [string]$CudaVersion,
  [switch]$RebuildBuildImage = $false,
  [string]$CompilerMemory = "8G",
  [string]$CompilerCpus = "4",
  [string]$Reference = "main",
  [string]$TorchCudaArchList = $null,
  [string]$PythonVersion = $null
)

function Get-PythonVersion {
  if ($PythonVersion) {
    return $PythonVersion
  }
  # Try to get Python version using 'python --version'
  try {
    $pythonVersion = & py -3 --version 2>&1 | ForEach-Object { $_ -replace 'Python ', '' }
  }
  catch {
    # If 'python --version' fails, try 'py -3 --version'
    try {
      $pythonVersion = & python --version 2>&1 | ForEach-Object { $_ -replace 'Python ', '' }
    }
    catch {
      Write-Error "Failed to get Python version. Ensure Python is installed and accessible."
      exit 1
    }
  }
  return $pythonVersion
}

if (-not $TorchCudaArchList) {
  $TorchCudaArchList = & nvidia-smi --query-gpu=compute_cap --format=csv -i 0 | Select-Object -Skip 1
}

$cudaVersionSplit = $CudaVersion.Split('.')

$pythonVersion = Get-PythonVersion
$pythonVersionSplit = $pythonVersion.Split('.')


$ImageName = "ktransformers-builder:cp$($pythonVersionSplit[0])$($pythonVersionSplit[1])cu$($cudaVersionSplit[0])$($cudaVersionSplit[1])"

if (-not $(docker images ${ImageName} --format "True") -or $RebuildBuildImage) {
  docker build `
    --memory="2GB" `
    --build-arg "CUDA_VERSION_MAJOR=$($cudaVersionSplit[0])" `
    --build-arg "CUDA_VERSION_MINOR=$($cudaVersionSplit[1])" `
    --build-arg "CUDA_VERSION_PATCH=$($cudaVersionSplit[2])" `
    --build-arg "CUDA_DRIVER_VERSION=$($cudaVersionSplit[3])" `
    --build-arg "PYTHON_VERSION_MAJOR=$($pythonVersionSplit[0])" `
    --build-arg "PYTHON_VERSION_MINOR=$($pythonVersionSplit[1])" `
    --build-arg "PYTHON_VERSION_PATCH=$($pythonVersionSplit[2])" `
    -t ${ImageName} `
    docker
}

New-Item -ItemType Directory -Path ${PSScriptRoot}\dist -Force | Out-Null

docker run --rm -it `
  --memory=${CompilerMemory} `
  --cpus=${CompilerCpus} `
  -e TORCH_CUDA_ARCH_LIST="${TorchCudaArchList}" `
  -e MAX_JOBS=${CompilerCpus} `
  -v ${PSScriptRoot}\scripts:"C:\scripts" `
  -v ${PSScriptRoot}\dist:"C:\dist" `
  ${ImageName} -File "C:/scripts/Build-KTransformers.ps1" -Reference ${Reference}
