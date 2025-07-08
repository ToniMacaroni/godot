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
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);

    if (any(greaterThanEqual(uv, params.screen_size))) { // too large, do nothing
        return;
    }

    vec4 center = imageLoad(color_image, uv);
    vec4 top = imageLoad(color_image, uv + ivec2(0, -1));
    vec4 left = imageLoad(color_image, uv + ivec2(-1, 0));
    vec4 right = imageLoad(color_image, uv + ivec2(1, 0));
    vec4 bottom = imageLoad(color_image, uv + ivec2(0, 1));

    imageStore(color_image, uv, center + (4.0 * center - top - bottom - left - right) * params.strength);
}
