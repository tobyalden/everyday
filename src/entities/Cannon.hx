package entities;

import com.haxepunk.graphics.*;
import com.haxepunk.utils.*;
import com.haxepunk.*;

class Cannon extends ActiveEntity
{

    public static inline var SHOOT_INTERVAL = 60;

    private var orientation:Int;
    private var shootTimer:Float;

    public function new(x:Float, y:Float, orientation:Int)
    {
        super(x, y);
        type = "walls";
        this.orientation = orientation;
        shootTimer = 0;
        sprite = new Spritemap("graphics/cannon.png", 8, 8);
        sprite.add("horizontal", [0]);
        sprite.add("vertical", [1]);
        if(orientation == Level.CANNON_HORIZONTAL) {
            sprite.play("horizontal");
        }
        else {
            sprite.play("vertical");
        }
        setHitbox(8, 8);
        finishInitializing();
    }

    public override function update()
    {
        var delta = HXP.elapsed * 60;
        shootTimer += delta;
        if(shootTimer >= SHOOT_INTERVAL)
        {
            shoot();
            shootTimer -= SHOOT_INTERVAL;
        }
        super.update();
    }

    private function shoot()
    {
        if(orientation == Level.CANNON_HORIZONTAL) {
            if(!isOnLeftWall()) {
                scene.add(new Bullet(x - width, y, "left"));
            }
            if(!isOnRightWall()) {
                scene.add(new Bullet(x + width, y, "right"));
            }
        }
        else {
            if(!isOnCeiling()) {
                scene.add(new Bullet(x, y - width, "up"));
            }
            if(!isOnGround()) {
                scene.add(new Bullet(x, y + width, "down"));
            }
        }
    }
}

