shader_type canvas_item;

// hit flash mostly
uniform bool hit = false;
uniform float hit_thresh = 0.2;
uniform float hit_step = 1.0;
uniform float hit_speed = 16.0;
uniform bool soft_flash = false;
uniform float s_flash_speed = 2.0;
//uniform float dissolve_progress : hint_range(0.0, 1.0, 0.001) = 0.0;

// How jagged each band of melting pixels are
//uniform float meltiness: hint_range(0.0, 16.0) = 1.0;

// set this to height in cell count (x2) if you're using a sprite sheet
//uniform float texture_height = 1.0;

float psuedo_rand(float x) {
	return mod(x * 2048103.0 + cos(x * 1912.0), 1.0);
}

//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

//vec4 melt(vec2 uvm,vec2 tps,sampler2D tex,float progress) {
	//vec2 uv = uvm;
	//
	//// Move pixels near the top faster
	//uv.y -= progress / uvm.y;
	//
	//// Created jagged edges for each pixel on the x-axis 
	//uv.y -= progress * meltiness * psuedo_rand(uvm.x - mod(uvm.x, tps.x));
	//
	//vec4 col;
	//col = texture(tex, uv);
	//
	//// "delete" pixels out of range
	//if (uv.y <= 0.0) {
		//col.a = 0.0;
	//}
	//return col;
//}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 COL = texture(TEXTURE,UV);
	//vec4 COL = melt(UV,TEXTURE_PIXEL_SIZE,TEXTURE,dissolve_progress / texture_height);
	
	if (hit && COL.r > hit_thresh) {
		COL.rgb = mix(COL.rgb,-COL.rgb,sin(floor((TIME * hit_speed) * hit_step) / hit_step));
	} else if (hit) {
		COL.rgb = mix(vec3(1.0),COL.rgb,cos(floor((TIME * hit_speed) * hit_step) / hit_step));
	}
	
	if (soft_flash) {
		COL.a *= sin(TIME * s_flash_speed);
	}
	
	
	COLOR.rgb = COL.rgb;
	COLOR.a *= COL.a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
