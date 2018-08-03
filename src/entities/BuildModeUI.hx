package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;

class BuildModeUI extends Entity
{
    private var onIndicator:Text;

    public function new()
    {
        super(0, 0);
        visible = false;
        layer = -99;
        onIndicator = new Text("BUILD MODE", {size: 24, color: 0xf940bc});
        addGraphic(onIndicator);
        graphic.scrollX = 0;
        graphic.scrollY = 0;
    }
}
    
