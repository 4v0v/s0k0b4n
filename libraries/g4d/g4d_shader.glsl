uniform mat4 projection_matrix;
uniform mat4 view_matrix;
uniform mat4 model_matrix;

varying vec4 vertex_color;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
	vertex_color = VertexColor;
	return projection_matrix * view_matrix * model_matrix * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 texture_color = Texel(texture, texture_coords);
	return texture_color * color * vertex_color;
}
#endif