package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;

class Spike extends Entity
{
    public function new(x:Float, y:Float, orientation:Int)
    {
        super(x, y);
        type = "hazard";
        var sprite:Image;
        if(orientation == Level.SPIKE_FLOOR) {
            sprite = new Image("graphics/spikefloor.png");
            setHitbox(8, 4, 0, -4);
        }
        else if(orientation == Level.SPIKE_CEILING) {
            sprite = new Image("graphics/spikeceiling.png");
            setHitbox(8, 4);
        }
        else if(orientation == Level.SPIKE_LEFT_WALL) {
            sprite = new Image("graphics/spikeleftwall.png");
            setHitbox(4, 8);
        }
        else {
            sprite = new Image("graphics/spikerightwall.png");
            setHitbox(4, 8, -4, 0);
        }
        sprite.smooth = false;
        graphic = sprite;
    }
}
