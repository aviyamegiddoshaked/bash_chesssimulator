# bash_chesssimulator

This repository features a collection of Bash scripts crafted to simplify the management and analysis of chess games stored in PGN (Portable Game Notation) files. Whether you're looking to divide a large collection of games into smaller, organized files or simulate and visualize individual games, these scripts offer a user-friendly and efficient way to handle your chess game data.

## Installation

1. Clone this repository to your local machine:

    ```bash
    git clone https://github.com/yourusername/Chess_Tools.git](https://github.com/aviyamegiddoshaked/bash_chesssimulator.git
    ```

2. Make the scripts executable by running the following commands:

    ```bash
    chmod +x ./split_pgn.sh
    chmod +x ./chess_sim.sh
    ```

## Usage

### Part 1: Splitting PGN Files

1. Place your PGN file in the project directory. For instance, `game_data.pgn`.

2. Use the `split_pgn.sh` script to divide the PGN file into smaller parts:

    ```bash
    ./split_pgn.sh ./game_data.pgn ./split_files
    ```

    - The first parameter specifies the path to the input PGN file.
    - The second parameter is the directory where the split files will be stored.

3. The resulting split files will be saved in the directory you specified.

---

### Part 2: Simulating Chess Games

1. Run the `chess_sim.sh` script to simulate a game from one of the split PGN files:

    ```bash
    ./chess_sim.sh split_files/game_data_1.pgn
    ```

    - Provide the path to the specific PGN file you want to simulate as an argument.

---

## Features

- **PGN File Splitting**: Effortlessly divide large PGN files into smaller, manageable chunks.
- **Game Simulation**: Visualize and analyze individual chess games using the simulation tool.
- **User-Friendly CLI**: Simple and intuitive command-line interface for executing the scripts.
- **Highly Customizable**: Easily adapt and enhance the scripts to meet your unique requirements.
