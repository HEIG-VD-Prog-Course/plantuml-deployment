#!/usr/bin/env fish

# Configuration
set SERVER_USER "debian"
set SERVER_HOST "83.228.208.185"
set SSH_KEY "$HOME/.ssh/programmation/id_rsa"
set LOCAL_BOOKS_DIR "../.books"
set REMOTE_BOOKS_DIR "plantuml-deployement/calibre/data/books/theater"

# Colors for output
set GREEN '\033[0;32m'
set YELLOW '\033[1;33m'
set RED '\033[0;31m'
set NC '\033[0m' # No Color

echo -e "$GREEN📚 Syncing books to server...$NC"
echo ""

# Check if SSH key exists
if not test -f "$SSH_KEY"
    echo -e "$RED❌ SSH key not found at: $SSH_KEY$NC"
    exit 1
end

# Check if local books directory exists
if not test -d "$LOCAL_BOOKS_DIR"
    echo -e "$RED❌ Local books directory not found: $LOCAL_BOOKS_DIR$NC"
    exit 1
end

# Find all book files
set book_files (find "$LOCAL_BOOKS_DIR" -type f \( -name "*.epub" -o -name "*.pdf" -o -name "*.mobi" -o -name "*.azw3" \))
set book_count (count $book_files)

if test $book_count -eq 0
    echo -e "$YELLOW⚠️  No books found in $LOCAL_BOOKS_DIR$NC"
    exit 0
end

echo -e "$YELLOW""Found $book_count book(s) to sync$NC"
echo ""

# First, fix permissions on the remote directory
echo -e "$YELLOW""Checking remote directory permissions...$NC"
ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "sudo chown -R debian:debian $REMOTE_BOOKS_DIR 2>/dev/null || mkdir -p $REMOTE_BOOKS_DIR"
echo ""

# Sync each book using scp
set success_count 0
for book in $book_files
    set filename (basename "$book")
    echo -e "$YELLOW→ Uploading: $filename$NC"
    
    scp -i "$SSH_KEY" "$book" "$SERVER_USER@$SERVER_HOST:$REMOTE_BOOKS_DIR"
    
    if test $status -eq 0
        set success_count (math $success_count + 1)
        echo -e "$GREEN  ✓ Success$NC"
    else
        echo -e "$RED  ✗ Failed$NC"
    end
    echo ""
end

if test $success_count -eq $book_count
    echo -e "$GREEN✅ All books synced successfully! ($success_count/$book_count)$NC"
    echo ""
    echo -e "$YELLOW""Next steps:$NC"
    echo "1. Books are now in: ~/plantuml-deployement/calibre/data/books/"
    echo "2. Kavita/Calibre will detect them automatically"
else
    echo -e "$YELLOW⚠️  Synced $success_count out of $book_count books$NC"
    exit 1
end
