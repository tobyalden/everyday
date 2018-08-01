package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.utils.*;

class Lever extends ActiveEntity
{
    public var leverNumber(default, null):Int;
    public var isPulled(default, null):Bool;
    public var isFlipped(default, null):Bool;

    public function new(x:Float, y:Float, leverNumber:Int, isFlipped:Bool) {
        super(x, y);
        this.leverNumber = leverNumber;
        this.isFlipped = isFlipped;
        type = "lever";
        sprite = new Spritemap("graphics/lever.png", 16, 16);
        sprite.add("unpulled", [0]);
        sprite.add("pulled", [1]);
        sprite.flipY = isFlipped;
        sprite.play("unpulled");
        setHitbox(16, 16);
        finishInitializing();
    }

    public function pull() {
        isPulled = !isPulled;
        sprite.play(isPulled ? "pulled" : "unpulled");
    }
}
