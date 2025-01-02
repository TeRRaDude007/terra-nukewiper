#!/bin/bash
##################################################
## TeRRaDuDe nuke wiper vers 1.0                ##
## Wipes diectory that contains tvmaze: NUKED-  ##
##################################################
#
# Add to cron if needed: 0 6 * * * /terra-nukewiper.sh >/dev/null 2>&1
# SETUP: Configuration Below
#
#################################################

# Add sections to scan if nukes are present
# Use full glftpd path

TARGET_DIRS=(
    "/glftpd/site/GAMES"
    "/glftpd/site/FLAC"
    "/glftpd/site/MP3"
    "/glftpd/site/APPS"
)

# Glftpd logfile

LOG_FILE="/glftpd/ftp-data/logs/nukewipe.log"

# Nuked dir that are 48 hours old will be wiped
# Change hours if needed
# Time threshold (48 hours in seconds)

TIME_THRESHOLD=$((48 * 3600))

#################################################
#     Keep in mind: There is NO undo.           #
#################################################
######## DONT EDIT BELOW THIS LINE ##############
#################################################

# Get the current time
CURRENT_TIME=$(date +%s)

# Ensure log file exists
touch "$LOG_FILE"

# Function to check and delete directories
wipe_nuked_dirs() {
    local dir="$1"

    # Find all directories starting with [NUKED]- in the given directory
    find "$dir" -type d -name '\[NUKED\]-*' -print | while read -r nuked_dir; do


        # Debug log for matched directory
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Matched directory: $nuked_dir" >> "$LOG_FILE"

        # Get the modification time of the directory in seconds since epoch
        MOD_TIME=$(stat -c %Y "$nuked_dir")

        # Debug log for modification time and age
        AGE=$((CURRENT_TIME - MOD_TIME))
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Directory age: $AGE seconds ($((AGE / 3600)) hours)" >> "$LOG_FILE"

        # If the directory is older than the threshold, delete it
        if (( AGE > TIME_THRESHOLD )); then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Deleting: $nuked_dir (Age: $((AGE / 3600)) hours)" | tee -a "$LOG_FILE"
            rm -rf "$nuked_dir"
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Skipping (not old enough): $nuked_dir" >> "$LOG_FILE"
        fi
    done
}

# Log the start of the script execution
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting nuked directory cleanup" >> "$LOG_FILE"

# Loop through each target directory
for dir in "${TARGET_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Processing directory: $dir" >> "$LOG_FILE"
        wipe_nuked_dirs "$dir"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Skipping non-existent directory: $dir" >> "$LOG_FILE"
    fi
done

# Log the end of the script execution
echo "$(date '+%Y-%m-%d %H:%M:%S') - Cleanup completed" >> "$LOG_FILE"
