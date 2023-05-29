package quench.objects;

import flixel.FlxG;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import quench.weapons.*;

// TODO Add a way to heal with items
class Player extends Entity {
	private var actionManager:FlxActionManager;
	private var moveLeft:FlxActionDigital = new FlxActionDigital("move_left");
	private var moveRight:FlxActionDigital = new FlxActionDigital("move_right");
	private var moveUp:FlxActionDigital = new FlxActionDigital("move_up");
	private var moveDown:FlxActionDigital = new FlxActionDigital("move_down");
	private var fire:FlxActionDigital = new FlxActionDigital("fire");
	private var changeWeapon:FlxActionDigital = new FlxActionDigital("change_weapon");
	private var changeSize:FlxActionDigital = new FlxActionDigital("change_size");
	private var noclip:FlxActionDigital = new FlxActionDigital("noclip");

	public var weapons:Array<QuenchWeapon> = [];
	public var weaponIndex:Int = 0;

	private var big(default, set):Bool = false;
	private var bigFactor:Float = 1;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		loadEntityFrames(FlxColor.YELLOW);

		initializeHealth(10);

		// useAcceleration = false;

		entityMovementSpeed = 2 * bigFactor;

		moveLeft.addKey(LEFT, PRESSED);
		moveLeft.addKey(A, PRESSED);
		moveRight.addKey(RIGHT, PRESSED);
		moveRight.addKey(D, PRESSED);
		moveUp.addKey(UP, PRESSED);
		moveUp.addKey(W, PRESSED);
		moveDown.addKey(DOWN, PRESSED);
		moveDown.addKey(S, PRESSED);
		fire.addMouse(LEFT, PRESSED);
		changeWeapon.addMouseWheel(true, JUST_PRESSED);
		changeWeapon.addMouseWheel(false, JUST_PRESSED);
		changeSize.addKey(ENTER, JUST_PRESSED);
		noclip.addKey(V, JUST_PRESSED); // Garry's Mod.

		actionManager = new FlxActionManager();
		FlxG.inputs.add(actionManager);
		actionManager.addActions([moveLeft, moveRight, moveUp, moveDown, fire, changeWeapon, changeSize, noclip]);

		weapons.push(new Fists(this));
		weapons.push(new Revolver(this));
		weapons.push(new MachineGun(this));
		weapons.push(new RocketPropelledGrenade(this));
		weapons.push(new TankGun(this));
		weapons.push(new MedKit(this));
		#if debug
		weapons.push(new DebugGun(this));
		#end
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (alive) {
			if (changeSize.triggered) {
				big = !big;
			}
			if (noclip.triggered) {
				solid = !solid;
				if (solid) {
					alpha = 1;
				} else {
					alpha = 0.5;
				}
			}

			var mousePoint:FlxPoint = FlxG.mouse.getPosition();
			lookAtPoint(mousePoint);
			mousePoint.put();

			if (changeWeapon.triggered) {
				weaponIndex = FlxMath.wrap(weaponIndex - FlxG.mouse.wheel, 0, weapons.length - 1);
			}

			if (fire.triggered) {
				weapons[weaponIndex].fireAtMouse();
			}
		}
	}

	override public function destroy():Void {
		super.destroy();

		actionManager = FlxDestroyUtil.destroy(actionManager);
		moveLeft = FlxDestroyUtil.destroy(moveLeft);
		moveRight = FlxDestroyUtil.destroy(moveRight);
		moveUp = FlxDestroyUtil.destroy(moveUp);
		moveDown = FlxDestroyUtil.destroy(moveDown);
		fire = FlxDestroyUtil.destroy(fire);
		changeWeapon = FlxDestroyUtil.destroy(changeWeapon);
		changeSize = FlxDestroyUtil.destroy(changeSize);
		noclip = FlxDestroyUtil.destroy(noclip);

		weapons = FlxDestroyUtil.destroyArray(weapons);
	}

	override private function updateDestinationPoint():Void {
		super.updateDestinationPoint();

		var left:Bool = moveLeft.triggered;
		var right:Bool = moveRight.triggered;
		var up:Bool = moveUp.triggered;
		var down:Bool = moveDown.triggered;
		var movementDirection:FlxDirectionFlags = FlxDirectionFlags.fromBools(left, right, up, down);
		destinationPoint.zero();
		if (movementDirection != NONE) {
			destinationPoint.set(0, 1);
			destinationPoint.degrees = movementDirection.degrees;
		}
		destinationPoint.addPoint(getMidpoint(FlxPoint.weak()));
	}

	private function set_big(value:Bool):Bool {
		big = value;
		if (big) {
			bigFactor = 2;
		} else {
			bigFactor = 1;
		}
		if (useMaxVelocity) {
			maxVelocity.set(bigFactor * PhysicsObject.MOTION_FACTOR, bigFactor * PhysicsObject.MOTION_FACTOR);
		}
		scale.set(bigFactor, bigFactor);
		updateHitbox();
		mass = scale.x * scale.y;
		entityMovementSpeed = 2 * bigFactor;
		// FIXME Weapon bullet offset does not update when making the Player bigger, because the player's width and height are only retrieved in the weapon's constructor
		// for (weapon in weapons) {
		// 	switch (weapon.fireFrom) {
		// 		case PARENT(parent, offset, useParentAngle, angleOffset):
		// 			getMidpoint(offset.min);
		// 		// getMidpoint(offset.max);
		// 		case POSITION(position):
		// 	}
		// }
		return value;
	}
}
