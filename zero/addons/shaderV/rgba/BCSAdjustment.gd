tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeRGBAadjustmentBCS

func _init() -> void:
	set_input_port_default_value(1, 1.0)
	set_input_port_default_value(2, 1.0)
	set_input_port_default_value(3, 1.0)

func _get_name() -> String:
	return "BCSAdjustment"

func _get_category() -> String:
	return "RGBA"

#func _get_subcategory():
#	return ""

func _get_description() -> String:
	return "Full analog of BCS adjustment of environment in Godot"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count() -> int:
	return 4

func _get_input_port_name(port: int):
	match port:
		0:
			return "color"
		1:
			return "brightness"
		2:
			return "contrast"
		3:
			return "saturation"

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

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "col"

func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode: int) -> String:
	var code : String = preload("BCSAdjustment.gdshader").code
	code = code.replace("shader_type canvas_item;\n", "").replace("shader_type canvas_item;\r\n", "")
	return code

func _get_code(input_vars: Array, output_vars: Array, mode: int, type: int) -> String:
	return "%s = _applyBCS(%s, vec3(%s, %s, %s));" % [
output_vars[0], input_vars[0], input_vars[1], input_vars[2], input_vars[3]]
