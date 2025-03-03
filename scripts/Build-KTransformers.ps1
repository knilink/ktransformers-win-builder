param (
    [string]$Reference = "main"  # Default branch is "main"
)

$ErrorActionPreference = "Stop"
$env:KTRANSFORMERS_FORCE_BUILD = "TRUE"

# Assert TORCH_CUDA_ARCH_LIST is set
if (-not $env:TORCH_CUDA_ARCH_LIST) {
    Write-Error "TORCH_CUDA_ARCH_LIST environment variable is not set."
    exit 1
}

$DistDir = "C:/dist"

# Assert ktransformers/dist exists
if (-not (Test-Path -Path ${DistDir})) {
    Write-Error "The directory '${DistDir}' does not exist. Please ensure it is mounted as an output folder."
    exit 1
}

git init C:/ktransformers
cd C:/ktransformers
git fetch https://github.com/kvcache-ai/ktransformers.git $Reference --depth 1
git checkout FETCH_HEAD
git submodule update --init --recursive --depth 1
pip install -r requirements-local_chat.txt
python ./setup.py bdist_wheel --dist-dir ${DistDir}
