import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.screen.UniformScaleMode;
import scenes.*;

class Main extends Engine
{
    override public function init()
    {
#if debug
        HXP.console.enable();
#end
        HXP.scene = new GameScene();
        HXP.fullscreen = true;
        HXP.screen.color = 0x000000;
        HXP.screen.scaleMode = new UniformScaleMode(UniformScaleType.Letterbox, false);
        HXP.screen.scaleMode.setBaseSize(640, 480);
        HXP.resize(HXP.windowWidth, HXP.windowHeight);
	}

    public static function main()
    {
        new Main();
    }
}
