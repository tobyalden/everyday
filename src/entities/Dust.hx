package entities;

import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.graphics.*;

class Dust extends ActiveEntity
{
    public function new(x:Float, y:Float)
    {
	    super(x, y);
        type = "dust";
        sprite = new Spritemap("graphics/grounddust.png", 8, 4);
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