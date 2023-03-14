package quench.objects;

import flixel.FlxG;
import flixel.path.FlxPath;
import flixel.util.FlxColor;
import quench.weapons.QuenchWeapon;
import quench.weapons.TankGun;

class Tank extends Enemy {
	public var weapon:QuenchWeapon;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y, FlxG.bitmap.create(100, 100, FlxColor.fromRGB(100, 100, 100)));

		mass = 10;
		health = 50;
		entityMovementSpeed = 0.5;
		noAcceleration = true;

		weapon = new TankGun(this);

		path = new FlxPath();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (target != null && target.alive) {
			weapon.fireAtTarget(target);
		}
	}
}
