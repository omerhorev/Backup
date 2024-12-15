# Homecloud

A self-hosted cloud server for photos and videos, powered by [Immich](https://immich.app/).

## Features

- Self-hosted photo and video backup solution
- HTTPS support with self-signed certificates
- Easy setup with Docker Compose
- Automatic timezone configuration

## Prerequisites

- Docker and Docker Compose
- Basic understanding of terminal/command line
- A machine to host the server (Linux recommended)

## Setup

1. Clone this repository
2. Generate SSL certificates:
   ```bash
   ./gen_cert.sh
   ```
   This will create self-signed certificates in the `certs/` directory and root CA certificates in `secrets/`. 
   Follow the instructions at the end to install the root CA certificate on your devices.
   
   **Important**: After installing the root CA certificate, delete the `rootCA.key` and `rootCA.crt` files from the `secrets/` directory for security.
3. Create a `.env` file from the example:
   ```bash
   cp .env.example .env
   ```
   Then edit `.env` and set the required values.
4. Start the server:
   ```bash
   docker compose up -d
   ```
   The server will be available at `https://homecloud`
