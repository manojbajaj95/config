import sys
from typing import Dict, List
import argparse
from pathlib import Path

class ZshHistoryManager:
    def __init__(self):
        self.history_cache: Dict[str, str] = {}
        self.multiline_commands: List[str] = []

    def load_file(self, filename: str) -> None:
        """Load and process zsh history file."""
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                buffer = f.read()
                commands = buffer.split("\n:")[1:]  # \n: is used as separator for each history command
                
                for command in commands:
                    try:
                        cmd = command.split(";")[1]
                        self.history_cache[cmd] = command
                    except IndexError:
                        # Handle multiline commands
                        self.multiline_commands.append(command)
                        print(f"Found multiline command: {command[:50]}...")
        except FileNotFoundError:
            print(f"Error: History file '{filename}' not found.")
            sys.exit(1)
        except Exception as e:
            print(f"Error reading history file: {e}")
            sys.exit(1)

    def write_file(self, filename: str) -> None:
        """Write processed history back to file."""
        try:
            with open(filename, 'w', encoding='utf-8') as f:
                for cmd, history_entry in self.history_cache.items():
                    f.write(f": {history_entry}\n")
        except Exception as e:
            print(f"Error writing history file: {e}")
            sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description='Process and deduplicate zsh history file')
    parser.add_argument('history_file', type=str, help='Path to zsh history file')
    args = parser.parse_args()

    # Validate file exists
    if not Path(args.history_file).exists():
        print(f"Error: History file '{args.history_file}' does not exist.")
        sys.exit(1)

    history_manager = ZshHistoryManager()
    history_manager.load_file(args.history_file)
    history_manager.write_file(args.history_file)

if __name__ == "__main__":
    main()
