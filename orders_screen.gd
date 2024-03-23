class_name OrdersScreen extends Control

signal order_accepted(layer_count: int, reward: int)


func _ready() -> void:
	for order_card: OrderCard in get_children():
		order_card.layer_count = randi_range(1, Util.MAX_LAYER_COUNT)
		order_card.reward = randi_range(50, 500)
		order_card.accepted.connect(func() -> void:
			order_accepted.emit(order_card.layer_count, order_card.reward)
		)
