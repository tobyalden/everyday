package entities;

import flash.system.System;
import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.graphics.*;

class Player extends ActiveEntity
{
    public static inline var SPEED = 2;
    public static inline var JUMP_POWER = 5;
    public static inline var GRAVITY = 0.16;
    public static inline var MAX_FALL_SPEED = 3;

    public function new(x:Int, y:Int)
    {
	    super(x, y);
        sprite = new Spritemap("graphics/player.png", 16, 24);
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 10);
        sprite.add("jump", [4]);
        sprite.play("idle");
        setHitbox(12, 24, -2, 0);
	    finishInitializing();
    }

    public override function update()
    {
        if(Input.check(Key.LEFT)) {
            velocity.x = -SPEED;
        }
        else if(Input.check(Key.RIGHT)) {
            velocity.x = SPEED;
        }
        else {
            velocity.x = 0;
        }

        if(isOnGround()) {
            velocity.y = 0;
            if(Input.pressed(Key.Z)) {
                velocity.y = -JUMP_POWER;
            }
        }
        else {
            velocity.y += GRAVITY;
        }

        moveBy(velocity.x, velocity.y, "walls");
        animate();

        super.update();
    }

    private function animate()
    {
        if(!isOnGround()) {
            sprite.play("jump");
        }
        else if(velocity.x != 0) {
            sprite.play("run");
        }
        else {
            sprite.play("idle");
        }

        if(velocity.x < 0) {
            sprite.flipped = true;
        }
        else if(velocity.x > 0) {
            sprite.flipped = false;
        }
    }
}
