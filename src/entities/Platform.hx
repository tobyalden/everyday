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
        //trace('moveAmount: ${moveAmount} moveAmount.length: ${moveAmount.length} getDistanceFromDestination(): ${getDistanceFromDestination()} position: (${x}, ${y}) destination: ${getCurrentDestination()}');
        while(moveAmount.length >= getDistanceFromDestination()) {
            var destination = getCurrentDestination();
            var sub = new Vector2(destination.x - x, destination.y - y);
            moveAmount.subtract(sub);
            if(_player != null && carryingPlayer) {
                carryPlayer(sub);
            }
            moveTo(destination.x, destination.y);
            advanceNode();
            var newMoveAmount = new Vector2(velocity.x, velocity.y);
            newMoveAmount.normalize();
            newMoveAmount.scale(moveAmount.length);
            moveAmount = newMoveAmount;
        } 
        moveBy(moveAmount.x, moveAmount.y);
        if(_player != null && carryingPlayer) {
            carryPlayer(moveAmount);
        }
        super.update();
    }

    private function carryPlayer(carryDistance:Vector2) {
        var _player = scene.getInstance("player");
        if(_player != null) {
            var player = cast(_player, Player);
            player.x += carryDistance.x;
            if(player.isFlipped) {
                player.y = y + height;
            }
            else {
                player.y = y - player.height;
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


