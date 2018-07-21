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
        type = "laserbeam";
        graphic = new ColoredRect(4, 4, 0xFF0000);
        setHitboxTo(graphic);
    }

    public override function update() {
        graphic = new ColoredRect(4, 4, 0xFF0000);
        setHitboxTo(graphic);
        moveTo(laser.centerX - 2, laser.centerY - 2);
        laser.type = "notwalls";
        if(laser.direction == "right") {
            moveTo(HXP.width, y, "walls", true);
            var blockerX = x + width;
            moveTo(laser.centerX - 2, laser.centerY - 2);
            graphic = new ColoredRect(blockerX - x, 4, 0xFF0000);
        }
        else if(laser.direction == "left") {
            moveTo(0, y, "walls", true);
            graphic = new ColoredRect(laser.centerX - x, 4, 0xFF0000);
        }
        else if(laser.direction == "down") {
            moveTo(x, HXP.height, "walls", true);
            var blockerY = y + height;
            moveTo(laser.centerX - 2, laser.centerY - 2);
            graphic = new ColoredRect(4, blockerY - y, 0xFF0000);
        }
        else if(laser.direction == "up") {
            moveTo(x, 0, "walls", true);
            graphic = new ColoredRect(4, laser.centerY - y, 0xFF0000);
        }
        setHitboxTo(graphic);
        laser.type = "walls";
        super.update();
    }
}
