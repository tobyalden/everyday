package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.math.*;

class Platform extends Entity
{
    public static inline var SPEED = 0.12;

    private var nodes:Array<Vector2>;
    private var destinationIndex:Int;
    private var velocity:Vector2;
    private var isReversed:Bool;

    private var delta:Float;

    public function new(
        x:Float, y:Float, width:Int, height:Int, nodes:Array<Vector2>
    ) {
        super(x, y);
        this.nodes = nodes;
        type = "walls";
        graphic = new TiledImage("graphics/platform.png", width, height);
        graphic.smooth = false;
        setHitbox(width, height);
        destinationIndex = 1;
        isReversed = false;
        setVelocityTowardsDestination();
    }

    public override function update() {
        var carryingPlayer = false;
        var _player = scene.getInstance("player");
        if(_player != null) {
            var player = cast(_player, Player);
            carryingPlayer = (
                player.isFlipped && collideWith(player, x, y + 1) != null
                || !player.isFlipped && collideWith(player, x, y - 1) != null
            );
        }

        var moveAmount = new Vector2(
            velocity.x * Main.getDelta(), velocity.y * Main.getDelta()
        );

        while(moveAmount.length >= getDistanceFromDestination()) {
            var destination = getCurrentDestination();
            var sub = new Vector2(destination.x - x, destination.y - y);
            moveAmount.subtract(sub);

            x += sub.x;
            if(_player != null) {
                if(carryingPlayer) {
                    carryPlayerHorizontally(sub);
                }
                pushPlayerHorizontally(sub);
            }

            y += sub.y;
            if(_player != null) {
                if(carryingPlayer) {
                    carryPlayerVertically(sub);
                }
                pushPlayerVertically(sub);
            }

            advanceNode();
            var newMoveAmount = new Vector2(velocity.x, velocity.y);
            newMoveAmount.normalize();
            newMoveAmount.scale(moveAmount.length);
            moveAmount = newMoveAmount;
        } 

        x += moveAmount.x;
        if(_player != null) {
            if(carryingPlayer) {
                carryPlayerHorizontally(moveAmount);
            }
            pushPlayerHorizontally(moveAmount);
        }

        y += moveAmount.y;
        if(_player != null) {
            if(carryingPlayer) {
                carryPlayerVertically(moveAmount);
            }
            pushPlayerVertically(moveAmount);
        }

        super.update();
    }

    private function carryPlayerHorizontally(carryDistance:Vector2) {
        // TODO: Refactor using early returns (or something better)
        var _player = scene.getInstance("player");
        if(_player != null) {
            var player = cast(_player, Player);
            var willCollide = player.collide(
                "walls", player.x + carryDistance.x, player.y
            );
            if(willCollide != null) {
                player.moveBy(carryDistance.x, 0, "walls", true);
            }
            else {
                player.x += carryDistance.x;
            }
        }
    }

    private function pushPlayerHorizontally(pushDirection:Vector2) {
        var player = scene.getInstance("player");
        if(player == null) {
           return;
        }
        if(collideWith(player, x, y) != null) {
            if(pushDirection.x < 0) {
                player.x = x - player.width + player.originX;
            }
            else if(pushDirection.x > 0) {
                player.x = x + width + player.originX;
            }
        }
    }

    private function carryPlayerVertically(carryDistance:Vector2) {
        var _player = scene.getInstance("player");
        if(_player != null) {
            var player = cast(_player, Player);
            if(player.isFlipped) {
                var willCollide = player.collide("walls", player.x, y + height);
                if(willCollide != null) {
                    player.moveTo(player.x, y + height, "walls", true);
                }
                else {
                    player.y = y + height;
                }
            }
            else {
                var willCollide = player.collide("walls", player.x, y - player.height);
                if(willCollide != null) {
                    player.moveTo(player.x, y - player.height, "walls", true);
                }
                else {
                    player.y = y - player.height;
                }
            }
            if(
                velocity.y < 0 && player.isFlipped
                || velocity.y > 0 && !player.isFlipped
            ) {
                player.setVelocity(
                    new Vector2(player.getVelocity().x, velocity.y)
                );
            }
        }
    }

    private function pushPlayerVertically(pushDirection:Vector2) {
        var player = scene.getInstance("player");
        if(player == null) {
           return;
        }
        if(collideWith(player, x, y) != null) {
            if(velocity.y < 0) {
                player.y = y - player.height;
            }
            else if(velocity.y > 0) {
                player.y = y + height;
            }
        }
    }


    private function setVelocityTowardsDestination() {
        var destination = getCurrentDestination();
        var direction = new Vector2(destination.x - x, destination.y - y);
        direction.normalize();
        direction.scale(SPEED);
        velocity = direction;
    }

    public function getCurrentDestination() {
        return nodes[destinationIndex];
    }

    public function getDistanceFromDestination() {
        var destination = getCurrentDestination();
        return MathUtil.distance(x, y, destination.x, destination.y);
    }

    public function advanceNode()
    {
        if(isReversed) {
            destinationIndex--;
            if(destinationIndex < 0) {
                destinationIndex = nodes.length - 1;
            }
        }
        else {
            destinationIndex++;
            if(destinationIndex >= nodes.length) {
                destinationIndex = 0;
            }
        }
        setVelocityTowardsDestination();
    }
}


