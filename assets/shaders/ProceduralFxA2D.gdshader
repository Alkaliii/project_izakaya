shader_type canvas_item;
//render_mode cull_disabled, unshaded;

// Like flak but written better and NO RAYMARCHING
// Less samplers also, and better shapes + shape morphing

///** Toggle Front Culling. Front face will not appear. */
//uniform bool front_cull = false;
//
///** Toggle Back Culling. Back face will not appear. */
//uniform bool back_cull = false;

uniform vec2 texture_size = vec2(1.0);

group_uniforms animation;
/**
	* This value animates the shader as it changes when [param derive_progress] == 1.
	* Modify it with an animation player or edit it from gdScript with:
	[code]material.set_shader_parameter("progress", new_value)[/code]
*/
uniform float progress : hint_range(0.0, 1.0, 0.001);

/**
	* Different ways to drive the shader's animation.
	* <0> [enum Time], Shader animates with global [constant TIME]
	* <1> [enum Progress], Shader animates with [param progress]
	* <2> [enum Lifetime], Shader animates with particle lifetime, [member INSTANCE_CUSTOM.y]
*/
uniform int derive_progress : hint_enum("Time","Progress","Lifetime") = 1;

/**
	* Different ways to interpolate the shader's animation.
	* <0> [enum Custom Ease], Use by setting a [CurveTexture] in [param custom_ease]
	* <1> [enum Ease In], Exponetial Ease In
	* <2> [enum Linear], Linear
	* <3> [enum Ease Out], Exponetial Ease Out
	* <4> [enum Ease In Out], Exponetial Ease In and Out
*/
uniform int ease_progress : hint_enum("Custom Ease","Ease In","Linear","Ease Out","Ease In Out","Ease Out In") = 2;

/**
	* Set a [CurveTexture] here and change [param ease_progress] to 0.
	* The shader will sample the texture red channel to interpolate the animation.
*/
uniform sampler2D custom_ease : hint_default_white, filter_linear, repeat_disable;

/** Modifies animation length when [param derive_progress] == 1 */
uniform float time_scale : hint_range(0.0, 8.0, 0.01) = 1.0;

uniform int ping_pong : hint_enum("No","Cos","Sin");

group_uniforms shape;
uniform vec2 shape_morph = vec2(0.0);
uniform vec4 shp_glb_translate = vec4(0.0);
uniform vec2 shp_glb_rotate = vec2(0.0);
uniform vec4 shp_glb_scale = vec4(1.0);
uniform vec2 shape_energy = vec2(1.0);
uniform int shape_morph_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int shp_glb_trans_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int shp_glb_rot_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int shp_glb_scl_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int shp_energy_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;

group_uniforms SHAPE.A;
uniform int shapei : hint_enum("Circle","Rect","Squircle","Rhombus","Equilateral","Isosceles","Polygon","Star","Compound Star","Cross","Round Cross","Oblique Cross","Clover","Heart","Arc","Ring","Segment","Letter Z") = 0;
uniform vec2 shape_sizei = vec2(0.25);
uniform vec2 shape_sizeib = vec2(0.25);
uniform int shape_sidesi : hint_range(3, 20, 1) = 4;
uniform vec2 shape_thicki = vec2(0.1);
uniform vec4 shape_extrai = vec4(0.1);
uniform vec3 shape_sri = vec3(1.0,1.0,0.0);
uniform int shape_szi_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int shape_szib_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int shape_thicki_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int shape_extrai_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;

group_uniforms SHAPE.B;
uniform int shapef : hint_enum("Circle","Rect","Squircle","Rhombus","Equilateral","Isosceles","Polygon","Star","Compound Star","Cross","Round Cross","Oblique Cross","Clover","Heart","Arc","Ring","Segment","Letter Z") = 0;
uniform vec2 shape_sizef = vec2(0.25);
uniform vec2 shape_sizefb = vec2(0.25);
uniform int shape_sidesf : hint_range(3, 20, 1) = 4;
uniform vec2 shape_thickf = vec2(0.1);
uniform vec4 shape_extraf = vec4(0.1);
uniform vec3 shape_srf = vec3(1.0,1.0,0.0);
uniform int shape_szf_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int shape_szfb_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int shape_thickf_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int shape_extraf_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;

group_uniforms SHAPE.C;
// overlap
// copies ab morph but at a different size and with a different feather
uniform int apply_overlap : hint_enum("No", "Add", "Subtract") = 0;
uniform vec2 overlap_percent = vec2(0.5);
uniform vec4 overlap_offset = vec4(0.0);
uniform vec2 overlap_feather = vec2(0.0);
//uniform int feather_falloff : hint_enum("Hermite","Pixiecubic","Exponetial","Sigmoid²ˣ","Plateauhalo");
//uniform vec3 feather_falloff_control = vec3(0.5);
uniform int overlap_percent_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int overlap_offset_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int overlap_feather_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;

group_uniforms SHAPE.FEATHER;
uniform vec2 shape_feather = vec2(0.0);
uniform int feather_falloff : hint_enum("Hermite","Pixiecubic","Exponetial","Sigmoid²ˣ","Plateauhalo");
uniform vec3 feather_falloff_control = vec3(0.5);
uniform int shape_feather_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
group_uniforms SHAPE.AUGMENT;
uniform vec2 shape_rounding = vec2(0.0);
uniform int apply_onion : hint_enum("No", "Before Rounding", "After Rounding");
uniform vec2 shape_onion = vec2(0.0);
uniform int shape_rounding_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int shape_onion_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
group_uniforms SHAPE.WOBBLE;
uniform vec4 wobble_freq_amp = vec4(0.0);
uniform vec2 wobble_rot = vec2(0.0);
uniform int wfa_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int wrot_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
group_uniforms SHAPE.TWIST;
uniform int twist_type : hint_enum("Normal", "Exponetial") = 0;
uniform vec2 shape_twist = vec2(0.0);
uniform bool distortion_factor_twist = false;
uniform bool mask_factor_twist = false;
uniform int shape_twist_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
group_uniforms SHAPE.FOLLOWTHROUGH;
uniform int shp_scale_anim : hint_enum("None","Xio","Xi","Xo","Yio","Yi","Yo");
uniform int shp_scale_anim_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 2;

group_uniforms DISTORTION;
uniform int apply_distortion : hint_enum("No", "Yes");
uniform sampler2D distort_texture : source_color,hint_default_black,filter_linear;
uniform vec2 distort_str = vec2(0.3);
uniform vec4 scroll_distortion = vec4(0.0);
uniform vec4 scale_distortion = vec4(1.0);
uniform vec4 polarize_distortion = vec4(0.5,0.5,0.6,0.0);
uniform int distort_str_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int distort_scroll_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform float floor_distort_scroll : hint_range(0.0, 100.0, 0.1) = 0.0;
uniform int distort_scale_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
group_uniforms DISTORTION.DISTORTION_MASK;
uniform int apply_dist_mask : hint_enum("No","X","Y","Xin","Yin","XY","XYin","XinY","XinYin","Radial","Radial Inverse","Box","Box Inverse");
uniform float dist_mask_power = 2.0;
uniform vec2 distmask_edge = vec2(0.0,1.0);
group_uniforms DISTORTION.FISHEYE;
uniform vec2 fisheye_str = vec2(0.0);
uniform vec4 fisheye_offset = vec4(0.0);
uniform int fisheye_str_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
uniform int fisheye_offset_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;

group_uniforms MASK;
//uniform int apply_mask : hint_enum("No","Static","Smoothstep","Step");
//uniform sampler2D mask_texture : source_color,hint_default_black,filter_linear;
//uniform vec2 mask_str = vec2(1.0);
//uniform vec4 mask_edge = vec4(vec2(0.0,1.0),vec2(1.0));
//uniform vec4 scroll_mask = vec4(0.0);
//uniform vec4 scale_mask = vec4(1.0);
//uniform vec4 polarize_mask = vec4(0.5,0.5,0.6,0.0);
//uniform int mask_str_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
//"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
//uniform int mask_edge_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
//"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 2;
//uniform int mask_scroll_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
//"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
//uniform float floor_mask_scroll : hint_range(0.0, 100.0, 0.1) = 0.0;
//uniform int mask_scale_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
//"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
//group_uniforms MASK.AUTO_GRADUATE;
//uniform int apply_mask_autograd : hint_enum("No","X","Y","Xin","Yin","XY","XYin","XinY","XinYin","Radial","Radial Inverse","Box","Box Inverse");
//uniform float mask_autograd_power = 2.0;
//uniform vec2 maskag_edge = vec2(0.0,1.0);
//uniform int maskag_interp : hint_enum("Hermite","Pixiecubic","Exponetial","Sigmoid²ˣ","Plateauhalo");
//uniform vec3 maskag_interp_control = vec3(0.5);
group_uniforms MASK.SIMPLE_MASK;
uniform int use_simple_mask : hint_enum("No","X","Y","Xin","Yin","XY","XYin","XinY","XinYin","Radial","Radial Inverse","Box","Box Inverse");
uniform float simple_mask_power = 2.0;
uniform vec2 simplem_edge = vec2(0.0,1.0);
uniform bool simple_only_alpha = true;
//group_uniforms MASK.OTHER;
//uniform bool mask_factor_distortion = false;

group_uniforms COLORIZE;
///**
	//* Color the shader with gradient mapping!
	//Set a [GradientTexture1D] here to sample from by gray value.
	//By default the right-most color value will be used when [param shading] == 0
//*/
//uniform sampler2D color_gradient : source_color, hint_default_white, repeat_disable;
//
//
///**
	//* This value will make the shader glow/darken.
	//Works best when [member WorldEnvironment.Glow] is enabled.
//*/
uniform float emission_intensity : hint_range(0.1, 32.0, 0.1) = 1.0;
//
///**
	//* This value will posterize the shading resulting in value bands.
	//A zero value will disable the calculation.
	//A higher value will result in [i]less[/i] banding.
//*/
//uniform int chunky_color : hint_range(0, 100, 1) = 0;
uniform float tweak_alpha = 1.0;
uniform float step_alpha = 1.0;
//
//group_uniforms COLORIZE.TWEAK_GRADIENT;
//uniform vec2 shift_gradient = vec2(0.0);
//uniform int gradient_bias : hint_enum("No","X","Y","Xin","Yin","XY","XYin","XinY","XinYin","Radial","Radial Inverse","Box","Box Inverse");
//uniform vec2 gbias_str = vec2(1.0);
//uniform vec2 gbias_shift = vec2(0.0);
//uniform int shift_gradient_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
//"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
//uniform int gb_str_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
//"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
//uniform int gb_shift_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
//"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;
//group_uniforms COLORIZE.CHROMATIC_ABERRATION;
//// Note: Very heavy on performance.
//
///**
	//* Control how the shader applies a chromatic aberration effect to the image.
	//Warn (!), Very heavy on performance! (For loops are increased by a factor of [param chroma_samples]/2.0])
	//<0> [enum No], Shader will not apply chromatic aberration.
	//<1> [enum Linear], Shader will apply effect in a linear fashion.
	//<2> [enum Radial], Shader will apply effect in a radial manner.
	//<3> [enum Twist], Shader will apply effect with a twist.
	//
	//* Chroma is based on example by XOR
	//@source: [url]https://mini.gmshaders.com/p/gm-shaders-mini-chromatic-aberration[/url]
//*/
//uniform int apply_chroma : hint_enum("No", "Linear", "Radial", "Twist");
//
///** Number of samples used to produce chroma effect. (More samples results in a smoother effect) */
//uniform int chroma_samples : hint_range(0, 10, 2);
//
///** Distance between samples in effect. */
//uniform vec2 chroma_offset = vec2(0.01);
//
//uniform int chroma_arrangement : hint_enum("rgb","rbg","grb","gbr","brg","bgr","rrb","rrg","ggr","ggb","bbr","bbg");
//uniform float chroma_power = 2.0;
//uniform vec4 tweak_chroma_weight = vec4(0.0);
//uniform int gray_chroma : hint_enum("No", "Weighted", "Average") = 0;

group_uniforms COLORIZE.RAINBOW;
uniform int apply_rainbow : hint_enum("No", "Multiply", "Add", "Replace") = 0;
uniform float rainbow_str : hint_range(-3.0, 3.0, 0.01) = 1.0;
uniform float r_time_scale : hint_range(-8.0, 8.0, 0.01) = 1.0; // Speed
uniform float r_sin_frequency : hint_range(0.1, 2.0) = 0.5;  // frequency of the rainbow
uniform float r_sin_offset : hint_range(0.0, 360.0) = 0.0;   // offset of the rainbow, useful to differentiate objects using the same shader
uniform float r_light_offset : hint_range(0.0, 1.0) = 0.5;   // this offsets all color channels; if set to 0 only red green and blue colors will be shown.
uniform int rainbow_bias : hint_enum("No","X","Y","Xin","Yin","XY","XYin","XinY","XinYin","Radial","Radial Inverse","Box","Box Inverse");
uniform vec2 rbias_edge = vec2(0.0,1.0);

//group_uniforms COLORIZE.PROXIMITY_FADE;
//uniform int enable_proximity_fade : hint_enum("No", "Normal", "Sophisticated");
//
///** Shader will fade when specified distance away from something in depth buffer. */
//uniform float proximity_fade_distance = 0.0;
//
///** Adds faux depth to the proximity fade calulation. */
//uniform float proximity_fade_offset = 0.9;
//uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

//group_uniforms COLORIZE.ALPHA_VICINITY;
//uniform int enable_alpha_vicinity : hint_enum("No", "Aligned", "Divergent");
//uniform float sphere_size = 3.0;
//uniform bool spoof_player_pos;
//uniform vec3 spoofed_position = vec3(0.0);
//global uniform vec3 player_pos;

//group_uniforms COLORIZE.FRESNEL;
//uniform int apply_fresnel : hint_enum("No", "Yes", "Invert");
//uniform vec2 fresnel_strength = vec2(1.0);
//uniform float floor_fresnel = 0.0;
//uniform int fresnel_str_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
//"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;

group_uniforms vertex;

///**
	//* Control how the mesh follows the camera.
	//<0> [enum No], Mesh will not billboard.
	//<1> [enum Yes], Mesh will billboard.
	//<2> [enum Y], Mesh will billboard on the Y axis.
	//<3> [enum Local Y], Mesh will billboard on it's local Y axis. (acts weird with scaling...?)
//*/
//uniform int billboard : hint_enum("No", "Yes", "Y", "Local Y") = 0;

///** Move the mesh towards or away from the camera. */
//uniform float camera_offset = 0.0;

uniform vec2 rescale_vertex = vec2(1.0);

/** Offset the mesh from it's center point. */
uniform vec2 mesh_offset = vec2(0.0);

/** Offset the mesh from it's center point, when interpolation is 'finished'. */
uniform vec2 final_mesh_offset = vec2(0.0);

uniform int mesh_offset_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;

/** Randomly rotate mesh using particle index, [member INSTANCE_ID]. */
//uniform vec3 index_rand_mesh_rot = vec3(0.0);
uniform float index_rand_mesh_rot = 0.0;

/** math stuff. [param index_rand_mesh_rot] will function differently. */
uniform bool maintain_irm_domain = false;

/** Rotate the mesh the shader is applied to in XYZ axis by the specified amount in degrees. */
uniform float mesh_rotation = 0.0;

/** Speed mesh will rotate with on axis. */
uniform float animate_mesh_rotation = 0.0;

/**
	* Control how the shader drives rotation.
	<0> [enum Nothing], Shader will not interpolate.
	<1> [enum Time], Shader will drive using global time, [constant TIME].
	<2> [enum Progress], Shader will drive using progress, [param progress].
*/
uniform int animate_mesh_rot_with : hint_enum("Nothing", "Time", "Progress") = 0;

//
///** Set a texture here to use when displacing vertices. */
//uniform sampler2D vertex_displacement_mask : hint_default_black;
//
///** How much vertices are displaced on each axis. */
//uniform vec3 vertex_displacement_str = vec3(0.0);
//
///** How much vertices are displaced on each axis, when interpolation is 'finished'. */
//uniform vec3 final_vertex_displacement_str = vec3(1.0);
//
//uniform int vert_disp_driver : hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
//"prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D") = 0;

group_uniforms vertex.PERSPECTIVE;
// Shamelessly stolen implementation
// Original by codevogel
// https://godotshaders.com/shader/faux-3d-perspective-shader-for-2d-canvas-items/
uniform bool cull_backface = false;
uniform float fov : hint_range(1, 179) = 1.0;
uniform float rot_y_deg : hint_range(-360, 360) = 0.0;
uniform float rot_x_deg : hint_range(-360, 360) = 0.0;
uniform float inset : hint_range(0, 1) = 0.0;

varying vec2 vp_offset;
varying vec3 world_pos_3d;

group_uniforms CURVES;
uniform sampler2D custom_a : hint_default_black, filter_linear, repeat_disable;
uniform sampler2D custom_b : hint_default_black, filter_linear, repeat_disable;
uniform sampler2D custom_c : hint_default_black, filter_linear, repeat_disable;
uniform sampler2D custom_d : hint_default_black, filter_linear, repeat_disable;

group_uniforms RANDOM;
/**
	* Control how the shader produces random values.
	<0> [enum BoSh] fract(sin(dot())) as described in the Book of Shaders
	@tutorial: [url]https://thebookofshaders.com/10/[/url]
	<1> [enum Sinless] fract() & dot() then fract(), an implementation by Dave Hoskins.
	@source: [url]https://www.shadertoy.com/view/4djSRWp[/url]
*/
uniform int randomness : hint_enum("BoSh", "Sinless") = 0;

/** Offset the randomness, the possibilities are finte, but varied! */
uniform int randomness_seed = 0;

/** Offset the randomness using particle index, [member INSTANCE_ID]. */
uniform int index_shift_randomness : hint_enum("No", "Yes") = 0;

uniform int custom_index = 0;

varying float LIFETIME;
varying float INDEX;
varying flat int PARTICLE;
varying float[11] CHRONOGRAPH;

varying vec3 world_vertex;

const float TINYV = 1./4056.;
const float EPSILON = 0.00001;

float random(vec2 uv) {
	// provides a random number given a vec2
	// seed setup sucks lol
	float seed = float(randomness_seed) / PI;
	if (index_shift_randomness == 1) {seed += float(PARTICLE);}
	switch (randomness) {
		case 0:
			return fract(sin(dot(uv.xy,vec2(12.9898 + seed,78.233))) * 43758.5453123 + seed);
		case 1:
			// https://www.shadertoy.com/view/4djSRW
			vec3 p3  = fract(vec3(uv.xyx + seed) * .1031);
			p3 += dot(p3, p3.yzx + 33.33);
			return fract((p3.x + p3.y) * p3.z + seed);
	}
}

//float fresnel(float amount, vec3 normal, vec3 view) {
	//return pow((1.0 - dot(normalize(normal), normalize(view))), amount);
//}

vec2 rotate(vec2 uv, vec2 pivot, float angle) {
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}
vec2 scale(vec2 uv, float x, float y) {
	mat2 scalee = mat2(vec2(x, 0.0), vec2(0.0, y));
	uv -= 0.5;
	uv = uv * scalee;
	uv += 0.5;
	return uv;
}
//mat3 rotateX(float theta) {
	//float cosa = cos(theta);
	//float sina = sin(theta);
//
	//mat3 rotate_x  = mat3(
	   //vec3(1.0, 0.0, 0.0),
	   //vec3(0.0, cosa, -sina),
	   //vec3(0.0, sina, cosa)
	//);
	//return rotate_x;
//}
//mat3 rotateY(float theta) {
	//float cosa = cos(theta);
	//float sina = sin(theta);
//
	//mat3 rotate_y  = mat3(
	   //vec3(cosa, 0.0, sina),
	   //vec3(0.0, 1.0, 0.0),
	   //vec3(-sina, 0.0, cosa)
	//);
	//return rotate_y;
//}
//mat3 rotateZ(float theta) {
	//float cosa = cos(theta);
	//float sina = sin(theta);
//
	//mat3 rotate_z  = mat3(
	   //vec3(cosa,-sina, 0.0),
	   //vec3(sina, cosa, 0.0),
	   //vec3(0.0, 0.0, 1.0)
	//);
	//return rotate_z;
//}

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

float shapestep(int type, float edge0, float edge1, float x, vec3 control) {
	// 0 Smoothstep
	// 1 Double-Cubic Seat : http://www.flong.com/archive/texts/code/shapers_poly/
	// 2 Exponetial In/Out : http://www.flong.com/archive/texts/code/shapers_exp/
	// 3 Double Exponetial Sigmoid : http://www.flong.com/archive/texts/code/shapers_exp/
	// 4 Double-Odd-Polynomial Seat : http://www.flong.com/archive/texts/code/shapers_poly/
	
	float mina = 0.0 + EPSILON;
	float maxa = 1.0 - EPSILON;
	float minb = 0.0;
	float maxb = 1.0;
	float a = min(maxa,max(mina,control.x));
	float b = min(maxb,max(minb,control.y));
	float y = 0.0;
	
	if (type != 0) {x = clamp((x - edge0) / (edge1 - edge0),0.0,1.0);}
	
	switch (type) {
		case 1: // 1 Double-Cubic Seat
			if (x <= a) {y = b-b*pow(1.0-x/a,3.0);}
			else {y = b + (1.0-b)*pow((x-a)/(1.0-a),3.0);}
			return y;
		case 2: // 2 Exponetial In/Out
			if (a < 0.5) {
				a = 2.0*a;
				y = pow(x,a);
			} else {
				a = 2.0*(a-0.5);
				y = pow(x,1.0/(1.0-a));
			}
			return y;
		case 3: // 3 Double Exponetial Sigmoid
			a = 1.0-a;
			if (x<0.5) {y = (pow(2.0*x,1.0/a))/2.0;}
			else {y = 1.0 - (pow(2.0*(1.0-x),1.0/a))/2.0;}
			return y;
		case 4: // 4 Double-Odd-Polynomial Seat
			float p = 2.0*ceil(control.z)+1.0;
			if (x <= a) {y = b - b*pow(1.0-x/a,p);}
			else {y = b + (1.0-b)*pow((x-a)/(1.0-a),p);}
			return y;
		default: return smoothstep(edge0,edge1,x);
	}
	return y;
}

float grayscale(vec3 rgb, int type) {
	// average
	if (type == 1) {
		return (rgb.r + rgb.g + rgb.b) / 3.0;
	}
	// weighted
	const float rw = 0.299;
	const float gw = 0.587;
	const float bw = 0.114;
	rgb *= vec3(rw,gw,bw);
	return rgb.r + rgb.g + rgb.b;
}

// SDF Other 
// : https://iquilezles.org/articles/distfunctions2d/
// : https://medium.com/@ohbonsai/2d-sdf-operation-3-space-manipulation-ef788b25497c
float ndot(vec2 a, vec2 b) {return a.x*b.x - a.y*b.y;}
float dot2(vec2 v) {return dot(v,v);}
float opRound(float d, float r) {return d-r;}
float opOnion(float d, float o) {return abs(d)-o;}
float opWobble(vec2 uv, float wobble_freq, float wobble_amp) {return sin(TIME*wobble_freq + uv.x * 2.0+uv.y)*wobble_amp;}
float smin( float a, float b, float k ) {k *= log(2.0); float x = b-a; return a + x/(1.0-exp2(x/k));}

// UV Distortions
// : https://medium.com/@ohbonsai/2d-sdf-operation-3-space-manipulation-ef788b25497c
// : ** Claude Sonnet 4.5, 2025
vec2 uv_wobble(vec2 uv, float wobble_freq, float wobble_amp) {
	vec2 wobble = sin(uv.yx * wobble_freq) * wobble_amp;
	return uv + wobble;
}
vec2 uv_twist(vec2 uv, float amt, vec2 center) {
	// **
	vec2 q = uv-center;
	float dist = length(q);
	float angle = dist * amt;
	if (twist_type == 1) {angle = exp(dist) * amt;}
	float c = cos(angle);
	float s = sin(angle);
	mat2 rotation = mat2(vec2(c, -s), vec2(s, c));
	return rotation * q + center;
}
vec2 polar_coordinates(vec2 uv, vec2 center, float zoomm, float repeat) {
	vec2 dir = uv - center;
	float radius = length(dir) * 2.0;
	float angle = atan(dir.y, dir.x) * 1.0/(3.1416 * 2.0);
	return mod(vec2(radius * zoomm, angle * repeat), 1.0);
}
vec2 spherize(vec2 uv, vec2 center, float strength, vec2 offset) {
	// https://godotshaders.com/shader/uv-spherize/
	// Вектор от центра искажения к текущим UV
	vec2 delta = uv - center;
	// Квадрат длины вектора delta (эквивалент length(delta)^2)
	float delta2 = dot(delta.xy, delta.xy);
	// delta4 — четвёртая степень расстояния (усиливает искажение ближе к краям)
	float delta4 = delta2 * delta2;
	// Смещение вектора delta в зависимости от delta4 и силы
	vec2 delta_offset = vec2(delta4, delta4) * strength;
	// Добавляем искажение и смещение
	return uv + (delta * delta_offset) + offset;
}

// SDFs
// : https://iquilezles.org/articles/distfunctions2d/
// : https://godotshaders.com/snippet/polygons/
float sdCircle(vec2 uv, float radius) {return length(uv-0.5)-radius;}
float sdRect(vec2 uv, vec2 bound) {vec2 d = abs(uv-0.5)-bound;return length(max(d,0.0)) + min(max(d.x,d.y),0.0);}
float sdSquircle(vec2 uv, float radius) {
	radius += radius < 0.001 && radius > -0.001 ? TINYV : 0.0;
	// maybe clamp?
	uv -= 0.5;
	uv /= radius;
	uv = abs(uv); if(uv.y>uv.x) uv=uv.yx;

	float a = uv.x-uv.y;
	float b = uv.x+uv.y;
	float c = (2.0*b-1.0)/3.0;
	float h = a*a + c*c*c;
	float t;
	if(h>=0.0) {
		h = sqrt(h);
		t = sign(h-a)*pow(abs(h-a),1.0/3.0) - pow(h+a,1.0/3.0);
	} else {
		float z = sqrt(-c);
		float v = acos(a/(c*z))/3.0;
		t = -z*(cos(v)+sin(v)*1.732050808);
	}
	t *= 0.5;
	vec2 w = vec2(-t,t) + 0.75 - t*t - uv;
	return (length(w) * sign(a*a*0.5+b-1.5)) * radius;
}
float sdRhombus(vec2 uv, vec2 bounds) {
	uv -= 0.5;
	uv = abs(uv);
	bounds = max(bounds,vec2(0.0));
	float h = clamp(ndot(bounds-2.0*uv,bounds)/dot(bounds,bounds),-1.0,1.0);
	float d = length(uv-0.5*bounds*vec2(1.0-h,1.0+h));
	return d * sign(uv.x*bounds.y+uv.y*bounds.x-bounds.x*bounds.y);
}
float sdEquilateral(vec2 uv, float radius) { //Triangle...
	//radius = max(radius,0.0);
	uv -= 0.5;
	const float k = sqrt(3.0);
	uv.x = abs(uv.x) - radius;
	uv.y = uv.y + (radius/(k/2.) * 2./3.);
	//uv.y = uv.y + radius/k;
	if(uv.x+k*uv.y>0.0) {uv = vec2(uv.x-k*uv.y,-k*uv.x-uv.y)/2.0;}
	uv.x -= clamp(uv.x,-2.0*radius,0.0);
	return -length(uv)*sign(uv.y);
}
float sdIsosceles(vec2 uv, vec2 bounds) { // Triangle
	uv -= 0.5;
	uv.y += bounds.y / 2.0;
	uv.x = abs(uv.x);
	vec2 a = uv - bounds*clamp(dot(uv,bounds)/dot(bounds,bounds),0.0,1.0);
	vec2 b = uv - bounds*vec2(clamp(uv.x/bounds.x,0.0,1.0),1.0);
	float s = -sign(bounds.y);
	vec2 d = min(vec2(dot(a,a),s*(uv.x*bounds.y-uv.y*bounds.x)),
				vec2(dot(b,b),s*(uv.y-bounds.y)));
	return -sqrt(d.x)*sign(d.y);
}
float sdPolygon(vec2 uv, float radius, int sides) {
	//make this an sdf?
	uv -= 0.5;
	const float twopi = PI * 2.0;
	float an = twopi/float(sides);
	float he = radius*tan(0.5*an);
	uv = -uv.yx;
	float bn = an*floor((atan(uv.y,uv.x)+0.5*an)/an);
	vec2 cs = vec2(cos(bn),sin(bn));
	uv = mat2(vec2(cs.x,-cs.y),vec2(cs.y,cs.x))*uv;
	return length(uv-vec2(radius,clamp(uv.y,-he,he)))*sign(uv.x-radius);
}
float sdStar(vec2 uv, float radius, float bend, int sides) {
	// bend is like the webbing between arms of the star
	uv -= 0.5;
	float m = bend + float(sides)*(2.0-bend);
	float an = PI/float(sides);
	float en = PI/m;
	vec2 acs = vec2(cos(an),sin(an));
	vec2 ecs = vec2(cos(en),sin(en));

	float bn = mod(atan(uv.x,uv.y),2.0*an) - an;
	uv = length(uv)*vec2(cos(bn),abs(sin(bn)));
	uv -= radius*acs;
	uv += ecs*clamp(-dot(uv,ecs),0.0,radius*acs.y/ecs.y);
	return length(uv)*sign(uv.x);
}
float sdCompoundStar(vec2 uv, float radius, float bend, int sides, float thickness) {
	// returns a star morphed with a circle (of the same size) by thickness
	float star = sdStar(uv,radius,bend,sides);
	float circle = sdCircle(uv,radius);
	return mix(star,circle,thickness);
	}
float sdCross(vec2 uv, float radius, vec2 bounds) {
	float box1 = sdRect(uv,vec2(radius,bounds.x));
	float box2 = sdRect(uv,vec2(bounds.y,radius));
	return min(box1,box2);
}
float sdRoundCross(vec2 uv, float radius, float width) {
	uv -= 0.5;
	uv = abs(uv);
	return length(uv-min(uv.x+uv.y,radius)*0.5)-width;
}
float sdObliqueCross(vec2 uv, float radius, float radius2, float thickness, vec2 rotations, int sides) {
	// returns two-four rhombus combined with a smooth min
	switch (sides) {
		case 8:
			// 8 quad
			float rhombA = sdRhombus(rotate(uv,vec2(0.5),radians(rotations.x) + radians(90)),vec2(.005 * thickness,radius));
			float rhombB = sdRhombus(rotate(uv,vec2(0.5),radians(rotations.y) + radians(45)),vec2(.005 * thickness,radius * radius2));
			float rhombC = sdRhombus(rotate(uv,vec2(0.5),radians(rotations.x * 2.0) + radians(-67.5)),vec2(.005 * thickness,radius * (radius2 * 0.875)));
			float rhombD = sdRhombus(rotate(uv,vec2(0.5),radians(rotations.y * 2.0) - radians(-11.25)),vec2(.005 * thickness,radius * 0.875));
			return smin(smin(rhombA,rhombB,0.01),smin(rhombC,rhombD,0.01),0.01);
		case 6:
			// 6 triple
			float rhombA = sdRhombus(rotate(uv,vec2(0.5),radians(rotations.x) + radians(90)),vec2(.005 * thickness,radius));
			float rhombB = sdRhombus(rotate(uv,vec2(0.5),radians(rotations.y) + radians(45)),vec2(.005 * thickness,radius * radius2));
			float rhombC = sdRhombus(rotate(uv,vec2(0.5),radians(rotations.x * 2.0) + radians(-67.5)),vec2(.005 * thickness,radius * (radius2 * 0.875)));
			return smin(smin(rhombA,rhombB,0.01),rhombC,0.01);
		default:
			// 4 standard
			float rhombA = sdRhombus(rotate(uv,vec2(0.5),radians(rotations.x) + radians(90)),vec2(.005 * thickness,radius));
			float rhombB = sdRhombus(rotate(uv,vec2(0.5),radians(rotations.y) + radians(45)),vec2(.005 * thickness,radius * radius2));
			return smin(rhombA,rhombB,0.01);
	}
}
float sdClover(vec2 uv, float radius, vec2 control) {
	radius = max(radius,0.0 + TINYV);
	control = max(control,vec2(0.0));
	uv -= 0.5;
	uv /= radius;
	uv = abs(uv);
	float he = control.x;
	uv = vec2(abs(uv.x-uv.y),1.0-uv.x-uv.y)/sqrt(2.0);
	float p = (he-uv.y-0.25/he)/(6.0*he);
	float q = uv.x/(he*he*16.0);
	float h = q*q - p*p*p;
	float x;
	if (h > 0.0) {float r = sqrt(h); x = pow(q+r,1.0/3.0)-pow(abs(q-r),1.0/3.0)*sign(r-q);}
	else {float r = sqrt(p); x = 2.0*r*cos(acos(q/(p*r))/3.0);}
	x = min(x,sqrt(2.0)/2.0);
	vec2 z = vec2(x,he*(1.0-2.0*x*x)) - uv;
	return (length(z) * sign(z.y) * radius) - control.y;
}
float sdHeart(vec2 uv, float radius) {
	radius += radius < 0.001 && radius > -0.001 ? TINYV : 0.0;
	uv = rotate(uv,vec2(0.5),radians(270));
	uv -= 0.5;
	uv.y += radius / 1.5;
	uv /= radius;
	uv.x = abs(uv.x);
	if (uv.y+uv.x > 1.0) {return (sqrt(dot2(uv-vec2(0.25,0.75))) - sqrt(2.0)/4.0) * radius;}
	return sqrt(min(dot2(uv-vec2(0.0,1.0)),dot2(uv-0.5*max(uv.x+uv.y,0.0)))) * sign(uv.x-uv.y) * radius;
}
float sdArc(vec2 uv, float radius, float angle, float thickness) {
	uv -= 0.5;
	angle = radians(angle / 2.0);
	vec2 sc = vec2(sin(angle),cos(angle));
	uv.x = abs(uv.x);
	return ((sc.y*uv.x>sc.x*uv.y) ? length(uv-sc*radius) : abs(length(uv)-radius)) - thickness;
}
float sdRing(vec2 uv, float radius, float angle, float thickness) {
	uv -= 0.5;
	angle = radians(angle / 2.0);
	vec2 n = vec2(sin(angle),cos(angle));
	uv.x = abs(uv.x);
	uv = mat2(vec2(n.x,n.y),vec2(-n.y,n.x))*uv;
	return max(abs(length(uv)-radius)-thickness*0.5,length(vec2(uv.x,max(0.0,abs(radius-uv.y)-thickness*0.5)))*sign(uv.x));
}
float sdSegment(vec2 uv, vec2 a, vec2 b) {
	vec2 pa = uv-a; 
	vec2 ba = b-a;
	float h = clamp(dot(pa,ba)/dot(ba,ba),0.0,1.0);
	return length(pa-ba*h);
}
float sdVerticalCapsule( vec2 p, float h, float r ){
	p.y -= clamp( p.y, 0.0, h );
	return length( p ) - r; 
}
float sdZ(vec2 pos, float thickness){
	// Thank you dottedboxguy 
	// https://www.shadertoy.com/view/XfjBWt
	pos -= 0.5;
	vec2 p = pos;
	p.y=abs(p.y-.05);
	//serif only supports so many thicknesses sadly
	float serif = sdEquilateral(scale(rotate(pos+vec2(0.33,0.72),vec2(0.5),radians(200)),1.0/2.0,1.0),0.05);
	float serif2 = sdEquilateral(scale(rotate(pos+vec2(0.68,0.18),vec2(0.5),radians(150)),1.0/2.0,1.0),0.05);
	return smin(min(
		sdVerticalCapsule(p.yx-vec2(.35, -.175), .35, thickness),
		sdSegment(pos, vec2(-.175, -.3), vec2(.175, .4))-thickness),min(serif,serif2),0.02);
}


float easeOutExpo(float x) {
	return 1.0 - pow(2.0, -10.0 * x);
}

float easeInExpo(float x) {
	return pow(2.0, 10.0 * x - 10.0);
}

float easeInOutExpo(float x) {
	float result;
	if (x == 0.0) {result = 0.0;}
	else if (x == 1.0) {result = 1.0;}
	else if (x < 0.5) {result = pow(2.0, 20.0 * x - 10.0) / 2.0;}
	else {result = (2.0 - pow(2.0, -20.0 * x + 10.0)) / 2.0;}
	return result;
}

float easeInCubic(float x) {
	return x * x * x;
}

float easeOutCubic(float x) {
	return 1.0 - pow(1.0 - x,3.0);
}

float easeInOutCubic(float x) {
	return x < 0.5 ? 4.0 * x * x * x : 1.0 - pow(-2.0 * x + 2.0,3.0) / 2.0;
}

float easeOutInCubic(float x) {
	return (4.0 * pow(x-0.5,3.0)) + 0.5;
}

float cos_wve(float x) {
	return -cos(x*2.*PI)*.5+.5;
}
float sin_wve(float x) {
	return -sin(x*2.*PI)*.5+.5;
}

float get_progress() {
	float p;
	float final;
	if (derive_progress == 2) {p = LIFETIME;}
	else if (derive_progress == 0) {p = mod(TIME * time_scale,1.0);}
	// abs(sin(TIME * time_scale)) [Back and Forth]
	// mod(TIME * time_scale,1.0) [Over and Over]
	else {p = progress;}
	
	if (ease_progress == 4) {final = easeInOutExpo(p);} //EASE IN OUT (2.0)
	else if (ease_progress == 0) {final = texture(custom_ease,vec2(p,0.0)).r;} //CUSTOM EASE (-2.0)
	else if (ease_progress == 3) {final = 1.0 - pow(2.0, -10.0 * p);} //EASE OUT (1.0)
	else if (ease_progress == 1) {final = pow(2.0, 10.0 * p - 10.0);} //EASE IN (-1.0)
	else {final = p;}
	
	switch (ping_pong) {
		case 1: return cos_wve(final);
		case 2: return sin_wve(final);
		default: return final;
	}
	
	return final;
}

vec4 get_rainbow(vec2 uv) {
	vec4 animated_color = 
		vec4(r_light_offset + sin((2.0*3.14+INDEX/PI)*r_sin_frequency*(TIME * r_time_scale)),
			r_light_offset + sin((2.0*3.14+INDEX/PI)*r_sin_frequency*(TIME * r_time_scale) + radians(120.0)),
			r_light_offset + sin((2.0*3.14+INDEX/PI)*r_sin_frequency*(TIME * r_time_scale) + radians(240.0)),
			1.0);
	float mask = uv2mask(uv,rainbow_bias,1.0,rbias_edge);
	return animated_color * vec4(vec3(rainbow_str),1.0) * vec4(vec3(mask),1.0);
}

vec2 scaleb(vec2 uv, float x, float y, vec2 from) {
	mat2 scale = mat2(vec2(x, 0.0), vec2(0.0, y));
	//uv -= 0.5;
	uv -= from;
	uv = uv * scale;
	//uv += 0.5;
	uv += from;
	return uv;
}

vec2 scale_anim(vec2 uv, int preset, float prg) {
	vec2 nuv = uv;
	vec2 from = vec2(0.0);
	// normal wave = -cos(x*2.*PI)*.5+.5
	// linear wave = (2./PI) * asin(-cos(x*2.*PI))*.5+.5
	if (prg >= 0.5) {from = vec2(1.0);}
	switch (preset) {
		case 0: return nuv;
		case 1:
			float s = max(cos_wve(prg),1./4096.);
			nuv = scaleb(nuv,1.0/s,1.0,from); break;
		case 2:
			float s = max(cos_wve(min(prg,0.5)),1./4096.);
			nuv = scaleb(nuv,1.0/s,1.0,from); break;
		case 3:
			float s = max(cos_wve(max(prg,0.5)),1./4096.);
			nuv = scaleb(nuv,1.0/s,1.0,from); break;
		case 4:
			float s = max(cos_wve(prg),1./4096.);
			nuv = scaleb(nuv,1.0,1.0/s,from); break;
		case 5:
			float s = max(cos_wve(min(prg,0.5)),1./4096.);
			nuv = scaleb(nuv,1.0,1.0/s,from); break;
		case 6:
			float s = max(cos_wve(max(prg,0.5)),1./4096.);
			nuv = scaleb(nuv,1.0,1.0/s,from); break;
	}
	return nuv;
}

float feed_chrono() {
	float p;
	if (derive_progress == 2) {p = LIFETIME;}
	else if (derive_progress == 0) {p = mod(TIME * time_scale,1.0);}
	// abs(sin(TIME * time_scale)) [Back and Forth]
	// mod(TIME * time_scale,1.0) [Over and Over]
	else {p = progress;}
	
	switch (ping_pong) {
		case 1: return cos_wve(p);
		case 2: return sin_wve(p);
		default: return p;
	}
	
	return p;
}

void vertex() {
	// Called for every vertex the material is visible on.
	LIFETIME = INSTANCE_CUSTOM.y;
	INDEX = float(INSTANCE_ID);
	PARTICLE = int(INDEX);
	if (custom_index != 0) {
		INDEX = float(custom_index);
		PARTICLE = custom_index;
	}
	
	// hint_enum("None","Time","Progress","prg Ease In","prg Ease Out",
	// "prg Ease In Out","prg Ease Out In","prg Custom A","prg Custom B","prg Custom C","prg Custom D");
	
	float fc = feed_chrono();
	CHRONOGRAPH[0] = 0.0;
	CHRONOGRAPH[1] = TIME;
	CHRONOGRAPH[2] = get_progress();
	CHRONOGRAPH[3] = easeInCubic(fc);
	CHRONOGRAPH[4] = easeOutCubic(fc);
	CHRONOGRAPH[5] = easeInOutCubic(fc);
	CHRONOGRAPH[6] = easeOutInCubic(fc);
	CHRONOGRAPH[7] = texture(custom_a,vec2(fc,0.0)).r;
	CHRONOGRAPH[8] = texture(custom_b,vec2(fc,0.0)).r;
	CHRONOGRAPH[9] = texture(custom_c,vec2(fc,0.0)).r;
	CHRONOGRAPH[10] = texture(custom_d,vec2(fc,0.0)).r;
	
	float r = random(vec2(float(PARTICLE)));
	float r2 = (random(vec2(float(PARTICLE))) - 0.5) * 2.0;
	
	//vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
	
	vec2 tv = VERTEX - vec2(0.5) * texture_size;
	tv *= rescale_vertex;
	VERTEX = tv + vec2(0.5) * texture_size;
	VERTEX += mix(mesh_offset,final_mesh_offset,CHRONOGRAPH[mesh_offset_driver]);
	
	float rot_rand = radians(index_rand_mesh_rot) * r2;
	if (maintain_irm_domain) { rot_rand = radians(index_rand_mesh_rot) * r;}
	float rotation_offset = radians(mesh_rotation) + (animate_mesh_rotation * CHRONOGRAPH[animate_mesh_rot_with]) + rot_rand;
	
	vec2 pos = VERTEX - vec2(0.5) * texture_size;
	mat2 rotation_matrix = mat2(vec2(cos(rotation_offset),-sin(rotation_offset)),vec2(sin(rotation_offset),cos(rotation_offset)));
	pos = rotation_matrix * pos;
	VERTEX = pos + vec2(0.5) * texture_size;
	
	// PERSPECTIVE
	float rot_y_rad = radians(rot_y_deg);
	float rot_x_rad = radians(rot_x_deg);

	float sin_y = sin(rot_y_rad), cos_y = cos(rot_y_rad);
	float sin_x = sin(rot_x_rad), cos_x = cos(rot_x_rad);

	// Construct rotation matrix
	mat3 rotation_matrix3d;
	rotation_matrix3d[0] = vec3(cos_y, 0.0, -sin_y);
	rotation_matrix3d[1] = vec3(sin_y * sin_x, cos_x, cos_y * sin_x);
	rotation_matrix3d[2] = vec3(sin_y * cos_x, -sin_x, cos_y * cos_x);

	// Project UV coordinates into pseudo-3D space
	float perspective_scale = tan(radians(fov) * 0.5);
	world_pos_3d = rotation_matrix3d * vec3(UV - 0.5, 0.5 / perspective_scale);

	// Adjust XY coordinates based on perspective depth
	float depth_scale = (0.5 / perspective_scale) + 0.5;
	world_pos_3d.xy *= depth_scale * rotation_matrix3d[2].z;
	vp_offset = depth_scale * rotation_matrix3d[2].xy;

	// Apply perspective transformation to vertex position 
	VERTEX += (UV - 0.5) / TEXTURE_PIXEL_SIZE * perspective_scale * (1.0 - inset);
}

float get_texture_mask(vec2 uv, sampler2D tex, vec2 edge_autograd, vec4 prg_str_edge, vec4 tex_scale_scroll, vec4 polarize) {
	vec2 mscl = 1.0/tex_scale_scroll.xy; //scale
	vec2 msrl = tex_scale_scroll.zw; //scroll
	
	if (polarize.w > 0.0) {
		uv = polar_coordinates(uv,polarize.xy,polarize.z,polarize.w);}
	uv = scale(uv,mscl.x,mscl.y);
	uv += msrl;
	
	float mask = texture(tex,uv).r;
	mask -= edge_autograd.y; // originally *=
	mask = clamp(mask,0.0,1.0);
	mask = pow(mask,prg_str_edge.y);
	
	switch (int(edge_autograd.x)) {
		case 0: return 1.0;
		case 1: return mask;
		case 2: mask = smoothstep(prg_str_edge.z,prg_str_edge.w,mask); break;
		case 3: mask = step(prg_str_edge.z,mask); break;
	}
	
	return mask;
}

vec2 get_texture_distort(vec2 uv, sampler2D tex, vec2 prg_str, vec4 tex_scale_scroll, vec4 polarize) {
	// To distort UV properly, you need to use two channels
	// You can get two channels (kinda) from one texture by sampling it twice and flipping the second sample
	vec2 dscl = 1.0/tex_scale_scroll.xy; //scale
	vec2 dsrl = tex_scale_scroll.zw; //scroll
	
	if (polarize.w > 0.0) {
		uv = polar_coordinates(uv,polarize.xy,polarize.z,polarize.w);}
	uv = scale(uv,dscl.x,dscl.y);
	uv += dsrl;
	
	vec2 distort = (vec2(texture(tex,uv).r,texture(tex,1.0-uv.yx).g) - 0.5) * 2.0;
	distort *= prg_str.y * 0.1;
	return distort;
}

float idx_to_shape(vec2 uv, int index, int ot) {
	// ot (shape one or two)
	//"Circle","Rect","Squircle",
	//"Rhombus","Equilateral","Isosceles",
	//"Polygon","Star","Cross",
	//"Round Cross","Clover","Heart","Arc",
	//"Ring","Segment"
	float size = mix(
		mix(shape_sizei.x,shape_sizei.y,CHRONOGRAPH[shape_szi_driver]),
		mix(shape_sizef.x,shape_sizef.y,CHRONOGRAPH[shape_szf_driver]),
		float(ot)
	);
	float size_b = mix(
		mix(shape_sizeib.x,shape_sizeib.y,CHRONOGRAPH[shape_szib_driver]),
		mix(shape_sizefb.x,shape_sizefb.y,CHRONOGRAPH[shape_szfb_driver]),
		float(ot)
	);
	int sides = ot < 1 ? shape_sidesi : shape_sidesf;
	float thickness = mix(
		mix(shape_thicki.x,shape_thicki.y,CHRONOGRAPH[shape_thicki_driver]),
		mix(shape_thickf.x,shape_thickf.y,CHRONOGRAPH[shape_thickf_driver]),
		float(ot)
	);
	vec2 extra = mix(
		mix(shape_extrai.xy,shape_extrai.zw,CHRONOGRAPH[shape_extrai_driver]),
		mix(shape_extraf.xy,shape_extraf.zw,CHRONOGRAPH[shape_extraf_driver]),
		float(ot)
	);
	vec2 scale_amt = mix(
		shape_sri.xy,
		shape_srf.xy,
		float(ot)
	);
	scale_amt.x += scale_amt.x < 0.001 && scale_amt.x > -0.001 ? TINYV : 0.0;
	scale_amt.y += scale_amt.y < 0.001 && scale_amt.y > -0.001 ? TINYV : 0.0;
	float rotation_amt = mix(
		shape_sri.z,
		shape_srf.z,
		float(ot)
	);
	uv = scale(rotate(uv,vec2(0.5),radians(rotation_amt) + radians(90.)),1.0/scale_amt.x,1.0/scale_amt.y);
	switch (index) {
		case 0: 	return sdCircle(uv,size);
		case 1: 	return sdRect(uv,vec2(size,size_b));
		case 2: 	return sdSquircle(uv,size);
		case 3: 	return sdRhombus(uv,vec2(size,size_b));
		case 4: 	return sdEquilateral(uv,size);
		case 5: 	return sdIsosceles(uv,vec2(size,size_b));
		case 6: 	return sdPolygon(uv,size,sides);
		case 7: 	return sdStar(uv,size,min(1.1+size_b,2.1),sides);
		case 8: 	return sdCompoundStar(uv,size,size_b,sides,thickness);
		case 9: 	return sdCross(uv,size,extra);
		case 10: 	return sdRoundCross(uv,size,size_b);
		case 11: 	return sdObliqueCross(uv,size,size_b,thickness,extra,sides);
		case 12: 	return sdClover(uv,size,extra);
		case 13: 	return sdHeart(uv,size);
		case 14: 	return sdArc(uv,size,size_b,thickness / 20.0);
		case 15: 	return sdRing(uv,size,size_b,thickness / 20.0);
		case 16: 	return sdSegment(uv,vec2(size,size_b),extra);
		case 17: 	return sdZ(uv,thickness);
	}
}

float get_shape(vec2 uv) {
	float sr = mix(shape_rounding.x,shape_rounding.y,CHRONOGRAPH[shape_rounding_driver]);
	vec2 gtra = mix(shp_glb_translate.xy,shp_glb_translate.zw,CHRONOGRAPH[shp_glb_trans_driver]);
	vec2 gscl = (1.0/mix(shp_glb_scale.xy,shp_glb_scale.zw,CHRONOGRAPH[shp_glb_scl_driver])) + (sr * 3.);
	float grot = mix(shp_glb_rotate.x,shp_glb_rotate.y,CHRONOGRAPH[shp_glb_rot_driver]);
	
	uv += gtra; // translate
	uv = scale(uv,gscl.x,gscl.y); // scale
	uv = rotate(uv,vec2(0.5),radians(grot) + radians(90.)); // rotate
	
	//uv = uv_wobble(uv,wobble.x,wobble.y);
	uv = uv_twist(uv,mix(shape_twist.x,shape_twist.y,CHRONOGRAPH[shape_twist_driver]),vec2(0.5));
	
	float si = idx_to_shape(scale_anim(uv,shp_scale_anim,CHRONOGRAPH[shp_scale_anim_driver]),shapei,0);
	float sf = idx_to_shape(scale_anim(uv,shp_scale_anim,CHRONOGRAPH[shp_scale_anim_driver]),shapef,1);
	float morph = mix(shape_morph.x,shape_morph.y,CHRONOGRAPH[shape_morph_driver]);
	vec2 wobble = mix(wobble_freq_amp.xy,wobble_freq_amp.zw,CHRONOGRAPH[wfa_driver]);
	vec2 wuv = rotate(uv,vec2(0.5),radians(mix(wobble_rot.x,wobble_rot.y,CHRONOGRAPH[wrot_driver])));
	float sm = mix(si,sf,morph);
	sm += opWobble(wuv,wobble.x,wobble.y / 20.0);
	if (apply_onion == 1) {sm = opOnion(sm,mix(shape_onion.x,shape_onion.y,CHRONOGRAPH[shape_onion_driver]) / 20.0);}
	sm = opRound(sm,sr);
	if (apply_onion == 2) {sm = opOnion(sm,mix(shape_onion.x,shape_onion.y,CHRONOGRAPH[shape_onion_driver]) / 20.0);}
	float feather = mix(shape_feather.x,shape_feather.y,CHRONOGRAPH[shape_feather_driver]) / 20.0;
	sm = feather >= 0.0 ? 1.0-shapestep(feather_falloff,0.0,feather,sm,feather_falloff_control) : shapestep(feather_falloff,0.0,feather,sm,feather_falloff_control);
	return sm;
}

float get_overlap(vec2 uv) {
	float sr = mix(shape_rounding.x,shape_rounding.y,CHRONOGRAPH[shape_rounding_driver]);
	vec2 gtra = mix(shp_glb_translate.xy,shp_glb_translate.zw,CHRONOGRAPH[shp_glb_trans_driver]);
	gtra += mix(overlap_offset.xy,overlap_offset.zw,CHRONOGRAPH[overlap_offset_driver]);
	vec2 gscl = (1.0/mix(shp_glb_scale.xy,shp_glb_scale.zw,CHRONOGRAPH[shp_glb_scl_driver])) + (sr * 3.);
	gscl *= 1.0/(mix(overlap_percent.x,overlap_percent.y,CHRONOGRAPH[overlap_percent_driver]) + EPSILON);
	float grot = mix(shp_glb_rotate.x,shp_glb_rotate.y,CHRONOGRAPH[shp_glb_rot_driver]);
	
	uv += gtra; // translate
	uv = scale(uv,gscl.x,gscl.y); // scale
	uv = rotate(uv,vec2(0.5),radians(grot) + radians(90.)); // rotate
	
	//uv = uv_wobble(uv,wobble.x,wobble.y);
	uv = uv_twist(uv,mix(shape_twist.x,shape_twist.y,CHRONOGRAPH[shape_twist_driver]),vec2(0.5));
	
	float si = idx_to_shape(uv,shapei,0);
	float sf = idx_to_shape(uv,shapef,1);
	float morph = mix(shape_morph.x,shape_morph.y,CHRONOGRAPH[shape_morph_driver]);
	vec2 wobble = mix(wobble_freq_amp.xy,wobble_freq_amp.zw,CHRONOGRAPH[wfa_driver]);
	vec2 wuv = rotate(uv,vec2(0.5),radians(mix(wobble_rot.x,wobble_rot.y,CHRONOGRAPH[wrot_driver])));
	float sm = mix(si,sf,morph);
	sm += opWobble(wuv,wobble.x,wobble.y / 20.0);
	if (apply_onion == 1) {sm = opOnion(sm,mix(shape_onion.x,shape_onion.y,CHRONOGRAPH[shape_onion_driver]) / 20.0);}
	sm = opRound(sm,sr);
	if (apply_onion == 2) {sm = opOnion(sm,mix(shape_onion.x,shape_onion.y,CHRONOGRAPH[shape_onion_driver]) / 20.0);}
	float feather = mix(overlap_feather.x,overlap_feather.y,CHRONOGRAPH[overlap_feather_driver]) / 20.0;
	sm = feather >= 0.0 ? 1.0-shapestep(feather_falloff,0.0,feather,sm,feather_falloff_control) : shapestep(feather_falloff,0.0,feather,sm,feather_falloff_control);
	return sm;
}

float get_image(vec2 uv) {
	float shape = get_shape(uv);
	float overlap = get_overlap(uv);
	switch (apply_overlap) {
		case 0: return shape;
		case 1: return clamp(shape + overlap,0.0,1.0);
		case 2: return clamp(shape - overlap,0.0,1.0);
	}
}

vec4 chroma_rearrange(int r, vec4 o) {
	// "rgb","rbg","grb","gbr","brg","bgr","rrb","rrg","ggr","ggb","bbr","bbg"
	switch (r) {
		case 0: 	return o.rgba;
		case 1: 	return o.rbga;
		case 2: 	return o.grba;
		case 3: 	return o.gbra;
		case 4: 	return o.brga;
		case 5: 	return o.bgra;
		case 6: 	return o.raba;
		case 7: 	return o.raga;
		case 8: 	return o.gara;
		case 9: 	return o.gaba;
		case 10: 	return o.bara;
		case 11: 	return o.baga;
	}
}

//vec4 get_shape_splits(vec2 uv) {
	//// Chromatic Aberration
	//// Super bad for performance lol and not that cool honestly due to how alpha works in this shader...
	//// https://mini.gmshaders.com/p/gm-shaders-mini-chromatic-aberration
	//vec4 chroma_sum = vec4(0.0);
	//vec4 weight_sum = vec4(0.0);
	//vec2 chroma_uv = uv;//scale(uv,0.01,0.01)-0.5;
	//for (float i = 0.0; i <= 1.0; i += 1.0/float(chroma_samples)) {
		//vec2 ca_uv;
		//switch (apply_chroma) {
			//case 1: ca_uv = chroma_uv + (i-0.5) * chroma_offset; break;
			//case 2: ca_uv = mix(chroma_uv,vec2(0.5),(i-0.5) * chroma_offset); break;
			//case 3: ca_uv = chroma_uv + vec2(chroma_uv.y-0.5,0.5-chroma_uv.x) * (i-0.5) * chroma_offset; break;
		//}
		//vec4 ca_color = vec4(get_image(ca_uv));
		//vec4 ca_weight = vec4(
			//i, //R
			//1.0-abs(i*2.0-1.0), //G
			//1.0-i, //B
			//0.5 //A
		//) + (tweak_chroma_weight);
		//ca_weight = pow(chroma_rearrange(chroma_arrangement,ca_weight),vec4(abs(chroma_power)));
		//chroma_sum += ca_color * ca_color * ca_weight;
		//weight_sum += ca_weight;
	//}
	////weight_sum *= 2.0;
	//vec4 chroma_split = sqrt(chroma_sum/weight_sum);
	//switch (gray_chroma) {
		//case 1: chroma_split.rgb = vec3(grayscale(chroma_split.rgb,0)); break;
		//case 2: chroma_split.rgb = vec3(grayscale(chroma_split.rgb,1)); break;
	//}
	////col = grayscale(chroma_split.rgb,0);
	//return clamp(chroma_split,-1.0,1.0);
//}

void fragment() {
	// Called for every pixel the material is visible on.
	if (cull_backface && world_pos_3d.z <= 0.0) discard;
	vec2 projected_uv = (world_pos_3d.xy / world_pos_3d.z) - vp_offset + 0.5;
	if (projected_uv.x < 0.0 || projected_uv.x > 1.0 || projected_uv.y < 0.0 || projected_uv.y > 1.0)
		discard;

	//vec2 rUV = rotate(UV,vec2(0.5),radians(TIME*80.0));
	//float fa1 = 0.0;
	//vec2 fa2 = vec2(0.0);
	float fa1 = mix(fisheye_str.x,fisheye_str.y,CHRONOGRAPH[fisheye_str_driver]);
	vec2 fa2 = mix(fisheye_offset.xy,fisheye_offset.zw,CHRONOGRAPH[fisheye_offset_driver]);
	vec2 auv = spherize(projected_uv,vec2(0.5),fa1,fa2);
	
	vec2 tuv = uv_twist(auv,mix(shape_twist.x,shape_twist.y,CHRONOGRAPH[shape_twist_driver]),vec2(0.5));
	
	// DISTORTION
	vec2 distort = vec2(0.0);
	if (apply_distortion == 1) {
		vec2 distortuv = distortion_factor_twist == true ? tuv : auv;
		distort = get_texture_distort(distortuv,distort_texture,
			vec2(get_progress(),mix(distort_str.x,distort_str.y,CHRONOGRAPH[distort_str_driver])),
			vec4(
				mix(scale_distortion.xy,scale_distortion.zw,CHRONOGRAPH[distort_scale_driver]),
				floor_distort_scroll < 1.0 ? mix(scroll_distortion.xy,scroll_distortion.zw,CHRONOGRAPH[distort_scroll_driver])
				: floor(mix(scroll_distortion.xy,scroll_distortion.zw,CHRONOGRAPH[distort_scroll_driver]) * floor_distort_scroll) / floor_distort_scroll
			), polarize_distortion
		);
		distort *= uv2mask(auv,apply_dist_mask,dist_mask_power,distmask_edge);
	}
	
	// SHAPING + CHROMA
	vec4 shape = vec4(get_image(auv + distort));
	//if (apply_chroma != 0 && chroma_samples != 0) {shape = get_shape_splits(auv + distort);}
	shape *= mix(shape_energy.x,shape_energy.y,CHRONOGRAPH[shp_energy_driver]);
	float shapeshade = grayscale(shape.rgb,1);
	
	// MASKING
	float mask = 1.0;
	//if (apply_mask != 0) {
		//vec2 maskuv = mask_factor_twist == true ? tuv : auv;
		//float autograd = apply_mask_autograd != 0 ? uv2mask(auv,apply_mask_autograd,mask_autograd_power,maskag_edge) : 0.0;
		////autograd = shapestep(maskag_interp,0.0,1.0,autograd,maskag_interp_control);
		//vec2 mask_distort = mask_factor_distortion == true ? distort : vec2(0.0);
		//mask = get_texture_mask(maskuv + mask_distort, mask_texture, vec2(float(apply_mask),autograd),
			//vec4(get_progress(),mix(mask_str.x,mask_str.y,CHRONOGRAPH[mask_str_driver]),
			//mix(mask_edge.xy,mask_edge.zw,CHRONOGRAPH[mask_edge_driver])),
			//vec4(
				//mix(scale_mask.xy,scale_mask.zw,CHRONOGRAPH[mask_scale_driver]),
				//floor_mask_scroll < 1.0 ? mix(scroll_mask.xy,scroll_mask.zw,CHRONOGRAPH[mask_scroll_driver])
				//: floor(mix(scroll_mask.xy,scroll_mask.zw,CHRONOGRAPH[mask_scroll_driver]) * floor_mask_scroll) / floor_mask_scroll
			//), polarize_mask
		//);
	//}
	float simple_mask = 1.0;
	if (use_simple_mask != 0) {
		simple_mask = uv2mask(projected_uv,use_simple_mask,simple_mask_power,simplem_edge);
	}
	
	// GRADIENT MAPPING
	//float shift_mod = 1.0;
	//float gbs = mix(gbias_str.x,gbias_str.y,CHRONOGRAPH[gb_str_driver]);
	//shift_mod *= gradient_bias != 0 ? uv2mask(UV,gradient_bias,gbs,vec2(0.0,1.0)) : 0.0; //TODO add edge to gbias
	//shift_mod += mix(gbias_shift.x,gbias_shift.y,CHRONOGRAPH[gb_shift_driver]);
	//float gm_shift = mix(shift_gradient.x,shift_gradient.y,CHRONOGRAPH[shift_gradient_driver]);
	//float gm_sample = shapeshade * mask;
	//if (chunky_color > 0) {gm_sample = floor(gm_sample * float(chunky_color)) / float(chunky_color);}
	//vec4 gm_color = texture(color_gradient,vec2(gm_sample + gm_shift,0.0) + shift_mod);
	
	vec4 gm_color = vec4(1.0);
	switch (apply_rainbow) {
		case 1: //mul?
			gm_color *= get_rainbow(UV);
			break;
		case 2: //add
			gm_color += get_rainbow(UV);
			break;
		case 3: //replace
			gm_color = get_rainbow(UV);
			break;
	}
	
	COLOR.rgb = shape.rgb * gm_color.rgb * mask * COLOR.rgb;
	if (simple_only_alpha == false) {COLOR.rgb *= simple_mask;}
	//ALBEDO = vec3(simple_mask);
	//ALBEDO = vec3(mask);
	float alpha = smoothstep(0.0,tweak_alpha/10.0,shapeshade * mask * simple_mask) * gm_color.a * COLOR.a;
	if (step_alpha > 1.0) {alpha = floor(alpha * step_alpha) / step_alpha;}
	
	COLOR.a *= clamp(alpha,0.0,1.0);
	COLOR.a *= emission_intensity;
}
