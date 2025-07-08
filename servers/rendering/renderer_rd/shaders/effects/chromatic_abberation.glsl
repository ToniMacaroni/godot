#[compute]

#version 450

#VERSION_DEFINES

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba8, set = 0, binding = 0) uniform image2D color_image;

layout(push_constant, std430) uniform Params {
    ivec2 screen_size;
    float strength;
} params;

void main() {
    ivec2 iuv = ivec2(gl_GlobalInvocationID.xy);
    vec2 screen_size = vec2(params.screen_size);

    if (any(greaterThanEqual(iuv, params.screen_size))) { // too large, do nothing
        return;
    }

    const vec2 resrcp = 1.0 / screen_size;
    const vec2 uv = (iuv + 0.5f) * resrcp;

    const vec2 distortion = (uv - 0.5f) * params.strength * resrcp;

    const vec2 uv_R = uv + vec2(1, 1) * distortion;
    const vec2 uv_G = uv + vec2(0, 0) * distortion;
    const vec2 uv_B = uv - vec2(1, 1) * distortion;

    const float R = imageLoad(color_image, ivec2(uv_R * screen_size)).r;
    const float G = imageLoad(color_image, ivec2(uv_G * screen_size)).g;
    const float B = imageLoad(color_image, ivec2(uv_B * screen_size)).b;

    const vec4 color = vec4(R, G, B, 1);
    imageStore(color_image, iuv, color);
}
