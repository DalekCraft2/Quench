package quench;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.system.System;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end

class FlxFPSMem extends FlxText {
	// private static var fpsCamera:FlxCamera = new FlxCamera();

	/**
	 * 	The current frame rate, expressed using frames per second.
	 */
	public var currentFrameRate(default, null):Int;

	public var currentMemory(default, null):Int;

	public var highestMem:Int = 0;

	@:noCompletion private var cacheCount:Int = 0;

	/**
	 * The current time, in milliseconds.
	 */
	@:noCompletion private var currentTime:Int = 0;

	@:noCompletion private var times:Array<Int> = [];

	/**
	 * Takes an amount of bytes and finds the fitting unit. Makes sure that the
	 * value is below `1024`. Example: `formatBytes(123456789);` -> 117.74 MB
	 * Modified from `FlxStringUtil.formatBytes()`.
	 */
	public static function formatBytes(bytes:Float, precision:Int = 2):String {
		var units:Array<String> = ["B", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
		var curUnit:Int = 0;
		while (bytes >= 1024 && curUnit < units.length - 1) {
			bytes /= 1024;
			curUnit++;
		}
		return FlxMath.roundDecimal(bytes, precision) + " " + units[curUnit];
	}

	public function new(x:Float = 0, y:Float = 0) {
		currentFrameRate = 0;

		super(x, y, 200, "Frame Rate: " + currentFrameRate + "\n", 14);

		// if (FlxG.cameras.list.contains(fpsCamera)) {
		// 	FlxG.cameras.add(fpsCamera);
		// }
		// camera = fpsCamera;
		setBorderStyle(OUTLINE);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		currentTime = FlxG.game.ticks;
		times.push(currentTime);
		while (times[0] < currentTime - 1000)
			times.shift();

		var currentCount:Int = times.length;
		currentFrameRate = Math.round((currentCount + cacheCount) / 2);
		currentMemory = System.totalMemory;

		if (currentMemory > highestMem)
			highestMem = currentMemory;
		if (currentCount != cacheCount && visible) {
			text = "";
			text += "Frame Rate: " + currentFrameRate + "\n";
			if (currentMemory < 0)
				text += "Memory: Leaking " + formatBytes(currentMemory) + "\n";
			else
				text += "Memory: " + formatBytes(currentMemory) + "\n";
			text += "Memory Peak: " + formatBytes(highestMem) + "\n";

			color = FlxColor.WHITE;
			if (currentFrameRate <= FlxG.drawFramerate / 2) {
				color = FlxColor.RED;
			}

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "totalDC: " + Context3DStats.totalDrawCalls() + "\n";
			text += "stageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE) + "\n";
			text += "stage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D) + "\n";
			#end
		}

		cacheCount = currentCount;
	}
}
