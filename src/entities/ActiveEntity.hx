
package entities;

import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.graphics.Spritemap;
import haxepunk.math.*;

class ActiveEntity extends Entity
{
    private var sprite:Spritemap;
    private var velocity:Vector2;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        velocity = new Vector2(0, 0);
    }

    public function finishInitializing()
    {
        sprite.smooth = false;
        graphic = sprite;
    }

    public override function update()
    {
        super.update();
    }

    private function isOnGround()
    {
        return collide("walls", x, y + 1) != null;
    }

    private function isOnCeiling()
    {
        return collide("walls", x, y - 1) != null;
    }

    private function isOnWall()
    {
        return isOnRightWall() || isOnLeftWall();
    }

    private function isOnRightWall()
    {
        return collide("walls", x + 1, y) != null;
    }

    private function isOnLeftWall()
    {
        return collide("walls", x - 1, y) != null;
    }
}
