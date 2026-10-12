shader_type canvas_item;

uniform float y_speed = 1.0;
uniform float x_speed = 1.0;

uniform vec4 modulate_color : source_color = vec4(1.0);

void fragment() {
    vec2 uv = UV;
    uv += vec2(x_speed, y_speed) * TIME;

    vec4 tex = texture(TEXTURE, uv);

    COLOR = tex * modulate_color;
}
