// ------------------------------------------------------------
// Réglages
// ------------------------------------------------------------

// Rayon du cercle lumineux à la tête.
// Diamètre ≈ HEAD_RADIUS * 2.
const float HEAD_RADIUS = 45.0;

// Épaisseur de la traînée.
const float TRAIL_RADIUS = 16.0;

// Halo diffus autour de la traînée.
const float TRAIL_GLOW = 25.0;

// Persistance de la traînée.
// Plus petit = disparaît plus vite.
const float DECAY = 0.90;

// Seuil sous lequel on détruit réellement le résidu.
const float DEAD_THRESHOLD = 0.008;

// Mouvement minimum en pixels.
const float MOVE_THRESHOLD = 0.35;


// ------------------------------------------------------------
// Stockage précis de la position précédente
// ------------------------------------------------------------

// Stocke un float 0..1 dans deux canaux 8 bits.
vec2 pack16(float v)
{
    float q = floor(clamp(v, 0.0, 1.0) * 65535.0 + 0.5);

    float hi = floor(q / 256.0);
    float lo = q - hi * 256.0;

    return vec2(hi, lo) / 255.0;
}


// Relit un float 0..1 depuis deux canaux.
float unpack16(vec2 p)
{
    vec2 bytes = floor(p * 255.0 + 0.5);

    return (bytes.x * 256.0 + bytes.y) / 65535.0;
}


// Pixel réservé à l'état interne.
vec2 state_uv()
{
    return vec2(
        0.5 / niri_output_size.x,
        0.5 / niri_output_size.y
    );
}


bool is_state_pixel(vec2 px)
{
    return px.x < 1.0 && px.y < 1.0;
}


// ------------------------------------------------------------
// Distance point -> segment
// ------------------------------------------------------------

float sdSegment(vec2 p, vec2 a, vec2 b)
{
    vec2 pa = p - a;
    vec2 ba = b - a;

    float denom = max(dot(ba, ba), 0.00001);

    float h =
        clamp(dot(pa, ba) / denom, 0.0, 1.0);

    return length(pa - ba * h);
}


// ------------------------------------------------------------
// Feedback
// ------------------------------------------------------------

vec4 global_buffer(vec3 coord)
{
    vec2 uv = coord.xy;
    vec2 px = uv * niri_output_size;

    vec2 current = niri_cursor;


    // --------------------------------------------------------
    // Relire la position précédente
    // --------------------------------------------------------

    vec4 state =
        tex2D_buffer(state_uv());

    vec2 previous_norm = vec2(
        unpack16(state.rg),
        unpack16(state.ba)
    );

    vec2 previous =
        previous_norm * niri_output_size;


    // --------------------------------------------------------
    // Écrire la nouvelle position avec 16 bits par axe
    // --------------------------------------------------------

    if (is_state_pixel(px)) {

        vec2 normalized =
            current / niri_output_size;

        vec2 packed_x = pack16(normalized.x);
        vec2 packed_y = pack16(normalized.y);

        return vec4(
            packed_x,
            packed_y
        );
    }


    // --------------------------------------------------------
    // Ancienne traînée
    // --------------------------------------------------------

    vec3 trail =
        tex2D_buffer(uv).rgb;

    trail *= DECAY;


    // Tue définitivement les très petites valeurs.
    float remaining =
        max(trail.r, max(trail.g, trail.b));

    if (remaining < DEAD_THRESHOLD) {
        trail = vec3(0.0);
    }


    // --------------------------------------------------------
    // Détection du mouvement
    // --------------------------------------------------------

    vec2 delta =
        current - previous;

    float movement =
        length(delta);


    // IMPORTANT :
    //
    // aucune injection de lumière lorsque le curseur
    // est immobile.
    if (movement < MOVE_THRESHOLD) {
        return vec4(trail, 1.0);
    }


    // --------------------------------------------------------
    // Trait entre ancienne et nouvelle position
    // --------------------------------------------------------

    float d =
        sdSegment(px, previous, current);

    float core =
        1.0 - smoothstep(
            0.0,
            TRAIL_RADIUS,
            d
        );

    float glow =
        exp(-d / TRAIL_GLOW);


    // --------------------------------------------------------
    // Cercle / tête lumineuse
    // --------------------------------------------------------

    float head_distance =
        length(px - current);

    float head =
        1.0 - smoothstep(
            0.0,
            HEAD_RADIUS,
            head_distance
        );


    // --------------------------------------------------------
    // Couleur
    // --------------------------------------------------------

    vec3 cyan =
        vec3(0.0, 0.95, 0.90);

    float intensity =
          core * 0.70
        + glow * 0.25
        + head * 0.75;

    vec3 fresh =
        cyan * intensity;

    trail =
        max(trail, fresh);


    return vec4(trail, 1.0);
}


// ------------------------------------------------------------
// Composition sur l'écran
// ------------------------------------------------------------

vec4 global_color(vec3 coord)
{
    vec2 uv = coord.xy;
    vec2 px = uv * niri_output_size;

    vec4 screen =
        tex2D_screen(uv);


    // Ne jamais afficher notre pixel d'état.
    if (is_state_pixel(px)) {
        return screen;
    }


    vec3 trail =
        tex2D_buffer(uv).rgb;


    float strength =
        clamp(
            max(trail.r, max(trail.g, trail.b)),
            0.0,
            1.0
        );


    vec3 result =
        screen.rgb + trail * 0.85;


    return vec4(
        mix(
            screen.rgb,
            result,
            strength
        ),
        screen.a
    );
}
