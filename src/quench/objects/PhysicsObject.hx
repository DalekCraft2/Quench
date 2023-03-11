package quench.objects;

import flixel.util.FlxDestroyUtil;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxTween;

class PhysicsObject extends FlxSprite {
	public static final MOTION_FACTOR:Float = 100;

	private var deathTween:FlxTween;
	private var deathTween2:FlxTween;

	public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset) {
		super(x, y, simpleGraphic);

		// maxVelocity.set(MOTION_FACTOR, MOTION_FACTOR);
		drag.set(MOTION_FACTOR, MOTION_FACTOR);
		elasticity = 0.5; // This is a value for how much acceleration is preserved after a collision (specifically with an immovable object); 0.5 means that half is preserved
		collisionXDrag = NEVER;
		collisionYDrag = NEVER;
	}

	override public function destroy():Void {
		super.destroy();

		if (deathTween != null) {
			deathTween.cancel();
			deathTween = FlxDestroyUtil.destroy(deathTween);
		}

		if (deathTween2 != null) {
			deathTween2.cancel();
			deathTween2 = FlxDestroyUtil.destroy(deathTween2);
		}
	}

	// HoloCure-inspired death animation.
	override public function kill():Void {
		alive = false;
		solid = false;

		deathTween = FlxTween.tween(this, {alpha: 0, angle: angle + 45}, 0.25, {
			onComplete: (tween:FlxTween) -> {
				exists = false;
			}
		});

		// Tween the offset's x value instead of the object's x value so it does not interfere with the object's motion
		// It also needs to be -25 when messing with the offset to get the same appearance as adding 25 to the object's x value
		// deathTween2 = FlxTween.tween(offset, {x: x - 25}, deathTween.duration);
	}
}
