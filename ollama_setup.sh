#!/bin/bash

# Start Ollama in the background.
OLLAMA_KEEP_ALIVE=1m OLLAMA_CONTEXT_LENGTH=40000 /bin/ollama serve &
# Record Process ID.
pid=$!

# Pause for Ollama to start.
sleep 5

echo "🔴 Retrieve LLAMA3 model..."
# Pull models specified in environment variable or defaults
MODELS="${OLLAMA_MODELS:-qwen3-embedding qwen3.5:9b}"
for model in $MODELS; do
    echo "Pulling model: $model"
    ollama pull "$model"
done
echo "🟢 Done!"

# Wait for Ollama process to finish.
wait $pid
