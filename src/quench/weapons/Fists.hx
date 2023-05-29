package quench.weapons;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.helpers.FlxBounds;

// TODO Improve melee weapons; make the "bullets" move with the player, rather than acting like actual bullets
class Fists extends QuenchWeapon {
	public function new(parent:FlxSprite) {
		var bulletSize:Int = 25;
		super("fists", parent, SPEED(new FlxBounds<Float>(300, 300)), bulletSize);

		fireFrom = PARENT(parent,
			new FlxBounds(FlxPoint.get(parent.width / 2 - bulletSize, parent.height / 2 - bulletSize), FlxPoint.get(parent.width / 2, parent.height / 2)));

		bulletLifeSpan = new FlxBounds<Float>(0.1, 0.1);
		fireRate = 150;

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
