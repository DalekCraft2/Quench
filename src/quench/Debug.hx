package quench;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.debug.log.LogStyle;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import haxe.Log;
import haxe.PosInfos;
import openfl.Lib;
import quench.objects.Enemy;
import quench.objects.Entity;
import quench.objects.PhysicsObject;

using StringTools;

#if sys
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
#end

/**
 * This class contains lots of utility functions for logging and debugging.
 * The goal is to integrate development more heavily with the HaxeFlixel debugger.
 * 
 * @see https://haxeflixel.com/documentation/debugger/
 */
class Debug {
	// I decided to merge Log4j2's log levels with HaxeFlixel's, which results in Log4j2's plus the "Notice" level.
	// The colors used for them, with the exception of "Trace" for visibility reasons, are based on this: https://logging.apache.org/log4j/2.x/manual/layouts.html
	private static final LOG_STYLE_FATAL:LogStyle = new LogStyle("[FATAL] ", "FF8888", 12, false, false, false, "flixel/sounds/beep", true);
	private static final LOG_STYLE_ERROR:LogStyle = LogStyle.ERROR;
	private static final LOG_STYLE_WARNING:LogStyle = LogStyle.WARNING;
	private static final LOG_STYLE_NOTICE:LogStyle = LogStyle.NOTICE;
	private static final LOG_STYLE_INFO:LogStyle = new LogStyle('[INFO] ', '5CF878');
	private static final LOG_STYLE_DEBUG:LogStyle = new LogStyle('[DEBUG] ', '00FFFF');
	private static final LOG_STYLE_TRACE:LogStyle = new LogStyle('[TRACE] ', 'FFFFFF');
	public static final LOG_STYLES:Array<LogStyle> = [
		LOG_STYLE_FATAL,
		LOG_STYLE_ERROR,
		LOG_STYLE_WARNING,
		LOG_STYLE_NOTICE,
		LOG_STYLE_INFO,
		LOG_STYLE_DEBUG,
		LOG_STYLE_TRACE
	];
	public static final LOG_STYLE_NAMES:Array<String> = [for (style in LOG_STYLES) style.prefix.replace("[", "").replace("]", "")];

	private static var logFileWriter:DebugLogWriter;

	/**
	 * Log a fatal message to the game's console.
	 * Plays a beep to the user and forces the console open if this is a debug build.
	 * @param input The message to display.
	 * @param pos This magic type is auto-populated, and includes the line number and class it was called from.
	 */
	public static inline function logFatal(input:Any, ?pos:PosInfos):Void {
		if (input == null)
			return;
		var output:Array<Any> = formatOutput(input, pos);
		writeToFlxGLog(output, LOG_STYLE_FATAL);
		writeToLogFile(output, LOG_STYLE_FATAL);
	}

	/**
	 * Log an error message to the game's console.
	 * Plays a beep to the user and forces the console open if this is a debug build.
	 * @param input The message to display.
	 * @param pos This magic type is auto-populated, and includes the line number and class it was called from.
	 */
	public static inline function logError(input:Any, ?pos:PosInfos):Void {
		if (input == null)
			return;
		var output:Array<Any> = formatOutput(input, pos);
		writeToFlxGLog(output, LOG_STYLE_ERROR);
		writeToLogFile(output, LOG_STYLE_ERROR);
	}

	/**
	 * Log an warning message to the game's console.
	 * Plays a beep to the user and forces the console open if this is a debug build.
	 * @param input The message to display.
	 * @param pos This magic type is auto-populated, and includes the line number and class it was called from.
	 */
	public static inline function logWarn(input:Any, ?pos:PosInfos):Void {
		if (input == null)
			return;
		var output:Array<Any> = formatOutput(input, pos);
		writeToFlxGLog(output, LOG_STYLE_WARNING);
		writeToLogFile(output, LOG_STYLE_WARNING);
	}

	/**
	 * Log a notice message to the game's console. Only visible in debug builds.
	 * @param input The message to display.
	 * @param pos This magic type is auto-populated, and includes the line number and class it was called from.
	 */
	public static inline function logNotice(input:Any, ?pos:PosInfos):Void {
		if (input == null)
			return;
		var output:Array<Any> = formatOutput(input, pos);
		writeToFlxGLog(output, LOG_STYLE_NOTICE);
		writeToLogFile(output, LOG_STYLE_NOTICE);
	}

	/**
	 * Log an info message to the game's console. Only visible in debug builds.
	 * @param input The message to display.
	 * @param pos This magic type is auto-populated, and includes the line number and class it was called from.
	 */
	public static inline function logInfo(input:Any, ?pos:PosInfos):Void {
		if (input == null)
			return;
		var output:Array<Any> = formatOutput(input, pos);
		writeToFlxGLog(output, LOG_STYLE_INFO);
		writeToLogFile(output, LOG_STYLE_INFO);
	}

	/**
	 * Log a debug message to the game's console. Only visible in debug builds.
	 * @param input The message to display.
	 * @param pos This magic type is auto-populated, and includes the line number and class it was called from.
	 */
	public static inline function logDebug(input:Any, ?pos:PosInfos):Void {
		if (input == null)
			return;
		var output:Array<Any> = formatOutput(input, pos);
		writeToFlxGLog(output, LOG_STYLE_DEBUG);
		writeToLogFile(output, LOG_STYLE_DEBUG);
	}

	/**
	 * Log a debug message to the game's console. Only visible in debug builds.
	 * NOTE: We redirect all Haxe `trace()` calls to this function.
	 * @param input The message to display.
	 * @param pos This magic type is auto-populated, and includes the line number and class it was called from.
	 */
	public static inline function logTrace(input:Any, ?pos:PosInfos):Void {
		if (input == null)
			return;
		var output:Array<Any> = formatOutput(input, pos);
		writeToFlxGLog(output, LOG_STYLE_TRACE);
		writeToLogFile(output, LOG_STYLE_TRACE);
	}

	/**
	 * Displays a popup with the provided text.
	 * This interrupts the game, so make sure it's REALLY important.
	 * @param title The title of the popup.
	 * @param description The description of the popup.
	 */
	public static inline function displayAlert(title:String, description:String):Void {
		Lib.application.window.alert(description, title);
	}

	/**
	 * Display the value of a particular field of a given object
	 * in the Debug watch window, labelled with the specified name.
	 * Updates continuously.
	 * @param object The object to watch.
	 * @param field The string name of a field of the above object.
	 * @param name
	 */
	public static inline function watchVariable(object:Any, field:String, name:String):Void {
		#if debug
		if (object == null) {
			Debug.logError('Tried to watch a variable on a null object!');
			return;
		}
		FlxG.watch.add(object, field, name == null ? field : name);
		#end
		// Else, do nothing outside of debug mode.
	}

	/**
	 * Adds the specified value to the Debug Watch window under the current name.
	 * A lightweight alternative to watchVariable, since it doesn't update until you call it again.
	 * 
	 * @param name
	 * @param value
	 */
	public static inline function quickWatch(name:String, value:Any):Void {
		FlxG.watch.addQuick(name == null ? 'QuickWatch' : name, value);
	}

	/**
	 * The Console window already supports most hScript, meaning you can do most things you could already do in Haxe.
	 * However, you can also add custom commands using this function.
	 */
	public static inline function addConsoleCommand(name:String, callbackFn:Any):Void {
		FlxG.console.registerFunction(name, callbackFn);
	}

	/**
	 * Add an object with a custom alias so that it can be accessed via the console.
	 */
	public static inline function addObject(name:String, object:Any):Void {
		FlxG.console.registerObject(name, object);
	}

	/**
	 * Create a tracker window for an object.
	 * This will display the properties of that object in
	 * a fancy little Debug window you can minimize and drag around.
	 * 
	 * @param obj The object to display.
	 */
	public static inline function trackObject(obj:Any):Void {
		if (obj == null) {
			Debug.logError('Tried to track a null object!');
			return;
		}
		FlxG.debugger.track(obj);
	}

	/**
	 * The game runs this function immediately when it starts.
	 * Use onGameStart() if it can wait until a little later.
	 */
	public static function onInitProgram():Void {
		// Initialize logging tools.
		trace('Initializing Debug tools...');

		// Getting the original trace() function before overriding it.
		var traceFunction:(v:Any, ?infos:PosInfos) -> Void = Log.trace; // No, HaxeCheckstyle, this is not a case of inner assignment. Shut up.

		// Override Haxe's vanilla trace() calls to use the Flixel console.
		Log.trace = (data:Any, ?info:PosInfos) -> {
			var paramArray:Array<Any> = [data];

			if (info != null) {
				if (info.customParams != null) {
					for (param in info.customParams) {
						paramArray.push(param);
					}
				}
			}

			logTrace(paramArray, info);
		};

		// Start the log file writer.
		// We have to set it to TRACE for now.
		// We also set the log file writer's trace() calls to be directed to the original trace() function.
		logFileWriter = new DebugLogWriter(LOG_STYLE_TRACE, traceFunction);

		logInfo('Debug logging initialized.');

		#if debug
		logInfo('This is a DEBUG build.');
		#else
		logInfo('This is a RELEASE build.');
		#end
		logInfo('HaxeFlixel version: ${Std.string(FlxG.VERSION)}');
		logInfo('${Lib.application.meta.get('name')} version: ${Lib.application.meta.get('version')}');
	}

	/**
	 * The game runs this function when it starts, but after Flixel is initialized.
	 */
	public static function onGameStart():Void {
		// Add the mouse position to the debug Watch window.
		FlxG.watch.addMouse();

		defineTrackerProfiles();
		defineConsoleCommands();

		// Now we can remember the log level.
		// if (EngineData.save.data.debugLogLevel == null)
		// 	EngineData.save.data.debugLogLevel = 'TRACE';

		// logFileWriter.setLogLevel(EngineData.save.data.debugLogLevel);
	}

	private static function writeToFlxGLog(data:Array<Any>, logStyle:LogStyle):Void {
		if (FlxG != null && FlxG.game != null && FlxG.log != null) {
			FlxG.log.advanced(data, logStyle);
		}
	}

	private static function writeToLogFile(data:Array<Any>, logStyle:LogStyle):Void {
		if (logFileWriter != null && logFileWriter.isActive()) {
			logFileWriter.write(data, logStyle);
		}
	}

	/**
	 * Defines what properties will be displayed in tracker windows for the given classes.
	 */
	private static function defineTrackerProfiles():Void {
		FlxG.debugger.addTrackerProfile(new TrackerProfile(PhysicsObject, null, [FlxSprite]));
		FlxG.debugger.addTrackerProfile(new TrackerProfile(Entity, ["directionalAcceleration", "entityMovementSpeed", "isWalking", "noAcceleration"],
			[PhysicsObject]));
		FlxG.debugger.addTrackerProfile(new TrackerProfile(Enemy, ["target"], [Entity]));
	}

	/**
	 * Defines some commands you can run in the console for easy use of important debugging functions.
	 * Feel free to add your own!
	 */
	private static inline function defineConsoleCommands():Void {
		addConsoleCommand('setLogLevel', (logLevel:String) -> {
			if (LOG_STYLE_NAMES.contains(logLevel)) {
				Debug.logInfo('CONSOLE: Setting log level to $logLevel...');
				logFileWriter.setLogLevel(logLevel);
			} else {
				Debug.logWarn('CONSOLE: Invalid log level $logLevel!');
				Debug.logWarn('  Expected one of: ${LOG_STYLE_NAMES.join(', ')}');
			}
		});
	}

	private static function formatOutput(input:Any, pos:PosInfos):Array<Any> {
		// This code is junk but I kept getting Null Function References.
		// TODO Make this code not "junk".
		var inArray:Array<Any>;
		if (input == null) {
			inArray = ['<NULL>'];
		} else if (input is Array) {
			inArray = input;
		} else {
			inArray = [input];
		}

		if (pos == null)
			return inArray;

		// Format the position ourselves.
		var output:Array<Any> = ['(${pos.className}/${pos.methodName}#${pos.lineNumber}): '];

		return output.concat(inArray);
	}
}

class DebugLogWriter {
	private static final LOG_FOLDER:String = 'logs';

	public var traceFunction:(v:Any, ?infos:PosInfos) -> Void;

	private var logLevel:Int;

	/**
	 * Whether this DebugLogWriter has access to the file system.
	 */
	private var active:Bool = false;

	#if sys
	private var file:FileOutput;
	#end

	public function new(logLevelParam:LogStyle, traceFunction:(v:Any, ?infos:PosInfos) -> Void) {
		logLevel = Debug.LOG_STYLES.indexOf(logLevelParam);
		this.traceFunction = traceFunction;

		#if sys
		print('Initializing log file...');

		var logFilePath:String = Path.join([LOG_FOLDER, Path.withExtension(Std.string(Date.now().getTime()), 'log')]);

		// Make sure that the path exists
		if (logFilePath.contains('/')) {
			var lastIndex:Int = logFilePath.lastIndexOf('/');
			var logFolderPath:String = logFilePath.substr(0, lastIndex);
			print('Creating log folder $logFolderPath');
			FileSystem.createDirectory(logFolderPath);
		}
		// Open the file
		print('Creating log file $logFilePath');
		file = File.write(logFilePath, false);
		active = true;
		#else
		print('Can not create log file; no file system access.');
		active = false;
		#end
	}

	public function isActive():Bool {
		return active;
	}

	private function shouldLog(input:LogStyle):Bool {
		var levelIndex:Int = Debug.LOG_STYLES.indexOf(input);
		// Could not find this log level.
		if (levelIndex == -1)
			return false;
		return levelIndex <= logLevel;
	}

	public function setLogLevel(input:String):Void {
		var levelIndex:Int = Debug.LOG_STYLE_NAMES.indexOf(input);
		// Could not find this log level.
		if (levelIndex == -1)
			return;

		logLevel = levelIndex;
		// EngineData.save.data.debugLogLevel = logLevel;
	}

	/**
	 * Output text to the log file.
	 */
	public function write(input:Array<Any>, logStyle:LogStyle):Void {
		var ts:String = Date.now().toString();
		var msg:String = '$ts ${logStyle.prefix} ${input.join('')}';

		// Output text to the debug console directly.
		if (shouldLog(logStyle)) {
			print(msg);
		}

		#if sys
		if (active && file != null) {
			if (shouldLog(logStyle)) {
				file.writeString('$msg\n');
				file.flush();
				file.flush();
			}
		}
		#end
	}

	private function print(msg:String):Void {
		// Pass no argument for the PosInfos to exclude the position.
		traceFunction(msg);
	}
}
