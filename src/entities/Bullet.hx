package entities;

import com.haxepunk.graphics.*;
import com.haxepunk.utils.*;
import com.haxepunk.*;

class Bullet extends ActiveEntity
{
    public static inline var SPEED = 2;

    private var direction:String;

    public function new(x:Float, y:Float, direction:String)
    {
        super(x, y);
        this.direction = direction;
        sprite = new Spritemap("graphics/bullet.png", 8, 8);
        sprite.add("up", [0]);
        sprite.add("down", [1]);
        sprite.add("left", [2]);
        sprite.add("right", [3]);
        sprite.add("explode", [4, 5, 6, 7, 8], 21, false);
        sprite.play(direction);
        setHitbox(8, 8);
        type = "bullet";
        layer = 1;

        if(direction == "up") {
            velocity.y = -SPEED;
        }
        else if(direction == "down") {
            velocity.y = SPEED;
        }
        else if(direction == "left") {
            velocity.x = -SPEED;
        }
        else if(direction == "right") {
            velocity.x = SPEED;
        }

        finishInitializing();
    }

    public override function update()
    {
        var delta = HXP.elapsed * 60;
        if(sprite.currentAnim == "explode") {
            if(sprite.complete) {
                scene.remove(this);
            }
            return;
        }

        moveBy(velocity.x * delta, velocity.y * delta);

        if(
            collide("walls", x, y) != null &&
            collide("cannon", x, y) == null
        )
        {
            explode();
        }
        else {
            var bullet = collide("bullet", x, y);
            if(bullet != null && collide("cannon", x, y) == null) {
                cast(bullet, Bullet).explode();
                explode();
            }
        }
        super.update();
    }

    public function explode() {
        velocity.x = 0;
        velocity.y = 0;
        sprite.play("explode");
        collidable = false;
    }
}

