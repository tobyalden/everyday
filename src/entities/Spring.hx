package entities;

import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.graphics.*;

class Spring extends Entity
{
    public static inline var BOUNCE_SQUASH = 0.1;
    public static inline var BOUNCE_STRETCH = 1.5;
    public static inline var SQUASH_RECOVERY = 0.05;

    private var sprite:Image;
    private var isBouncing:Bool;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        type = "spring";
        sprite = new Image("graphics/spring.png");
        sprite.smooth = false;
        graphic = sprite;
        setHitbox(8, 7, 0, -1);
        isBouncing = false;
    }

    public function bounce() {
        // Prevent infinite recursion
        if(isBouncing) {
            return;
        }
        isBouncing = true;

        scaleY(BOUNCE_SQUASH);

        // Make adjacent springs bounce so it looks like it's all one spring
        var leftSpring = collide("spring", x - 1, y);
        if(leftSpring != null) {
            cast(leftSpring, Spring).bounce();
        }
        var rightSpring = collide("spring", x + 1, y);
        if(rightSpring != null) {
            cast(rightSpring, Spring).bounce();
        }
    }

    public override function update()
    {
        isBouncing = false;
        if(sprite.scaleY < 1) {
            scaleY(Math.min(sprite.scaleY + SQUASH_RECOVERY, 1));
        }
        super.update();
    }

    private function scaleY(newScaleY:Float) {
        // Scales sprite vertically upwards
        sprite.scaleY = newScaleY;
        sprite.originY = height - (height / sprite.scaleY);
    }
}

