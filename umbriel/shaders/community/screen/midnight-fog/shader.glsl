// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Barrulus. Original shader with Codex assistance.
const float INTENSITY = 0.3; // 0..1
const float FOG_PX = 34.0;
const float IDLE_SPEED = 0.24;

float fog_hash(vec2 p) {
    vec3 q = fract(vec3(p.xyx) * 0.1031);
    q += dot(q, q.yzx + 33.33);
    return fract((q.x + q.y) * q.z);
}

float fog_noise(vec2 p) {
    vec2 cell = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    // Hash each shared lattice coordinate identically to avoid cell seams.
    vec4 h = vec4(fog_hash(cell), fog_hash(cell + vec2(1.0, 0.0)),
                  fog_hash(cell + vec2(0.0, 1.0)), fog_hash(cell + vec2(1.0)));
    return mix(mix(h.x, h.y, f.x), mix(h.z, h.w, f.x), f.y);
}

float fog_column(float x) {
    float pos = clamp(x, 0.0, 1.0);
    float band = umbriel_audio_spectrum(pos);
    band += umbriel_audio_spectrum(clamp(pos - 0.012, 0.0, 1.0));
    band += umbriel_audio_spectrum(clamp(pos + 0.012, 0.0, 1.0));
    band += umbriel_audio_spectrum(clamp(pos - 0.03, 0.0, 1.0));
    band += umbriel_audio_spectrum(clamp(pos + 0.03, 0.0, 1.0));
    return band * 0.2;
}

vec4 screen(vec2 uv) {
    vec4 source = umbriel_sample(uv);
    float altitude_px = (1.0 - uv.y) * umbriel_size.y;
    if (altitude_px >= FOG_PX) return source;
    float live = umbriel_audio_available();
    float mirror = abs(uv.x * 2.0 - 1.0);
    float column = live * fog_column(mirror);
    float energy = live * (
        umbriel_audio_spectrum(0.08) + umbriel_audio_spectrum(0.28) +
        umbriel_audio_spectrum(0.50) + umbriel_audio_spectrum(0.72) +
        umbriel_audio_spectrum(0.92)) * 0.2;
    float playing = smoothstep(0.04, 0.16, energy);
    vec2 p = vec2(mix(uv.x, mirror, playing), uv.y) * umbriel_size / 170.0;
    float t = umbriel_time * IDLE_SPEED;
    float warp = fog_noise(p * 0.7 + vec2(t * 0.15, -t));
    float n = fog_noise(p * vec2(1.0, 2.3) + vec2(-t * 0.15, warp * 2.8));
    float detail = fog_noise(p * 2.8 + vec2(t * 0.4, n));
    float shaped = mix(5.0, FOG_PX, clamp(column * (0.75 + 0.25 * n), 0.0, 1.0));
    float crest_px = mix(FOG_PX, shaped, playing);
    float bank = 1.0 - smoothstep(crest_px * (0.15 + 0.50 * n), crest_px, altitude_px);
    float loud = mix(1.0, 0.35 + 0.65 * column, playing);
    float opacity = INTENSITY * loud * bank * (0.35 + 0.65 * smoothstep(0.2, 0.8, n)) * (0.65 + 0.35 * detail);
    vec3 purple = mix(vec3(0.30, 0.20, 0.43), vec3(0.73, 0.61, 0.86), mix(n, column, playing));
    return vec4(mix(source.rgb, purple * source.a, clamp(opacity, 0.0, 1.0)), source.a);
}
