# B2FTP
B2FTP (Build to FTP) is a simple command line interface to upload build files to FTP. Made in Haxe and Neko.

I mainly use this as a quick way for me to upload my build files made in Flambe/2DKit to an FTP server. The project started out as a way for me to learn Neko and I have improved it ever since to be more robust and easy to use.

# Download
* [B2FTP.exe](https://docs.google.com/uc?authuser=0&id=0B_P9tqmR0jHZZ3pXRU1Tb2kzakkc&export=download) (Windows)

# How to Use
Using the command prompt just type B2FTP.exe and supply the following options.

* -l --url      The url to connect to.
* -o --port     The port number to connect to.
* -u --user     The username to use when connecting.
* -p --pass     [OPTIONAL] The password to use when connecting.
* -d --dest     The destination directory at the remote server. Relative from the initial directory.
* -s --source   The source directory in the local computer. Relative from the current working directory.
* -D --debug    Debug mode. Prints helpful debug messages.
* -h --help     Shows the help

For example:
```
B2FTP  -l 123.456.789.0 -u username -p pass -d builds -s ../assets
```

To make things easier, you can also make a .bat file that automatically supplies the needed options.

# Usage Notes
* You can choose not to specify a password. You will be asked for it while it is connecting.
* Use debug mode to see more debug traces. This is useful for troubleshooting if any problems arise.

# Hacking the source
If you don't have it, download and install haxe and neko on your machine. http://haxe.org/

Then, install the "mtwin" library from haxelib and include it as a classpath for your project.

```
haxelib install mtwin
```

Download the source and it should work.

# Hacking Notes
* Be sure to change the options found in Run.bat
* tester.bat is used for testing the generated .exe file. Be sure to change the necessary options in it as well.
* The files and directories in the assets folder are used for testing if the uploading is working properly

# To do
[ ] Allow accepting of backspace when entering the password
