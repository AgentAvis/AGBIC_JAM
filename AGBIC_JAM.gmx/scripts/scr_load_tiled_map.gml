///scr_load_tiled_map(filename)

var filename;
var tileheight, tilewidth;

filename = argument0;

var data_file = file_text_open_read(working_directory + filename);
var json_data = "";
while (!file_text_eof(data_file))
{

    json_data += file_text_read_string(data_file);
    file_text_readln(data_file);
}
file_text_close(data_file); 

if ( !is_undefined(json_data) )
{
    var json = json_decode( json_data );
    //show_debug_message("read from file");
}
else
    exit;

global.tilewidth = ds_map_find_value( json, "tilewidth" );
global.tileheight = ds_map_find_value( json, "tileheight" );
globalvar map_width;
map_width = ds_map_find_value( json, "width" );
var map_height = ds_map_find_value( json, "height" );
var lst_tileset = ds_map_find_value( json, "tilesets" );
var tileset = ds_list_find_value(lst_tileset, 0);
var tileset_img = ds_map_find_value(tileset, "image");
var tile_cols = ds_map_find_value(tileset, "imagewidth") / global.tilewidth;
var tile_rows = ds_map_find_value(tileset, "imageheight") / global.tileheight;
var layer_depth = 0;
//show_debug_message(working_directory + tileset_img);
tileset_bg = background0;//background_add(working_directory + tileset_img, 0, false );

var lst_layers = ds_map_find_value( json, "layers" );
//show_debug_message(string(ds_list_size(lst_layers)));
for ( var layer_i = 0; layer_i < ds_list_size(lst_layers); layer_i++){
    var layer_object = ds_list_find_value( lst_layers, layer_i);
    var layer_type = ds_map_find_value( layer_object, "type");
    switch(layer_type){
        case "tilelayer":
            var layer_height = ds_map_find_value( layer_object, "height" );
            var layer_width = ds_map_find_value( layer_object, "width" );
            layer_depth -= 1 * layer_i;
            var lst_data = ds_map_find_value( layer_object, "data" );
            //build tile layer
            var i;
            for ( j = 0; j < map_height; j++ ){
                for ( k = 0; k < map_width; k++ ){   
                    i = ( j * map_width) + k;          
                    var tile_id = ds_list_find_value(lst_data, i);
                    var x_scl = 1;
                    var y_scl = 1;
                    var flip_x = false;
                    var flip_y = false;
                    //show_debug_message(tile_id);
                    if (tile_id < 0 )
                    {   
                            x_scl = -1;               
                            flip_x = true;                               
                            tile_id = (tile_id) + 2147483648;
                    }                  
                    if ( tile_id > 1073741824 ) 
                    {
                        y_scl = -1;
                        flip_y = true;
                        tile_id = (tile_id) - 1073741824;
                    }
                    if ( tile_id != 0 ) {
                        var tile_x = ((( tile_id - 1) mod tile_cols ) * global.tilewidth ) ; 
                        var tile_y = ((( tile_id - 1) div tile_cols ) * global.tileheight ); 
                        //show_debug_message(string(tile_x) + "," + string(tile_y));
                        //show_debug_message("x: " + string(x_scl) + " y: " + string(y_scl) );
                        var tile = tile_add(tileset_bg, tile_x, tile_y, global.tilewidth, global.tileheight, (k * global.tilewidth) + (global.tilewidth * flip_x), (j * global.tileheight) + (global.tileheight * flip_y), layer_depth+1);
                        tile_set_scale(tile, x_scl, y_scl);
                    }                         
                }
               }
            ds_list_destroy(lst_data);
        break;
        case "objectgroup":
            var lst_objects = ds_map_find_value( layer_object, "objects");
            for ( var o = 0; o < ds_list_size( lst_objects ); o++ ) {
                var object_map = ds_list_find_value( lst_objects, o);
                var object_type = asset_get_index( ds_map_find_value( object_map, "type"));
//                show_debug_message(object_type);
                var object_x = ds_map_find_value( object_map, "x" );
                var object_y = ds_map_find_value( object_map, "y" );
                var object_width = ds_map_find_value( object_map, "width");
                var object_height = ds_map_find_value( object_map, "height");
                if object_exists(object_type){
//                    show_debug_message("exists");
                    var object = instance_create( object_x, object_y, object_type);
                    var object_scale_x =  (object_width / object.sprite_width);
                    var object_scale_y = ( object_height / object.sprite_height);
                    //scale object and reposition based on offset                   
                    object.image_xscale = object_scale_x;
                    object.image_yscale = object_scale_y;
                    object.x = object_x + ( object.sprite_xoffset);
                    object.y = object_y + ( object.sprite_yoffset);
                }
            }
        break;
    }
}

ds_list_destroy(lst_layers);
ds_list_destroy(lst_tileset);
ds_map_destroy(json);
