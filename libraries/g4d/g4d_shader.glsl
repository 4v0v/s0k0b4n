#define MAX_LIGHTS 32

// Global lights data
struct Light {
	vec4  position;
	vec3  color;

	float ambient_intensity;
	float diffuse_intensity;
	float specular_intensity;
};
uniform Light lights[MAX_LIGHTS];
uniform int lights_count = 0;

// Camera data
uniform mat4 projection_matrix;
uniform mat4 view_matrix;
// uniform vec4 camera_position;

// Model data
uniform vec4 model_color;
uniform bool model_is_lit;
uniform mat4 model_matrix;

varying vec4 vertex_normal;   // vertex normal after model transformation
varying vec4 vertex_position; // vertex position after model transformation

#ifdef VERTEX
attribute vec4 initial_vertex_normal;
vec4 position(mat4 transform_projection, vec4 initial_vertex_position)
{
	vertex_normal   = model_matrix * initial_vertex_normal;
	vertex_position = model_matrix * initial_vertex_position;

	return projection_matrix * view_matrix * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 texture_color  = Texel(texture, texture_coords);

	if (!model_is_lit) return texture_color * model_color;
	
	// Phong lighting
	vec3 total_ambient,total_diffuse, total_specular;

	for (int i = 0; i < lights_count; i++) {
		Light light = lights[i];

		// Ambient
		vec3 ambient_color = vec3(light.ambient_intensity) * light.color;
		total_ambient += ambient_color;

		// Diffuse
		vec4  light_vector  = light.position - vertex_position;
		float diffuse_dp    = max(dot(normalize(vertex_normal), normalize(light_vector)), 0.0);
		vec3  diffuse_color = diffuse_dp * light.color * vec3(light.diffuse_intensity);
		total_diffuse += diffuse_color;

		// Specular
		// vec4 camera_vector   = camera_position - vertex_position;
		// float specular_dp    = max(dot(normalize(vertex_normal), normalize(camera_vector)), 0.0);
		// vec3  specular_color = specular_dp * light.color * .2;
		// total_specular += specular_color;
	}

	vec4 phong_intensity = vec4(total_ambient + total_diffuse + total_specular, 1);

	return texture_color * (model_color + phong_intensity);
}
#endif
