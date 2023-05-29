package quench;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite {
	/**
	 * The width of the game, in pixels. 
	 */
	private var gameWidth:Int = 1280;

	/**
	 * The height of the game, in pixels.
	 */
	private var gameHeight:Int = 720;

	/**
	 * The `FlxState` the game starts with.
	 */
	private var initialState:Class<FlxState> = PlayState;

	/**
	 * How many frames per second the game should run at.
	 */
	private var frameRate:Int = 60;

	/**
	 * Whether to skip the Flixel splash screen that appears in release mode.
	 */
	private var skipSplash:Bool = false;

	/**
	 * Whether to start the game in fullscreen on desktop targets.
	 */
	private var startFullscreen:Bool = false;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void {
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		if (stage != null) {
			init();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?e:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE)) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void {
		// Run this before the game starts so logs show up in the VS Code debug console.
		FlxG.signals.preGameStart.add(Debug.onInitProgram);
		// Finish loading debug tools after the game starts.
		FlxG.signals.postGameStart.add(Debug.onGameStart);

		addChild(new FlxGame(gameWidth, gameHeight, initialState, frameRate, frameRate, skipSplash, startFullscreen));

		FlxG.addChildBelowMouse(new FPSMem(0, 0, FlxColor.WHITE));
		// FlxG.plugins.add(new FlxFPSMem());
	}
}
