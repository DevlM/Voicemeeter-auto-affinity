# Voicemeeter auto affinity

This PowerShell script automatically sets the CPU affinity and priority for both the Windows Audio Device Graph (audiodg.exe) and Voicemeeter processes to improve audio performance and reduce latency.

## Features

- Sets CPU affinity to the last CPU core for both audiodg.exe and Voicemeeter processes
- Sets process priority to "High" for both processes
- Automatically detects and applies settings when both processes are running
- Runs at system startup and applies settings as soon as possible
- Self-elevates to administrator privileges when needed

## Prerequisites

- Windows 10/11
- PowerShell 5.1 or later
- Administrator privileges (the script will request elevation if needed)
- Voicemeeter installed on your system

## Installation

1. **Clone or download** this repository to your preferred location
2. **Create a scheduled task** to run the script at system startup:

   a. Press `Win + R`, type `taskschd.msc` and press Enter
   
   b. In the right panel, click "Create Task"
   
   c. General tab:
      - Name: `Voicemeeter Affinity Manager`
      - Check "Run with highest privileges"
      - Select "Run whether user is logged on or not"
   
   d. Triggers tab → New → "At startup"
   
   e. Actions tab → New → "Start a program":
      - Program/script: `PowerShell.exe`
      - Add arguments: `-NoProfile -ExecutionPolicy Bypass -File "PATH\TO\voicemeeter.ps1" -WindowStyle Hidden`
      
   f. Settings tab:
      - Check "Allow task to be run on demand"
      - Check "Run task as soon as possible after a scheduled start is missed"
      - Set "If the task fails, restart every" to 1 minute

## How It Works

The script performs the following actions:

1. Checks for administrator privileges and requests elevation if needed
2. Continuously monitors for both audiodg.exe and Voicemeeter processes
3. When both processes are detected:
   - Gets the total number of CPU cores
   - Calculates the affinity mask for the last CPU core
   - Applies the CPU affinity and "High" priority to both processes
4. Exits automatically after successful configuration

## Troubleshooting

### The script doesn't seem to work
- Make sure the scheduled task is set to run with highest privileges
- Check the Task Scheduler history for any error messages
- Run the script manually with administrator rights to see any error messages

### Voicemeeter process not found
- Make sure Voicemeeter is running before the script executes
- The script will keep retrying every 10 seconds until Voicemeeter is detected

### Access denied errors
- Ensure the script has administrator privileges
- Disable any security software that might be blocking the script

## License

This project is open source and available under the [MIT License](LICENSE).

## Credits

Created for Voicemeeter users looking to optimize their audio processing performance.