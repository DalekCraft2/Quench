package quench;

import flixel.FlxG;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import flixel.math.FlxMath;
import flixel.util.FlxBitmapDataPool;
import flixel.util.FlxColor;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.IBitmapDrawable;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
#if flash
import openfl.Lib;
import openfl.display.PixelSnapping;
#end
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end

/**
 * The FPS class provides an easy-to-use monitor to display
 * the current frame rate of an OpenFL project
 */
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPSMem extends TextField {
	/**
	 * 	The current frame rate, expressed using frames-per-second
	 */
	public var currentFrameRate(default, null):Int;

	public var currentMemory(default, null):Int;

	public var highestMem:Int = 0;

	private var bitmap:Bitmap;
	private var outlineEffect:FlxOutlineEffect;

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

	/**
	 * Converts an `IBitmapDrawable` to a `BitmapData`.
	 * @param src Source `IBitmapDrawable`.
	 * @param bitmapData Optional `BitmapData` to reuse instead of creating a new instance.
	 * @return `BitmapData` created from source.
	 */
	public static function toBitmapData(src:IBitmapDrawable, ?bitmapData:BitmapData):BitmapData {
		if (src is DisplayObject) {
			var dsp:DisplayObject = cast src;
			var width:Int = Std.int(dsp.width);
			var height:Int = Std.int(dsp.height);
			if (bitmapData == null) {
				bitmapData = FlxBitmapDataPool.get(width, height, true, FlxColor.TRANSPARENT, true);
			} else {
				#if flash
				#else
				@:privateAccess bitmapData.__resize(width, height);
				#end
				bitmapData.fillRect(bitmapData.rect, FlxColor.TRANSPARENT);
			}

			bitmapData.draw(src);
		} else if (src is BitmapData) {
			var bmp:BitmapData = cast src;
			var width:Int = bmp.width;
			var height:Int = bmp.height;
			if (bitmapData == null) {
				// bitmapData = FlxBitmapDataPool.get(width, height, true, FlxColor.TRANSPARENT, true);
				bitmapData = bmp;
			} else {
				#if flash
				// TODO Implement this for Flash
				#else
				@:privateAccess bitmapData.__resize(width, height);
				#end
				bitmapData.fillRect(bitmapData.rect, FlxColor.TRANSPARENT);
			}
		}
		return bitmapData;
	}

	public function new(x:Float = 0, y:Float = 0, color:FlxColor = FlxColor.BLACK) {
		super();

		this.x = x;
		this.y = y;

		currentFrameRate = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		text = "Frame Rate: " + currentFrameRate + "\n";
		width += 200;

		// var filter:GlowFilter = new GlowFilter(FlxColor.BLACK, 1, 6, 6, 0, BitmapFilterQuality.LOW, false, true);
		// filters.push(filter);
		// filters = [filter];

		// On the Flash target, pixelSnapping is not automatically set to PixelSnapping.AUTO if it is null, so we have to provide it manually
		bitmap = new Bitmap(null, #if flash PixelSnapping.AUTO #else null #end, true);
		bitmap.x = this.x;
		bitmap.y = this.y;

		outlineEffect = new FlxOutlineEffect(NORMAL, FlxColor.BLACK);

		addEventListener(Event.ADDED_TO_STAGE, (e:Event) -> {
			parent.addChildAt(bitmap, parent.getChildIndex(this));
		});

		addEventListener(Event.REMOVED_FROM_STAGE, (e:Event) -> {
			parent.removeChild(bitmap);
		});

		#if flash
		addEventListener(Event.ENTER_FRAME, (e:Event) -> {
			var time:Int = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	#if !flash override #end private function __enterFrame(deltaTime:Int):Void {
		#if !flash
		super.__enterFrame(deltaTime);
		#end

		currentTime += deltaTime;
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

			textColor = FlxColor.WHITE;
			if (currentFrameRate <= FlxG.drawFramerate / 2) {
				textColor = FlxColor.RED;
			}

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "totalDC: " + Context3DStats.totalDrawCalls() + "\n";
			text += "stageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE) + "\n";
			text += "stage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D) + "\n";
			#end
		}

		cacheCount = currentCount;

		bitmap.x = x;
		bitmap.y = y;
		bitmap.visible = visible;

		outlineEffect.dirty = true;
		if (bitmap.bitmapData != null) {
			FlxBitmapDataPool.put(bitmap.bitmapData);
		}
		#if !hl // Bug caused by either Lime, OpenFL, or Flixel
		bitmap.bitmapData = outlineEffect.apply(toBitmapData(this));
		#end
	}
}
