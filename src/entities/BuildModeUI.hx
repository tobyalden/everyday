package entities;

import flash.events.Event;
import flash.net.FileReference;
import flash.net.FileFilter;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.input.*;

class BuildModeUI extends Entity
{
    private var onIndicator:Text;
    private var fileRef:FileReference;

    public function new()
    {
        super(0, 0);
        visible = false;
        layer = -99;
        onIndicator = new Text("BUILD MODE", {size: 24, color: 0xf940bc});
        addGraphic(onIndicator);
        graphic.scrollX = 0;
        graphic.scrollY = 0;
        Key.define("load", [Key.L]);
    }

    override public function update() {
        if(!visible) {
            super.update();
            return;
        }
        if(Input.pressed("load")) {
            pickScreen();
        }
        super.update();
    }

    private function pickScreen() {
        fileRef = new FileReference();
        fileRef.addEventListener(Event.SELECT, onFileSelected);
        var oelTypeFilter:FileFilter = new FileFilter(".oel Files", "*.oel");
        fileRef.browse([oelTypeFilter]);
    }
    
    private function onFileSelected(_:Event) {
        var levelDir = Sys.getCwd().split("bin")[0] + "assets/levels/";
        findScreen(levelDir, fileRef.name);
    }

    private function findScreen(directory:String, name:String) {
        if(sys.FileSystem.exists(directory)) {
            for(file in sys.FileSystem.readDirectory(directory)) {
                var path = haxe.io.Path.join([directory, file]);
                if(!sys.FileSystem.isDirectory(path)) {
                    if(file == name) {
                        trace("file found: " + path);
                    }
                    // do something with file
                }
                else {
                    var directory = haxe.io.Path.addTrailingSlash(path);
                    findScreen(directory, name);
                }
            }
        }
    }
}
