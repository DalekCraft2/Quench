package quench.objects;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.path.FlxPath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

/**
 * Fracktail.
 * Ram has my favorite AI, but Worm has my favorite appearance.
 * However, Worm also has better pathfinding. In fact, Worm has pathfinding at all.
 */
/*
	TODO To make a worm, I first need to figure out how to apply "pulling" forces with Flixel so I can connect the body segments. Pushing forces are built in by default.
	I need to make those pulling forces affect not just the children of the given WormSegment, but also the parents, too, so doing something like impacting the middle with enough force would cause the whole Worm to move.
	I also need to make the forces become stronger the further the segments are from their child and parent. This will keep the Worm from spreading apart too much, allowing me to set "noAcceleration" to "false" without the whole body being flung everywhere.
	I also need to make it so Worms can collide with other Worms and their segments without colliding with their own segments.

	Note: I might be able to use Nape to create the "pulling" forces what I mentioned. I need to learn how it works first, though.
 */
class Worm extends WormSegment {
	private static final WORM_LENGTH:Int = 100;

	public var children:FlxTypedGroup<WormSegment>;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y, FlxG.bitmap.create(40, 40, FlxColor.BLACK));

		health = 10;
		mass = 1;

		// Use the pathfinding system to move
		path = new FlxPath();

		children = new FlxTypedGroup();

		var midpoint:FlxPoint = getMidpoint();
		for (i in 0...WORM_LENGTH) {
			var child:WormSegment = new WormSegment(x, y);
			var childMidpoint:FlxPoint = child.getMidpoint();
			child.setPosition(child.x + midpoint.x - childMidpoint.x, child.y + midpoint.y - childMidpoint.y);
			childMidpoint.put();
			child.color = i % 2 == 0 ? FlxColor.GRAY : FlxColor.BLACK;
			// The most recent is closest to the start so it is layered correctly in-game
			children.insert(0, child);
			if (i == 0) {
				child.parent = this;
				this.child = child;
			} else {
				child.parent = children.members[1];
				children.members[1].child = child;
			}
			child.target = child.parent;
		}
		midpoint.put();
	}

	override public function destroy():Void {
		super.destroy();

		children = FlxDestroyUtil.destroy(children);
	}
}

class WormSegment extends Enemy {
	public var parent(default, set):WormSegment;
	public var child:WormSegment;

	public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset) {
		super(x, y, simpleGraphic == null ? FlxG.bitmap.create(30, 30, FlxColor.WHITE) : simpleGraphic);

		health = 1;
		mass = 0.5;
		noAcceleration = true;
	}

	override public function destroy():Void {
		super.destroy();

		parent = null; // I felt the need to set these to null instead of destroying them
		child = null;
	}

	override public function kill():Void {
		super.kill();
		if (child != null) {
			child.parent = parent;
		}
		if (parent != null) {
			parent.child = child;
		}
	}

	override public function hurt(damage:Float):Void {
		if (child != null && child.alive) {
			child.hurt(damage);
		} else {
			var remainingDamage:Float = damage - health;
			super.hurt(damage);
			if (!alive && parent != null && parent.alive && remainingDamage > 0) {
				parent.hurt(remainingDamage);
			}
		}
	}

	private function set_parent(value:WormSegment):WormSegment {
		parent = value;
		target = value;
		return value;
	}
}
