package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.utils.*;

class Checkpoint extends ActiveEntity
{
    public var isFlipped(default, null):Bool;

    public function new(x:Float, y:Float, isFlipped:Bool) {
        super(x, y);
        this.isFlipped = isFlipped;
        type = "checkpoint";
        sprite = new Spritemap("graphics/checkpoint.png", 16, 16);
        sprite.add("idle", [0, 2, 4, 6, 4, 2], 12);
        sprite.add("flash", [1, 3, 5], 18, false);
        sprite.flipY = isFlipped;
        sprite.play("idle");
        setHitbox(16, 16);
        finishInitializing();
    }

    public override function update() {
        if(sprite.complete) {
            sprite.play("idle");
        }
        super.update();
    }

    public function flash() {
        sprite.play("flash", true);
    }
}
