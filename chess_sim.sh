#!/bin/bash

# check existence of file 
if [ ! -f "$1" ]; then
    echo "File does not exist: $1"
    exit 1 # exit with error code if file is missing
fi

# extract metadata and moves from the PGN file
# metadata =  player names, results, date.

metadata=$(grep -E '^\[.*\]$' "$1")
pgn_moves=""



while IFS= read -r line || [ -n "$line" ]; do
    if [[ $line =~ ^\[.*\]$ ]]; then
        continue
    fi
    pgn_moves+="$line "

done < "$1"
echo "Metadata from PGN file:"
echo "$metadata"
echo

# convert PGN moves to UCI using parse_moves.py and store in a Bash array
# note to self:'parse_moves.py` handles the conversion logic.
uci_moves=$(python3 parse_moves.py "$pgn_moves")
IFS=' ' read -r -a moves_array <<< "$uci_moves"

# initialize the board
initial_board="r n b q k b n r
p p p p p p p p
. . . . . . . .
. . . . . . . .
. . . . . . . .
. . . . . . . .
P P P P P P P P
R N B Q K B N R"

# current move index
current_move=0

display_board() {
    echo "Move $current_move/${#moves_array[@]}"
    echo "  a b c d e f g h"
    row=8
    for line in "${board[@]}"; do
        if [[ ${line: -1} == " " ]]; then
           line=${line%?}
        fi
        echo "$row $line $row"
        ((row--))
    done
    echo "  a b c d e f g h"
}

initialize_board() {
    IFS=$'\n' read -r -d '' -a board <<< "$initial_board"
}

#applies move to chessboard
# double check end of game
apply_move() {
    move=${moves_array[$((current_move - 1))]}
    start=${move:0:2}
    end=${move:2:2}
    start_col=$(echo ${start:0:1} | tr 'a-h' '1-8')
    start_row=${start:1:1}
    end_col=$(echo ${end:0:1} | tr 'a-h' '1-8')
    end_row=${end:1:1}
    
    start_row=$((8 - start_row))
    end_row=$((8 - end_row))
    start_col=$((start_col - 1))
    end_col=$((end_col - 1))
    
    piece=${board[$start_row]:$((start_col*2)):1}


# BONUS STARTS HERE
    ######################

    
    # Handle en passant
    if [[ "$piece" == "p" && "$start_row" == "4" && "$end_row" == "5" && "${board[$end_row]:$((end_col*2)):1}" == "." ]]; then
        capture_row=$((end_row - 1))
        board[$capture_row]=${board[$capture_row]:0:$((end_col*2))}'. '${board[$capture_row]:$((end_col*2+2))}    

    elif [[ "$piece" == "P" && "$start_row" == "3" && "$end_row" == "2" && "${board[$end_row]:$((end_col*2)):1}" == "." ]]; then
        capture_row=$((end_row + 1))
        board[$capture_row]=${board[$capture_row]:0:$((end_col*2))}'. '${board[$capture_row]:$((end_col*2+2))}
    fi

    board[$start_row]=${board[$start_row]:0:$((start_col*2))}'. '${board[$start_row]:$((start_col*2+2))}
    board[$end_row]=${board[$end_row]:0:$((end_col*2))}"$piece "${board[$end_row]:$((end_col*2+2))}

    # Handle castling - handles special king-side and queen-side castling rules

    if [[ "$piece" == "k" || "$piece" == "K" ]]; then
        if [[ "$start$end" == "e8g8" || "$start$end" == "e1g1" ]]; then
            rook_start_col=7
            rook_end_col=5
        elif [[ "$start$end" == "e8c8" || "$start$end" == "e1c1" ]]; then
            rook_start_col=0
            rook_end_col=3
        else
            rook_start_col=-1
            rook_end_col=-1
        fi

        if (( rook_start_col >= 0 && rook_end_col >= 0 )); then
            rook_piece=${board[$start_row]:$((rook_start_col*2)):1}
            board[$start_row]=${board[$start_row]:0:$((rook_start_col*2))}'. '${board[$start_row]:$((rook_start_col*2+2))}
            board[$start_row]=${board[$start_row]:0:$((rook_end_col*2))}"$rook_piece "${board[$start_row]:$((rook_end_col*2+2))}
        fi
    fi
}

initialize_board
display_board




while true; do
    echo -n "Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit:"
    read -r key
    echo
    case $key in
        d)
            if (( current_move < ${#moves_array[@]} )); then
                ((current_move++))
                apply_move
                display_board
            else
                echo "No more moves available."
            fi
            ;;
        a)
            if (( current_move > 0 )); then
                ((current_move--))
                ((temp_move = current_move))
                initialize_board
                for ((i=0; i < temp_move; i++)); do
                    ((current_move = i + 1))
                    apply_move
                done
                current_move=$temp_move
            fi
            display_board
            ;;
        w)
            current_move=0
            initialize_board
            display_board
            ;;
        s)
            if ((current_move < ${#moves_array[@]})); then                       
                for ((i=current_move; i<${#moves_array[@]}; i++)); do
                    ((current_move++))
                    apply_move
                done
            fi
            display_board
            ;;
        q)   
            echo "Exiting."
            echo "End of game."
            exit 0
            ;;
        *)
            echo "Invalid key pressed: $key"
            ;;
    esac
done
