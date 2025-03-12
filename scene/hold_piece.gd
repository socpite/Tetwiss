extends Node2D

var default_position: Vector2

func _ready() -> void:
	default_position = $Piece.position

func center_piece(piece_name: String):
	match piece_name:
		"I":
			$Piece.position = default_position + Vector2(-Data.TILE_SIZE/2, -Data.TILE_SIZE/2)*$Piece.scale
		"O":
			$Piece.position = default_position + Vector2(Data.TILE_SIZE/2, 0)*$Piece.scale
		_:
			$Piece.position = default_position
