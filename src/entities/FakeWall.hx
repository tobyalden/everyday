
package entities;

import haxepunk.*;
import haxepunk.utils.*;
import haxepunk.graphics.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;

class FakeWall extends Entity
{
    private var sprite:Image;
    private var isRevealed:Bool;

    public function new(x:Float, y:Float, width:Int, height:Int)
    {
        super(x, y);
        sprite = new TiledImage("graphics/fakewall.png", width, height);
        sprite.smooth = false;
        graphic = sprite;
        setHitbox(width, height);
        isRevealed = false;
        layer = 1;
    }

    public override function update() {
        if(!isRevealed && collide("player", x, y) != null) {
            reveal();
        }
    }

    public function reveal() {
        trace("reveal");
        isRevealed = true;
        var revealer = new VarTween(TweenType.OneShot);
        addTween(revealer);
        revealer.tween(sprite, "alpha", 0, 0.5, Ease.expoOut);
    }
}
