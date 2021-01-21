uniform mat4 projectionMatrix;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;

varying vec4 vertexColor;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
	vertexColor = VertexColor;
	return projectionMatrix * viewMatrix * modelMatrix * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
	vec4 texturecolor = Texel(tex, texture_coords);
	return texturecolor * color;
}
#endif
