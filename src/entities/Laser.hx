package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.utils.*;

class Laser extends ActiveEntity
{
    public var leverNumber(default, null):Int;
    public var beam(default, null):LaserBeam;
    public var direction(default, null):String;

    public function new(
        x:Float, y:Float, direction:String, isOn:Bool, leverNumber:Int
    ) {
        super(x, y);
        this.direction = direction;
        this.leverNumber = leverNumber;
        type = "walls";
        sprite = new Spritemap("graphics/laser.png", 16, 16);
        sprite.add("right", [0]);
        sprite.add("left", [1]);
        sprite.add("down", [2]);
        sprite.add("up", [3]);
        sprite.play(direction);
        setHitbox(16, 16);
        layer = -2;

        beam = new LaserBeam(centerX - 2, centerY - 2, this, isOn);

        finishInitializing();
    }

    public function toggle() {
        beam.setIsOn(!beam.isOn);
    }

}
