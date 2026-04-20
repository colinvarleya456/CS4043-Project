shader_type canvas_item;

uniform float health_percent = 1.0;
uniform vec4 vignette_color : source_color = vec4(0.8, 0.0, 0.0, 1.0);
uniform float intensity = 1.0;
uniform float radius = 0.55;
uniform float softness = 0.35;

void fragment() {
    vec2 center = UV - vec2(0.5, 0.5);
    float dist = length(center) * 2.0;
    float low_health = 1.0 - health_percent;
    float edge = smoothstep(radius, radius + softness, dist);
    float alpha = edge * low_health * intensity * vignette_color.a;
    COLOR = vec4(vignette_color.rgb, alpha);
}
