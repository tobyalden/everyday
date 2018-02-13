package entities;

import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.graphics.*;
import com.haxepunk.Tween;
import com.haxepunk.tweens.misc.*;
import flash.geom.Point;
import flash.system.System;

class Player extends ActiveEntity
{
    // Movement constants
    public static inline var RUN_ACCEL = 0.15;
    public static inline var RUN_DECCEL = 0.3;
    public static inline var AIR_ACCEL = 0.13;
    public static inline var AIR_DECCEL = 0.1;
    public static inline var MAX_RUN_VELOCITY = 1.6;
    public static inline var MAX_AIR_VELOCITY = 2;
    public static inline var JUMP_POWER = 2.4;
    public static inline var DOUBLE_JUMP_POWER = 2;
    public static inline var WALL_JUMP_POWER_X = 3;
    public static inline var WALL_JUMP_POWER_Y = 1.975;
    public static inline var JUMP_CANCEL_POWER = 0.5;
    public static inline var GRAVITY = 0.13;
    public static inline var WALL_GRAVITY = 0.1;
    public static inline var MAX_FALL_VELOCITY = 3;
    public static inline var WALL_STICK_VELOCITY = 1;

    // Animation constants
    public static inline var LAND_SQUASH = 0.5;
    public static inline var SQUASH_RECOVERY = 0.05;
    public static inline var HORIZONTAL_SQUASH_RECOVERY = 0.08;
    public static inline var AIR_SQUASH_RECOVERY = 0.03;
    public static inline var JUMP_STRETCH = 1.5;
    public static inline var DOUBLE_JUMP_STRETCH = 1.4;
    public static inline var WALL_SQUASH = 0.5;
    public static inline var WALL_JUMP_STRETCH_X = 1.4;
    public static inline var WALL_JUMP_STRETCH_Y = 1.4;

    public static inline var WIPE_DELAY = 0.5;
    public static inline var RESTART_DELAY = 0.25;

    private var isTurning:Bool;
    private var canDoubleJump:Bool;
    private var wasOnGround:Bool;
    private var wasOnWall:Bool;
    private var lastWallWasRight:Bool;

    private var isDying:Bool;
    private var canMove:Bool;

    public function new(x:Float, y:Float)
    {
	    super(x, y);
        sprite = new Spritemap("graphics/player.png", 8, 12);
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 10);
        sprite.add("jump", [4]);
        sprite.add("wall", [5]);
        sprite.add("skid", [6]);
        sprite.add("die", [7, 8, 9, 10, 11, 12, 13, 14, 15, 16], 60, false);
        sprite.play("idle");
        setHitbox(6, 12, -1, 0);

        isTurning = false;
        canDoubleJump = false;
        wasOnGround = false;
        wasOnWall = false;
        lastWallWasRight = false;

        canMove = false;
        var restartDelay = new Alarm(
            RESTART_DELAY, function(_) { canMove = true; }, TweenType.OneShot
        );
        addTween(restartDelay, true);

	    finishInitializing();
    }

    private function scaleX(newScaleX:Float, toLeft:Bool) {
        // Scales sprite horizontally in the specified direction
        sprite.scaleX = newScaleX;
        if(toLeft) {
            sprite.originX = width - (width / sprite.scaleX);
        }
    }

    private function scaleY(newScaleY:Float) {
        // Scales sprite vertically upwards
        sprite.scaleY = newScaleY;
        sprite.originY = height - (height / sprite.scaleY);
    }

    private function makeDustOnWall(isLeftWall:Bool) {
        var dust:Dust;
        if(isLeftWall) {
            dust = new Dust(x + 1, centerY - 2, false);
        }
        else {
            dust = new Dust(x + width - 3, centerY - 2, false);
            dust.sprite.flipped = true;
        }
        scene.add(dust);
    }

    private function makeDustAtFeet() {
        var dust = new Dust(x, bottom - 4, true);
        if(sprite.flipped) {
            dust.x += 0.5;
        }
        scene.add(dust);
    }

    public override function update()
    {
        collisions();
        if(!isDying) {
            if(canMove) {
                movement();
            }
            animation();
        }
        else {
            if(sprite.complete && visible) {
                visible = false;
                explode();
                var wipeDelay = new Alarm(
                    WIPE_DELAY, screenWipe, TweenType.OneShot
                );
                addTween(wipeDelay, true);
            }
        }
        super.update();
    }

    private function screenWipe(_):Void {
        var wipe = new Wipe(false);
        scene.add(wipe);
    }

    private function explode() {
        var directions = [
            new Point(1, 1),
            new Point(1, 0),
            new Point(1, -1),
            new Point(0, 1),
            new Point(0, -1),
            new Point(-1, 1),
            new Point(-1, 0),
            new Point(-1, -1)
        ];
        var count = 0;
        for(direction in directions) {
            var explosion = new Explosion(
                centerX,
                centerY,
                directions[count]
            );
            scene.add(explosion);
            count++;
        }
    }

    private function collisions() {
        if(collide("hazard", x, y) != null) {
            die();
        }
    }

    private function die() {
        isDying = true;
        sprite.play("die");
    }

    private function movement() {
        isTurning = (
            Input.check(Key.LEFT) && velocity.x >= 0 ||
            Input.check(Key.RIGHT) && velocity.x <= 0
        );

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
            if(isOnWall()) {
                velocity.x = 0;
            }
        }

        if(isOnCeiling()) {
            velocity.y = 0;
            scaleY(1);
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
                makeDustAtFeet();
            }
        }
        else if(isOnWall()) {
            if(velocity.y < 0) {
                velocity.y += GRAVITY;
            }
            else {
                velocity.y += WALL_GRAVITY;
            }
            if(Input.pressed(Key.Z)) {
                velocity.y = -WALL_JUMP_POWER_Y;
                scaleY(WALL_JUMP_STRETCH_Y);
                if(isOnLeftWall()) {
                    velocity.x = WALL_JUMP_POWER_X;
                    scaleX(WALL_JUMP_STRETCH_X, false);
                    makeDustOnWall(true);
                }
                else {
                    velocity.x = -WALL_JUMP_POWER_X;
                    scaleX(WALL_JUMP_STRETCH_X, true);
                    makeDustOnWall(false);
                }
            }
        }
        else {
            velocity.y += GRAVITY;
            if(Input.pressed(Key.Z) && canDoubleJump) {
                velocity.y = -DOUBLE_JUMP_POWER;
                scaleY(DOUBLE_JUMP_STRETCH);
                makeDustAtFeet();
                canDoubleJump = false;
            }
            if(Input.released(Key.Z)) {
                velocity.y = Math.max(-JUMP_CANCEL_POWER, velocity.y);
            }
        }

        // Cap the player's velocity
        var maxVelocity:Float = MAX_AIR_VELOCITY;
        if(isOnGround()) {
            maxVelocity = MAX_RUN_VELOCITY;
        }
        velocity.x = Math.min(velocity.x, maxVelocity);
        velocity.x = Math.max(velocity.x, -maxVelocity);
        velocity.y = Math.min(velocity.y, MAX_FALL_VELOCITY);

        wasOnGround = isOnGround();
        wasOnWall = isOnWall();

        moveBy(velocity.x, velocity.y, "walls");
    }

    private function animation()
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

        squashRecovery = HORIZONTAL_SQUASH_RECOVERY;

        if(sprite.scaleX > 1) {
            scaleX(
                Math.max(sprite.scaleX - squashRecovery, 1), lastWallWasRight
            );
        }
        else if(sprite.scaleX < 1) {
            scaleX(
                Math.min(sprite.scaleX + squashRecovery, 1), lastWallWasRight
            );
        }

        if(!wasOnGround && isOnGround()) {
            scaleY(LAND_SQUASH);
            makeDustAtFeet();
        }
        if(!wasOnWall && isOnWall()) {
            if(isOnRightWall()) {
                lastWallWasRight = true;
                velocity.x = Math.min(velocity.x, WALL_STICK_VELOCITY);
            }
            else {
                lastWallWasRight = false;
                velocity.x = Math.max(velocity.x, -WALL_STICK_VELOCITY);
            }
            scaleX(WALL_SQUASH, lastWallWasRight);
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
