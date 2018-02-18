
package entities;

import flash.geom.Point;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Spritemap;

class ActiveEntity extends Entity
{
    private var sprite:Spritemap;
    private var velocity:Point;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        velocity = new Point(0, 0);
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
        return collideTypes(["walls", "cannon"], x, y + 1) != null;
    }

    private function isOnCeiling()
    {
        return collideTypes(["walls", "cannon"], x, y - 1) != null;
    }

    private function isOnWall()
    {
        return isOnRightWall() || isOnLeftWall();
    }

    private function isOnRightWall()
    {
        return collideTypes(["walls", "cannon"], x + 1, y) != null;
    }

    private function isOnLeftWall()
    {
        return collideTypes(["walls", "cannon"], x - 1, y) != null;
    }
}
