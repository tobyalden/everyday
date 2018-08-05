package entities;

import haxepunk.*;
import haxepunk.input.*;
import haxepunk.graphics.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import flash.geom.Point;
import flash.system.System;
import scenes.GameScene;

// Q: Why does game run slower at lower framerates?
// A: Engine.maxElapsed

// TODO: Attaching things to platforms, save/load, music, sfx.

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

    public var isFlipped(default, null):Bool;
    private var wasStanding:Bool;
    private var isDying:Bool;
    private var canFlip:Bool;
    private var canMove:Bool;

    private var lastCheckpoint:Checkpoint;
    private var resetTimer:Alarm;

    public function new(x:Float, y:Float)
    {
	    super(x, y);
        Key.define("left", [Key.LEFT, Key.LEFT_SQUARE_BRACKET]);
        Key.define("right", [Key.RIGHT, Key.RIGHT_SQUARE_BRACKET]);
        Key.define("jump", [Key.Z]);
        Key.define("flip", [Key.X]);
        Key.define("interact", [Key.DOWN]);
        name = "player";
        type = "player";
        sprite = new Spritemap("graphics/player.png", 16, 24);
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 10);
        sprite.add("jump", [4]);
        sprite.add("die", [7, 8, 9, 10, 11, 12, 13, 14, 15, 16], 45, false);
        sprite.play("idle");
        setHitbox(10, 24, -3, 0);

        wasStanding = false;
        isDying = false;
        isFlipped = false;
        canFlip = false;
        canMove = true;

        lastCheckpoint = null;

        resetTimer = new Alarm(1, TweenType.OneShot);
        resetTimer.onComplete.bind(resetLevel);
        addTween(resetTimer);

	    finishInitializing();
    }

    private function scaleX(newScaleX:Float, anchorRight:Bool) {
        // Scales sprite horizontally, outward from the anchored side
        sprite.scaleX = newScaleX;
        if(anchorRight) {
            sprite.originX = width - (width / sprite.scaleX);
        }
        else {
            sprite.originX = 0;
        }
    }

    private function scaleY(newScaleY:Float, anchorBottom:Bool) {
        // Scales sprite vertically, outward from the anchored side
        sprite.scaleY = newScaleY;
        if(anchorBottom) {
            sprite.originY = height - (height / sprite.scaleY);
        }
        else {
            sprite.originY = 0;
        }
    }

    private function makeDustAtFeet() {
        var dust = new Dust(x, bottom);
        if(isFlipped) {
            var platform = collide("walls", x, y - 1);
            if(platform != null) {
                dust.setAnchor(platform);
            }
            dust.y = top + dust.height;
            dust.sprite.scaleY = -1;
        }
        else {
            var platform = collide("walls", x, y + 1);
            if(platform != null) {
                dust.setAnchor(platform);
            }
            dust.y = bottom - dust.height;
        }
        if(sprite.flipX) {
            dust.x += 1;
        }
        scene.add(dust);
    }

    private function isStanding() {
        return isOnGround() && !isFlipped || isOnCeiling() && isFlipped;
    }

    public override function update() {
        collisions();
        if(!isDying) {
            if(canMove) {
                movement();
                interaction();
            }
            animation();
        }
        else {
            if(sprite.complete && visible) {
                visible = false;
                explode();
                resetTimer.start();
            }
        }
        if(collide("walls", x, y) != null) {
            die();
        }
        super.update();
    }

    private function resetLevel() {
        HXP.scene = new GameScene();
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
        var _extraFlip = collide("extraflip", x, y);
        if(_extraFlip != null) {
            var extraFlip = cast(_extraFlip, ExtraFlip);
            if(!canFlip && extraFlip.canUse()) {
                canFlip = true;
                extraFlip.use();
            }
        }

        if(
            collide("hazard", x, y) != null
            || collide("laserbeam", x, y) != null
        ) {
            die();
        }
    }

    private function die() {
        isDying = true;
        sprite.play("die");
    }

    private function movement() {
        if(Input.pressed("flip") && canFlip) {
            isFlipped = !isFlipped;
            canFlip = false;
        }

        // Check if the player is moving left or right
        if(Input.check("left")) {
            velocity.x = -RUN_SPEED;
        }
        else if(Input.check("right")) {
            velocity.x = RUN_SPEED;
        }
        else {
            velocity.x = 0;
        }

        var gravity = GRAVITY * Main.getDelta();
        if(isFlipped) {
            gravity = -gravity;
        }

        // Check if the player is jumping or falling
        if(isStanding()) {
            velocity.y = 0;
            canFlip = true;
            var extraFlips = new Array<Entity>();
            scene.getType("extraflip", extraFlips);
            for(extraFlip in extraFlips) {
                cast(extraFlip, ExtraFlip).reset();
            }
            if(Input.pressed("jump")) {
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
            // See if the player is bonking her head on the ceiling (or floor)
            if(isFlipped && isOnGround() || !isFlipped && isOnCeiling()) {
                if(isFlipped) {
                    velocity.y = Math.min(0, velocity.y);
                }
                else {
                    velocity.y = Math.max(0, velocity.y);
                }
                scaleY(sprite.scaleY, isFlipped);
            }
            velocity.y += gravity;
            if(Input.released("jump")) {
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

        moveBy(velocity.x * Main.getDelta(), velocity.y * Main.getDelta(), "walls");
    }

    private function interaction() {
        if(Input.pressed("interact") && isStanding()) {
            var levers = new Array<Entity>();
            collideInto("lever", x, y, levers);
            for(lever in levers)  {
                cast(lever, Lever).pull();
            }

            var checkpoints = new Array<Entity>();
            collideInto("checkpoint", x, y, checkpoints);
            for(_checkpoint in checkpoints) {
                var checkpoint = cast(_checkpoint, Checkpoint);
                checkpoint.flash();
                lastCheckpoint = checkpoint;
            }
        }
    }

    private function animation() {
        // Recover if squashed
        var squashRecovery:Float = AIR_SQUASH_RECOVERY;
        if(isStanding()) {
            squashRecovery = SQUASH_RECOVERY;
        }
        squashRecovery *= Main.getDelta();
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
            sprite.flipX = true;
        }
        else if(velocity.x > 0) {
            sprite.flipX = false;
        }

        sprite.flipY = isFlipped;
    }
}
