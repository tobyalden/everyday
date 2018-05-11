package entities;

import com.haxepunk.graphics.*;
import com.haxepunk.utils.*;
import com.haxepunk.*;

class Cannon extends ActiveEntity
{

    public static inline var SHOOT_INTERVAL = 70;

    private var orientation:Int;
    private var shootTimer:Float;

    public function new(x:Float, y:Float, orientation:Int)
    {
        super(x, y);
        this.orientation = orientation;
        type = "cannon";
        shootTimer = SHOOT_INTERVAL;
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
            shootTimer -= SHOOT_INTERVAL;
            shoot();
        }
        super.update();
    }

    private function shoot()
    {
        if(orientation == Level.CANNON_HORIZONTAL) {
            scene.add(new Bullet(x, y, "left"));
            scene.add(new Bullet(x, y, "right"));
        }
        else {
            scene.add(new Bullet(x, y, "up"));
            scene.add(new Bullet(x, y, "down"));
        }
    }
}

