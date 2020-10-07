# PowerShellScripts
This is the main repository for my PowerShell works. I need time to adapt and commit all my curren scripts to GitHub.
## Search tools
### [LogToolkit](/Up%20To%20Date/Text%20Sort/LogToolkit.ps1)
LogToolkit is a tool written in PowerShell to ease the things.
Current Version: 1.0 (Stable) 
The main concept is to give a robot handle something that shouldn’t be done by a human and/or where current tools are struggling at something.
The tool has features such as:
- 🔎 Search - common search in huge sized logs
- 📥 Get values and X - get’s values and does something them
- 🔁 Convert to SQL - converts set of values to SQL format
- 👥 Differentiation -  compares 2 files (For today compares only .CSVs)

All tools in this Toolkit are easy to use. If you encounter any issue or error, please get informed here and contact me if you have not found an answer.
#### A little bit of theory
This tool uses regex. There are many advantages of using it and the most important are:
- Universality
- Scale-ability
- Ease of control

Quick example:
Get values and X tool mainly uses formula like this (?<="yourvalue":"|"yourvalue\\":\\")[^\\"]+ to find needed values. You can actually see how it works! Just click on the [link here](https://regexr.com/59s8q).
![Example](/Up%20To%20Date/Images/examplesku.png)

- Universal - As you can see it can be used even outside of PowerShell
- Scale-ability - We can change the formula in order to adapt to changes. 
- Ease of control - This is not a fancy multiline code but a short and logical formula that a person can get acquainted with. Tweak it and not ruin anything at all. 

### Deploy multiple EXEs and MSIs packages (POSTPONED)
### PC Setup (POSTPONED)
## License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
