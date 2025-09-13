# NZBGet Docker Cleanup Scripts

This directory contains scripts to completely wipe NZBGet from your Docker setup.

## Scripts

### 1. `wipe-nzbget.sh` - Main Cleanup Script
This script will completely remove NZBGet from your Docker setup:
- Stops and removes all NZBGet containers
- Removes all NZBGet volumes (⚠️ **This deletes all your data!**)
- Removes all NZBGet images
- Removes all NZBGet networks
- Cleans up orphaned Docker resources

**Usage:**
```bash
./wipe-nzbget.sh
```

**Safety Features:**
- Shows a preview of what will be removed
- Requires explicit confirmation before proceeding
- Color-coded output for easy reading
- Comprehensive error handling

### 2. `verify-nzbget-cleanup.sh` - Verification Script
This script checks if NZBGet has been completely removed from Docker.

**Usage:**
```bash
./verify-nzbget-cleanup.sh
```

**What it checks:**
- NZBGet containers
- NZBGet volumes
- NZBGet images
- NZBGet networks
- Shows current Docker status

## Important Notes

⚠️ **WARNING**: The cleanup script will permanently delete all NZBGet data including:
- Downloaded files
- Configuration files
- Logs
- Database files
- Any other data stored in NZBGet volumes

## Usage Workflow

1. **Before cleanup** - Run verification to see what exists:
   ```bash
   ./verify-nzbget-cleanup.sh
   ```

2. **Perform cleanup** - Run the main cleanup script:
   ```bash
   ./wipe-nzbget.sh
   ```

3. **After cleanup** - Verify everything is removed:
   ```bash
   ./verify-nzbget-cleanup.sh
   ```

## Requirements

- Docker must be running
- Scripts must be executable (they are already set up)
- Bash shell

## Troubleshooting

If you encounter permission issues:
```bash
chmod +x wipe-nzbget.sh
chmod +x verify-nzbget-cleanup.sh
```

If Docker is not running:
```bash
sudo systemctl start docker
# or
sudo service docker start
```