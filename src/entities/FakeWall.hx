
package entities;

import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.graphics.*;
import com.haxepunk.Tween;
import com.haxepunk.tweens.misc.*;

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
        revealer.tween(sprite, "alpha", 0, 0.6, Ease.expoOut);
    }
}
