tool
extends VisualShaderNodeCustom
class_name VisualShaderToolsRemap

func _init() -> void:
	set_input_port_default_value(1, 0.0)
	set_input_port_default_value(2, 1.0)
	set_input_port_default_value(3, -1.0)
	set_input_port_default_value(4, 1.0)

func _get_name() -> String:
	return "Remap"

func _get_category() -> String:
	return "Tools"

#func _get_subcategory():
#	return ""

func _get_description() -> String:
	return "Remaps input value from ( [inMin], [inMax] ) range to ( [outMin], [outMax] ). UV is default input value."

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count() -> int:
	return 5

func _get_input_port_name(port: int):
	match port:
		0:
			return "input"
		1:
			return "inMin"
		2:
			return "inMin"
		3:
			return "outMin"
		4:
			return "outMax"

func _get_input_port_type(port: int):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR
		4:
			return VisualShaderNode.PORT_TYPE_SCALAR
	

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port ) -> String:
	return "out"

func _get_output_port_type(port) -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode: int) -> String:
	var code : String = preload("remap.gdshader").code
	code = code.replace("shader_type canvas_item;\n", "").replace("shader_type canvas_item;\r\n", "")
	return code

func _get_code(input_vars: Array, output_vars: Array, mode: int, type: int) -> String:
	var uv = "UV"
	
	if input_vars[0]:
		uv = input_vars[0]
	
	return output_vars[0] + " = _remapFunc(%s, vec2(%s, %s), vec2(%s, %s));" % [
	uv, input_vars[1], input_vars[2], input_vars[3], input_vars[4]]




