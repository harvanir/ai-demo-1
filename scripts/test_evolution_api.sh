#!/usr/bin/env bash

curl -X POST "http://localhost:8080/message/sendText/my-wa" \
  -H "apikey: EVOL_api_KEY_9e7f0c1f2f1b4d3698452bbf82d7ab54" -H "Content-Type: application/json" \
  -d '{ "number": "6285691285642", "text": "Halo! Bot sudah online 🚀" }'