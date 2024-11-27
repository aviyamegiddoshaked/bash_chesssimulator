#!/bin/bash

show_help() {
    echo "Usage: $0 <source_pgn_file> <destination_directory>"
    exit 1
}

# checks if a file exists
check_file_exists() {
    if [ ! -f "$1" ]; then
        echo "Error: The file '$1' does not exist."
        exit 1
    fi
}

# makes sure the destination directory exists - if not, echo to user and handle error
create_dir_if_missing() {
    if [ ! -d "$1" ]; then
        echo "Directory '$1' not found. Making it now."
        mkdir -p "$1"
    fi
}

# Function to split the PGN file into separate games
split_games() {
    local source_file="$1"
    local dest_dir="$2"
    local count=0
    local game_content=""
    local file_name="${source_file##*/}"
    local base_name="${file_name%.pgn}"

    # Reads line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == "[Event "* ]]; then
            if [[ -n "$game_content" ]]; then
                count=$((count + 1))
                local output_file="$dest_dir/${base_name}_$count.pgn"
                echo "$game_content" > "$output_file"
                echo "Saved game #$count to $output_file"
                game_content=""
            fi
        fi
        game_content+="$line"$'\n'
    done < "$source_file"

    # Last game - if any 
    if [[ -n "$game_content" ]]; then
        count=$((count + 1))
        local output_file="$dest_dir/${base_name}_$count.pgn"
        echo "$game_content" > "$output_file"
        echo "Saved game #$count to $output_file"
    fi

    echo "Done! All games saved in '$dest_dir'."
}

# main script
if [[ "$#" -ne 2 ]]; then
    show_help
fi

src_file="$1"
dest_dir="$2"
check_file_exists "$src_file"
create_dir_if_missing "$dest_dir"
split_games "$src_file" "$dest_dir"
