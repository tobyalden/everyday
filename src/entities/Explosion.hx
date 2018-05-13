package entities;

import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.graphics.*;
import flash.geom.Point;

class Explosion extends ActiveEntity
{
    public function new(x:Float, y:Float, velocity:Point)
    {
	    super(x, y);
        this.velocity = velocity;
        sprite = new Spritemap("graphics/explosion.png", 24, 24);
        sprite.add("idle", [0, 1, 2, 3], 4, false);
        sprite.play("idle");
        sprite.originX = 12;
        sprite.originY = 12;
        finishInitializing();
    }

    public override function update()
    {
        moveBy(velocity.x, velocity.y);
        if(sprite.complete) {
            scene.remove(this);
        }
    }
}
