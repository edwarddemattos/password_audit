# text_password_audit
Powershell script to audit plain text files for passwords in clear text and log them for removal


This script audits all .txt files in a folder to check for clear text credentials. Written to check configuration scripts for Cisco IOS, I'm sure it can have other uses.

It will check a target folder for text files. Then it will check all text files found for key words like 'user' and 'password'.
It then checks the text immediately after the key words for certain conditions to determine how urgent the matter may be.
Each violation is logged with line number and text.

Make sure that if you find any credentials with this script that you clear the log too.

You wouldn't want to have your passwords stored in clear text in TWO places. LOL
