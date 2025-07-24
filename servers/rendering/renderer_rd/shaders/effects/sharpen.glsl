#[compute]

#version 450

#VERSION_DEFINES

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba8, set = 0, binding = 0) uniform image2D color_image;

layout(push_constant, std430) uniform Params {
    ivec2 screen_size;
    float strength;
} params;

#define coeff_orig (1 + params.strength)

#define Src(a, b) imageLoad(color_image, ivec2(uv.x + a, uv.y + b))
#define dx (1)
#define dy (1)

// void main() {
//     ivec2 uv = ivec2(gl_GlobalInvocationID.xy);

//     if (any(greaterThanEqual(uv, params.screen_size))) { // too large, do nothing
//         return;
//     }

//     vec4 center = imageLoad(color_image, uv);
//     vec4 top = imageLoad(color_image, uv + ivec2(0, -1));
//     vec4 left = imageLoad(color_image, uv + ivec2(-1, 0));
//     vec4 right = imageLoad(color_image, uv + ivec2(1, 0));
//     vec4 bottom = imageLoad(color_image, uv + ivec2(0, 1));

//     imageStore(color_image, uv, center + (4.0 * center - top - bottom - left - right) * params.strength);
// }

void main() {
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
    ivec2 size = ivec2(params.screen_size);

    if (uv.x >= size.x || uv.y >= size.y) {
        return;
    }

    vec4 orig = Src(0, 0);

    vec4 c1 = Src(-dx, -dy);
    vec4 c2 = Src(0, -dy);
    vec4 c3 = Src(dx, -dy);
    vec4 c4 = Src(-dx, 0);
    vec4 c5 = Src(dx, 0);
    vec4 c6 = Src(-dx, dy);
    vec4 c7 = Src(0, dy);
    vec4 c8 = Src(dx, dy);

    vec4 blur = (c1 + c3 + c6 + c8 + 2 * (c2 + c4 + c5 + c7) + 4 * orig) / 16;

    vec4 corr = coeff_orig * orig - params.strength * blur;

    imageStore(color_image, uv, corr);
}
