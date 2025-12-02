# Book Sync Guide

## Quick Start

To sync books from your local `.books` folder to the server:

```bash
./sync-books.sh
```

## What it does

The script will:

1. Find all book files (`.epub`, `.pdf`, `.mobi`, `.azw3`) in `../.books/`
2. Upload them to your server at `~/plantuml-deployement/calibre/data/books/`
3. Show progress for each file
4. Confirm when complete

## Requirements

- SSH access to the server (already configured in the script)
- `rsync` installed (usually pre-installed on macOS/Linux)

## Adding New Books

1. Place your book files in the `../.books/` folder (one level up from calibre/)
2. Run `./sync-books.sh`
3. The books will be synced to the server automatically

## Manual Sync (Alternative)

If you prefer to sync manually:

```bash
rsync -avz --progress \
  -e "ssh -i ~/.ssh/programmation/id_rsa" \
  ../.books/*.epub \
  debian@83.228.208.185:plantuml-deployement/calibre/data/books/
```

## Troubleshooting

**SSH key not found**: Make sure your SSH key is at `~/.ssh/programmation/id_rsa`

**Permission denied**: The remote directory may be owned by root. SSH to the server and fix permissions:

```bash
ssh -i ~/.ssh/programmation/id_rsa debian@83.228.208.185
sudo chown -R debian:debian ~/plantuml-deployement/calibre/data/books/
```

**Books not showing up**: After syncing, restart the Calibre/Kavita container:

```bash
ssh -i ~/.ssh/programmation/id_rsa debian@83.228.208.185
cd plantuml-deployement/calibre
docker compose restart
```
