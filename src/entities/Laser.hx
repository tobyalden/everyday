package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.utils.*;

class Laser extends ActiveEntity
{
    public function new(x:Float, y:Float, direction:String) {
        super(x, y);
        type = "walls";
        sprite = new Spritemap("graphics/laser.png", 16, 16);
        sprite.add("right", [0]);
        sprite.add("left", [1]);
        sprite.add("down", [2]);
        sprite.add("up", [3]);
        sprite.play(direction);
        setHitbox(16, 16);
        finishInitializing();
    }
}
