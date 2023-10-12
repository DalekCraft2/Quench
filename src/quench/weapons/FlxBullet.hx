package quench.weapons;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxRect;

/**
 * @link http://www.photonstorm.com
 * @link http://www.haxeflixel.com
 * @author Richard Davey / Photon Storm
 * @author Touch added by Impaler / Beeblerox
 */
class FlxBullet extends FlxSprite {
	/**
	 * For how long this bullet will exist before being killed, in seconds.
	 */
	public var lifespan:Float;

	/**
	 * The `bounds` field from the parent `FlxWeapon`.
	 */
	@:allow(quench.weapons)
	var bounds:FlxRect;

	public function new() {
		super(0, 0);
		exists = false;
	}

	override public function update(elapsed:Float):Void {
		if (lifespan > 0) {
			lifespan -= elapsed;

			if (lifespan <= 0) {
				kill();
			}
		}

		if (!FlxMath.pointInFlxRect(Math.floor(x), Math.floor(y), bounds)) {
			kill();
		}

		super.update(elapsed);
	}

	override public function destroy():Void {
		super.destroy();

		// bounds = FlxDestroyUtil.put(bounds);
		bounds = null; // The FlxRect instance is still used by the parent FlxWeapon
	}
}
