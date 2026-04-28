# Quick Start Guide

## Using External Servers (Recommended for most users)

If you want to use external LLM and Stable Diffusion servers instead of running them locally:

### 1. Create `.env` file

Copy the example environment file:
```bash
cp .env.example .env
```

### 2. Configure for external servers

Edit `.env` and set:
```bash
# Disable local containers
ENABLE_OLLAMA=false
ENABLE_SD=false

# Your external server URLs
EXTERNAL_LLM_URL=http://your-llm-server:11434/v1/
EXTERNAL_SD_URL=http://your-sd-server:7860/
```

### 3. Start without local AI services

Since you disabled local containers, you don't need to run docker-compose:
```bash
# Just build and run the application
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
./build/bin/kuni
```

## Using Local Containers (Only if you have NVIDIA GPU)

If you want to run Ollama and/or Stable Diffusion locally:

### Option A: Run everything locally (requires NVIDIA GPU)

```bash
docker compose up -d
```

### Option B: Run only Ollama locally (no SD)

```bash
docker compose --profile ollama-local up -d ollama
```

### Option C: Run only Stable Diffusion locally (no Ollama)

```bash
docker compose --profile sd-local up -d sd
```

### Option D: Use CPU-only mode (slow but works without GPU)

Create `.env` file with:
```bash
OLLAMA_USE_NVIDIA_GPU=false
SD_USE_NVIDIA_GPU=false
```

Then start:
```bash
docker compose up -d
```

**Note:** Running Stable Diffusion on CPU is extremely slow and not recommended.

## Configuration Options

See `.env.example` for all available configuration options:

- `ENABLE_OLLAMA` - Enable/disable local Ollama container
- `ENABLE_SD` - Enable/disable local Stable Diffusion container  
- `OLLAMA_USE_NVIDIA_GPU` - Use NVIDIA GPU for Ollama
- `SD_USE_NVIDIA_GPU` - Use NVIDIA GPU for Stable Diffusion
- `GPU_DEVICE_IDS` - Which GPU devices to use (e.g., "0", "0,1", "all")
- `OLLAMA_MODEL` - Which model to pull on startup
- `EXTERNAL_LLM_URL` - External LLM server URL (when using external server)
- `EXTERNAL_SD_URL` - External SD server URL (when using external server)

## Troubleshooting

### "NVIDIA GPU not found" error

If you don't have an NVIDIA GPU or don't want to use it:

1. Set `OLLAMA_USE_NVIDIA_GPU=false` in your `.env` file
2. Or use AMD/other GPUs by setting `OLLAMA_GPU_DRIVER=rocm` (for AMD)

### Want to use cloud LLM providers?

Configure in `src/config.h`:
```cpp
static const EndpointAndModel ENDPOINT_MAIN {
    .endpoint = {
        .baseUrl = "https://api.deepseek.com/",
        .bearerKey = secrets::DEEPSEEK_BEARER_KEY,
    },
    .model = "deepseek-chat",
};
```

And disable local Ollama:
```bash
ENABLE_OLLAMA=false
```
