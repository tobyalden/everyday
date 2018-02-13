package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;

class Spike extends Entity
{
    public function new(x:Float, y:Float)
    {
        super(x, y);
        var sprite = new Image("graphics/spikefloor.png");
        sprite.smooth = false;
        graphic = sprite;
    }
}
