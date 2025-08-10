# object_template.gd
extends Control

var MIN_DISTANCES := {
	"generator": {
		"generator": 5.0,
		"tent": 10.0
	},
	"tent": {
		"tent": 2.0,
		"generator": 10.0
	}
}

var OBJECT_TEMPLATE := {
	"tent": {
		"color": Color(0.6, 0.9, 0.3),
		"hqss": {
			"size": Vector2(60, 28),
			"elec_inputs": [
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 60,
					"quantity": 1
				}
			],
			"elec_outputs": []
		},
		"mod": {
			"size": Vector2(68, 24),
			"elec_inputs": [
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 100,
					"quantity": 1
				}
			],
			"elec_outputs": []
		}
	},
	"generator": {
		"color": Color(0.3, 0.6, 0.9),
		"30kw": {
			"size": Vector2(60, 28),
			"elec_inputs": [],
			"elec_outputs": [
				{
					"connector": "CamLok",
					"phase": "3PH",
					"voltage": "120",
					"amperage": 400,
					"quantity": 1
				}
			],
			"fuel_type": "diesel"
		},
		"60kw": {
			"size": Vector2(60, 28),
			"elec_inputs": [],
			"elec_outputs": [
				{
					"connector": "CamLok",
					"phase": "3PH",
					"voltage": "120",
					"amperage": 400,
					"quantity": 1
				}
			],
			"fuel_type": "diesel"
		}
	},
	"distribution box": {
		"color": Color(0.9, 0.6, 0.3),
		"lex200": {
			"size": Vector2(60, 28),
			"elec_inputs": [
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 100,
					"quantity": 2
				}
			],
			"elec_outputs": [
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 60,
					"quantity": 10
				},
				{
					"connector": "Receptacle",
					"phase": "1PH",
					"voltage": "120",
					"amperage": 15,
					"quantity": 1
				}
			]
		},
		"lex800": {
			"size": Vector2(60, 28),
			"elec_inputs": [
				{
					"connector": "CamLok",
					"phase": "3PH",
					"voltage": "120",
					"amperage": 400,
					"quantity": 2
				}
			],
			"elec_outputs": [
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 60,
					"quantity": 10
				},
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 100,
					"quantity": 4
				},
				{
					"connector": "Receptacle",
					"phase": "1PH",
					"voltage": "120",
					"amperage": 15,
					"quantity": 1
				}
			]
		},
		"lex1200": {
			"size": Vector2(60, 28),
			"elec_inputs": [
				{
					"connector": "CamLok",
					"phase": "3PH",
					"voltage": "120",
					"amperage": 400,
					"quantity": 3
				}
			],
			"elec_outputs": [
				{
					"connector": "CamLok",
					"phase": "3PH",
					"voltage": "120",
					"amperage": 400,
					"quantity": 3
				},
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 100,
					"quantity": 2
				},
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 60,
					"quantity": 2
				}
			]
		}
	}
}
