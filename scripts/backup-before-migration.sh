#!/bin/bash

# Database Backup Script - Before Migration
# This script creates a complete backup of the current database before migration

set -e

echo "🔒 Creating database backup before migration..."

# Get current timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="./backups"
BACKUP_FILE="$BACKUP_DIR/db_backup_before_migration_$TIMESTAMP.sql"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo "❌ DATABASE_URL environment variable is not set"
    echo "Please set DATABASE_URL or run with: DATABASE_URL=your_db_url ./backup-before-migration.sh"
    exit 1
fi

# Extract database connection details from DATABASE_URL
# Format: postgresql://user:password@host:port/database
DB_URL_REGEX="postgresql://([^:]+):([^@]+)@([^:]+):([0-9]+)/(.+)"

if [[ $DATABASE_URL =~ $DB_URL_REGEX ]]; then
    DB_USER="${BASH_REMATCH[1]}"
    DB_PASSWORD="${BASH_REMATCH[2]}"
    DB_HOST="${BASH_REMATCH[3]}"
    DB_PORT="${BASH_REMATCH[4]}"
    DB_NAME="${BASH_REMATCH[5]}"
else
    echo "❌ Invalid DATABASE_URL format"
    echo "Expected format: postgresql://user:password@host:port/database"
    exit 1
fi

echo "📊 Database Details:"
echo "  Host: $DB_HOST:$DB_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo "  Backup file: $BACKUP_FILE"

# Set password for pg_dump
export PGPASSWORD="$DB_PASSWORD"

# Create database backup
echo "💾 Creating backup..."
pg_dump \
    --host="$DB_HOST" \
    --port="$DB_PORT" \
    --username="$DB_USER" \
    --dbname="$DB_NAME" \
    --verbose \
    --clean \
    --if-exists \
    --create \
    --format=custom \
    --file="$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Backup created successfully: $BACKUP_FILE"
    
    # Get backup file size
    BACKUP_SIZE=$(ls -lh "$BACKUP_FILE" | awk '{print $5}')
    echo "📁 Backup size: $BACKUP_SIZE"
    
    # Create a quick verification
    echo "🔍 Verifying backup..."
    pg_restore --list "$BACKUP_FILE" > /dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Backup verification successful"
        
        # Create restore script
        RESTORE_SCRIPT="$BACKUP_DIR/restore_backup_$TIMESTAMP.sh"
        cat > "$RESTORE_SCRIPT" << EOF
#!/bin/bash

# Restore script for backup created on $TIMESTAMP
# WARNING: This will completely replace the current database!

set -e

echo "⚠️  WARNING: This will completely replace the current database!"
echo "Database: $DB_NAME"
echo "Backup file: $BACKUP_FILE"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "\$confirm" != "yes" ]; then
    echo "❌ Restore cancelled"
    exit 1
fi

echo "🔄 Restoring database from backup..."

# Set password
export PGPASSWORD="$DB_PASSWORD"

# Drop and recreate database
echo "🗑️  Dropping existing database..."
dropdb --if-exists --host="$DB_HOST" --port="$DB_PORT" --username="$DB_USER" "$DB_NAME"

echo "🆕 Creating new database..."
createdb --host="$DB_HOST" --port="$DB_PORT" --username="$DB_USER" "$DB_NAME"

echo "📥 Restoring data..."
pg_restore \\
    --host="$DB_HOST" \\
    --port="$DB_PORT" \\
    --username="$DB_USER" \\
    --dbname="$DB_NAME" \\
    --verbose \\
    --clean \\
    --if-exists \\
    --create \\
    "$BACKUP_FILE"

if [ \$? -eq 0 ]; then
    echo "✅ Database restored successfully from backup"
else
    echo "❌ Database restore failed"
    exit 1
fi
EOF
        
        chmod +x "$RESTORE_SCRIPT"
        echo "📝 Restore script created: $RESTORE_SCRIPT"
        
    else
        echo "❌ Backup verification failed"
        exit 1
    fi
    
else
    echo "❌ Backup creation failed"
    exit 1
fi

# Clear password from environment
unset PGPASSWORD

echo ""
echo "🎉 Backup process completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Verify the backup file exists: $BACKUP_FILE"
echo "2. Test the restore script (optional): $RESTORE_SCRIPT"
echo "3. Proceed with the database migration"
echo ""
echo "⚠️  IMPORTANT: Keep this backup safe until migration is confirmed successful!"