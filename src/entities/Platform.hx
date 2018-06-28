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
        type = "platform";
        graphic = new TiledImage("graphics/platform.png", width, height);
        graphic.smooth = false;
        setHitbox(width, height);
        destinationIndex = 1;
        isReversed = false;
        setVelocityTowardsDestination();
    }

    public override function update() {
        var move = velocity;
        move.scale(Main.getDelta());
        trace('velocity ${velocity} move ${move} delta ${delta} destinationIndex ${destinationIndex}');
        moveByAmount(move);
        super.update();
    }

    public function moveByAmount(move:Vector2) {
        var distanceFromDestination = getDistanceFromDestination();

        /* If the given move would take the platform to or past its
        destination when applied, set the platform's position to its
        destination */
        if(move.length >= distanceFromDestination) {
            trace("jump");
            var destination = getCurrentDestination();
            var snapDistanceX = destination.x - x;
            //if(platformIsUnderPlayer) {
                //carryPlayerHorizontally(snapDistanceX);
            //}
            x = destination.x;
            //resolveHorizontalCollisionsWithPlayer(platform);

            var snapDistanceY = destination.y - y;
            //if(platformIsUnderPlayer) {
                //carryPlayerVertically(platform, snapDistanceY);
            //}
            y = destination.y;
            //resolveVerticalCollisionsWithPlayer(platform);

            advanceNode();

            /* If the move would have taken the platform past its
            destination, subtract the distance traveled above when it snapped
            to the destination from the move, and use what's left over to
            travel towards its new destination */
            if(move.length > distanceFromDestination) {
                var newMove = velocity;
                newMove.scale(Main.getDelta());

                var distanceTraveled = newMove;
                distanceTraveled.normalize();
                distanceTraveled.scale(distanceFromDestination);

                newMove.subtract(distanceTraveled);
                moveByAmount(newMove);
            }
        }
        // If the move would not take the platform to or past its
        // destination, apply velocity normally
        else {
            trace("applied normally");
            //if(platformIsUnderPlayer) {
                //carryPlayerHorizontally(moveVector.X);
            //}
            x += move.x;
            //resolveHorizontalCollisionsWithPlayer(platform);

            //if(platformIsUnderPlayer) {
                //carryPlayerVertically(platform, move.Y);
            //}
            y += move.y;
            //resolveVerticalCollisionsWithPlayer(platform);
        }
    }

    public function getCurrentDestination() {
        return nodes[destinationIndex];
    }

    private function setVelocityTowardsDestination() {
        var destination = getCurrentDestination();
        var direction = new Vector2(destination.x - x, destination.y - y);
        direction.normalize();
        direction.scale(SPEED);
        velocity = direction;
    }

    public function advanceNode()
    {
        var oldVelocity = velocity;
        if(isReversed) {
            destinationIndex--;
            if(destinationIndex < 0) {
                destinationIndex = nodes.length - 1;
            }
            setVelocityTowardsDestination();
        }
        else {
            destinationIndex++;
            if(destinationIndex >= nodes.length) {
                destinationIndex = 0;
            }
            setVelocityTowardsDestination();
        }
        if(velocity.x != oldVelocity.x || velocity.y != oldVelocity.y) {
            // Changed direction sfx
        }
    }

    public function getDistanceFromDestination() {
        var destination = getCurrentDestination();
        return MathUtil.distance(x, y, destination.x, destination.y);
    }

    // Reverses the direction and path of the platform
    public function reverse() {
        isReversed = !isReversed;
        advanceNode();
        // Reverse sfx
    }
}
