import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.screen.UniformScaleMode;
import haxepunk.utils.*;
import scenes.*;

class Main extends Engine
{
    override public function init()
    {
#if debug
#end
        HXP.fullscreen = true;
        HXP.screen.scaleMode = new UniformScaleMode(UniformScaleType.Expand);
        HXP.screen.color = Color.Black;
        HXP.scene = new GameScene();
    }

    public static function main()
    {
        new Main();
    }
}
