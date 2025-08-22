#[compute]

#version 450

#VERSION_DEFINES

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba8, set = 0, binding = 0) uniform image2D color_image;

layout(push_constant, std430) uniform Params {
    vec2 screen_size_rcp;
    ivec2 screen_size;
    float strength;
} params;

void main() {

    ivec2 iuv = ivec2(gl_GlobalInvocationID.xy);

    if (iuv.x >= params.screen_size.x || iuv.y >= params.screen_size.y) {
        return;
    }

    vec2 uv = (vec2(iuv)+0.5) * params.screen_size_rcp;

    vec4 r0, r1, r2;
    r0.yw = imageLoad(color_image, iuv).yw;
    r1.x = params.strength + params.strength;
    r1.yz = r1.xx * params.screen_size_rcp + 1.0;
    r1.xw = -r1.xx * params.screen_size_rcp + 1.0;
    r2.xy = uv - 0.5;
    r1.yz = r2.xy * r1.yz + 0.5;
    r1.xw = r2.xy * r1.xw + 0.5;
    r0.z = imageLoad(color_image, ivec2(r1.xw*params.screen_size)).z;
    r0.x = imageLoad(color_image, ivec2(r1.yz*params.screen_size)).x; // ca'd image
    imageStore(color_image, ivec2(gl_GlobalInvocationID.xy), r0);
}
