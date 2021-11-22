# Docker Sheepit

A fully featured (or so I hope) Docker-container for running the sheepit-client with GPU support and advanced options.

## Volumes

It is possible to mount `/sheepit` from the container to a local directory to persistently store renderers and sheepit client.
This will save bandwidth and can be used as a shared volume when running multiple clients.

## Relevant Options
Those are just all options that are available. \
**The most relevant options are LOGIN, PASSWORD (and maybe MEMORY)** \
If you don't know what a specific setting means, it is likely that you won't need it.

| Option            | Setting               | Description                                  |
|-------------------|-----------------------|--------------------------------------------------------------------------------------------------------------------|
| SHOW_GPU          | `TRUE`/`FALSE`        | Show GPU info (check logs)                                                                                 |
| VERBOSE           | `TRUE`/`FALSE`        | Increase logging                                                                                                   |
| COMPUTE_METHOD    | `CPU`/`CPU_GPU`/`GPU` | How to render - GPU requires GPU option to be set and the correct docker setup, check `Docker with GPU` Section    |
| CORES             | int                   | Number of CPU cores to use for rendering                                                                           |
| GPU               | GPU_ID                | GPU_ID found through SHOW_GPU (typically CUDA_0)                                                                   |
| HOSTNAME          | string                | Custom hostname                                                                                                    |
| LOGIN             | string                | **(REQUIRED)** username                                                                                            |
| MEMORY            | string                | **(RECOMMENDED)** Maximum memory allow to be used by renderer, number with unit (800M, 2G, ...)                                      |
| PASSWORD          | string                | **(REQUIRED)** password                                                                                            |
| RENDERBUCKET_SIZE | int                   | Set a custom GPU renderbucket size (32 for 32x32px, 64 for 64x64px, and so on). NVIDIA GPUs support a maximum renderbucket size of 512x512 pixel, while AMD GPUs support a maximum 2048x2048 pixel renderbucket size. Minimum renderbucket size is 32 pixels for all GPUs (default: -1) |
| RENDERTIME        | int                   | Maximum time allow for each frame (in minutes) (default: -1)                                                       |
| REQUEST_TIME      | string                | H1:M1-H2:M2,H3:M3-H4:M4 Use the 24h format. For example to request job between 2am-8.30am and 5pm-11pm you should do --request-time 2:00-8:30,17:00-23:00 Caution, it's the requesting job time to get a project, not the working time |
| SERVER            | string                | Render-farm server, default https://client.sheepit-renderfarm.com (default: https://client.sheepit-renderfarm.com) |
| ...               | more                  | ...                                                                                                                |
Also Available: CACHE_DIR, EXTRAS, PRIORITY, PROXY, SHARED_ZIP, SHUTDOWN, SHUTDOWN_MODE, UI

For additional reference run `java -jar sheepit-client --help`


# Docker

## Minimal Setup

```bash
docker run --name "sheepit" \
-e LOGIN=username \
-e PASSWORD=renderKeyOrPassword \
freezingdaniel/sheepit:latest
```

## Docker with CPU

```bash
docker run --name "sheepit-cpu" \
-e LOGIN=username \
-e PASSWORD=renderKeyOrPassword \
-v /path/to/local/folder:/sheepit \
freezingdaniel/sheepit:latest
```

## Docker with GPU:

Refer to https://docs.docker.com/config/containers/resource_constraints/#gpu to enable GPU support

```bash
docker run --name "sheepit-gpu" \
    --gpus '"device=0"' \
    -e LOGIN=username \
    -e PASSWORD=renderKeyOrPassword \
    -e COMPUTE_METHOD=GPU \
    -e GPU=CUDA_0 \
    -v /path/to/local/folder:/sheepit \
    freezingdaniel/sheepit:latest
```

## Graceful shutdown

For when you want the container to quit after finishing its current frame.

```bash
```

# Docker-Compose

## docker-compose with CPU in background

This configuration uses unused CPU resources to render.

```bash
version: "2.4"
services:
    sheepit:
        image: freezingdaniel/sheepit:latest
        restart: unless-stopped
        cpu_shares: 10
        volumes:
            - ./sheepit:/sheepit
        environment:
            - LOGIN=username
            - PASSWORD=renderKeyOrPassword
            - MEMORY=8G
```

## docker-compose with CPU

```bash
version: "3"
services:
    sheepit-cpu:
        image: freezingdaniel/sheepit:latest
        restart: unless-stopped
        volumes:
            - ./sheepit:/sheepit
        environment:
            - LOGIN=username
            - PASSWORD=renderKeyOrPassword
            - MEMORY=8G
```

## docker-compose with GPU

```bash
version: "3"
services:
    sheepit-gpu:
        image: freezingdaniel/sheepit:latest
        restart: unless-stopped
        volumes:
            - ./sheepit:/sheepit
        environment:
            - LOGIN=username
            - PASSWORD=renderKeyOrPassword
            - COMPUTE_METHOD=GPU
            - GPU=CUDA_0
            - MEMORY=8G
        deploy:
            resources:
                reservations:
                    devices:
                        - driver: nvidia
                        device_ids: ['0']
                        capabilities: [gpu]
```

## docker-compose with CPU and GPU

One at a time:
```bash
version: "3"
services:
    sheepit-gpu:
        image: freezingdaniel/sheepit:latest
        restart: unless-stopped
        volumes:
            - ./sheepit:/sheepit
        environment:
            - LOGIN=username
            - PASSWORD=renderKeyOrPassword
            - COMPUTE_METHOD=CPU_GPU
            - GPU=CUDA_0
            - MEMORY=8G
        deploy:
            resources:
                reservations:
                    devices:
                        - driver: nvidia
                        device_ids: ['0']
                        capabilities: [gpu]
```

Both simultaneously:
```bash
version: "3"
services:
    sheepit-cpu:
        image: freezingdaniel/sheepit:latest
        restart: unless-stopped
        volumes:
            - ./sheepit:/sheepit
        environment:
            - LOGIN=username
            - PASSWORD=renderKeyOrPassword
            - MEMORY=8G
    sheepit-gpu:
        image: freezingdaniel/sheepit:latest
        restart: unless-stopped
        volumes:
            - ./sheepit:/sheepit
        environment:
            - LOGIN=username
            - PASSWORD=renderKeyOrPassword
            - COMPUTE_METHOD=GPU
            - GPU=CUDA_0
            - MEMORY=8G
        deploy:
            resources:
                reservations:
                    devices:
                        - driver: nvidia
                        device_ids: ['0']
                        capabilities: [gpu]
```