package quench.weapons;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.helpers.FlxBounds;

// TODO Improve melee weapons; make the "bullets" move with the player, rather than acting like actual bullets
class Fists extends QuenchWeapon {
	public function new(parent:FlxSprite) {
		var bulletSize:Int = 25;
		super("fists", parent, SPEED(new FlxBounds<Float>(300, 300)), bulletSize);

		var fireFromRect:FlxRect = FlxRect.get()
			.fromTwoPoints(FlxPoint.weak(parent.width / 2 - bulletSize, parent.height / 2 - bulletSize), FlxPoint.weak(parent.width / 2, parent.height / 2));

		fireFrom = PARENT(parent, fireFromRect);

		bulletLifeSpan = new FlxBounds<Float>(0.1, 0.1);
		fireRate = 0.15;

		recoil = false;
		bulletColor = parent.color;
		bulletMass = 0.05;
		bulletDamage = 0.5;

		useAmmo = false;

		var originalCallback:() -> Void = onPostFireCallback;
		setPostFireCallback(() -> {
			originalCallback();
			currentBullet.alpha = 0.8;
		});
	}
}
