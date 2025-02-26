param (
  [string]$Preset = $null,
  [switch]$BuildImageOnly = $false,
  [string]$TorchCudaArchList = "8.9;8.6;7.5;6.1",
  [string]$CompilerMemory = "8G",
  [string]$CompilerCpus = "4",
  [string]$Branch = "main"
)

if ($Preset) {
  . $Preset
}

$ImageName = "ktransformers-builder:${ImageTag}"

docker build `
  -m 2GB `
  --build-arg "CUDA_VERSION=${CudaVersion}" `
  --build-arg "CUDA_PATH=${CudaPath}" `
  --build-arg "PYTHON_VERSION=${PythonVersion}" `
  --build-arg "TORCH_INDEX_URL=${TorchIndexUrl}" `
  -t ${ImageName} `
  docker


if ($BuildImageOnly) {
  exit 0
}


New-Item -ItemType Directory -Path ${PSScriptRoot}\dist -Force | Out-Null

docker run --rm -it `
  --memory=${CompilerMemory} `
  --cpus=${CompilerCpus} `
  -e TORCH_CUDA_ARCH_LIST=${TorchCudaArchList} `
  -v ${PSScriptRoot}\scripts:"C:\scripts" `
  -v ${PSScriptRoot}\dist:"C:\dist" `
  ${ImageName} -File "C:/scripts/Compile-KTransformers.ps1" -RemoteBranch ${Branch}
