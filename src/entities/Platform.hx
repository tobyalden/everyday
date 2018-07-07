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
    }

    public override function update() {
        setVelocityTowardsDestination();
        var moveAmount = new Vector2(
            velocity.x * Main.getDelta(), velocity.y * Main.getDelta()
        );
        while(moveAmount.length >= getDistanceFromDestination()) {
            var sub = moveAmount;
            sub.normalize();
            sub.scale(getDistanceFromDestination());
            moveAmount.subtract(sub);
            moveTo(getCurrentDestination().x, getCurrentDestination().y);
            advanceNode();
        } 
        moveBy(moveAmount.x, moveAmount.y);
        super.update();
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
            setVelocityTowardsDestination();
        }
        else {
            destinationIndex++;
            if(destinationIndex >= nodes.length) {
                destinationIndex = 0;
            }
            setVelocityTowardsDestination();
        }
    }
}


