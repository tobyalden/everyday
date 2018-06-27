package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;

class Platform extends Entity
{
    public function new(x:Float, y:Float, width:Int, height:Int)
    {
        super(x, y);
        type = "platform";
        graphic = new TiledImage("graphics/platform.png", width, height);
        graphic.smooth = false;
        setHitbox(width, height);
    }
}
