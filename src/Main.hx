/**
 * The MIT License (MIT)
 * 
 * Copyright (c) 2015 Juan Karlo Licudine
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package;

import haxe.io.Input;
import lib.GetPot;
import mtwin.net.Ftp;
import neko.Lib;
import sys.FileSystem;
import sys.io.File;
 
class Main 
{	
	static private var _debugMode:Bool = false;
	static private var _configData:ConfigData;
	static private var _ftp:Ftp;
	
	static function main() 
	{		
		log("====================== B2FTP ======================");
		
		_configData = new ConfigData();	
		handleSystemArguments();
		
		if ( _configData.pass == null )
			askForPassword();
		
		setupFTP();
		
		var timeStamp : String = getTimeStamp();
		setupRemoteDirectory(timeStamp);
		setupSourceDirectory();
		
		var sourceArray : Array<String> = FileSystem.readDirectory(Sys.getCwd());
		log("Uploading...");
		loopThroughDirectory(sourceArray, "");
		
		log("...................");
		log("Uploading complete!");
		
		_ftp.close();		
	}
	
	// ============================================= SETUP ============================================= //
	static private function setupFTP()
	{
		try {
			log("Connecting to FTP...");
			_ftp = new Ftp(_configData.url, _configData.port);					
			_ftp.login(_configData.user, _configData.pass);	
		}
		catch (msg : String) {
			logError(msg);
			Sys.exit(1);
		}
	}
	
	static private function setupRemoteDirectory(timeStamp : String) 
	{
		try {
			_ftp.cwd(_configData.destinationDirectory);			
			_ftp.createDirectory(timeStamp);
			_ftp.cwd(timeStamp);
			log("Remote working directory is set to: " + _ftp.pwd());
		}
		catch (msg : String) {
			logError(msg);
			Sys.exit(1);
		}		
	}
	
	static private function setupSourceDirectory() 
	{
		checkIfDirectoryExists(_configData.sourceDirectory, "source");	
		Sys.setCwd(_configData.sourceDirectory);
		debugLog("Local working directory is " + Sys.getCwd());
	}
	
	// ============================================= FLOW ============================================= //
	static private function askForPassword() 
	{
		log("Type your password and press enter: ");
		
		var enteredInput : Int;
		var enteredText : String = "";
		while ( true) {
			enteredInput = Sys.getChar(false);
			if ( enteredInput == 13 )
				break;
			
			enteredText += String.fromCharCode(enteredInput);				
		}
		
		_configData.pass = enteredText;		
		debugLog("The password you entered is " + _configData.pass);
	}
	
	static private function printHelp() 
	{
		log("====================== Help ======================\n" +
			"    -l --url      The url to connect to.\n" +
			"    -o --port     The port number to connect to.\n" +
			"    -u --user     The username to use when connecting.\n" +
			"    -p --pass     [OPTIONAL] The password to use when connecting.\n" +
			"    -d --dest     The destination directory at the remote server.\n" +
			"                  Relative from the initial directory.\n" +
			"    -s --source   The source directory in the local computer. Relative\n" +
			"                  from the current working directory.\n" +
			"    -D --debug    Debug mode. Prints helpful debug messages.\n"
		);
	}
	
	// ============================================= HELPERS ============================================= //
	static private function loopThroughDirectory(sourceArray : Array<String>, baseDirectory : String) 
	{
		for ( source in sourceArray ) {
			var newSourcePath : String = baseDirectory + source;
			
			debugLog("newSourcePath is " + newSourcePath);
			if ( FileSystem.isDirectory(Sys.getCwd() + newSourcePath) ) {	
				debugLog("Found local directory " + Sys.getCwd() + newSourcePath);
				_ftp.createDirectory(newSourcePath);
				log("Created remote directory at " + newSourcePath);
				
				var newSourceArray : Array<String> = FileSystem.readDirectory(Sys.getCwd() + newSourcePath);
				loopThroughDirectory(newSourceArray, newSourcePath + "/");				
			}
			else {				
				debugLog("Found local file: " + Sys.getCwd() + newSourcePath);
				_ftp.put(File.read(Sys.getCwd() + newSourcePath), newSourcePath);
				log("Uploaded local file at " + newSourcePath);
			}
		}
	}
	
	static private function handleSystemArguments() 
	{			
		var systemArgs : Array<String> = Sys.args();
		debugLog("System arguments: " + systemArgs);
		
		if ( systemArgs.length <= 0 )
			logError("No options were detected");
		
		var options = new GetPot(systemArgs);		
		
		if ( options.got( ["-h"]) || options.got( ["--help"]) ) {
			printHelp();
			Sys.exit(0);
		}
		if ( options.got( ["-l"]) || options.got( ["--url"]) )
			_configData.url = options.next();	
		if ( options.got( ["-o"]) || options.got( ["--port"]) )
			_configData.port = Std.parseInt(options.next());
		if ( options.got( ["-u"]) || options.got( ["--user"]) ) 
			_configData.user = options.next();		
		if ( options.got( ["-p"]) || options.got( ["--pass"]) ) 
			_configData.pass = options.next();
		if ( options.got( ["-d"]) || options.got( ["--dest"]) ) 
			_configData.destinationDirectory = options.next();
		if ( options.got( ["-s"]) || options.got( ["--source"]) ) 
			_configData.sourceDirectory = options.next();
		if ( options.got( ["-D"]) || options.got( ["--debug"]) ) 
			_debugMode = true;
		
		checkForUnkownAndUnprocessedOptions(options);
		
		debugLog(Std.string(_configData));
	}
	
	static private function checkForUnkownAndUnprocessedOptions(options:GetPot) 
	{
		var unknown : Null<String>;		
		while (true) {
			unknown = options.unknown();
			if ( unknown == null )
				break;				
			log(unknown + " is an unknown option");			
		}
		var unprocessed : Null<String>;
		while (true) {
			unprocessed = options.unprocessed();
			if ( unprocessed == null )
				break;				
			log(unprocessed + " was not processed");			
		}
	}
	
	static private function getTimeStamp() : String
	{
		var dateString : String = Date.now().toString();
		var timeStamp : String = StringTools.replace(dateString, " ", "_");
		timeStamp = StringTools.replace(timeStamp, ":", "-");		
		debugLog("TimeStamp: " + timeStamp);	
		
		return timeStamp;
	}
	
	// ============================================= DEBUG ============================================= //
	static private function debugLog(str : String)
	{
		if ( !_debugMode )
			return;
			
		Lib.println("DEBUG: " + str);
	}
	
	static private function log(str : String)
	{
		Lib.println(str);
	}
	
	static private function logError(str : String)
	{
		Lib.println("ERROR: " + str);
	}
	
	// ============================================= EXCEPTION HANDLERS ============================================= //
	static private function checkIfDirectoryExists(directory:String, ?directoryClassification : String) 
	{
		try {
			FileSystem.isDirectory(directory);
		} 
		catch ( msg : String ) {
			logError("Cannot read " + (directoryClassification == null ? "" : directoryClassification + " ") + "directory. No such file or directory!");
			Sys.exit(1);
		}
	}
}

class ConfigData 
{
	public var url : String;
	public var user : String;
	public var pass : String;
	public var destinationDirectory : String;
	public var sourceDirectory : String;
	public var port : Int;
	
	public function new() {}
}