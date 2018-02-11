package entities;

import flash.system.System;
import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.graphics.*;

class Player extends ActiveEntity
{
    // Movement constants
    public static inline var RUN_ACCEL = 0.15;
    public static inline var RUN_DECCEL = 0.3;
    public static inline var AIR_ACCEL = 0.15;
    public static inline var AIR_DECCEL = 0.1;
    public static inline var MAX_RUN_VELOCITY = 1.6;
    public static inline var JUMP_POWER = 2.4;
    public static inline var DOUBLE_JUMP_POWER = 2;
    public static inline var WALL_JUMP_POWER_X = 2;
    public static inline var WALL_JUMP_POWER_Y = 2;
    public static inline var JUMP_CANCEL_POWER = 0.5;
    public static inline var GRAVITY = 0.13;
    public static inline var WALL_GRAVITY = 0.1;
    public static inline var MAX_FALL_VELOCITY = 3;

    // Animation constants
    public static inline var LAND_SQUASH = 0.5;
    public static inline var SQUASH_RECOVERY = 0.05;
    public static inline var AIR_SQUASH_RECOVERY = 0.03;
    public static inline var JUMP_STRETCH = 1.5;
    public static inline var DOUBLE_JUMP_STRETCH = 1.4;

    private var isTurning:Bool;
    private var canDoubleJump:Bool;
    private var wasOnGround:Bool;

    public function new(x:Int, y:Int)
    {
	    super(x, y);
        sprite = new Spritemap("graphics/player.png", 8, 12);
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 10);
        sprite.add("jump", [4]);
        sprite.add("wall", [5]);
        sprite.add("skid", [6]);
        sprite.play("idle");
        setHitbox(6, 12, -1, 0);

        isTurning = false;
        canDoubleJump = false;
        wasOnGround = false;

	    finishInitializing();
    }

    private function scaleY(newScaleY:Float) {
        // Scales sprite vertically "upward", keeping its feet on the ground
        sprite.scaleY = newScaleY;
        sprite.originY = height - (height / sprite.scaleY);
    }

    public override function update()
    {
        isTurning = (
            Input.check(Key.LEFT) && velocity.x >= 0 ||
            Input.check(Key.RIGHT) && velocity.x <= 0
        );

        if(Input.pressed(Key.Y)) {
            scaleY(HXP.choose(1, 2, 3, 4.5, 2.3, 0.3, 0.1, 0.54, 0.88));
        }

        // If the player is changing directions or just starting to move,
        // multiply their acceleration
        var accelMultiplier = 1.0;
        if(velocity.x == 0 && isOnGround()) {
            accelMultiplier = 3;
        }
        else if(Input.pressed(Key.Z) && canDoubleJump) {
            accelMultiplier = 2;
        }

        var accel = AIR_ACCEL;
        var deccel = AIR_DECCEL;
        if(isOnGround()) {
            accel = RUN_ACCEL;
            deccel = RUN_DECCEL;
        }

        // Check if the player is moving left or right
        if(Input.check(Key.LEFT)) {
            velocity.x -= accel * accelMultiplier;
        }
        else if(Input.check(Key.RIGHT)) {
            velocity.x += accel * accelMultiplier;
        }
        else {
            if(velocity.x > 0) {
                velocity.x = Math.max(0, velocity.x - deccel);
            }
            else {
                velocity.x = Math.min(0, velocity.x + deccel);
            }
        }

        // Check if the player is jumping or falling
        if(isOnGround()) {
            velocity.y = 0;
            canDoubleJump = true;
            if(Input.pressed(Key.Z)) {
                velocity.y = -JUMP_POWER;
                scaleY(JUMP_STRETCH);
            }
        }
        else if(isOnWall()) {
            velocity.y += WALL_GRAVITY;
            if(Input.pressed(Key.Z)) {
                velocity.y = -WALL_JUMP_POWER_Y;
                if(isOnLeftWall()) {
                    velocity.x = WALL_JUMP_POWER_X;
                }
                else {
                    velocity.x = -WALL_JUMP_POWER_X;
                }
            }
        }
        else {
            velocity.y += GRAVITY;
            if(Input.pressed(Key.Z) && canDoubleJump) {
                velocity.y = -DOUBLE_JUMP_POWER;
                scaleY(DOUBLE_JUMP_STRETCH);
                canDoubleJump = false;
            }
            if(Input.released(Key.Z)) {
                velocity.y = Math.max(-JUMP_CANCEL_POWER, velocity.y);
            }
        }

        // Cap the player's velocity
        velocity.x = Math.min(velocity.x, MAX_RUN_VELOCITY);
        velocity.x = Math.max(velocity.x, -MAX_RUN_VELOCITY);
        velocity.y = Math.min(velocity.y, MAX_FALL_VELOCITY);

        wasOnGround = isOnGround();

        moveBy(velocity.x, velocity.y, "walls");
        animate();

        super.update();
    }

    private function animate()
    {
        var squashRecovery = AIR_SQUASH_RECOVERY;
        if(isOnGround()) {
            squashRecovery = SQUASH_RECOVERY;
        }

        if(sprite.scaleY > 1) {
            scaleY(Math.max(sprite.scaleY - squashRecovery, 1));
        }
        else if(sprite.scaleY < 1) {
            scaleY(Math.min(sprite.scaleY + squashRecovery, 1));
        }

        if(!wasOnGround && isOnGround()) {
            scaleY(LAND_SQUASH);
        }

        if(!isOnGround()) {
            if(isOnWall()) {
                sprite.play("wall");
            }
            else {
                sprite.play("jump");
            }
        }
        else if(velocity.x != 0) {
            if(isTurning) {
                sprite.play("skid");
            }
            else {
                sprite.play("run");
            }
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
