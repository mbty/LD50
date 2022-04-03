extends Node

const TILE_LENGTH = 32

const AISLE_COST = 5

enum STRATEGY_TYPE {
	MIND_OF_STEEL,
	CHECK_OUT
}

enum TILE_TYPES {
	AISLE = 0,
	CHECKOUT = 1,
	GROUND = 2,
	DOOR = 3
}
