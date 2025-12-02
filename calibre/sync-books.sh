#!/usr/bin/env bash

# Configuration
SERVER_USER="debian"
SERVER_HOST="83.228.208.185"
SSH_KEY="$HOME/.ssh/programmation/id_rsa"
LOCAL_BOOKS_DIR="../.books"
REMOTE_BOOKS_DIR="plantuml-deployement/calibre/data/books/theater"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}📚 Syncing books to server...${NC}"
echo ""

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo -e "${RED}❌ SSH key not found at: $SSH_KEY${NC}"
    exit 1
fi

# Check if local books directory exists
if [ ! -d "$LOCAL_BOOKS_DIR" ]; then
    echo -e "${RED}❌ Local books directory not found: $LOCAL_BOOKS_DIR${NC}"
    exit 1
fi

# Count books to sync
BOOK_COUNT=$(find "$LOCAL_BOOKS_DIR" -type f \( -name "*.epub" -o -name "*.pdf" -o -name "*.mobi" -o -name "*.azw3" \) | wc -l)

if [ "$BOOK_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No books found in $LOCAL_BOOKS_DIR${NC}"
    exit 0
fi

echo -e "${YELLOW}Found $BOOK_COUNT book(s) to sync${NC}"
echo ""

# Sync books using rsync
rsync -avz --progress \
    -e "ssh -i $SSH_KEY" \
    --include="*.epub" \
    --include="*.pdf" \
    --include="*.mobi" \
    --include="*.azw3" \
    --exclude="*" \
    "$LOCAL_BOOKS_DIR/" \
    "$SERVER_USER@$SERVER_HOST:$REMOTE_BOOKS_DIR"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Books synced successfully!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. The books are now in: ~/plantuml-deployement/calibre/data/books/"
    echo "2. Calibre will automatically detect them on next scan"
else
    echo ""
    echo -e "${RED}❌ Sync failed${NC}"
    exit 1
fi
