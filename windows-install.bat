@echo off

@REM Call the PowerShell script and forward any arguments.
Powershell -noprofile -executionpolicy bypass -file "./windows-install.ps1" %*
