vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
    vec2 coords_centered = coords_curr_geo.xy - 0.5;
    vec2 coords_sign = sign(coords_centered);
    vec2 coords_normalized = abs(coords_centered) * 2.0;

    vec2 prev_scale = vec2(niri_curr_geo_to_prev_geo[0][0], niri_curr_geo_to_prev_geo[1][1]);
    vec2 prev_coords = coords_normalized * prev_scale - (prev_scale - 1.0);

    float prev_distance = prev_coords.x + prev_coords.y;
    float min_prev_distance = 1.0 - max(prev_scale.x, prev_scale.y);

    prev_coords = prev_coords * 0.5 * coords_sign;
    vec2 prev_uv = (niri_geo_to_tex_prev * vec3(prev_coords + 0.5, 1.0)).xy;

    vec4 prev_color = texture2D(niri_tex_prev, prev_uv);

    vec2 next_scale = vec2(niri_curr_geo_to_next_geo[0][0], niri_curr_geo_to_next_geo[1][1]);
    vec2 next_coords = coords_normalized * next_scale - (next_scale - 1.0);

    float next_distance = next_coords.x + next_coords.y;
    float min_next_distance = 1.0 - max(next_scale.x, next_scale.y);

    next_coords = next_coords * 0.5 * coords_sign;
    vec2 next_uv = (niri_geo_to_tex_next * vec3(next_coords + 0.5, 1.0)).xy;

    vec4 next_color = texture2D(niri_tex_next, next_uv);

    vec4 color = next_color;
    if(prev_distance >= next_distance) {
        if(prev_distance - next_distance > niri_clamped_progress * (1.0 - min_next_distance)) {
            color = prev_color;
        }
    } else {
        color = prev_color;
        if(next_distance - prev_distance > (1.0 - niri_clamped_progress) * (1.0 - min_prev_distance)) {
            color = next_color;
        }
    }
    
    return color;
}
