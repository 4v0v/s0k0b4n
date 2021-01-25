#define MAX_LIGHTS 32

// Global light data
struct Light {
	vec4  position;
	vec3  color;
	float ambientness;
	float diffuseness;
};
uniform Light lights[MAX_LIGHTS];
uniform int lights_count = 0;

// Global camera data
uniform mat4 projection_matrix;
uniform mat4 view_matrix;

// Model data
uniform vec3 model_color;
uniform mat4 model_matrix;

varying vec4 vertex_normal;   // vertex normal after model transformation
varying vec4 vertex_position; // vertex position after model transformation

#ifdef VERTEX
attribute vec4 initial_vertex_normal;
vec4 position(mat4 transform_projection, vec4 initial_vertex_position)
{
	vertex_normal   = model_matrix * initial_vertex_normal;
	vertex_position = model_matrix * initial_vertex_position;

	return projection_matrix * view_matrix * model_matrix * initial_vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 texture_color = Texel(texture, texture_coords);
	vec3 total_ambient = vec3(0);
	vec3 total_diffuse = vec3(0);

	for (int i = 0; i < lights_count; i++) {
		Light light = lights[i];

		// Ambient
		// vec3 ambient_color = vec3(light.ambientness) * light.color;
		// total_ambient += ambient_color;

		// Diffuse
		vec4  light_vector  = light.position - vertex_position;
		float dot_product   = max(dot(normalize(vertex_normal), normalize(light_vector)), 0.0);
		vec3  diffuse_color = dot_product * light.color;
		total_diffuse += diffuse_color;
	}

	vec3 phong_intensity = total_ambient + total_diffuse;


	return texture_color * vec4(model_color + phong_intensity, 1.0);
}
#endif
