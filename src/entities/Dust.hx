package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.utils.*;

class Dust extends ActiveEntity
{
    private var anchor:Entity;
    private var anchorPosition:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        sprite = new Spritemap("graphics/grounddust.png", 16, 8);
        sprite.add("idle", [0, 1, 2, 3, 4], 16, false);
        sprite.play("idle");
        setHitboxTo(sprite);
        anchor = null;
        anchorPosition = new Vector2();
        finishInitializing();
    }

    public override function update() {
        if(anchor != null) {
            moveBy(anchor.x - anchorPosition.x, anchor.y - anchorPosition.y);
            anchorPosition = new Vector2(anchor.x, anchor.y);
        }
        if(sprite.complete) {
            scene.remove(this);
        }
        super.update();
    }

    public function setAnchor(newAnchor:Entity) {
        anchor = newAnchor;
        anchorPosition = new Vector2(anchor.x, anchor.y);
    }
}
