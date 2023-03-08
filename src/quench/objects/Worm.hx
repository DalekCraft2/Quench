package quench.objects;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

/**
 * Fracktail.
 * Ram has my favorite AI, but Worm has my favorite appearance.
 */
/*
	TODO To make a worm, I first need to figure out how to apply "pulling" forces with Flixel so I can connect the body segments.Pushing forces are built in by default.
	I need to make those pulling forces affect not just the children of the given WormSegment, but also the parents, too, so doing something like impacting the middle with enough force would cause the whole Worm to move.
	I also need to make the forces become stronger the further the segments are from their child and parent. This will keep the Worm from spreading apart too much, allowing me to set "noAcceleration" to "false" without the whole body being flung everywhere.
	I also need to make it so Worms can collide with other Worms and their segments without colliding with their own segments.
 */
class Worm extends WormSegment {
	private static final WORM_LENGTH:Int = 100;

	public var children:FlxTypedGroup<WormSegment>;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(40, 40, FlxColor.BLACK);

		solid = true;

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
			} else {
				child.parent = children.members[1];
				children.members[1].child = child;
			}
			child.target = child.parent;
		}
		midpoint.put();
		child = children.members[0];
	}

	override public function destroy():Void {
		super.destroy();

		children = FlxDestroyUtil.destroy(children);
	}
}

class WormSegment extends Enemy {
	public var parent:WormSegment;
	public var child:WormSegment;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(30, 30, FlxColor.WHITE);

		noAcceleration = true;
	}

	// override public function update(elapsed:Float):Void {
	// 	super.update(elapsed);
	// }

	override public function destroy():Void {
		super.destroy();

		parent = null; // I felt the need to set these to null instead of destroying them
		child = null;
	}
}
