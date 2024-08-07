tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeRGBAcreateCheckerboard

func _init() -> void:
	set_input_port_default_value(1, Vector3(8.0, 8.0, 0.0))
	set_input_port_default_value(2, Vector3(1.0, 1.0, 1.0))
	set_input_port_default_value(3, 1)

func _get_name() -> String:
	return "CheckerboardShape"

func _get_category() -> String:
	return "RGBA"

func _get_subcategory():
	return "Shapes"

func _get_description() -> String:
	return "Creates checkerboard pattern"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count() -> int:
	return 4

func _get_input_port_name(port: int):
	match port:
		0:
			return "uv"
		1:
			return "amount"
		2:
			return "color"
		3:
			return "alpha"

func _get_input_port_type(port: int):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR
		2:
			return VisualShaderNode.PORT_TYPE_VECTOR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 2

func _get_output_port_name(port: int):
	match port:
		0:
			return "col"
		1:
			return "alpha"

func _get_output_port_type(port: int):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode: int) -> String:
	var code : String = preload("chekerboardPattern.gdshader").code
	code = code.replace("shader_type canvas_item;\n", "").replace("shader_type canvas_item;\r\n", "")
	return code

func _get_code(input_vars: Array, output_vars: Array, mode: int, type: int) -> String:
	var uv = "UV"
	
	if input_vars[0]:
		uv = input_vars[0]
	
	return """%s = %s;
%s = _checkerboardPatternFunc(%s.xy, %s.xy) * %s;""" % [
output_vars[0], input_vars[2],
output_vars[1], uv, input_vars[1], input_vars[3]]
