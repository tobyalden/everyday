package entities;

import haxepunk.*;
import haxepunk.graphics.*;

class Spike extends Entity
{
    public static inline var SPIKE_FLOOR = 0;
    public static inline var SPIKE_CEILING = 1;
    public static inline var SPIKE_LEFT_WALL = 2;
    public static inline var SPIKE_RIGHT_WALL = 3;

    public function new(x:Float, y:Float, orientation:Int)
    {
        super(x, y);
        type = "hazard";
        var sprite:Image;
        if(orientation == SPIKE_FLOOR) {
            sprite = new Image("graphics/spikefloor.png");
            setHitbox(16, 8, 0, -8);
        }
        else if(orientation == SPIKE_CEILING) {
            sprite = new Image("graphics/spikeceiling.png");
            setHitbox(16, 8);
        }
        else if(orientation == SPIKE_LEFT_WALL) {
            sprite = new Image("graphics/spikeleftwall.png");
            setHitbox(8, 16);
        }
        else {
            sprite = new Image("graphics/spikerightwall.png");
            setHitbox(8, 16, -8, 0);
        }
        sprite.smooth = false;
        graphic = sprite;
    }
}
