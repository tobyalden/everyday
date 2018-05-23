package entities;

import haxepunk.*;
import haxepunk.utils.*;
import haxepunk.graphics.*;
import scenes.*;

class Wipe extends Entity
{
    public static inline var WIPE_SPEED = 17;

    private var wipeIn:Bool;
    private var sprite:Image;

    public function new(wipeIn:Bool)
    {
        super(0, 0);
        this.wipeIn = wipeIn;
        sprite = new Image("graphics/wipe.png");
        if(wipeIn) {
            sprite.scaleX = -1;
            x = -40;
        }
        else {
            x = -sprite.width;
        }
        sprite.smooth = false;
        graphic = sprite;
        layer = -100;
    }

    public override function update()
    {
        if(wipeIn && x < sprite.width || !wipeIn && x < 0) {
            moveBy(WIPE_SPEED, 0);     
        }
        else if (!wipeIn) {
            HXP.scene.removeAll();
            HXP.scene = new GameScene();
        }
    }
}

