package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;

class MovingPlatform extends Entity
{
    public function new(x:Float, y:Float, width:Int, height:Int)
    {
        super(x, y);
        var sprite = new TiledImage(
            "graphics/movingplatform.png", width, height
        );
        sprite.smooth = false;
        graphic = sprite;
    }
}
