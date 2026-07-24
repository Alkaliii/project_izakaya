shader_type canvas_item;

// tweaked version of this: https://godotshaders.com/shader/pixelated-radial-2d-clouds/

uniform vec2 pixelation = vec2(256, 256); //The resolution of the Texture
uniform float time_step = 1.0;
uniform float noise_step = 1.0;
uniform sampler2D cloud_noise1; //The first scroling noise for the clouds
uniform vec2 scroll_speed1 = vec2(0.02, 0.007); //The scroll-speed of the first noise
uniform sampler2D cloud_noise2; //The second scroling noise for the clouds
uniform vec2 scroll_speed2 = vec2(-0.015, -0.004); //The scroll-speed of the second noise
uniform vec2 center_pos = vec2(0.5, 0.0); //The position, the clouds are bend around
uniform float position_impact : hint_range(0.0, 1.0, 0.01) = 0.75;
uniform sampler2D color_gardient; //The colors of the cloud-sky-transition as a 1D-Gradient (set interpolation to constant for more pixel look)

group_uniforms mask;
uniform int use_simple_mask : hint_enum("No","X","Y","Xin","Yin","XY","XYin","XinY","XinYin","Radial","Radial Inverse","Box","Box Inverse");
uniform float simple_mask_power = 2.0;
uniform vec2 simplem_edge = vec2(0.0,1.0);
uniform float mask_step = 1.0;
uniform bool simple_only_alpha = true;

vec2 rotate(vec2 uv, vec2 pivot, float angle) {
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}
float uv2mask(vec2 uv, int type, float power, vec2 edge) {
	// generates a mask using UV;
	float mask = 1.0;
	switch (type) {
		case 0: return mask;
		case 1: mask = uv.x; break;
		case 2: mask = uv.y; break;
		case 3: mask = 1.0-uv.x; break;
		case 4: mask = 1.0-uv.y; break;
		case 5: mask = ((uv.x) + (uv.y)) / 2.0; break;
		case 6: mask = ((uv.x) + (1.0-uv.y)) / 2.0; break;
		case 7: mask = ((1.0-uv.x) + (uv.y)) / 2.0; break;
		case 8: mask = ((1.0-uv.x) + (1.0-uv.y)) / 2.0; break;
		case 9: mask = length(uv-0.5); break;
		case 10: mask = 1.0-length(uv-0.5); break;
		case 11:
			uv = rotate(uv,vec2(0.5),radians(45.0));
			mask = 1.0-((1.0-length(uv.y-0.5)) * (1.0-length(uv.x-0.5))); break;
		case 12:
			uv = rotate(uv,vec2(0.5),radians(45.0));
			mask = (1.0-length(uv.y-0.5)) * (1.0-length(uv.x-0.5)); break;
	}
	mask = smoothstep(edge.x,edge.y,mask);
	mask = pow(mask,power);
	mask = clamp(mask,0.0,1.0);
	return mask;
}

void fragment() {
	//The pixelated UV (so that the texture is actually pixelart)
	vec2 pixel_uv = floor(UV * pixelation) / pixelation;
	//Makes sure the clouds aren't stretched, even if it's not square shaped
	vec2 noise_uv_scale = pixel_uv;
	noise_uv_scale.x *= pixelation.x / pixelation.y;
	//The UVs inside the noise texture with time-offset
	float t = TIME;
	if (time_step > 1.0) {t = floor(t * time_step) / time_step;}
	
	vec2 noise1uv = fract(noise_uv_scale + t * scroll_speed1);
	vec2 noise2uv = fract(noise_uv_scale + t * scroll_speed2);
	//Determents the average color of the two noises
	vec4 noise_col = (texture(cloud_noise1, noise1uv) + texture(cloud_noise2, noise2uv)) * 0.5;
	
	//The pixels distance to the center
	float dist = distance(pixel_uv, center_pos);
	//Scales the distance to a range between 0 and 1
	vec2 furthest = vec2(-min(sign(center_pos.x - 0.5), 0.0), -min(sign(center_pos.y - 0.5), 0.0));
	float max_dist = distance(center_pos, furthest);
	dist /= max_dist;
	//Mixes the noise color with the distance to get noise that warps around the center
	float final = mix(1.0-noise_col.r, dist, position_impact);
	if (noise_step > 1.0) {final = floor(final * noise_step) / noise_step;}
	//applies the color from the gradient
	float simple_mask = 1.0;
	if (use_simple_mask != 0) {
		simple_mask = uv2mask(UV,use_simple_mask,simple_mask_power,simplem_edge);
		if (mask_step > 1.0) {simple_mask = floor(simple_mask * mask_step) / mask_step;}
	}
	COLOR *= texture(color_gardient, vec2(final, final));
	COLOR.a *= simple_mask;
}
