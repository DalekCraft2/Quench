package quench.objects;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxTween;
import flixel.util.FlxDestroyUtil;

class PhysicsObject extends FlxSprite {
	public static final MOTION_FACTOR:Float = 100;

	public var maxHealth:Float = 1;

	public var deathTween:FlxTween;

	private var useMaxVelocity:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset) {
		super(x, y, simpleGraphic);

		if (useMaxVelocity) {
			maxVelocity.set(MOTION_FACTOR, MOTION_FACTOR);
		}
		drag.set(MOTION_FACTOR, MOTION_FACTOR);
		elasticity = 0.5;
		collisionXDrag = NEVER;
		collisionYDrag = NEVER;
	}

	override public function destroy():Void {
		super.destroy();

		if (deathTween != null) {
			deathTween.cancel();
			deathTween = FlxDestroyUtil.destroy(deathTween);
		}
	}

	// HoloCure-inspired death animation.
	override public function kill():Void {
		alive = false;

		deathTween = FlxTween.tween(this, {alpha: 0, angle: angle + 45}, 0.25, {
			onComplete: (tween:FlxTween) -> {
				alpha = 1;
				angle = 0;
				exists = false;
			}
		});
	}

	override public function revive():Void {
		super.revive();

		health = maxHealth;
	}

	override public function hurt(damage:Float):Void {
		super.hurt(damage);

		if (health > maxHealth) {
			health = maxHealth;
		}
	}

	private function initializeHealth(maxHealth:Float):Void {
		this.maxHealth = maxHealth;
		health = maxHealth;
	}
}
