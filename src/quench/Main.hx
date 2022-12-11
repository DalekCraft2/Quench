package quench;

import flixel.FlxGame;
import flixel.FlxState;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite {
	private var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	private var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	private var initialState:Class<FlxState> = PlayState; // The FlxState the game starts with.
	private var frameRate:Int = 60; // How many frames per second the game should run at.
	private var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	private var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

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
		// Run this first so we can see logs.
		Debug.onInitProgram();

		addChild(new FlxGame(gameWidth, gameHeight, initialState, frameRate, frameRate, skipSplash, startFullscreen));

		#if !mobile
		addChild(new FPSMem(0, 0, FlxColor.WHITE));
		#end

		// Finish up loading debug tools.
		Debug.onGameStart();
	}
}
