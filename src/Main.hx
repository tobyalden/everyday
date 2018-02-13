import com.haxepunk.Engine;
import com.haxepunk.HXP;
import scenes.*;

class Main extends Engine
{
    override public function init()
    {
#if debug
        HXP.console.enable();
#end
        HXP.screen.scale = 2;
        HXP.scene = new GameScene();
	}

    public static function main()
    {
        new Main(640, 360, 60, true);
    }
}
