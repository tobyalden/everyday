package entities;

import haxepunk.*;
import haxepunk.graphics.*;

class ExtraFlip extends Entity
{
    private var used:Bool;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        type = "extraflip";
        graphic = new Image("graphics/extraflip.png");
        setHitbox(10, 16, -3, 0);
        used = false;
    }
    
    public function use() {
        used = true;
    }
    
    public function reset() {
        used = false;
    }

    public function canUse() {
        return !used;
    }

    public override function update() {
        collidable = !used;
        visible = !used;
    }
}
