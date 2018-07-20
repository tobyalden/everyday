package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.utils.*;

class LaserBeam extends Entity
{
    private var laser:Laser;

    public function new(x:Float, y:Float, laser:Laser) {
        super(x, y);
        this.laser = laser;
        graphic = new ColoredRect(4, 4, 0xFF0000);
        setHitboxTo(graphic);
    }

    public override function update() {
        if(laser.direction == "right") {
            graphic = new ColoredRect(4, 4, 0xFF0000);
            setHitboxTo(graphic);
            moveTo(laser.centerX - 2, laser.centerY - 2);
            laser.type = "notwalls";
            moveTo(HXP.width, y, "walls", true);
            laser.type = "walls";
            var blockerX = x + width;
            moveTo(laser.centerX - 2, laser.centerY - 2);
            graphic = new ColoredRect(blockerX - x, 4, 0xFF0000);
            setHitboxTo(graphic);
        }
        super.update();
    }
}
