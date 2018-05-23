package entities;

import haxepunk.*;
import haxepunk.utils.*;
import haxepunk.graphics.*;

class Dust extends ActiveEntity
{
    public static inline var SPRITE_HEIGHT = 8;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        sprite = new Spritemap("graphics/grounddust.png", 16, 8);
        sprite.add("idle", [0, 1, 2, 3, 4], 16, false);
        sprite.play("idle");
        finishInitializing();
    }

    public override function update()
    {
        if(sprite.complete) {
            scene.remove(this);
        }
    }
}
