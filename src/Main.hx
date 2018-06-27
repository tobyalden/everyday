import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.screen.UniformScaleMode;
import haxepunk.utils.*;
import scenes.*;

class Main extends Engine
{
    private static var delta:Float;

    public static function getDelta() {
        return delta;
    }

    override public function init()
    {
#if debug
#end
        HXP.fullscreen = false;
        HXP.screen.scaleMode = new UniformScaleMode(UniformScaleType.Expand);
        HXP.screen.color = Color.Black;
        HXP.scene = new GameScene();
    }

    public static function main()
    {
        new Main();
    }

    override public function update()
    {
        delta = HXP.elapsed * 1000;
        super.update();
    }
}
