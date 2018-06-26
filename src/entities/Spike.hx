package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;

class Spike extends Entity
{
    public static inline var SPIKE_FLOOR = 0;
    public static inline var SPIKE_CEILING = 1;
    public static inline var SPIKE_LEFT_WALL = 2;
    public static inline var SPIKE_RIGHT_WALL = 3;

    public function new(x:Float, y:Float, orientation:Int, length:Int)
    {
        super(x, y);
        type = "hazard";
        var sprite:Image;
        if(orientation == SPIKE_FLOOR) {
            sprite = new TiledImage("graphics/spikefloor.png", length, 16);
            setHitbox(length, 8, 0, -8);
        }
        else if(orientation == SPIKE_CEILING) {
            sprite = new TiledImage("graphics/spikeceiling.png", length, 16);
            setHitbox(length, 8);
        }
        else if(orientation == SPIKE_LEFT_WALL) {
            sprite = new TiledImage("graphics/spikeleftwall.png", 16, length);
            setHitbox(8, length);
        }
        else {
            sprite = new TiledImage("graphics/spikerightwall.png", 16, length);
            setHitbox(8, length, -8, 0);
        }
        sprite.smooth = false;
        graphic = sprite;
    }
}
