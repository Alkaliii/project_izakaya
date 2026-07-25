shader_type canvas_item;

uniform int modulate_on_step : hint_enum("NONE","X", "Y", "XY");
uniform vec4 modu : source_color = vec4(1.0);
uniform float modu_step = 3.0;
group_uniforms Sine;
uniform bool do_abs;
uniform bool do_quantize;
uniform float quantize_to : hint_range(0, 2, 0.1) = 1;
uniform vec2 sine_amplitude = vec2(1.0, 0.0);
uniform vec2 sine_speed = vec2(1.0, 0.0);

void vertex() {
	vec2 s = sin(TIME * sine_speed);
	if (do_abs) {
		s = abs(s);
	}
	VERTEX += s * sine_amplitude;
	if (do_quantize) {
		VERTEX = round(VERTEX / quantize_to);
		VERTEX *= quantize_to;
	}
}

void fragment() {
	vec4 col = texture(TEXTURE,UV);
	vec2 s = sin(TIME * sine_speed);
	if (do_abs) {s = abs(s);}
	if (modu_step > 1.0) {s = round(s * modu_step) / modu_step;}
	switch (modulate_on_step) {
		case 1: 
			col = mix(col,modu,s.x);
			break;
		case 2: 
			col = mix(col,modu,s.y);
			break;
		case 3: 
			col = mix(col,modu,(s.x * s.y) / 2.0);
			break;
	}
	COLOR.rgb = col.rgb;
	COLOR.a *- col.a;
}