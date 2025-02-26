# ktransformers-win-builder

`ktransformers-win-builder` is a Docker-based build system designed to compile and package the `ktransformers` library on windows hassle-free.

## Prerequisites

Before you begin, ensure that:
- You have [Docker Desktop](https://www.docker.com/products/docker-desktop) installed on your machine.
- You have [switch to windows containers](https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=dockerce#windows-10-and-11-1).
- Your C: drive has at least **40GB** of free disk space, as the built Docker image can be around 30GB. Or relocate the storage with black magic.

## Quickstart
Assuming your build target is Python 3.11 and CUDA 12.6, preset configurations are provided in `presets/cp311cu126.ps1`. You can run the script directly or create a custom configuration as needed.
```powershell
git clone https://github.com/yourusername/ktransformers-win-builder.git
cd ktransformers-win-builder
.\run.ps1 -Preset ./presets/cp311cu126.ps1 -TorchCudaArchList "8.9;8.6;7.5;6.1" -CompilerMemory "8G" -CompilerCpus "4" -Branch "pull/622/head"
```
This will build the Docker image and start the compilation process using the specified preset configuration.

Explanations:
- `-Preset ./presets/cp311cu126.ps1`: Loads a specific CUDA version, Python version, etc., from the provided file.
- `-TorchCudaArchList "8.9;8.6;7.5;6.1"`: Specifies the CUDA architectures which match your GPU's. [Find out more](https://developer.nvidia.com/cuda-gpus).
- `-CompilerMemory "8G" -CompilerCpus "4"`: There is a chance that `ninja` builder will run out of heap space if the resource is too limited, lower ram may work but I have only tested with "8G".
- `-Branch "pull/622/head"`: Specifies the branch or commit to build. This [fix](https://github.com/kvcache-ai/ktransformers/pull/622) is required to successfully build on windows. Defaults to "main".

## Notes
- Downloading and installing Visual Studio Build Tools component could take very long time, check network and CPU usage if unsure about whether it's hanging or not.
- Customize the preset file for different build targets, `python` and `cuda` are installed via [Chocolatey package index](https://community.chocolatey.org/packages). So make sure the package version exists in the index.
- To debug or build manually, run `docker run --rm -it --memory="8G" -v </path/to/ktransformers>:"C:/ktransformers" ktransformers-builder:<tag>` to enter a shell environment with all dependencies installed.
- Image building and source compiling may hang if running out of disk space.
