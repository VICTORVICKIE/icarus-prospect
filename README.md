# Waxen: Icarus Prospect Save Synchronization Script

## Overview

Waxen is a PowerShell script designed to simplify synchronizing Icarus game save files between your local machine and a GitHub repository. 
It provides two primary commands: `fly` and `land`, which help you push and pull your game saves effortlessly.
Like Icarus's wings bridging the mortal realm with the heavens, this script bridges your local game saves with the cloud, 
helping you soar between different save states without falling into the sea of lost progress.

## Prerequisites

-   PowerShell
-   Git installed and configured
-   GitHub account
-   Icarus game installed

## Features

-   Automatically locate your Icarus save files
-   Push local save files to GitHub
-   Pull save files from GitHub to local machine
-   Timestamp-based backup of save files
-   Simple, intuitive commands

## Setup

1.  Clone this repository to your local machine.
`git clone https://github.com/VICTORVICKIE/icarus-prospect.git`
2.  Ensure Git is installed and accessible in your system PATH.
3.  The script will automatically use your latest Steam ID for save file management.

## Usage

### Commands

-   `.\waxen.ps1 fly`: Pushes your current Icarus save to GitHub
    -   Copies the save file to the current directory
    -   Commits changes with a timestamp
    -   Pushes to the main branch
-   `.\waxen.ps1 land`: Pulls the latest save from GitHub
    -   Backs up your current local save with a timestamp
    -   Pulls latest save from GitHub
    -   Copies save to Icarus saves directory

### Help

-   `.\waxen.ps1 help`: Shows available subcommands
-   `.\waxen.ps1 help fly`: Detailed help for the `fly` command
-   `.\waxen.ps1 help land`: Detailed help for the `land` command
