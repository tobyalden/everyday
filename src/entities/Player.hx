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
    public static inline var GRAVITY = 0.00067;
    public static inline var MAX_FALL_SPEED = 0.28;
    public static inline var RUN_SPEED = 0.17;
    public static inline var JUMP_POWER = 0.29;
    public static inline var JUMP_CANCEL_POWER = 0.08;

    // Animation constants
    public static inline var LAND_SQUASH = 0.5;
    public static inline var SQUASH_RECOVERY = 0.003;
    public static inline var AIR_SQUASH_RECOVERY = 0.0018;
    public static inline var JUMP_STRETCH = 1.5;

    public static inline var WIPE_DELAY = 0.5;
    public static inline var RESTART_DELAY = 0.25;

    private var wasStanding:Bool;
    private var isDying:Bool;
    private var isFlipped:Bool;
    private var canFlip:Bool;
    private var canMove:Bool;

    private var delta:Float;

    public function new(x:Float, y:Float)
    {
	    super(x, y);
        type = "player";
        sprite = new Spritemap("graphics/player.png", 16, 24);
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 10);
        sprite.add("jump", [4]);
        sprite.add("die", [7, 8, 9, 10, 11, 12, 13, 14, 15, 16], 45, false);
        sprite.play("idle");
        setHitbox(12, 24, -2, 0);

        wasStanding = false;
        isDying = false;
        isFlipped = false;
        canFlip = false;
        canMove = false;

        var restartDelay = new Alarm(
            RESTART_DELAY, function(_) { canMove = true; }, TweenType.OneShot
        );
        addTween(restartDelay, true);

	    finishInitializing();
    }

    private function scaleX(newScaleX:Float, anchorRight:Bool) {
        // Scales sprite horizontally, outward from the anchored side
        sprite.scaleX = newScaleX;
        if(anchorRight) {
            sprite.originX = width - (width / sprite.scaleX);
        }
    }

    private function scaleY(newScaleY:Float, anchorBottom:Bool) {
        // Scales sprite vertically, outward from the anchored side
        sprite.scaleY = newScaleY;
        if(anchorBottom) {
            sprite.originY = height - (height / sprite.scaleY);
        }
    }

    private function makeDustAtFeet() {
        var dust = new Dust(x, bottom);
        dust.y -= Dust.SPRITE_HEIGHT;
        if(sprite.flipped) {
            dust.x += 1;
        }
        scene.add(dust);
    }

    private function isStanding() {
        return isOnGround() && !isFlipped || isOnCeiling() && isFlipped;
    }

    public override function update()
    {
        delta = HXP.elapsed * 1000;

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
        if(Input.check(Key.X) && canFlip) {
            isFlipped = !isFlipped;
            canFlip = false;
        }

        // Check if the player is moving left or right
        if(Input.check(Key.UP)) {
            velocity.x = -RUN_SPEED;
        }
        else if(Input.check(Key.DOWN)) {
            velocity.x = RUN_SPEED;
        }
        else {
            velocity.x = 0;
        }

        var gravity = GRAVITY * delta;
        if(isFlipped) {
            gravity = -gravity;
        }

        // Check if the player is jumping or falling
        if(isStanding()) {
            velocity.y = 0;
            canFlip = true;
            if(Input.pressed(Key.Z)) {
                if(isFlipped) {
                    velocity.y = JUMP_POWER;
                }
                else {
                    velocity.y = -JUMP_POWER;
                }
                scaleY(JUMP_STRETCH, !isFlipped);
                makeDustAtFeet();
            }
        }
        else {
            velocity.y += gravity;
            if(Input.released(Key.Z)) {
                if(isFlipped) {
                    velocity.y = Math.min(JUMP_CANCEL_POWER, velocity.y);
                }
                else {
                    velocity.y = Math.max(-JUMP_CANCEL_POWER, velocity.y);
                }
            }
        }

        // Cap the player's velocity
        if(isFlipped) {
            velocity.y = Math.max(velocity.y, -MAX_FALL_SPEED);
        }
        else {
            velocity.y = Math.min(velocity.y, MAX_FALL_SPEED);
        }

        wasStanding = isStanding();

        moveBy(velocity.x * delta, velocity.y * delta, "walls");
    }

    private function animation()
    {
        // Recover if squashed
        var squashRecovery:Float = AIR_SQUASH_RECOVERY;
        if(isStanding()) {
            squashRecovery = SQUASH_RECOVERY;
        }
        squashRecovery *= delta;
        if(sprite.scaleY > 1) {
            scaleY(Math.max(sprite.scaleY - squashRecovery, 1), !isFlipped);
        }
        else if(sprite.scaleY < 1) {
            scaleY(Math.min(sprite.scaleY + squashRecovery, 1), !isFlipped);
        }

        if(!wasStanding && isStanding()) {
            scaleY(LAND_SQUASH, !isFlipped);
            makeDustAtFeet();
        }

        if(!isStanding()) {
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

        //if(isFlipped) {
            //sprite.scaleY = -1;
        //}
    }
}
