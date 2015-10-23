@echo off
cd ../bin
B2FTP  -l 123.456.789.0 -u username -d builds -s ../assets
pause