package quench;

import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.IBitmapDrawable;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

using StringTools;

// credits, original source https://lassieadventurestudio.wordpress.com/2008/10/07/image-outline/
class ImageOutline {
	/**
	 * Renders a BitmapData display of any IBitmapDrawable with an outline drawn around it.
	 * Outline is rendered based on image's alpha channel.
	 * @param src source IBitmapDrawable image to outline.
	 * @param weight stroke thickness (in pixels) of outline.
	 * @param color color of outline.
	 * @param alpha opacity of outline (range of 0 to 1).
	 * @param useMatrix if src is a DisplayObject, whether to use its transformation matrix when drawing the BitmapData.
	 * @param antialias smooth edge (true), or jagged edge (false).
	 * @param threshold Alpha sensitivity to source image (0 - 1). Used when drawing a jagged edge based on an antialiased source image.
	 * @return BitmapData of rendered outline image.
	 */
	public static function renderImage(src:IBitmapDrawable, weight:Int, color:FlxColor, alpha:Float = 1, useMatrix:Bool = true, antialias:Bool = false,
			threshold:Float = 0.56):BitmapData {
		var render:BitmapData = null;
		if (src is DisplayObject) {
			var dsp:DisplayObject = cast src;
			var width:Int = Std.int(dsp.width);
			var height:Int = Std.int(dsp.height);
			var matrix:Matrix = useMatrix ? dsp.transform.matrix : null;
			render = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
			render.draw(src, matrix);
		} else if (src is BitmapData) {
			render = cast src;
		}

		if (render != null) {
			return outline(render, weight, color, alpha, antialias, threshold);
		}
		return null;
	}

	/**
	 * Renders an outline around a BitmapData image.
	 * Outline is rendered based on image's alpha channel.
	 * @param src source BitmapData image to outline.
	 * @param weight stroke thickness (in pixels) of outline.
	 * @param color color of outline.
	 * @param alpha opacity of outline (range of 0 to 1).
	 * @param antialias smooth edge (true), or jagged edge (false).
	 * @param threshold Alpha sensitivity to source image (0 - 1). Used when drawing a jagged edge based on an antialiased source image.
	 * @return BitmapData of rendered outline image.
	 */
	public static function outline(src:BitmapData, weight:Int, color:FlxColor, alpha:Float = 1, antialias:Bool = false, threshold:Float = 0.56):BitmapData {
		var brush:Int = (weight * 2) + 1;

		var copy:BitmapData = src.clone();

		for (iy in 0...src.height) {
			for (ix in 0...src.width) {
				// get current pixel's alpha component.
				var pixelColor:FlxColor = src.getPixel32(ix, iy);
				var pixelAlpha:Float = pixelColor.alphaFloat;
				var colorToUse:FlxColor = color;
				colorToUse.alphaFloat *= alpha;
				if (antialias) {
					// if antialiasing,
					// draw anti-aliased edge.
					_antialias(copy, ix, iy, colorToUse, brush);
				} else if (pixelAlpha > threshold) {
					// if aliasing and pixel alpha is above draw threshold,
					// draw aliased edge.
					_alias(copy, ix, iy, colorToUse, brush);
				}
			}
		}

		// merge source image display into the outline shape's canvas.
		copy.copyPixels(src, new Rectangle(0, 0, copy.width, copy.height), new Point(weight, weight), null, null, true);
		return copy;
	}

	/**
	 * Renders an antialiased pixel block.
	 */
	private static function _antialias(src:BitmapData, x:Int, y:Int, color:FlxColor, brush:Int):BitmapData {
		if (color.alpha > 0) {
			for (iy in y...y + brush) {
				for (ix in x...x + brush) {
					// get current pixel's alpha component.
					var pixelColor:FlxColor = src.getPixel32(ix, iy);
					var pixelAlpha:Float = pixelColor.alphaFloat;

					// set pixel if it's target adjusted alpha is greater than the current value.
					if (pixelAlpha < color.alphaFloat) {
						src.setPixel32(ix, iy, color);
					}
				}
			}
		}
		return src;
	}

	/**
	 * Renders an aliased pixel block.
	 */
	private static function _alias(src:BitmapData, x:Int, y:Int, color:FlxColor, brush:Int):BitmapData {
		src.fillRect(new Rectangle(x, y, brush, brush), color);
		return src;
	}
}
