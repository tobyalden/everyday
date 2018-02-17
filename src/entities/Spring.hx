package entities;

import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.graphics.*;

class Spring extends Entity
{
    public function new(x:Float, y:Float)
    {
        super(x, y);
        var sprite:Image;
        sprite = new Image("graphics/spring.png");
        sprite.smooth = false;
        graphic = sprite;
    }

    public override function update()
    {
    }
}

