package entities;

import com.haxepunk.tmx.TmxEntity;
import com.haxepunk.tmx.TmxMap;
import com.haxepunk.Entity;

class Level extends TmxEntity
{
    public static inline var PLAYER = 17;
    
    public var entities:Array<Entity>;

    public function new(filename:String)
    {
        super(filename);
        entities = new Array<Entity>();
        loadGraphic("graphics/tiles.png", ["main"]);
        loadMask("collision_mask", "walls");
        map = TmxMap.loadFromFile(filename);
        for(entity in map.getObjectGroup("entities").objects) {
            if(entity.gid == PLAYER) {
                entities.push(new Player(entity.x, entity.y));
            }
        }
    }
}
