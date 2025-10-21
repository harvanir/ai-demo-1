#!/bin/sh

# # n8n
# docker run -it --rm -p 5678:5678 -v .n8n:/home/node/.n8n -e N8N_SECURE_COOKIE=false n8nio/n8n:1.115.3

# # ollama
# docker run -d -v .ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama:0.12.6