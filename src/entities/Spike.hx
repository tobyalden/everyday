package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;

class Spike extends Entity
{
    public function new(x:Float, y:Float, type:Int)
    {
        super(x, y);
        var sprite:Image;
        if(type == Level.SPIKE_FLOOR) {
            sprite = new Image("graphics/spikefloor.png");
        }
        else if(type == Level.SPIKE_CEILING) {
            sprite = new Image("graphics/spikeceiling.png");
        }
        else if(type == Level.SPIKE_LEFT_WALL) {
            sprite = new Image("graphics/spikeleftwall.png");
        }
        else {
            sprite = new Image("graphics/spikerightwall.png");
        }
        sprite.smooth = false;
        graphic = sprite;
    }
}
