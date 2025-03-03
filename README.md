# ktransformers-win-builder

`ktransformers-win-builder` is a Docker-based build system designed to compile and package the [`ktransformers`](https://github.com/kvcache-ai/ktransformers) library on windows hassle-free.

## Prerequisites

Before you begin, ensure that:
- You have [Docker Desktop](https://www.docker.com/products/docker-desktop) installed on your machine.
- You have [switch to windows containers](https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=dockerce#windows-10-and-11-1).
- Your C: drive has at least **40GB** of free disk space, as the built Docker image can be around 30GB. Or relocate the storage with black magic.

## Quickstart
Assuming your build target is CUDA 12.6. You can run the script directly or create a custom configuration as needed.
```powershell
git clone https://github.com/yourusername/ktransformers-win-builder.git
cd ktransformers-win-builder
.\run.ps1 -CudaVersion 12.6.3.561
```
This will build the Docker image and start the compilation process. Output can be found in `dist` folder.
Then
```powershell
pip install ./dist/ktransformers-*-win_amd64.whl
```

### Explanations:
- `-CudaVersion 12.6.3.561`: REQUIRED, Specifies the CUDA Toolkit version. The format needs to be exactly `{major}.{minor}.{patch}.{dirver version}`. [Find out more available version](https://community.chocolatey.org/packages/cuda#versionhistory).
- `-PythonVersion 3.12.9`: Specifies the CUDA Toolkit version. If not provided, default to host machine's python version. The format needs to be exactly `{major}.{minor}.{patch}`
- `-TorchCudaArchList "8.9;8.6;7.5;6.1"`: Specifies the CUDA architectures which match your GPU's. Use `nvidia-smi --query-gpu=compute_cap --format=csv` to find out yours. If not provided, default to host machine's cuda arch. [Find out more](https://developer.nvidia.com/cuda-gpus).
- `-CompilerMemory "8G" -CompilerCpus "4"`: There is a chance that `ninja` builder will run out of heap space if the resource is too limited, lower ram may work but I have only tested with "8G".
- `-Reference "v0.2.2rc2"`: Specifies the git reference to build, can be either git branch, tag, commit hash or PR (`pull/<pr-number>/head`). This [fix](https://github.com/kvcache-ai/ktransformers/pull/622) is required to successfully build on windows. Defaults to "main".

### Other Pre-compiled dependencies:
- `flash-attn`: https://github.com/kingbri1/flash-attention/releases or can be manually compiled from source using this image
- `triton`: https://github.com/woct0rdho/triton-windows/releases

### My settings:
- Build: `.\run.ps1 -CudaVersion 12.6.3.561 -PythonVersion 3.12.9 -Reference 48b9800`
- Runtime:
  - CUDA: 12.8, DRIVER: 572.16
  - python: 3.12.1
  - torch: 2.7.0.dev20250302+cu128
  - flash_attn: 2.7.4.post1
  - triton: v3.2.0.post10
- Run: `python -m ktransformers.local_chat --gguf_path C:/models/DeepSeek-R1-Q2_K_XS --model_path deepseek-ai/DeepSeek-R1`

## Known issues:
- `DLL load failed while importing KTransformersOps`: pytoch cuda is overridden by cpu version when installing `ktransformers`, make sure `python -c "import torch ; print(torch.cuda.is_available())"` is `True` otherwise **force reinstall** pytorch cuda https://pytorch.org/get-started/locally/
- `-Python 3.12.1` could fail installing pytorch when building docker image
- `Failed to find MSVC`: If `ktransformers` failed to run due to runtime compilation is required, try to run `ktransformers` in [Visual Studio Developer Terminal](https://learn.microsoft.com/en-us/visualstudio/ide/reference/command-prompt-powershell?view=vs-2022#start-from-windows-menu) assuming Visual Studio and its C++ workload is installed on your machine.

## Notes
- Downloading and installing Visual Studio Build Tools component could take very long time, check network and CPU usage if unsure about whether it's hanging or not.
- To debug or build manually, run `docker run --rm -it --memory="8G" -v </path/to/ktransformers>:"C:/ktransformers" ktransformers-builder:<tag>` to enter a shell environment with all dependencies installed.
- Image building and source compiling may hang if running out of disk space.
- Remember to cleanup unwanted images and containers to free up space, and switch back to Linux container if needed.
