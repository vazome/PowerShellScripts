# PowerShellScripts
This is the main repository for my PowerShell works, most of them are "bleached" aka connection strings or any sensetive information that might be exposed are removed from the script. I need time to adapt and commit all my curren scripts to GitHub.
## [InboundCheck](/Project%20Specific/InboundCheck%20Ver1.2.ps1) (Final)
Current Version: 1.0 (Stable)
It's a complitaced tool that aimed to safe time and automate workflow, includes manipulation with SQL, WCF, .NET and RABBIT MQ (REST API). It is mostly "bleached" and only shows my current scripting level. But there is always a room to advance!

## [Logkit](/Windows/Logkit.ps1) (POSTPONED)
Logkit is a tool written in PowerShell to ease the things with log checking, it can work with multiple huge logs at once!

Current Version: 1.0 (Stable)

The main concept is to give a robot handle something that shouldn’t be done by a human and/or where current tools are struggling at something.
The tool has features such as:
- 🔎 Search - common search in huge sized logs
- 📥 Get values and X - get’s values and does something to them
- 🔁 Convert to SQL - converts set of values to SQL format
- 👥 Differentiation -  compares 2 files (For today compares only .CSVs)

All tools in this Toolkit are easy to use. If you encounter any issue or error, please get informed here and contact me if you have not found an answer.
### A little bit of theory
This tool uses regex. There are many advantages of using it and the most important are:
- Universality
- Scale-ability
- Ease of control

Quick example:
Get values and X tool mainly uses formula like this `(?<="yourvalue":"|"yourvalue\\":\\")[^\\"]+` to find needed values. You can actually see how it works! Just click on the [link here](https://regexr.com/59s8q).
![Example](/Up%20To%20Date/Images/examplesku.png)

- Universal - As you can see it can be used even outside of PowerShell
- Scale-ability - We can change the formula in order to adapt to changes. 
- Ease of control - This is not a fancy multiline code but a short and logical formula that a person can get acquainted with. 
### Let’s put some practice
#### Search
The “Search” is the default option in the selection menu (this means that you can just press enter). 

Purpose: search in huge logs, relatively quick
![Menu](/Up%20To%20Date/Images/mainMenu.png)

- You will be asked to specify files for search
- Then provide the search scope(s) (regex enabled)
- After, you will be prompted to save it all to a file.

![Multiselection is enabled](/Up%20To%20Date/Images/multiselection.jpg)

#### Get values and X
Purpose: extract values from a specific method in a specific log and maybe convert them.

1. You will be asked to specify one file for search
2. Provide the first search scope, here you can split patterns by comma (,) or just skip it all (regex enabled)
3. With the second prompt, you specify a value to extract
4. In the end, found values can be saved and get unification, and Converted to SQL

![Get Values Image](/Up%20To%20Date/Images/selectiongtin.png)

#### Convert to SQL
Purpose: to convert an array of values to an SQL-friendly format.

You just select a file to process and save everything in another.

|BEFORE|AFTER|
|:------------:|:-------------------:|
|4060507377377|('4060507377377',|
|4060507377322|'4060507377322',|
|4060507378343|'4060507378343',|
|4060507379425|'4060507379425',|
|4060507379449|'4060507379449’)|

#### Differentiation
Purpose: comparison of huge text arrays to find similarities and etc.
The tool and documentation are in progress.

## [Export Distribution (mailing) Groups with Related Users](Exchange/ExportDistributionGroupsWithRelatedUsers.ps1)
This is simple. One thing that you need is enough rights to launch below mentioned commands.
If it fails and gives you errors like "-Filter is not recognized", please refer to: Exchange.
The code itself:
### 
## License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
