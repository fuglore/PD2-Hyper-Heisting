local origin_init = CharacterTweakData.init
local origin_presets = CharacterTweakData._presets
local origin_charmap = CharacterTweakData.character_map

function CharacterTweakData:init(tweak_data)
	local presets = self:_presets(tweak_data)
	self._speech_prefix_p2 = "n"
	origin_init(self, tweak_data)
end

--LANDMARK: SHARK

--TODO: Lots of untested stuff right now, get testing it solo, if it works, it works, if it doesn't, make it work.

function CharacterTweakData:_presets(tweak_data)
	local presets = origin_presets(self, tweak_data)
	
	
	--replace existing suppression presets with lighter and consistent ones to accomodate for lack of immediate enemy suppression
	presets.suppression = {
		easy = {
			panic_chance_mul = 1,
			duration = {
				10,
				15
			},
			react_point = {
				0,
				0
			},
			brown_point = {
				1,
				1
			}
		},
		hard_def = {
			panic_chance_mul = 0.7,
			duration = {
				5,
				10
			},
			react_point = {
				0,
				1
			},
			brown_point = {
				2,
				2
			}
		},
		hard_agg = {
			panic_chance_mul = 0.7,
			duration = {
				5,
				8
			},
			react_point = {
				3,
				4
			},
			brown_point = {
				5,
				6
			}
		},
		no_supress = {
			panic_chance_mul = 0,
			duration = {
				0.1,
				0.15
			},
			react_point = {
				100,
				200
			},
			brown_point = {
				400,
				500
			}
		}
	}
	
	--Custom suppression presets for certain types of enemies which should be affected by suppressive effects but not have damage reactions, flawed, yes, but it's the best that can currently be done until someone can help me figure out how to disable the suppression resistance and instantaneous build up on hit.
	presets.suppression.stalwart_nil = {
        panic_chance_mul = 0,
        duration = {
            2,
            2
        },
        brown_point = {
            400,
            500
        }
    }
	presets.suppression.stalwart_agg = {
        panic_chance_mul = 0.7,
        duration = {
            5,
            8
        },
        brown_point = {
            5,
            6
        }
    }
	presets.suppression.stalwart_def = {
        panic_chance_mul = 0.7,
        duration = {
            5,
            10
        },
        brown_point = {
            5,
            6
        }
    }
	presets.suppression.stalwart_easy = {
        panic_chance_mul = 1,
        duration = {
            10,
            15
        },
        brown_point = {
            3,
            5
        }
    }
	
	--Dodge presets begin here.
	presets.dodge.heavy_complex = {
		speed = 1.3,
		occasions = {
			hit = {
				chance = 1,
				check_timeout = {
					0,
					0
				},
				variations = {
					side_step = {
						chance = 1,
						shoot_chance = 1,
						shoot_accuracy = 1,
						timeout = {
							1,
							2
						}
					},
					roll = {
						chance = 1,
						timeout = {
							0.7,
							1
						}
					},
					dive = {
						chance = 1,
						shoot_chance = 1,
						shoot_accuracy = 0.9,
						timeout = {
							2,
							3
						}
					}
				}
			},
			preemptive = {
				chance = 1,
				check_timeout = {
					0.5,
					0.75
				},
				variations = {
					roll = {
						chance = 1,
						timeout = {
							0.7,
							1
						}
					},
					dive = {
						chance = 2,
						shoot_chance = 1,
						shoot_accuracy = 0.9,
						timeout = {
							0.75,
							1
						}
					}
				}
			},
			scared = {
				chance = 1,
				check_timeout = {
					0,
					0
				},
				variations = {
					side_step = {
						chance = 1,
						shoot_chance = 0.8,
						shoot_accuracy = 0.6,
						timeout = {
							1,
							1.5
						}
					},
					roll = {
						chance = 1,
						timeout = {
							0.7,
							1
						}
					},
					dive = {
						chance = 1,
						shoot_chance = 0.6,
						shoot_accuracy = 0.4,
						timeout = {
							0.75,
							1
						}
					}
				}
			}
		}
	}
	presets.dodge.athletic_complex = {
		speed = 1.5,
		occasions = {
			hit = {
				chance = 1,
				check_timeout = {
					0,
					0
				},
				variations = {
					side_step = {
						chance = 1,
						shoot_chance = 1,
						shoot_accuracy = 1,
						timeout = {
							0.5,
							0.5
						}
					},
					roll = {
						chance = 2,
						timeout = {
							0.5,
							0.5
						}
					},
					dive = {
						chance = 2,
						shoot_chance = 1,
						shoot_accuracy = 0.9,
						timeout = {
							0.5,
							0.5
						}
					}
				}
			},
			preemptive = {
				chance = 1,
				check_timeout = {
					0,
					0
				},
				variations = {
					roll = {
						chance = 2,
						timeout = {
							0.5,
							0.5
						}
					},
					dive = {
						chance = 1,
						shoot_chance = 1,
						shoot_accuracy = 1,
						timeout = {
							0.5,
							0.5
						}
					}
				}
			},
			scared = {
				chance = 1,
				check_timeout = {
					0,
					0
				},
				variations = {
					side_step = {
						chance = 1,
						shoot_chance = 1,
						shoot_accuracy = 0.6,
						timeout = {
							0.5,
							0.5
						}
					},
					roll = {
						chance = 1,
						timeout = {
							0.5,
							0.5
						}
					},
					dive = {
						chance = 2,
						shoot_chance = 1,
						shoot_accuracy = 0.6,
						timeout = {
							0.5,
							0.5
						}
					}
				}
			}
		}
	}
	presets.dodge.ninja_complex = {
			speed = 2,
			occasions = {
				hit = {
					chance = 1,
					check_timeout = {
						0,
						0
					},
					variations = {
							dive = {
							chance = 1,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.5,
								0.5
							}
						},
						roll = {
							chance = 1,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.5,
								0.5
							}
						},
						wheel = {
							chance = 2,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.35,
								0.35
							}
						}
					}
				},
				preemptive = {
					chance = 1,
					check_timeout = {
						0,
						0
					},
					variations = {
							dive = {
							chance = 1,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.5,
								0.5
							}
						},
						roll = {
							chance = 1,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.5,
								0.5
							}
						},
						wheel = {
							chance = 2,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.35,
								0.35
							}
						}
					}
				},
				scared = {
					chance = 1,
					check_timeout = {
						0,
						0
					},
					variations = {
						dive = {
							chance = 1,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.5,
								0.5
							}
						},
						roll = {
							chance = 1,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.5,
								0.5
							}
						},
						wheel = {
							chance = 3,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.35,
								0.35
							}
						}
					}
				}
			}
		}
	
	--custom shield move speed presets, escalates with difficulty as it should, starting from normal-based speeds to very_fast
	presets.move_speed.shield_sim = {
		stand = {
			walk = {
				ntl = {
					strafe = 220,
					fwd = 220,
					bwd = 220
				},
				hos = {
					strafe = 220,
					fwd = 220,
					bwd = 220
				},
				cbt = {
					strafe = 220,
					fwd = 220,
					bwd = 220
				}
			},
			run = {
				hos = {
					strafe = 450,
					fwd = 450,
					bwd = 450
				},
				cbt = {
					strafe = 450,
					fwd = 450,
					bwd = 450
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 230,
					fwd = 230,
					bwd = 230
				},
				cbt = {
					strafe = 230,
					fwd = 230,
					bwd = 230
				}
			},
			run = {
				hos = {
					strafe = 460,
					fwd = 460,
					bwd = 460
				},
				cbt = {
					strafe = 460,
					fwd = 460,
					bwd = 460
				}
			}
		}
	}
	presets.move_speed.shield_civ = {
		stand = {
			walk = {
				ntl = {
					strafe = 220,
					fwd = 220,
					bwd = 220
				},
				hos = {
					strafe = 253,
					fwd = 253,
					bwd = 253
				},
				cbt = {
					strafe = 253,
					fwd = 253,
					bwd = 253
				}
			},
			run = {
				hos = {
					strafe = 518,
					fwd = 518,
					bwd = 518
				},
				cbt = {
					strafe = 518,
					fwd = 518,
					bwd = 518
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 263,
					fwd = 263,
					bwd = 263
				},
				cbt = {
					strafe = 263,
					fwd = 263,
					bwd = 263
				}
			},
			run = {
				hos = {
					strafe = 528,
					fwd = 528,
					bwd = 528
				},
				cbt = {
					strafe = 528,
					fwd = 528,
					bwd = 528
				}
			}
		}
	}
	presets.move_speed.shield_com = {
		stand = {
			walk = {
				ntl = {
					strafe = 220,
					fwd = 220,
					bwd = 220
				},
				hos = {
					strafe = 264,
					fwd = 264,
					bwd = 264
				},
				cbt = {
					strafe = 264,
					fwd = 264,
					bwd = 264
				}
			},
			run = {
				hos = {
					strafe = 540,
					fwd = 540,
					bwd = 540
				},
				cbt = {
					strafe = 540,
					fwd = 540,
					bwd = 540
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 274,
					fwd = 274,
					bwd = 274
				},
				cbt = {
					strafe = 274,
					fwd = 274,
					bwd = 274
				}
			},
			run = {
				hos = {
					strafe = 550,
					fwd = 550,
					bwd = 550
				},
				cbt = {
					strafe = 550,
					fwd = 550,
					bwd = 550
				}
			}
		}
	}
	presets.move_speed.shield_anarch = {
		stand = {
			walk = {
				ntl = {
					strafe = 220,
					fwd = 220,
					bwd = 220
				},
				hos = {
					strafe = 275,
					fwd = 275,
					bwd = 275
				},
				cbt = {
					strafe = 275,
					fwd = 275,
					bwd = 275
				}
			},
			run = {
				hos = {
					strafe = 562,
					fwd = 562,
					bwd = 562
				},
				cbt = {
					strafe = 562,
					fwd = 562,
					bwd = 562
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 285,
					fwd = 285,
					bwd = 285
				},
				cbt = {
					strafe = 285,
					fwd = 285,
					bwd = 285
				}
			},
			run = {
				hos = {
					strafe = 572,
					fwd = 572,
					bwd = 572
				},
				cbt = {
					strafe = 572,
					fwd = 572,
					bwd = 572
				}
			}
		}
	}	
	
		
	--Custom move speedds start here to keep enemy approaches and movement consistent.
	presets.move_speed.simple_consistency = {
		stand = {
			walk = {
				ntl = {
					strafe = 220,
					fwd = 220,
					bwd = 220
				},
				hos = {
					strafe = 220,
					fwd = 220,
					bwd = 220
				},
				cbt = {
					strafe = 220,
					fwd = 220,
					bwd = 220
				}
			},
			run = {
				hos = {
					strafe = 450,
					fwd = 450,
					bwd = 450
				},
				cbt = {
					strafe = 450,
					fwd = 450,
					bwd = 450
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 210,
					fwd = 210,
					bwd = 210
				},
				cbt = {
					strafe = 210,
					fwd = 210,
					bwd = 210
				}
			},
			run = {
				hos = {
					strafe = 350,
					fwd = 350,
					bwd = 350
				},
				cbt = {
					strafe = 350,
					fwd = 350,
					bwd = 350
				}
			}
		}
	}
	-- 15% faster
	presets.move_speed.civil_consistency = {
		stand = {
			walk = {
				ntl = {
					strafe = 220,
					fwd = 220,
					bwd = 220
				},
				hos = {
					strafe = 253,
					fwd = 253,
					bwd = 253
				},
				cbt = {
					strafe = 253,
					fwd = 253,
					bwd = 253
				}
			},
			run = {
				hos = {
					strafe = 518,
					fwd = 518,
					bwd = 518
				},
				cbt = {
					strafe = 518,
					fwd = 518,
					bwd = 518
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 240,
					fwd = 240,
					bwd = 240
				},
				cbt = {
					strafe = 240,
					fwd = 240,
					bwd = 240
				}
			},
			run = {
				hos = {
					strafe = 402,
					fwd = 402,
					bwd = 402
				},
				cbt = {
					strafe = 402,
					fwd = 402,
					bwd = 402
				}
			}
		}
	}
	--20% faster
	presets.move_speed.complex_consistency = {
		stand = {
			walk = {
				ntl = {
					strafe = 220,
					fwd = 220,
					bwd = 220
				},
				hos = {
					strafe = 264,
					fwd = 264,
					bwd = 264
				},
				cbt = {
					strafe = 264,
					fwd = 264,
					bwd = 264
				}
			},
			run = {
				hos = {
					strafe = 540,
					fwd = 540,
					bwd = 540
				},
				cbt = {
					strafe = 540,
					fwd = 540,
					bwd = 540
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 252,
					fwd = 252,
					bwd = 252
				},
				cbt = {
					strafe = 252,
					fwd = 252,
					bwd = 252
				}
			},
			run = {
				hos = {
					strafe = 420,
					fwd = 420,
					bwd = 420
				},
				cbt = {
					strafe = 420,
					fwd = 420,
					bwd = 420
				}
			}
		}
	}
	--25% faster, climax
	presets.move_speed.anarchy_consistency = {
		stand = {
			walk = {
				ntl = {
					strafe = 220,
					fwd = 220,
					bwd = 220
				},
				hos = {
					strafe = 275,
					fwd = 275,
					bwd = 275
				},
				cbt = {
					strafe = 275,
					fwd = 275,
					bwd = 275
				}
			},
			run = {
				hos = {
					strafe = 562,
					fwd = 562,
					bwd = 562
				},
				cbt = {
					strafe = 562,
					fwd = 562,
					bwd = 562
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 262,
					fwd = 262,
					bwd = 262
				},
				cbt = {
					strafe = 262,
					fwd = 262,
					bwd = 262
				}
			},
			run = {
				hos = {
					strafe = 438,
					fwd = 438,
					bwd = 438
				},
				cbt = {
					strafe = 438,
					fwd = 438,
					bwd = 438
				}
			}
		}
	}	
	--preset for dozers
	presets.move_speed.slow_consistency = {
		stand = {
			walk = {
				ntl = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				},
				hos = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				},
				cbt = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				}
			},
			run = {
				hos = {
					strafe = 360,
					fwd = 360,
					bwd = 360
				},
				cbt = {
					strafe = 360,
					fwd = 360,
					bwd = 360
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				},
				cbt = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				}
			},
			run = {
				hos = {
					strafe = 360,
					fwd = 360,
					bwd = 360
				},
				cbt = {
					strafe = 360,
					fwd = 360,
					bwd = 360
				}
			}
		}
	}
	--minigun dozer movespeed
	presets.move_speed.mini_consistency = {
		stand = {
			walk = {
				ntl = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				},
				hos = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				},
				cbt = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				}
			},
			run = {
				hos = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				},
				cbt = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				},
				cbt = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				}
			},
			run = {
				hos = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				},
				cbt = {
					strafe = 144,
					fwd = 144,
					bwd = 144
				}
			}
		}
	}
	--preset for cloakers to keep them zippy and fast no matter what
	presets.move_speed.lightning_constant = { 
		stand = {
			walk = {
				ntl = {
					strafe = 800,
					fwd = 800,
					bwd = 800
				},
				hos = {
					strafe = 800,
					fwd = 800,
					bwd = 800
				},
				cbt = {
					strafe = 800,
					fwd = 800,
					bwd = 800
				}
			},
			run = {
				hos = {
					strafe = 800,
					fwd = 800,
					bwd = 800
				},
				cbt = {
					strafe = 800,
					fwd = 800,
					bwd = 800
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 800,
					fwd = 800,
					bwd = 800
				},
				cbt = {
					strafe = 800,
					fwd = 800,
					bwd = 800
				}
			},
			run = {
				hos = {
					strafe = 800,
					fwd = 800,
					bwd = 800
				},
				cbt = {
					strafe = 800,
					fwd = 800,
					bwd = 800
				}
			}
		}
	}
	
	presets.move_speed.speedofsoundsonic = { 
		stand = {
			walk = {
				ntl = {
					strafe = 1000,
					fwd = 1000,
					bwd = 1000
				},
				hos = {
					strafe = 1000,
					fwd = 1000,
					bwd = 1000
				},
				cbt = {
					strafe = 1000,
					fwd = 1000,
					bwd = 1000
				}
			},
			run = {
				hos = {
					strafe = 1000,
					fwd = 1000,
					bwd = 1000
				},
				cbt = {
					strafe = 1000,
					fwd = 1000,
					bwd = 1000
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 1000,
					fwd = 1000,
					bwd = 1000
				},
				cbt = {
					strafe = 1000,
					fwd = 1000,
					bwd = 1000
				}
			},
			run = {
				hos = {
					strafe = 1000,
					fwd = 1000,
					bwd = 1000
				},
				cbt = {
					strafe = 1000,
					fwd = 1000,
					bwd = 1000
				}
			}
		}
	}
	
	--prevents Application has crashed: C++ exception[string "core/lib/utils/coretable.lua"]:32: bad argument #1 to 'pairs' (table expected, got nil)
	
	for speed_preset_name, poses in pairs(presets.move_speed) do
		for pose, hastes in pairs(poses) do
			hastes.run.ntl = hastes.run.hos
		end
		poses.crouch.walk.ntl = poses.crouch.walk.hos
		poses.crouch.run.ntl = poses.crouch.run.hos
		poses.stand.run.ntl = poses.stand.run.hos
		poses.panic = poses.stand
	end
	
	--making base-game presets clone my new set of movespeed presets
	presets.move_speed.slow = deep_clone(presets.move_speed.slow_consistency)
	presets.move_speed.very_slow = deep_clone(presets.move_speed.mini_consistency)
	presets.move_speed.normal = deep_clone(presets.move_speed.simple_consistency)
	presets.move_speed.fast = deep_clone(presets.move_speed.civil_consistency)
	presets.move_speed.very_fast = deep_clone(presets.move_speed.complex_consistency)
	
	--detection preset for regular enemies so they are fully capable of identifying players during loud	
	presets.detection.enemymook = { 
		idle = {},
		combat = {},
		recon = {},
		guard = {},
		ntl = {}
	}
	presets.detection.enemymook.idle.dis_max = 10000
	presets.detection.enemymook.idle.angle_max = 360
	presets.detection.enemymook.idle.delay = {
		0.35,
		0.35
	}
	presets.detection.enemymook.idle.use_uncover_range = true
	presets.detection.enemymook.combat.dis_max = 10000
	presets.detection.enemymook.combat.angle_max = 360
	presets.detection.enemymook.combat.delay = {
		0.35,
		0.35
	}
	presets.detection.enemymook.combat.use_uncover_range = true
	presets.detection.enemymook.recon.dis_max = 10000
	presets.detection.enemymook.recon.angle_max = 360
	presets.detection.enemymook.recon.delay = {
		0.35,
		0.35
	}
	presets.detection.enemymook.recon.use_uncover_range = true
	presets.detection.enemymook.guard.dis_max = 10000
	presets.detection.enemymook.guard.angle_max = 360
	presets.detection.enemymook.guard.delay = {
		0.35,
		0.35
	}
	presets.detection.enemymook.ntl.dis_max = 2000
	presets.detection.enemymook.ntl.angle_max = 55
	presets.detection.enemymook.ntl.delay = {
		0.7,
		0.7
	}
	presets.detection.civilian.cbt.dis_max = 700
	presets.detection.civilian.cbt.angle_max = 360
	presets.detection.civilian.cbt.delay = {
		0,
		0
	}
	presets.detection.civilian.cbt.use_uncover_range = true
	presets.detection.civilian.ntl.dis_max = 2000
	presets.detection.civilian.ntl.angle_max = 55
	presets.detection.civilian.ntl.delay = {
		0.7,
		0.7
	}
	
	--make normal clone my new preset to keep enemies not currently set here capable of detecting people too
	presets.detection.normal = deep_clone(presets.detection.enemymook)
	presets.detection.gang_member = deep_clone(presets.detection.enemymook)
	
	--custom hurt severities start here, focus on less enemy down time as enemy health goes up 
	--satisfying staggering behavior, burying full auto rounds into enemies faces eventually makes them fall over and squirm, anything that deals immediate large damage staggers enemies consistently. 
	--melee becomes gratifying, rewarding and ridiculously fun using explodes
	presets.hurt_severities.hordemook = {
		bullet = {
			health_reference = "current",
			zones = {
				{
					heavy = 0.05,
					health_limit = 0.1,
					light = 0.8,
					moderate = 0.15,
				},
				{
					heavy = 0.1,
					light = 0.7,
					moderate = 0.15,
					health_limit = 0.15
				},
				{
					heavy = 0.2,
					light = 0.6,
					moderate = 0.2,
					health_limit = 0.2
				},
				{
					heavy = 0.6,
					light = 0,
					moderate = 0.4,
					health_limit = 0.25
				},
				{
					heavy = 0.4,
					explode = 0.4,
					moderate = 0.2,
					health_limit = 0.35
				},
				{
					explode = 0.33,
					moderate = 0.33,
					heavy = 0.33
				}
			}
		},
		explosion = {
			health_reference = "current",
			zones = {
				{
					moderate = 0.6,
					heavy = 0.4,
					health_limit = 0.2
				},
				{
					explode = 0.4,
					heavy = 0.6,
					health_limit = 0.5
				},
				{
					explode = 0.8,
					heavy = 0.2
				}
			}
		},
		melee = {
			health_reference = "current",
			zones = {
				{
					heavy = 0,
					health_limit = 0.05,
					light = 0.7,
					moderate = 0.3,
					none = 0
				},
				{
					heavy = 0.4,
					light = 0,
					explode = 0,
					moderate = 0.6,
					health_limit = 0.2
				},
				{
					heavy = 0.2,
					explode = 0.4,
					moderate = 0.4,
					health_limit = 0.3
				},
				{
					explode = 0.8,
					heavy = 0.2
				}
			}
		},
		fire = {
			health_reference = "current",
			zones = {
				{
					fire = 1
				}
			}
		},
		poison = {
			health_reference = "current",
			zones = {
				{
					poison = 1,
					none = 0
				}
			}
		}
	}
	
	presets.hurt_severities.heavyhordemook = {
		bullet = {
			health_reference = "current",
			zones = {
				{
					heavy = 0.05,
					health_limit = 0.2,
					light = 0.9,
					moderate = 0.05,
				},
				{
					heavy = 0.3,
					light = 0.3,
					moderate = 0.4,
					health_limit = 0.3
				},
				{
					heavy = 0.4,
					light = 0.2,
					moderate = 0.4,
					health_limit = 0.4
				},
				{
					heavy = 0.5,
					light = 0,
					moderate = 0.5,
					health_limit = 0.5
				},
				{
					heavy = 0.4,
					explode = 0.2,
					moderate = 0.4,
					health_limit = 0.6
				},
				{
					moderate = 9
				}
			}
		},
		explosion = {
			health_reference = "current",
			zones = {
				{
					moderate = 0.6,
					heavy = 0.4,
					health_limit = 0.2
				},
				{
					explode = 0.4,
					heavy = 0.6,
					health_limit = 0.5
				},
				{
					explode = 0.5,
					heavy = 0.5
				}
			}
		},
		melee = {
			health_reference = "current",
			zones = {
				{
					heavy = 0,
					health_limit = 0.1,
					light = 0.7,
					moderate = 0.3,
					none = 0
				},
				{
					heavy = 0.4,
					light = 0,
					explode = 0,
					moderate = 0.6,
					health_limit = 0.3
				},
				{
					heavy = 0.2,
					explode = 0.4,
					moderate = 0.4,
					health_limit = 0.4
				},
				{
					moderate = 0.5,
					heavy = 0.5
				}
			}
		},
		fire = {
			health_reference = "current",
			zones = {
				{
					fire = 0.05,
					none = 0.95
				}
			}
		},
		poison = {
			health_reference = "current",
			zones = {
				{
					poison = 0.25,
					none = 0.75,
					--none = 0
				}
			}
		}
	}
		
	presets.hurt_severities.specialenemy = {
		bullet = {
			health_reference = "current",
			zones = {
				{
					heavy = 0,
					health_limit = 0.3, --increase health limits for minimum staggers, needs significant damage before they start reacting
					light = 0.95,
					moderate = 0.05,
				},
				{
					heavy = 0.05,
					light = 0.9,
					moderate = 0.05,
					health_limit = 0.4
				},
				{
					heavy = 0.2,
					light = 0.6,
					moderate = 0.2,
					health_limit = 0.5
				},
				{
					moderate = 1
				}
			}
		},
		explosion = {
			health_reference = "current",
			zones = {
				{
					moderate = 0.6, --no explode reacts
					heavy = 0.4,
					health_limit = 0.5
				},
				{
					explode = 0.5,
					heavy = 0.5
				}
			}
		},
		melee = {
			health_reference = "current",
			zones = {
				{
					heavy = 0,
					health_limit = 0.2,
					light = 0.7,
					moderate = 0.3,
					none = 0
				},
				{
					heavy = 0.4,
					light = 0,
					explode = 0,
					moderate = 0.6,
					health_limit = 0.45
				},
				{
					heavy = 0.2,
					explode = 0.4,
					moderate = 0.4,
					health_limit = 0.6
				},
				{
					light = 0,
					heavy = 0.8,
					explode = 0.2
				}
			}
		},
		fire = {
			health_reference = "current",
			zones = {
				{
					fire = 0.025,
					none = 0.975,
				}
			}
		},
		poison = {
			health_reference = "current",
			zones = {
				{
					poison = 0.05,
					none = 0.95
				}
			}
		}
	}
	--special no_tase hurt severities based on specialenemy, possibly used on taser.
	presets.hurt_severities.no_tase_special = deep_clone(presets.hurt_severities.specialenemy)
	presets.hurt_severities.no_tase_special.tase = false
	
	--no more weirdness with gangsters
	presets.hurt_severities.base = deep_clone(presets.hurt_severities.hordemook)
	
	presets.base.damage.tased_response = {
		light = {
			down_time = nil,
			tased_time = 1
		},
		heavy = {
			down_time = nil,
			tased_time = 5
		}
	}
		
	--Custom sniper preset to make them work differently, they work as a mini turret of sorts, dealing big damage with good accuracy, standing in their line of fire isn't wise as they'll suppress the shit out of you and take off armor very quickly.
	presets.weapon.rhythmsniper = deep_clone(presets.weapon.sniper)
	presets.weapon.rhythmsniper.is_rifle.autofire_rounds = nil	
	presets.weapon.rhythmsniper.is_rifle.focus_delay = 5  
	presets.weapon.rhythmsniper.is_rifle.aim_delay = {
		0.8,
		0.8
	}
	presets.weapon.rhythmsniper.is_rifle.FALLOFF = {
		{
			dmg_mul = 2.5,
			r = 700,
			acc = {
				0,
				1
			},
			recoil = {
				0.8,
				0.8
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 2.5,
			r = 3500,
			acc = {
				0,
				0.75
			},
			recoil = {
				0.8,
				0.8
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 2.5,
			r = 6000,
			acc = {
				0,
				0.3
			},
			recoil = {
				0.8,
				0.8
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 9000,
			acc = {
				0,
				0.1
			},
			recoil = {
				0.8,
				0.8
			},
			mode = {
				0,
				0,
				0,
				1
			}
		}
	}
	
	--Weapon presets setup starts here, simple corresponds to swat, civil to fbi, complex to gensec and anarchy to zeal.
	
	--TODO: A lot of these comments are completely outdated and from older designs based on Vanilla Version, I should clean this up later for better understanding.
	
	--Differences between difficulties are a mix of spawngroup changes, custom units escalating gameplay complexity (when I get to that) and enemy numbers escalating to 80.
	presets.weapon.simple = deep_clone(presets.weapon.normal)
	presets.weapon.civil = deep_clone(presets.weapon.normal)
	presets.weapon.complex = deep_clone(presets.weapon.normal)
	presets.weapon.anarchy = deep_clone(presets.weapon.normal)
	
	--Simple preset begins here, lets players settle in.
	
	presets.weapon.simple.is_pistol = {
		aim_delay = { --no aim delay
			0,
			0
		},
		focus_delay = 2, --halved focus delay, still a lot, but pistols have good accuracy, so it's fair
		focus_dis = 500,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 0.6, --cops will reload their weapons slower, and realistically, no tweaks from simple to this one
		melee_speed = 1.5,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 3000, --cant walk and shoot past this range
			far = 4000, --40m cut off range.
			close = 2000 --20m close range means they'll aim at players consistently, pistols are light weight weapons and dont deal much damage
		},
		FALLOFF = {
			{
				dmg_mul = 3, --increased average damage for vh and ovk, increases immediate threat of enemy fire from pistol cops
				r = 100,
				acc = {
					0.1, --focus delay build up
					0.9
				},
				recoil = {
					0.4,
					0.45
				},
				mode = { --tap fire like crazy
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0.1,
					0.85
				},
				recoil = {
					0.45,
					0.45
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2, --moderate falloff begins, still ok.
				r = 1000,
				acc = {
					0,
					0.55
				},
				recoil = {
					0.5,
					0.6
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0,
					0.45
				},
				recoil = { --reduced from simple, keeps them still moderately effective at this range
					0.55,
					0.6
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1, --still dangerous, acc drops hard, but not recoil or firing pattern
				r = 3000,
				acc = {
					0,
					0.2
				},
				recoil = {
					0.9,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.1, --no longer a threat past this range, merely a warning shot
				r = 4000,
				acc = {
					0,
					0.01
				},
				recoil = {
					0.9,
					1.2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.simple.akimbo_pistol = { --isnt ever really used, changing it anyways, mostly matches pistol, but with more bang bang bang and less accuracy
		aim_delay = { --no aim delay
			0,
			0
		},
		focus_delay = 1, --less focus delay than pistol, bit eh accuracy wise, so it's fair
		focus_dis = 500,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 0.3, --slightly reduced from simple
		melee_speed = 1.5,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 3000,
			far = 4000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.1,
					0.9
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0.1,
					0.7
				},
				recoil = {
					0.15,
					0.2
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 1000,
				acc = {
					0,
					0.5
				},
				recoil = {
					0.15,
					0.2
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0,
					0.5
				},
				recoil = {
					0.2,
					0.3
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 0.1, --shorter falloff
				r = 3000,
				acc = {
					0,
					0.01
				},
				recoil = {
					0.4,
					1
				},
				mode = {
					1,
					0,
					1,
					0
				}
			}
		}
	}
	presets.weapon.simple.is_rifle = {
		aim_delay = { 
			0.1,
			0.2
		},
		focus_delay = 4, --4 sec focus delay build up, accuracy is based of number of enemies on the map, not on the assumption you're squaring off against a single enemy, being outnumbered does not equal being in trouble automatically, but rather, being outnumbered with enemies CLOSE to you is
		focus_dis = 100,
		spread = 40, 
		miss_dis = 1,
		RELOAD_SPEED = 0.8,
		melee_speed = 1.5,
		melee_dmg = 2.5, --100 damage on melee, no joke
		melee_retry_delay = {
			1,
			1
		},
		tase_distance = 1500, --include tase parameters so that tasers can scale with difficulties better, since doing it the other way would keep reload speed, autofire rounds and other parameters unchanged
		aim_delay_tase = {
			0,
			0
		},
		tase_sphere_cast_radius = 5,
		range = {
			optimal = 3000,
			far = 4000, --longer range style firing patterns begin, enemy movement gets complexer due to the close range being increased
			close = 2000
		},
		autofire_rounds = { --autofire rounds match to 8-16, with low recoil to boot, should make hitting players consistent with 10 or more units at range
			8,
			16
		},
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = { 
					0,
					0.1
				},
				recoil = { --super low recoil at this range
					0.05,
					0.15
				},
				mode = { --full auto
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 5,
				r = 500,
				acc = {
					0, 
					0.1
				},
				recoil = {
					0.05,
					0.15
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3, --damage, recoil and acc falloff begins, still quite good, 30 damage.
				r = 1000,
				acc = { --accuracy increased slightly from simple for this range, not a main feature, just a tiny little boost
					0,
					0.05
				},
				recoil = {
					0.1,
					0.25
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2, --damage maintains 20.
				r = 2000,
				acc = { 
					0,
					0.025
				},
				recoil = { --no top recoil increase, just lower half
					0.25,
					0.35
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2, --20 damage, but low acc, with the recoil still being fine, maintains suppressive fire feel when there are multiple enemies.
				r = 3000,
				acc = {
					0,
					0.01
				},
				recoil = {
					0.25,
					0.35
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, --instructions unclear, gun stopped working at the 40m range
				r = 4000,
				acc = {
					0,
					0
				},
				recoil = {
					1,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.simple.is_bullpup = presets.weapon.simple.is_rifle
	presets.weapon.simple.is_shotgun_pump = {
		aim_delay = { --aim delay changed to match PDTH style aim-delay, might lower it later if shotgunners feel underpowered
			0,
			0.2
		},
		focus_delay = 7,
		focus_dis = 500, --focus delay only starts past 5m, cqc maps become dangerous fun houses while long-range maps encourage players to kite and keep enemies away
		spread = 20,
		miss_dis = 20,
		RELOAD_SPEED = 0.4, --lowered reload speed
		melee_speed = 1.5,
		melee_dmg = 10, --100 damage on melee, no joke, keep as is
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 1000,
			far = 3000,
			close = 800 
		},
		FALLOFF = {
			{
				dmg_mul = 2,
				r = 100,
				acc = {
					0,
					0.9
				},
				recoil = { --dramatically lowered recoil from simple
					1,
					1.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0,
					0.9
				},
				recoil = {
					1,
					1.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = { --accuracy increased from simple
					0,
					0.5
				},
				recoil = {
					1.35,
					1.6
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0,
					0.25
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.2,
				r = 3000,
				acc = {
					0,
					0.01
				},
				recoil = {
					2,
					4
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.simple.is_shotgun_mag = { --a mix of both shotgun and rifle, its a jack of all trades!
		aim_delay = { --aim delay changed to match PDTH style aim-delay.
			0,
			0.2
		},
		focus_delay = 3, --shotgun-like focus delay
		focus_dis = 500, --im sure its unescessary for me to keep commenting this now.
		spread = 20, --increased spread from regular shotgun
		miss_dis = 20,
		RELOAD_SPEED = 0.9, --saiga only has 7 shots per clip which forces a reload animation once depleted, justifying the rather quick reload
		melee_speed = 1.5,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 1500, --halfway point between shotguns and rifles, higher than shotgun, lower than rifle
			far = 3000,
			close = 800
		},
		autofire_rounds = { --autofire rounds
			4,
			4
		},
		--before i start falloff, if you can, go watch that one video of that one terrorist war crime guy eating a cyanide pill mid-trial to express my frustration at overkill simply cloning shotgun_pump for shotgun_mag 
		FALLOFF = {
			{
				dmg_mul = 5, --the danger isnt just damage or accuracy, its the fact that its a split between shotgun and rifle in damage, firerate and falloff, saiga starts at 150 damage per hit with this preset, complex will increase its range and autofire rounds!
				r = 100,
				acc = {
					0.1,
					0.9
				},
				recoil = {
					0.4,
					0.8
				},
				mode = {
					0,
					3,
					3,
					1 --ugh fill me with that lead big boy
				}
			},
			{
				dmg_mul = 5,
				r = 500,
				acc = {
					0.1,
					0.9
				},
				recoil = {
					0.4,
					0.8
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 3, --90 damage at this range, pretty good
				r = 1000,
				acc = {
					0,
					0.4
				},
				recoil = {
					0.6,
					0.8
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 2, --60 damage, lower end of the falloff scale
				r = 2000,
				acc = {
					0,
					0.2
				},
				recoil = {
					0.8,
					1
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 0.5, --15, no longer a threat due to low accuracy, generally a warning shot if it hits
				r = 3000,
				acc = {
					0,
					0.01
				},
				recoil = {
					1,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.simple.is_smg = { --used by hrts, cloakers and other sneaky buggers, generally not too scary damage-wise but does hella suppressive fire
		aim_delay = { --aim delay kept, the intent of the weapon is just to build suppression on the player and be generally annoying, its damage isnt worth too much consideration most of the time...MOST of the time.
			0.1,
			0.1
		},
		focus_delay = 4,
		focus_dis = 500, --then again, so was destroying all the spawngroups in housewarming update
		spread = 20,
		miss_dis = 20,
		RELOAD_SPEED = 1.1, --decreased slightly from normal
		melee_speed = 1.5,
		melee_dmg = 2.5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 2000,
			far = 4000,
			close = 1000 --light weight weapon, allows run'n gun, shortened since cloakers exist, will revise later per difficulty
		},
		autofire_rounds = { --defined autofire for smgs.
			16,
			24
		},
		FALLOFF = {
			{
				dmg_mul = 4,
				r = 100,
				acc = { 
					0,
					0.05
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0,
					0.05
				},
				recoil = { --low recoil, meant to simulate rapid bursts
					0.1,
					0.15
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 1000,
				acc = { --low accuracy compared to rifles, auto-fire makes up for it
					0,
					0.025
				},
				recoil = {
					0.5,
					0.9
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1, --start dropping damage, hard, accuracy hits a low point
				r = 2000,
				acc = {
					0,
					0.01
				},
				recoil = {
					0.6,
					1.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, -- no longer a threat, gun stops working
				r = 3000,
				acc = {
					0,
					0
				},
				recoil = {
					1.5,
					3
				},
				mode = {
					3,
					1,
					1,
					0
				}
			}
		}
	}
	presets.weapon.simple.is_revolver = {
		aim_delay = { --aim delay
			0.1,
			0.1
		},
		focus_delay = 5, --5 second focus delay, justified due to increased accuracy of the weapon along with damage scale
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 0.9, --faster reloads than shotguns
		melee_speed = 1.5,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = { --leave untouched, long range weapon
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 3, --120 damage start.
				r = 100,
				acc = {
					0,
					0.9
				},
				recoil = {
					0.8,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0,
					0.9
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2.5, --120, range remains excellent
				r = 1000,
				acc = {
					0,
					0.85
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2.5,
				r = 2000,
				acc = {
					0,
					0.7
				},
				recoil = { --lowered slightly from normal for the higher end, was 1.3, is 1.1
					1,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1, --40, lower end of the accuracy scale with very little chance to hit anything unless in high numbers (which wont happen anytime soon)
				r = 3000,
				acc = {
					0,
					0.2 --slightly increased from simple .15 to .2
				},
				recoil = {
					1,
					1.3 --slightly decreased from simple
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.2, --8 damage, acc, recoil and falloff destroy themselves past 4000 no matter what weapon, to keep maps like birth of sky bearable and make open areas less of a pain in the fucking ass 
				r = 4000,
				acc = {
					0,
					0.01
				},
				recoil = {
					4,
					5.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.simple.mini = { --unused, its 4 am and im redoing the entire simple preset, im too tired to swear, for the love of god please help me
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 3,
		focus_dis = 100,
		spread = 100, --bigger spread
		miss_dis = 1, --reduced miss dis to make it easier than complex
		RELOAD_SPEED = 0.5,
		melee_speed = 1.5,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 1500,
			far = 1800,
			close = 1000
		},
		autofire_rounds = { --absolutely in awe of the size of this lad, absolute unit
			50,
			50
		},
		FALLOFF = {
			{
				dmg_mul = 10, --200 damage start, get the fuck out of its way.
				r = 100,
				acc = {
					1,
					1
				},
				recoil = {
					4,
					4
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 10,
				r = 500,
				acc = {
					1,
					1
				},
				recoil = {
					4,
					4
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 6, --120, still slightly above lmg dozer by now, accuracy drops hard to force focus delay to build, recoil escalates to 1 second or more between barrages
				r = 1000,
				acc = {
					1,
					1
				},
				recoil = {
					4,
					4
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4 , --80
				r = 2000,
				acc = {
					0,
					0.2
				},
				recoil = {
					4,
					4
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2, --40, compare to anarchy at 80
				r = 3000,
				acc = {
					0,
					0.1
				},
				recoil = {
					4,
					4
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0,
				r = 4000,
				acc = {
					0,
					0.01
				},
				recoil = {
					4,
					4
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}	
	presets.weapon.simple.is_lmg = { --unused at this difficulty, based on complex
		aim_delay = { --this...is questionable but i feel increases fairness against lmg dozers just a bit.
			0.35,
			0.35
		},
		focus_delay = 5,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.5, --2 second pause after a full burst, theres 200 ammo in the fucking thing, it'll take time to empty, believe me.
		melee_speed = 1.5,
		melee_dmg = 15,
		melee_retry_delay = presets.weapon.expert.is_lmg.melee_retry_delay,
		range = { --cant walk and shoot at ranges beyond 10 meters, pretty good.
			optimal = 1500,
			far = 4000,
			close = 1000
		},
		autofire_rounds = {20, 100}, --bullet hose, kinda scary, fires in random, long bursts though
		FALLOFF = {
			{
				dmg_mul = 4,
				r = 100,
				acc = {
					0.65,
					0.85
				},
				recoil = {
					0.4,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = { --lessened accuracy, firerate keeps it scary
					0,
					0.2
				},
				recoil = {
					0.4,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4, --accuracy and recoil drop begins
				r = 1000,
				acc = {
					0,
					0.05
				},
				recoil = {
					0.6,
					1.0
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2, --falloff begins
				r = 2000,
				acc = {
					0,
					0.05
				},
				recoil = {
					0.8,
					1.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0.5, --lower end of the falloff scale, drop the damage, but recoil and acc still remains the same to keep it suppressing players
				r = 3000,
				acc = {
					0,
					0.05
				},
				recoil = {
					0.8,
					1.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, --range limit reach, gun stops working, higher recoil than rifles to compensate for the full auto
				r = 4000,
				acc = {
					0,
					0.01
				},
				recoil = {
					2,
					3
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	
	--civil begins here, noteworthy change being increases in attack rate along with less falloff, plus the increase of focus delay minimum starting range
	presets.weapon.civil.is_pistol = {
		aim_delay = { --no aim delay
			0.35,
			0.35
		},
		focus_delay = 2, --halved focus delay, still a lot, but pistols have good accuracy, so it's fair
		focus_dis = 500,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 0.9, --cops will reload their weapons slower, and realistically, no tweaks from simple to this one
		melee_speed = 0.75,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 3000, --cant walk and shoot past this range
			far = 4000, --40m cut off range.
			close = 2000 --20m close range means they'll aim at players consistently, pistols are light weight weapons and dont deal much damage
		},
		FALLOFF = {
			{
				dmg_mul = 3, --increased average damage for vh and ovk, increases immediate threat of enemy fire from pistol cops
				r = 100,
				acc = {
					0.1, --focus delay build up
					0.9
				},
				recoil = {
					0.25,
					0.35
				},
				mode = { --tap fire like crazy
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0.1,
					0.85
				},
				recoil = {
					0.35,
					0.35
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2, --moderate falloff begins, still ok.
				r = 1000,
				acc = {
					0,
					0.55
				},
				recoil = {
					0.4,
					0.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0,
					0.45
				},
				recoil = { --reduced from simple, keeps them still moderately effective at this range
					0.5,
					0.6
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1, --still dangerous, acc drops hard, but not recoil or firing pattern
				r = 3000,
				acc = {
					0,
					0.2
				},
				recoil = {
					0.6,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.1, --no longer a threat past this range, merely a warning shot
				r = 4000,
				acc = {
					0,
					0.01
				},
				recoil = {
					0.6,
					1.2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.civil.akimbo_pistol = { --isnt ever really used, changing it anyways, mostly matches pistol, but with more bang bang bang and less accuracy
		aim_delay = { --no aim delay
			0.35,
			0.35
		},
		focus_delay = 1, --less focus delay than pistol, bit eh accuracy wise, so it's fair
		focus_dis = 500,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 0.6, --slightly reduced from simple
		melee_speed = 0.75,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 3000,
			far = 4000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.1,
					0.9
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0.1,
					0.7
				},
				recoil = {
					0.15,
					0.2
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 1000,
				acc = {
					0,
					0.5
				},
				recoil = {
					0.15,
					0.2
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0,
					0.5
				},
				recoil = {
					0.2,
					0.3
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 0.1, --shorter falloff
				r = 3000,
				acc = {
					0,
					0.01
				},
				recoil = {
					0.4,
					1
				},
				mode = {
					1,
					0,
					1,
					0
				}
			}
		}
	}
	presets.weapon.civil.is_rifle = {
		aim_delay = {
			0.4,
			0.4
		},
		focus_delay = 3, --3 sec focus delay build up, accuracy is based of number of enemies on the map, not on the assumption you're squaring off against a single enemy, being outnumbered does not equal being in trouble automatically, but rather, being outnumbered with enemies CLOSE to you is
		focus_dis = 500, --focus delay starts after 5m
		spread = 30, --lowered slightly from simple
		miss_dis = 1,
		RELOAD_SPEED = 1.25, --lowered slightly from simple
		melee_speed = 0.75,
		melee_dmg = 10, --100 damage on melee, no joke
		melee_retry_delay = {
			1,
			1
		},
		tase_distance = 1500, --include tase parameters so that tasers can scale with difficulties better, since doing it the other way would keep reload speed, autofire rounds and other parameters unchanged
		aim_delay_tase = {
			0,
			0
		},
		tase_sphere_cast_radius = 5,
		range = {
			optimal = 3000,
			far = 4000, --longer range style firing patterns begin, enemy movement gets complexer due to the close range being increased
			close = 2000
		},
		autofire_rounds = { --autofire rounds match to 8-16, with low recoil to boot, should make hitting players consistent with 10 or more units at range
			15,
			20
		},
		FALLOFF = {
			{
				dmg_mul = 5, --damage mostly maintains the layout from simple, but rather, focuses on removing falloff, damage increases with presets, begin in complex, instead, focus on using this one to measure changes in weapontweakdata
				r = 100,
				acc = { 
					0,
					0.15
				},
				recoil = { --super low recoil at this range
					0.2,
					0.2
				},
				mode = { --full auto
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 5,
				r = 500,
				acc = {
					0,
					0.15
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3, --damage, recoil and acc falloff begins, still quite good, 30 damage.
				r = 1000,
				acc = { --accuracy increased slightly from simple for this range, not a main feature, just a tiny little boost
					0,
					0.08
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2, --damage maintains 20.
				r = 2000,
				acc = { 
					0,
					0.02
				},
				recoil = { --no top recoil increase, just lower half
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2, --20 damage, but low acc, with the recoil still being fine, maintains suppressive fire feel when there are multiple enemies.
				r = 3000,
				acc = {
					0,
					0.01
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, --instructions unclear, gun stopped working at the 40m range
				r = 4000,
				acc = {
					0,
					0
				},
				recoil = {
					1,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.civil.is_bullpup = presets.weapon.civil.is_rifle
	presets.weapon.civil.is_shotgun_pump = {
		aim_delay = { --aim delay changed to match PDTH style aim-delay
			0.7,
			0.7
		},
		focus_delay = 5, --quicker focus delay build from simple, accuracy remains mostly the same
		focus_dis = 500, --focus delay only starts past 5m, cqc maps become dangerous fun houses while long-range maps encourage players to kite and keep enemies away
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 0.8, --lowered reload speed
		melee_speed = 0.75,
		melee_dmg = 10, --100 damage on melee, no joke, keep as is
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 1000,
			far = 3000,
			close = 800 
		},
		FALLOFF = {
			{
				dmg_mul = 2,
				r = 100,
				acc = {
					0.2,
					0.9
				},
				recoil = { --dramatically lowered recoil from simple
					1,
					1.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2, --100 damage, intent is to encourage players to take out shotgunners first
				r = 500,
				acc = {
					0.2, --increased from simple, should resolve a few consistency issues
					0.9
				},
				recoil = {
					1,
					1.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1.5, --75 damage.
				r = 1000,
				acc = { --accuracy increased from simple
					0,
					0.75
				},
				recoil = {
					1.35,
					1.6
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1, --50 damage, lower end of the falloff scale. 
				r = 2000,
				acc = {
					0,
					0.35
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.2, --10, no longer a threat due to low accuracy and high recoil
				r = 3000,
				acc = {
					0,
					0.01
				},
				recoil = {
					2,
					4
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.civil.is_shotgun_mag = { --a mix of both shotgun and rifle, its a jack of all trades!
		aim_delay = {
			0.7,
			0.7
		},
		focus_delay = 3, --shotgun-like focus delay
		focus_dis = 500, --im sure its unescessary for me to keep commenting this now.
		spread = 20, --increased spread from regular shotgun
		miss_dis = 20,
		RELOAD_SPEED = 1.25, --saiga only has 7 shots per clip which forces a reload animation once depleted, justifying the rather quick reload
		melee_speed = 0.75,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 1500, --halfway point between shotguns and rifles, higher than shotgun, lower than rifle
			far = 3000,
			close = 800
		},
		autofire_rounds = { --autofire rounds
			4,
			4
		},
		--before i start falloff, if you can, go watch that one video of that one terrorist war crime guy eating a cyanide pill mid-trial to express my frustration at overkill simply cloning shotgun_pump for shotgun_mag 
		FALLOFF = {
			{
				dmg_mul = 1.5, --the danger isnt just damage or accuracy, its the fact that its a split between shotgun and rifle in damage, firerate and falloff, saiga starts at 75 damage per hit with this preset, complex will increase its range and autofire rounds!
				r = 100,
				acc = {
					0,
					0.12
				},
				recoil = {
					0.05,
					0.1
				},
				mode = {
					0,
					3,
					3,
					1 --ugh fill me with that lead big boy
				}
			},
			{
				dmg_mul = 1.5,
				r = 500,
				acc = {
					0,
					0.12
				},
				recoil = {
					0.1,
					0.2
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 1, --50 damage at this range, its short-ranged like rifles, and yet, technically more powerful
				r = 1000,
				acc = {
					0,
					0.057
				},
				recoil = {
					0.2,
					0.3
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 0,
				r = 1500,
				acc = {
					0,
					0
				},
				recoil = {
					1,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.civil.is_smg = { --used by hrts, cloakers and other sneaky buggers, generally not too scary damage-wise but does hella suppressive fire
		aim_delay = {
			0.28,
			0.28
		},
		focus_delay = 4,
		focus_dis = 500, --then again, so was destroying all the spawngroups in housewarming update
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1.5,
		melee_speed = 0.75,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 2000,
			far = 4000,
			close = 1000 --light weight weapon, allows run'n gun, shortened since cloakers exist, will revise later per difficulty
		},
		autofire_rounds = { --defined autofire for smgs.
			16,
			24
		},
		FALLOFF = {
			{
				dmg_mul = 4, --damage unchanged from simple
				r = 100,
				acc = { 
					0,
					0.1
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0,
					0.1
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 1000,
				acc = { --low accuracy compared to rifles, auto-fire makes up for it
					0,
					0.05
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1, --start dropping damage, hard, accuracy hits a low point
				r = 2000,
				acc = {
					0,
					0.01
				},
				recoil = {
					0.6,
					1.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, -- no longer a threat, gun stops working
				r = 3000,
				acc = {
					0,
					0
				},
				recoil = {
					1.5,
					3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	presets.weapon.civil.is_revolver = { --might be used later for custom revolver-wielding fbis, currently given a similar role to shotguns but with more applied individuality, makes them good joker cops
		aim_delay = { --aim delay
			0.4,
			0.4
		},
		focus_delay = 5, --5 second focus delay, justified due to increased accuracy of the weapon along with damage scale
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 1.4, --faster reloads than shotguns
		melee_speed = 0.75,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = { --leave untouched, long range weapon
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 3, --120 damage start.
				r = 100,
				acc = {
					0,
					0.9
				},
				recoil = {
					0.8,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0,
					0.9
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2.5, --120, range remains excellent
				r = 1000,
				acc = {
					0,
					0.85
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2.5,
				r = 2000,
				acc = {
					0,
					0.7
				},
				recoil = { --lowered slightly from normal for the higher end, was 1.3, is 1.1
					1,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1, --40, lower end of the accuracy scale with very little chance to hit anything unless in high numbers (which wont happen anytime soon)
				r = 3000,
				acc = {
					0,
					0.2 --slightly increased from simple .15 to .2
				},
				recoil = {
					1,
					1.3 --slightly decreased from simple
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.2, --8 damage, acc, recoil and falloff destroy themselves past 4000 no matter what weapon, to keep maps like birth of sky bearable and make open areas less of a pain in the fucking ass 
				r = 4000,
				acc = {
					0,
					0.01
				},
				recoil = {
					4,
					5.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.civil.mini = { --only used in crimespree, mostly based on complex with a few tweaks, also, blame overkill for making the minigun dozer look like shit, i really, really want to love it, its design is cool, it's mechanics are awesome, it works to solve lack of movement and encourages smart gameplay for once, and they kinda messed IT ALL UP, BY NOT GIVING IT A PROPER MINIGUN HOLDING ANIMATION BECAUSE YOU CANT GET YOUR PEOPLE TO MAKE NEW 3RD PERSON ANIMATIONS AND YET WE HAD A 3RD PERSON ANIMATIONS UPDATE MONTHS AGO HECK HECK HEEEEEEEEEEEEEEECK
		aim_delay = {
			0.9,
			0.9
		},
		focus_delay = 3,
		focus_dis = 100,
		spread = 80, --bigger spread from anarchy
		miss_dis = 5, --reduced miss dis to make it easier than complex
		RELOAD_SPEED = 0.5,
		melee_speed = 0.75,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 1500,
			far = 3000,
			close = 1000
		},
		autofire_rounds = { --absolutely in awe of the size of this lad, absolute unit
			100,
			100
		},
		FALLOFF = {
			{
				dmg_mul = 5, --100 damage start
				r = 100,
				acc = {
					0.75,
					0.75
				},
				recoil = {
					2.7,
					2.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4, --80
				r = 1000,
				acc = {
					0.75,
					0.75
				},
				recoil = {
					2.7,
					2.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3, --60
				r = 2000,
				acc = {
					0,
					0.01
				},
				recoil = {
					2.7,
					2.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0,
				r = 3000,
				acc = {
					0,
					0
				},
				recoil = {
					2.7,
					2.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}	
	presets.weapon.civil.is_lmg = { --unused at this difficulty outside of crime spree, based on complex
		aim_delay = {
			0.5,
			0.5
		},
		focus_delay = 1.4, --higher than rifles at this preset, (well, not in this one particular, possibly but, still.) to show it as a suppressing bullet hose at longer ranges, makes the minigun feel comparably close-range oriented while the lmg reaches a tiny bit longer to make the difference. ('course, though, what matters is always technique)
		focus_dis = 200,
		spread = 40,
		miss_dis = 1,
		RELOAD_SPEED = 0.6,
		melee_speed = 0.75,
		melee_dmg = 15,
		melee_retry_delay = presets.weapon.expert.is_lmg.melee_retry_delay,
		range = { --cant walk and shoot at ranges beyond 10 meters, pretty good.
			optimal = 1500,
			far = 4000,
			close = 1000
		},
		autofire_rounds = {20, 180}, --bullet hose, kinda scary, fires in random, long bursts though
		FALLOFF = {
			{
				dmg_mul = 3, --60, keeps the gun scarier than rifles.
				r = 100,
				acc = {
					0,
					0.05
				},
				recoil = {
					1.7,
					1.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = { --lessened accuracy, firerate keeps it scary
					0,
					0.05
				},
				recoil = {
					1.7,
					1.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2, --accuracy and recoil drop begins, no falloff yet to keep it suppressive and scary
				r = 1000,
				acc = {
					0,
					0.01
				},
				recoil = {
					1.7,
					1.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1, --little to no falloff, can suppress through misses though, which makes it pressure players for long periods of time
				r = 2000,
				acc = {
					0,
					0.01
				},
				recoil = {
					1.7,
					1.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0,
					0.01
				},
				recoil = {
					1.7,
					1.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, --range limit reach, gun stops working, higher recoil than rifles to compensate for the full auto
				r = 4000,
				acc = {
					0,
					0
				},
				recoil = {
					2,
					3
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	
	--complex begins here, focus delay, recoil and reloads get reduced, there are tweaks to autofire and falloff as well, enemy damage is not changed, worthwhile changes will be done in weapontweakdata to increase firing frequency and such
	
	presets.weapon.complex.is_pistol = {
		aim_delay = { --no aim delay
			0.35,
			0.35
		},
		focus_delay = 5, --focus delay for pistols unchanged, they do a good enough job.
		focus_dis = 500,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 1,
		melee_speed = 0.75,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 3000, --cant walk and shoot past this range
			far = 4000, --40m cut off range.
			close = 2000 --20m close range means they'll aim at players consistently, pistols are light weight weapons and dont deal much damage
		},
		FALLOFF = {
			{
				dmg_mul = 3, --unchanged from civil
				r = 100,
				acc = {
					0.1,
					0.9
				},
				recoil = {
					0.25,
					0.25
				},
				mode = { --tap fire like crazy, unchanged from civil
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0.1,
					0.85
				},
				recoil = {
					0.3,
					0.35
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3, --falloff does not begin, save it for 20m, the harsh drop is kept ofc
				r = 1000,
				acc = {
					0,
					0.6 --increased slightly from .55 to .6
				},
				recoil = {
					0.3,
					0.4
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0,
					0.45
				},
				recoil = { 
					0.35,
					0.4 --reduced from civil by .1, shouldnt matter too much but keeps a certain feeling of noteworthyness
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1, --still dangerous, acc drops hard, but not recoil or firing pattern
				r = 3000,
				acc = {
					0,
					0.25 --slight increase from .2 to .25, matters, due to fbi gunslingers being quite the nuisance
				},
				recoil = {
					0.35,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.1, --no longer a threat past this range, merely a warning shot
				r = 4000,
				acc = {
					0,
					0.01
				},
				recoil = {
					0.4,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.complex.akimbo_pistol = { --isnt ever really used, changing it anyways, mostly matches pistol, but with more bang bang bang and less accuracy, unchanged outside of reload and focus delay for complex
		aim_delay = {
			0.35,
			0.35
		},
		focus_delay = 2.5, --less focus delay than pistol, bit eh accuracy wise, so it's fair
		focus_dis = 500,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 0.9,
		melee_speed = 0.75,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 3000,
			far = 4000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.1,
					0.9
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0.1,
					0.7
				},
				recoil = {
					0.15,
					0.2
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 1000,
				acc = {
					0,
					0.5
				},
				recoil = {
					0.15,
					0.2
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0,
					0.5
				},
				recoil = {
					0.2,
					0.3
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 0.1, --shorter falloff
				r = 3000,
				acc = {
					0,
					0.01
				},
				recoil = {
					0.4,
					1
				},
				mode = {
					1,
					0,
					1,
					0
				}
			}
		}
	}
	presets.weapon.complex.is_rifle = {
		aim_delay = {
			0.35,
			0.35
		},
		focus_delay = 2, --2 sec focus delay build up, accuracy is based of number of enemies on the map, not on the assumption you're squaring off against a single enemy, being outnumbered does not equal being in trouble automatically, but rather, being outnumbered with enemies CLOSE to you is
		focus_dis = 500, --focus delay starts after 5m
		spread = 20, --lowered slightly from civil
		miss_dis = 5,
		RELOAD_SPEED = 1.1,
		melee_speed = 0.75,
		melee_dmg = 10, --100 damage on melee, no joke
		melee_retry_delay = {
			1,
			1
		},
		tase_distance = 1500, --include tase parameters so that tasers can scale with difficulties better, since doing it the other way would keep reload speed, autofire rounds and other parameters unchanged
		aim_delay_tase = {
			0,
			0
		},
		tase_sphere_cast_radius = 5,
		range = {
			optimal = 3000,
			far = 4000, --longer range style firing patterns begin, enemy movement gets complexer due to the close range being increased
			close = 2000
		},
		autofire_rounds = { --fires massive bursts of 16 to 30 shots, weapontweakdata increases max clip for rifles at mayhem and above
			16,
			30
		},
		FALLOFF = {
			{
				dmg_mul = 5, --damage mostly maintains the layout from simple, but rather, focuses on removing falloff, damage increases with presets, begin in complex, instead, focus on using this one to measure changes in weapontweakdata
				r = 100,
				acc = { 
					0,
					0.15
				},
				recoil = { 
					0.2,
					0.2
				},
				mode = { --full auto
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 5,
				r = 500,
				acc = {
					0, 
					0.15
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4, --damage, recoil and acc falloff begins, still quite good, 40 damage, increased by 10 from civil, very, very active
				r = 1000,
				acc = { --accuracy slightly higher than civil
					0,
					0.1
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3, --damage maintains 30, rather than dropping to 20, hazardous, you're encouraged to not peek too much
				r = 2000,
				acc = { 
					0,
					0.05
				},
				recoil = { 
					0.25,
					0.3 --slightly decreased from civil, from 0.35 to 0.3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3, --30 damage, acc and recoil unchanged from civil
				r = 3000,
				acc = {
					0,
					0.025
				},
				recoil = {
					0.25,
					0.35
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, --help my gun is jammed call 911
				r = 4000,
				acc = {
					0,
					0
				},
				recoil = {
					1,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.complex.is_bullpup = presets.weapon.complex.is_rifle
	presets.weapon.complex.is_shotgun_pump = {
		aim_delay = { --no aim delay for complex, focus delay increases significantly
			0.5,
			0.5
		},
		focus_delay = 3, --significantly quicker focus delay build from civil, peek first, verify, shoot later
		focus_dis = 500, --focus delay only starts past 5m, unchanged from civil
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1, --lowered reload speed greatly from civil, shit starts getting dangerous
		melee_speed = 0.75,
		melee_dmg = 10, --100 damage on melee, no joke, keep as is from civil and up
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 2000, --increased from civil, shotgun types will run'n gun which makes them significantly more hazardous
			far = 3000,
			close = 1500 
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.2,
					0.9
				},
				recoil = { --slightly lowered recoil from civil, lower end has more variance
					0.8,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3, --150 damage, pop your ICTV in two rather than 3, its fair enough with the recoil
				r = 500,
				acc = {
					0.2, --increased from simple, should resolve a few consistency issues
					0.9
				},
				recoil = {
					0.8,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2, --100 damage at 10m, kinda scary.
				r = 1000,
				acc = { --unchanged, they're too powerful for higher accuracy at this point, changing this would have negative effects
					0,
					0.75
				},
				recoil = { --reduced massively from civil
					1.15,
					1.4
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1, --50 damage, lower end of the falloff scale for shotgunners, should remain mostly unchanged acc and damage-wise as increasing their range has negative effects on gameplay and causes too many "who just destroyed all my armor in one shot" situations 
				r = 2000,
				acc = {
					0,
					0.4
				},
				recoil = { --recoil is ok though
					1.2,
					1.8
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0, --10, no longer a threat due to low accuracy and high recoil
				r = 3000,
				acc = {
					0,
					0
				},
				recoil = {
					2,
					4
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.complex.is_shotgun_mag = { --a mix of both shotgun and rifle, its a jack of all trades, HAZARDOUS FOR THAT PRECISE REASON.
		aim_delay = { --no more aim delay on complex.
			0.5,
			0.5
		},
		focus_delay = 4, --focus delay unchanged from civil.
		focus_dis = 500, --unchanged from civil.
		spread = 20, --spread unchanged from civil.
		miss_dis = 20,
		RELOAD_SPEED = 1.25, --saiga no longer has 7 shots per clip, but the animation is still justified because this is "complex"
		melee_speed = 0.75,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500, --more run'n gun
			far = 4000,
			close = 1500
		},
		autofire_rounds = { --this difficulty partially increases the saiga mag-capacity, so this gets increased too
			8,
			16
		},
		--before i start falloff, if you can, go watch that one video of that one terrorist war crime guy eating a cyanide pill mid-trial to express my frustration at overkill simply cloning shotgun_pump for shotgun_mag, and yes, if you're reading this so far, this isnt copy paste, i have willingly chosen to let this message be known every time shotgun mag falloff is ever mentioned in this fucking lua file
		FALLOFF = {
			{
				dmg_mul = 2, --anarchy further increases range and autofire rounds, maintain this one easy to comphrehend
				r = 100,
				acc = {
					0,
					0.12
				},
				recoil = {
					0.05,
					0.05
				},
				mode = {
					0,
					3,
					3,
					1 --ugh fill me with that lead big boy
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0,
					0.12
				},
				recoil = {
					0.05,
					0.1
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 1.5, --75 damage
				r = 1000,
				acc = {
					0,
					0.07
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 1, --50 damage, lower end of the falloff scale
				r = 1500,
				acc = {
					0,
					0.05
				},
				recoil = {
					0.1,
					0.2
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 0,
				r = 2000,
				acc = {
					0,
					0
				},
				recoil = {
					1,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.complex.is_smg = { --used by hrts, cloakers and other sneaky buggers, generally not too scary damage-wise but does hella suppressive fire
		aim_delay = { --aim delay kept, the intent of the weapon is just to build suppression on the player and be generally annoying, its damage isnt worth too much consideration most of the time...MOST of the time.
			0.28,
			0.28
		},
		focus_delay = 4,
		focus_dis = 500, 
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1.5,
		melee_speed = 0.75,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 2000,
			far = 4000,
			close = 1000 --light weight weapon, allows run'n gun, shortened since cloakers exist, will revise later per difficulty
		},
		autofire_rounds = { --defined autofire for smgs, their mag capacity is increased at this difficulty, so auto-fire has to be increased too
			24,
			32
		},
		FALLOFF = {
			{
				dmg_mul = 4, --damage unchanged from civil, keep as is.
				r = 100,
				acc = { 
					0,
					0.1
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0,
					0.1
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 1000,
				acc = { --low accuracy compared to rifles, auto-fire makes up for it
					0,
					0.05
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1, --start dropping damage, hard, accuracy hits a low point
				r = 2000,
				acc = {
					0,
					0.02
				},
				recoil = {
					0.6,
					1.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, -- no longer a threat, gun stops working
				r = 3000,
				acc = {
					0,
					0
				},
				recoil = {
					1.5,
					3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	presets.weapon.complex.is_revolver = { --might be used later for custom revolver-wielding fbis, currently given a similar role to shotguns but with more applied individuality, makes them good joker cops, mostly unchanged from civil outside of no aim delay, a little bit of increased range and reduced focus delay
		aim_delay = {
			0.4,
			0.4
		},
		focus_delay = 4, --4 second focus delay, justified due to increased accuracy of the weapon along with damage scale
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 1.4, --FAST reload.
		melee_speed = 0.75,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = { --leave untouched, long range weapon
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 4, --160 damage start.
				r = 100,
				acc = {
					0,
					0.9
				},
				recoil = {
					0.8,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0,
					0.9
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 4, --120, range remains excellent.
				r = 1000,
				acc = {
					0,
					0.85
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3, --120, great.
				r = 2000,
				acc = {
					0,
					0.7
				},
				recoil = { --lowered slightly from normal for the higher end, was 1.3, is 1
					1,
					1.
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2, --80, lower end of the accuracy scale with very little chance to hit anything unless in high numbers (which wont happen anytime soon)
				r = 3000,
				acc = {
					0,
					0.3 --increased from civil from 0.2 to 0.3
				},
				recoil = {
					1,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.3, --12 damage, acc, recoil and falloff destroy themselves past 4000 no matter what weapon, to keep maps like birth of sky bearable and make open areas less of a pain in the fucking ass 
				r = 4000,
				acc = {
					0,
					0.01
				},
				recoil = {
					4,
					5.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.complex.mini = { --yes
		aim_delay = {
			0.8,
			0.8
		},
		focus_delay = 0.7,
		focus_dis = 100,
		spread = 80, --weapon is mechanically different from every single other npc weapon in the game, works separate from the acc system
		miss_dis = 10,
		RELOAD_SPEED = 0.5,
		melee_speed = 0.75,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 1500, --overall short range, but continues shooting often
			far = 3000,
			close = 1000
		},
		autofire_rounds = { --absolutely in awe of the size of this lad, absolute unit
			100,
			100
		},
		FALLOFF = {
			{
				dmg_mul = 10, --200 damage start, get the fuck out of its way.
				r = 100,
				acc = {
					1,
					1
				},
				recoil = {
					2.7,
					2.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4, --80
				r = 1000,
				acc = {
					1,
					1
				},
				recoil = {
					2.7,
					2.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4 , --80
				r = 2000,
				acc = {
					0.75,
					0.75
				},
				recoil = {
					2.7,
					2.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0,
				r = 3000,
				acc = {
					0,
					0
				},
				recoil = {
					2.7,
					2.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	presets.weapon.complex.is_lmg = { --LMG dozer, usage defined on weapontweakdata to suit it
		aim_delay = {
			0.35,
			0.35
		},
		focus_delay = 1.05, --higher than rifles at this preset to show it as a suppressing bullet hose at longer ranges
		focus_dis = 200,
		spread = 20,
		miss_dis = 5,
		RELOAD_SPEED = 0.9, --decently long pause after burst
		melee_speed = 0.75,
		melee_dmg = 15,
		melee_retry_delay = presets.weapon.expert.is_lmg.melee_retry_delay,
		range = { --cant walk and shoot at ranges beyond 10 meters, pretty good.
			optimal = 1500,
			far = 4000,
			close = 1000
		},
		autofire_rounds = {100, 200}, --bullet hose, kinda scary, fires in random, long bursts though
		FALLOFF = {
			{
				dmg_mul = 3, --60, keeps the gun scarier than rifles.
				r = 100,
				acc = {
					0,
					0.1
				},
				recoil = {
					1.4,
					1.4
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = { --lessened accuracy, firerate keeps it scary
					0,
					0.1
				},
				recoil = {
					1.4,
					1.4
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3, --accuracy and recoil drop begins, no falloff yet to keep it suppressive and scary
				r = 1000,
				acc = {
					0,
					0.02
				},
				recoil = {
					1.4,
					1.4
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2, --little to no falloff, can suppress through misses though, which makes it pressure players for long periods of time
				r = 2000,
				acc = {
					0,
					0.02
				},
				recoil = {
					1.4,
					1.4
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2, --increased slightly from complex, 20 to 40
				r = 3000,
				acc = {
					0,
					0.01
				},
				recoil = {
					1.4,
					1.4
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, --range limit reach, gun stops working, higher recoil than rifles to compensate for the full auto
				r = 4000,
				acc = {
					0,
					0
				},
				recoil = {
					2,
					3
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	
	}
	
	--anarchy begins here, all damage increased slightly, firing ranges are increased dramatically, and gun damage is mostly flat until a sudden skydive at 40m, minor acc or recoil changes, none of that is particularly as bad as the zeal spawngroups in this difficulty however, which can, and will, tear out your asshole through your mouth
	
	presets.weapon.anarchy.is_pistol = {
		aim_delay = { --no aim delay
			0.35,
			0.35
		},
		focus_delay = 5, --focus delay for pistols unchanged, they do a good enough job.
		focus_dis = 100,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 1.4, --slight reduction from civil
		melee_speed = 0.75,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 4000, --cant walk and shoot past this range
			far = 4000, --40m cut off range.
			close = 2000 --20m close range means they'll aim at players consistently, pistols are light weight weapons and dont deal much damage
		},
		FALLOFF = {
			{
				dmg_mul = 4, --increased from complex
				r = 100,
				acc = {
					0, --focus delay build up, unchanged from civil
					0.9
				},
				recoil = {
					0.2,
					0.25
				},
				mode = { --tap fire like crazy, unchanged from civil
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0,
					0.85
				},
				recoil = {
					0.25,
					0.35
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 4, --falloff does not begin, save it for 20m
				r = 1000,
				acc = {
					0,
					0.6
				},
				recoil = {
					0.3,
					0.4
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2, --harsh drop slightly reduced, 
				r = 2000,
				acc = {
					0,
					0.45
				},
				recoil = { 
					0.3,
					0.45
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2, --still dangerous, acc drops hard, but not recoil or firing pattern
				r = 3000,
				acc = {
					0,
					0.25
				},
				recoil = {
					0.35,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.1, --no longer a threat past this range, merely a warning shot
				r = 4000,
				acc = {
					0,
					0.01
				},
				recoil = {
					0.4,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.anarchy.akimbo_pistol = { --isnt ever really used, changing it anyways, mostly matches pistol, but with more bang bang bang and less accuracy, unchanged outside of reload and focus delay for anarchy
		aim_delay = {
			0.35,
			0.35
		},
		focus_delay = 2.5, --less focus delay than pistol, bit eh accuracy wise, so it's fair
		focus_dis = 100,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 1, --slightly reduced from civil
		melee_speed = 0.75,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 3000,
			far = 4000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 4,
				r = 100,
				acc = {
					0,
					0.9
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0,
					0.7
				},
				recoil = {
					0.15,
					0.2
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 1000,
				acc = {
					0,
					0.5
				},
				recoil = {
					0.15,
					0.2
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 2000,
				acc = {
					0,
					0.5
				},
				recoil = {
					0.2,
					0.3
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 0.1, --shorter falloff
				r = 3000,
				acc = {
					0,
					0.01
				},
				recoil = {
					0.4,
					1
				},
				mode = {
					1,
					0,
					1,
					0
				}
			}
		}
	}
	presets.weapon.anarchy.is_rifle = {
		aim_delay = {
			0.35,
			0.35
		},
		focus_delay = 2, --2 sec focus delay build up, accuracy is based of number of enemies on the map, not on the assumption you're squaring off against a single enemy, being outnumbered does not equal being in trouble automatically, but rather, being outnumbered with enemies CLOSE to you is
		focus_dis = 100,
		spread = 20, 
		miss_dis = 5, --experimental change, might make damage feel less forced with the reduced accuracy now
		RELOAD_SPEED = 1.4, --DW style.
		melee_speed = 0.75,
		melee_dmg = 10, --100 damage on melee
		melee_retry_delay = {
			1,
			1
		},
		tase_distance = 1500, --include tase parameters so that tasers can scale with difficulties better, since doing it the other way would keep reload speed, autofire rounds and other parameters unchanged
		aim_delay_tase = {
			0,
			0
		},
		tase_sphere_cast_radius = 5,
		range = {
			optimal = 3000,--optimal range increased, enemies start firing sooner before 30m, but not in a way where they'll fire too much past 40 either
			far = 4000, 
			close = 2000
		},
		autofire_rounds = { --yes.
			30,
			60
		},
		FALLOFF = {
			{
				dmg_mul = 5.5, --damage increased from 50 to 55
				r = 100,
				acc = { 
					0,
					0.2
				},
				recoil = { --increased recoil a tiiiiny bit to make sure it doesn't get too ballistic
					0.2,
					0.2
				},
				mode = { --full auto
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 5.5,
				r = 500,
				acc = {
					0, --increased from simple to create consistency at close ranges in regards to danger
					0.2
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 5, --light damage, recoil and acc falloff begins, really good still, powerful, even
				r = 1000,
				acc = { 
					0,
					0.15
				},
				recoil = {
					0.2,
					0.2 
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4, --light falloff, just enough to count 5 hits on ICTV armor
				r = 2000,
				acc = { 
					0,
					0.1
				},
				recoil = { 
					0.25,
					0.3 --slightly decreased from civil, from 0.35 to 0.3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3, --drop damage by 10, player survivability should be a bit higher now at 6 hits
				r = 3000,
				acc = {
					0,
					0.05 --acc drops
				},
				recoil = {
					0.25,
					0.35
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, --young man, theres no need to get downed, i said, young man, get the fuck off the ground, because, young man, there are cops all around, and the FUCK. ING. DRILL. IS. JAMMED UP.
				r = 4000,
				acc = {
					0,
					0
				},
				recoil = {
					1,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.anarchy.is_bullpup = presets.weapon.anarchy.is_rifle
	presets.weapon.anarchy.is_shotgun_pump = {
		aim_delay = {
			0.5,
			0.5
		},
		focus_delay = 2, --focus delay change here.
		focus_dis = 100, --focus delay only starts past 5m
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1.4, --HOW? ARE THEY JUST PILING ALL THE SHELLS ON THEIR HAND AND JUST SHOVING IT IN THERE LIKE CANDY INTO A BOWL???? either way, quite powerful
		melee_speed = 0.75,
		melee_dmg = 10, --100 damage on melee, no joke, keep as is from civil and up
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 2000, --unchanged, run'n gun remains
			far = 3000,
			close = 1500 
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0,
					0.9
				},
				recoil = { --slightly lowered recoil from civil, lower end has more variance
					0.8,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3, --150 damage, pop your ICTV in two shots
				r = 500,
				acc = {
					0,
					0.9
				},
				recoil = {
					0.8,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3, --150 damage remains, yes, yes, y e s.
				r = 1000,
				acc = { --unchanged, they're too powerful for higher accuracy at this point, changing this would have negative effects
					0,
					0.75
				},
				recoil = { --reduced massively from civil
					1,
					1.2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2, --100 damage, lower end of the falloff scale for shotgunners, should remain mostly unchanged acc and damage-wise as increasing their range has negative effects on gameplay and causes too many "who just destroyed all my armor in one shot" situations 
				r = 2000,
				acc = {
					0,
					0.5
				},
				recoil = { --recoil is ok though, said the slut who is designing this mess
					1.1,
					1.3
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0,
				r = 3000,
				acc = {
					0,
					0
				},
				recoil = {
					2,
					4
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.anarchy.is_shotgun_mag = { --JUGGERNAUT RHGHGHGHGHG
		aim_delay = {
			0.5,
			0.5
		},
		focus_delay = 1.5, --reduced from 2 to 1.5, dozers are priority, you'll see them coming.
		focus_dis = 100, --unchanged from civil.
		spread = 20, --spread unchanged from civil.
		miss_dis = 20,
		RELOAD_SPEED = 1.4, --whew.
		melee_speed = 0.75,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500, --more run'n gun
			far = 4000,
			close = 1500
		},
		autofire_rounds = { --increased from complex, yes, it's terrifying.
			16,
			32
		},
		--before i start falloff, please be aware that, current fuglore has been without internet for quite a few days now, his decision to work on this is probably motivated more from insanity than because he wants to.
		FALLOFF = {
			{
				dmg_mul = 2, --damage unchanged, focus is on increasing frequency of fire and range.
				r = 100,
				acc = {
					0,
					0.12
				},
				recoil = {
					0.05,
					0.05
				},
				mode = {
					0,
					0,
					0,
					1 --ugh fill me with that lead big boy
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0,
					0.12
				},
				recoil = {
					0.05,
					0.05
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1.7, --80 counts one less hit on ICTV
				r = 1000,
				acc = {
					0,
					0.11
				},
				recoil = {
					0.05,
					0.1
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0,
					0.08
				},
				recoil = {
					0.15,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, 
				r = 2500,
				acc = {
					0,
					0
				},
				recoil = {
					4,
					4.2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.anarchy.is_smg = { --used by hrts, light swats, cloakers and other sneaky buggers, generally not too scary damage-wise but does hella suppressive fire
		aim_delay = {
			0.28,
			0.28
		},
		focus_delay = 2,
		focus_dis = 100, 
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 2, --whew.
		melee_speed = 0.75,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 3500,
			far = 4000,
			close = 1000 --light weight weapon, allows run'n gun, shortened since cloakers exist, will revise later per difficulty
		},
		autofire_rounds = { --extended mags a ton, pretty hazardous and continuous
			32,
			60
		},
		FALLOFF = {
			{
				dmg_mul = 4, --damage unchanged from civil, keep as is.
				r = 100,
				acc = { 
					0,
					0.15
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0,
					0.15
				},
				recoil = { 
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 1000,
				acc = { --low accuracy compared to rifles, auto-fire makes up for it
					0,
					0.1
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1, --start dropping damage, hard, accuracy hits a low point
				r = 2000,
				acc = {
					0,
					0.04
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, -- no longer a threat, gun stops working
				r = 3000,
				acc = {
					0,
					0
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	presets.weapon.anarchy.is_revolver = { --used for custom revolver-wielding fbis, currently given a similar role to shotguns but with more applied individuality, makes them good joker cops, gains reasonable reduction in recoil to make it more dangerous
		aim_delay = {
			0.4,
			0.4
		},
		focus_delay = 3, --3 second focus delay, justified due to increased accuracy of the weapon along with damage scale
		focus_dis = 100,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 1.8, --FAST reload.
		melee_speed = 0.75,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = { --leave untouched, long range weapon
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 3, --120 damage start.
				r = 100,
				acc = {
					0,
					0.9
				},
				recoil = {
					0.64,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0,
					0.9
				},
				recoil = {
					0.64,
					1.05
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3, --120, range remains excellent.
				r = 1000,
				acc = {
					0,
					0.9
				},
				recoil = {
					0.7,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2.5, --100, great.
				r = 2000,
				acc = {
					0,
					0.85
				},
				recoil = { --lowered slightly from normal for the higher end, was 1.3, is 1.2
					0.75,
					1.2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1.88, --75, lower end of the accuracy scale with very little chance to hit anything unless in high numbers (which wont happen anytime soon)
				r = 3000,
				acc = {
					0,
					0.25 --slightly increased from civil from 0.2 to 0.25
				},
				recoil = {
					1,
					1.3 
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0, --12 damage, acc, recoil and falloff destroy themselves past 4000 no matter what weapon, to keep maps like birth of sky bearable and make open areas less of a pain in the fucking ass 
				r = 4000,
				acc = {
					0,
					0
				},
				recoil = {
					4,
					5.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.anarchy.mini = { --my wrath is finally............gone...........
		aim_delay = {
			0.7,
			0.7
		},
		focus_delay = 0.7,
		focus_dis = 100,
		spread = 60, --weapon is mechanically different from every single other npc weapon in the game, works separate from the acc system
		miss_dis = 10,
		RELOAD_SPEED = 0.5,
		melee_speed = 0.75,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 1500, --overall short range, but continues shooting often
			far = 3000,
			close = 1000
		},
		autofire_rounds = { --absolutely in awe of the size of this lad, absolute unit
			100,
			100
		},
		FALLOFF = {
			{
				dmg_mul = 10, --200 damage start, get the fuck out of its way.
				r = 100,
				acc = {
					1,
					1
				},
				recoil = {
					2,
					2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 5, --100
				r = 1000,
				acc = {
					1,
					1
				},
				recoil = {
					2,
					2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4 , --80
				r = 2000,
				acc = {
					1,
					1
				},
				recoil = {
					2,
					2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0,
				r = 3000,
				acc = {
					0,
					0
				},
				recoil = {
					2,
					2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	presets.weapon.anarchy.is_lmg = { --LMG dozer, usage defined on weapontweakdata to suit it
		aim_delay = {
			0.35,
			0.35
		},
		focus_delay = 0.7, --higher than rifles, set to 3.
		focus_dis = 100,
		spread = 20,
		miss_dis = 10,
		RELOAD_SPEED = 1.15, --theres 200 ammo in the fucking thing, it'll take time to empty
		melee_speed = 0.75,
		melee_dmg = 15,
		melee_retry_delay = presets.weapon.expert.is_lmg.melee_retry_delay,
		range = { --cant walk and shoot at ranges beyond 10 meters, pretty good.
			optimal = 1500,
			far = 4000,
			close = 1000
		},
		autofire_rounds = {100, 200}, --bullet hose, kinda scary, fires in random, long bursts though
		FALLOFF = {
			{
				dmg_mul = 3, --60, keeps the gun scarier than rifles.
				r = 100,
				acc = {
					0,
					0.1
				},
				recoil = {
					0.8,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = { --lessened accuracy, firerate keeps it scary
					0,
					0.1
				},
				recoil = {
					0.8,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3, --accuracy and recoil drop begins, no falloff yet to keep it suppressive and scary
				r = 1000,
				acc = {
					0,
					0.02
				},
				recoil = {
					0.8,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2, --little to no falloff, can suppress through misses though, which makes it pressure players for long periods of time
				r = 2000,
				acc = {
					0,
					0.02
				},
				recoil = {
					0.8,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2, --increased slightly from complex, 20 to 40
				r = 3000,
				acc = {
					0,
					0.01
				},
				recoil = {
					0.8,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, --range limit reach, gun stops working, higher recoil than rifles to compensate for the full auto
				r = 4000,
				acc = {
					0,
					0
				},
				recoil = {
					2,
					3
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	
	presets.weapon.fbigod = deep_clone(presets.weapon.anarchy)
	
	presets.weapon.fbigod.is_pistol = { --Only used by FBIs on Anarchy, they're tough guys.
		aim_delay = {
			0.28,
			0.28
		},
		focus_delay = 2, --focus delay.
		focus_dis = 500,
		spread = 25,
		miss_dis = 10,
		RELOAD_SPEED = 2.1, --Fast reloads.
		melee_speed = 0.75,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 4000, --cant walk and shoot past this range
			far = 6000, --40m cut off range.
			close = 2000 --20m close range means they'll aim at players consistently, pistols are light weight weapons and dont deal much damage
		},
		FALLOFF = {
			{
				dmg_mul = 6, --increased massively from anarchy, meant to solidify their threat as a veteran unit.
				r = 100,
				acc = {
					0.1, --focus delay build up, unchanged from civil
					0.9
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 6,
				r = 500,
				acc = {
					0.1,
					0.85
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 6, --falloff does not begin, save it for 20m
				r = 1000,
				acc = {
					0,
					0.7 --higher accuracy
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 4, --no harsh drop
				r = 2000,
				acc = {
					0,
					0.5
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 4, --still dangerous, acc drops hard, but not recoil or firing pattern
				r = 3000,
				acc = {
					0,
					0.35
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0, --no longer a threat past this range, merely a warning shot
				r = 4000,
				acc = {
					0,
					0
				},
				recoil = {
					0.05,
					0.05
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.fbigod.akimbo_pistol = { --oh boy why didnt i do this earlier
		aim_delay = { --no aim delay
			0.28,
			0.28
		},
		focus_delay = 2, --focus delay.
		focus_dis = 500,
		spread = 25,
		miss_dis = 10,
		RELOAD_SPEED = 2.1, --Fast reloads.
		melee_speed = 0.75,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 4000, --cant walk and shoot past this range
			far = 6000, --40m cut off range.
			close = 2000 --20m close range means they'll aim at players consistently, pistols are light weight weapons and dont deal much damage
		},
		FALLOFF = {
			{
				dmg_mul = 6, --increased massively from anarchy, meant to solidify their threat as a veteran unit.
				r = 100,
				acc = {
					0.1, --focus delay build up, unchanged from civil
					0.9
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 6,
				r = 500,
				acc = {
					0.1,
					0.85
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 6, --falloff does not begin, save it for 20m
				r = 1000,
				acc = {
					0,
					0.7 --higher accuracy
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 4, --no harsh drop
				r = 2000,
				acc = {
					0,
					0.5
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 4, --still dangerous, acc drops hard, but not recoil or firing pattern
				r = 3000,
				acc = {
					0,
					0.35
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 0, --no longer a threat past this range, merely a warning shot
				r = 4000,
				acc = {
					0,
					0
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.fbigod.is_rifle = {
		aim_delay = {
			0.28,
			0.28
		},
		focus_delay = 0.7,
		focus_dis = 500, --focus delay starts after 5m
		spread = 20, 
		miss_dis = 10, --experimental change, might make damage feel less forced with the reduced accuracy now
		RELOAD_SPEED = 1.8, --DW style.
		melee_speed = 1.5,
		melee_dmg = 10, --100 damage on melee
		melee_retry_delay = {
			1,
			1
		},
		tase_distance = 1500, --include tase parameters so that tasers can scale with difficulties better, since doing it the other way would keep reload speed, autofire rounds and other parameters unchanged
		aim_delay_tase = {
			0,
			0
		},
		tase_sphere_cast_radius = 30,
		range = {
			optimal = 3000,--optimal range increased, enemies start firing sooner before 30m, but not in a way where they'll fire too much past 40 either
			far = 4000, 
			close = 2000
		},
		autofire_rounds = { --yes.
			30,
			60
		},
		FALLOFF = {
			{
				dmg_mul = 7.5, --75 damage for vet boyes
				r = 100,
				acc = { 
					0,
					0.3
				},
				recoil = { --increased recoil a tiiiiny bit to make sure it doesn't get too ballistic
					0.2,
					0.2
				},
				mode = { --full auto
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 7.5,
				r = 500,
				acc = {
					0,
					0.3
				},
				recoil = {
					0.2,
					0.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 7.5, --no damage falloff
				r = 1000,
				acc = { 
					0,
					0.3
				},
				recoil = {
					0.1,
					0.2 
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 7.5, --light falloff
				r = 2000,
				acc = { 
					0,
					0.25
				},
				recoil = { 
					0.25,
					0.3 --slightly decreased from civil, from 0.35 to 0.3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 6,
				r = 3000,
				acc = {
					0,
					0.2 --acc drops
				},
				recoil = {
					0.25,
					0.35
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, --young man, theres no need to get downed, i said, young man, get the fuck off the ground, because, young man, there are cops all around, and the FUCK. ING. DRILL. IS. JAMMED UP.
				r = 4000,
				acc = {
					0,
					0
				},
				recoil = {
					1,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}

	--commonly used presets for enemies replaced by existing presets
	presets.weapon.normal = deep_clone(presets.weapon.civil)
	presets.weapon.good = deep_clone(presets.weapon.civil)
	presets.weapon.expert = deep_clone(presets.weapon.civil)
	presets.weapon.deathwish = deep_clone(presets.weapon.complex)

	presets.weapon.gang_member = {
		is_pistol = {}
	}
	presets.weapon.gang_member.is_pistol.aim_delay = {
		0.2,
		0.3
	}
	presets.weapon.gang_member.is_pistol.focus_delay = 1
	presets.weapon.gang_member.is_pistol.focus_dis = 200
	presets.weapon.gang_member.is_pistol.spread = 25
	presets.weapon.gang_member.is_pistol.miss_dis = 20
	presets.weapon.gang_member.is_pistol.RELOAD_SPEED = 1.5
	presets.weapon.gang_member.is_pistol.melee_speed = 3
	presets.weapon.gang_member.is_pistol.melee_dmg = 3
	presets.weapon.gang_member.is_pistol.melee_retry_delay = presets.weapon.normal.is_pistol.melee_retry_delay
	presets.weapon.gang_member.is_pistol.range = presets.weapon.normal.is_pistol.range
	presets.weapon.gang_member.is_pistol.FALLOFF = {
		{
			dmg_mul = 6.4,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 2.5,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	presets.weapon.gang_member.is_rifle = {
		aim_delay = {
			0.25,
			0.3
		},
		focus_delay = 1,
		focus_dis = 100,
		spread = 25,
		miss_dis = 10,
		RELOAD_SPEED = 1,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = presets.weapon.normal.is_rifle.melee_retry_delay,
		range = {
			optimal = 2500,
			far = 6000,
			close = 1500
		},
		autofire_rounds = {45, 45},
		FALLOFF = {
			{
				dmg_mul = 6.4,
				r = 300,
				acc = {
					1,
					1
				},
				recoil = {
					1,
					1
				},
				mode = {
					0,
					0.25,
					0.25,
					0.5
				}
			},
			{
				dmg_mul = 6.4,
				r = 1000,
				acc = {
					0.9,
					0.9
				},
				recoil = {
					1.1,
					1.35
				},
				mode = {
					0,
					0.25,
					0.25,
					0.5
				}
			},
			{
				dmg_mul = 6.4,
				r = 2000,
				acc = {
					0.5,
					0.5
				},
				recoil = {
					1.5,
					1.75
				},
				mode = {
					0,
					0.25,
					0.5,
					0.25
				}
			},
			{
				dmg_mul = 6.4,
				r = 6000,
				acc = {
					0,
					0.25
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					0,
					0.5,
					0.25,
					0.25
				}
			},
		}
	}
	presets.weapon.gang_member.is_sniper = {
		aim_delay = {
			0.25,
			1
		},
		focus_delay = 1.5,
		focus_dis = 200,
		spread = 25,
		miss_dis = 10,
		RELOAD_SPEED = 1,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = presets.weapon.normal.is_rifle.melee_retry_delay,
		range = {
			optimal = 4000,
			far = 6000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 10,
				r = 500,
				acc = {
					0,
					1
				},
				recoil = {
					1,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 10,
				r = 1000,
				acc = {
					0,
					1
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 10,
				r = 2500,
				acc = {
					0,
					1
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 5,
				r = 4000,
				acc = {
					0,
					1
				},
				recoil = {
					2,
					4
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 5,
				r = 6000,
				acc = {
					0,
					1
				},
				recoil = {
					3,
					6
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.gang_member.is_lmg = {
		aim_delay = {
			0.35,
			0.35
		},
		focus_delay = 1,
		focus_dis = 100,
		spread = 30,
		miss_dis = 10,
		RELOAD_SPEED = 0.7,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = presets.weapon.normal.is_lmg.melee_retry_delay,
		range = {
			optimal = 2500,
			far = 6000,
			close = 1500
		},
		autofire_rounds = {100, 200},
		FALLOFF = {
			{
				dmg_mul = 4,
				r = 100,
				acc = {
					1,
					1
				},
				recoil = {
					2.5,
					3.5
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 1000,
				acc = {
					0.6,
					0.6
				},
				recoil = {
					2.5,
					3.5
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 2000,
				acc = {
					0.3,
					0.3
				},
				recoil = {
					2.5,
					3.5
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.2,
					0.2
				},
				recoil = {
					2.5,
					3.5
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0.4,
				r = 4000,
				acc = {
					0.1,
					0.1
				},
				recoil = {
					1,
					2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0.25,
				r = 6000,
				acc = {
					0.01,
					0.1
				},
				recoil = {
					2,
					3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	presets.weapon.gang_member.is_shotgun_pump = {
		aim_delay = {
			0.25,
			0.3
		},
		focus_delay = 3,
		focus_dis = 100,
		spread = 15,
		miss_dis = 10,
		RELOAD_SPEED = 2,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = presets.weapon.normal.is_shotgun_pump.melee_retry_delay,
		range = presets.weapon.normal.is_shotgun_pump.range,
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 300,
				acc = {
					1,
					1
				},
				recoil = {
					0.75,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1.5,
				r = 1500,
				acc = {
					1,
					1
				},
				recoil = {
					0.75,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.5,
				r = 3000,
				acc = {
					0.5,
					0.75
				},
				recoil = {
					2,
					3
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.gang_member.is_shotgun_mag = {
		aim_delay = {
			0.25,
			0.35
		},
		focus_delay = 1,
		focus_dis = 200,
		spread = 18,
		miss_dis = 10,
		RELOAD_SPEED = 1.6,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = presets.weapon.normal.is_shotgun_mag.melee_retry_delay,
		range = presets.weapon.normal.is_shotgun_mag.range,
		autofire_rounds = {
			4,
			8
		},
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					1,
					1
				},
				recoil = {
					0.1,
					0.1
				},
				mode = {
					1,
					1,
					4,
					6
				}
			},
			{
				dmg_mul = 5,
				r = 500,
				acc = {
					1,
					1
				},
				recoil = {
					0.1,
					0.1
				},
				mode = {
					1,
					1,
					4,
					5
				}
			},
			{
				dmg_mul = 4,
				r = 1000,
				acc = {
					0.85,
					0.95
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					2,
					4,
					4
				}
			},
			{
				dmg_mul = 1.5,
				r = 2000,
				acc = {
					0.75,
					0.9
				},
				recoil = {
					0.25,
					0.45
				},
				mode = {
					1,
					4,
					4,
					1
				}
			},
			{
				dmg_mul = 0.5,
				r = 3000,
				acc = {
					0.4,
					0.7
				},
				recoil = {
					0.4,
					0.5
				},
				mode = {
					4,
					2,
					1,
					0
				}
			},
			{
				dmg_mul = 0.1,
				r = 5000,
				acc = {
					0.05,
					0.2
				},
				recoil = {
					0.5,
					1
				},
				mode = {
					2,
					1,
					0,
					0
				}
			}
		}
	}
	presets.weapon.gang_member.is_smg = presets.weapon.gang_member.is_rifle
	presets.weapon.gang_member.is_pistol = presets.weapon.gang_member.is_pistol
	presets.weapon.gang_member.is_revolver = presets.weapon.gang_member.is_pistol
	presets.weapon.gang_member.is_bullpup = presets.weapon.gang_member.is_rifle
	presets.weapon.gang_member.mac11 = presets.weapon.gang_member.is_smg
	presets.weapon.gang_member.rifle = deep_clone(presets.weapon.gang_member.is_pistol)
	presets.weapon.gang_member.rifle.autofire_rounds = nil
	presets.weapon.gang_member.rifle.FALLOFF = {
		{
			dmg_mul = 10,
			r = 300,
			acc = {
				0,
				1
			},
			recoil = {
				0.45,
				1
			},
			mode = {
				0.5,
				0.5,
				0,
				0
			}
		},
		{
			dmg_mul = 10,
			r = 3000,
			acc = {
				0,
				1
			},
			recoil = {
				0.45,
				1.25
			},
			mode = {
				0.5,
				0.5,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 10000,
			acc = {
				0,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.gang_member.akimbo_pistol = presets.weapon.gang_member.is_pistol
	
	presets.weapon.akuma = deep_clone(presets.weapon.anarchy)
	
	presets.weapon.akuma.is_smg = { --oh? on god?
		aim_delay = {
			0,
			0
		},
		focus_delay = 2,
		focus_dis = 500, 
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 100, 
		melee_speed = 1.5,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = {
			optimal = 3500,
			far = 4000,
			close = 1000 
		},
		autofire_rounds = {
			32,
			60
		},
		
		FALLOFF = {
			{
				dmg_mul = 0,
				r = 100,
				acc = { 
					0,
					0.15
				},
				recoil = {
					0.1,
					0.1
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0,
				r = 500,
				acc = {
					0,
					0.15
				},
				recoil = { 
					0.1,
					0.1
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0,
				r = 1000,
				acc = { 
					0,
					0.1
				},
				recoil = {
					0.5,
					0.9
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0, 
				r = 2000,
				acc = {
					0,
					0.04
				},
				recoil = {
					0.6,
					1.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0,
				r = 3000,
				acc = {
					0,
					0
				},
				recoil = {
					1.5,
					3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	
	presets.enemy_chatter = {
		no_chatter = {},
		cop = {
			aggressive = true,
			contact = true,
			enemyidlepanic = true,
			clear_whisper = true,
			ecm = true,
			saw = true,
			trip_mines = true,
			sentry = true,
			suppress = true,
			dodge = true
		},
		swat = {
			entry = true,
			aggressive = true,
			enemyidlepanic = true,
			retreat = true,
			contact = true,
			clear = true,
			clear_whisper = true,
			go_go = true,
			push = true,
			reload = true,
			look_for_angle = true,
			ecm = true,
			saw = true,
			trip_mines = true,
			sentry = true,
			ready = true,
			smoke = true,
			flash_grenade = true,
			follow_me = true,
			deathguard = true,
			open_fire = true,
			suppress = true,
			dodge = true
		},
		shield = {
            entry = true,
			aggressive = true,
			enemyidlepanic = true,
			retreat = true,
			contact = true,
			clear = true,
			clear_whisper = true,
			go_go = true,
			push = true,
			reload = true,
			look_for_angle = true,
			ecm = true,
			saw = true,
			trip_mines = true,
			sentry = true,
			ready = true,
			follow_me = true,
			deathguard = true,
			open_fire = true,
			suppress = true
        },
		bulldozer = {
			contact = true,
			aggressive = true,
			retreat = true,
			approachingspecial = true
			
		},
		akuma = {
			contact = true,
			aggressive = true,
			approachingspecial = true		
		},
		taser = {
			contact = true,
			aggressive = true,
			retreat = true,
			approachingspecial = true
		},
		medic = {
			aggressive = true,
			contact = true
		},
		spooc = {
			cloakercontact = true,
			go_go = true, --only used for russian cloaker
			cloakeravoidance = true --only used for russian cloaker
		}
	}
	return presets
end

function CharacterTweakData:_set_characters_weapon_preset(preset)
	local all_units = {
		"security",
		"security_undominatable",
		"mute_security_undominatable",
		"cop",
		"cop_scared",
		"cop_female",
		"gensec",
		"swat",
		"heavy_swat",
		"heavy_swat_sniper",
		"fbi_swat",
		"fbi_heavy_swat",
		"city_swat",
		"gangster",
		"biker",
		"biker_escape",
		"mobster",
		"bolivian",
		"bolivian_indoors",
		"bolivian_indoors_mex",
		"tank",
		"tank_hw",
		"tank_medic",
		"tank_mini",
		"spooc",
		"spooc_heavy",
		"shadow_spooc",
		"medic",
		"taser",
		"shield",
		"mobster_boss",
		"biker_boss",
		"chavez_boss",
		"hector_boss",
		"hector_boss_no_armor",
		"drug_lord_boss",
		"drug_lord_boss_stealth"
	}

	for _, name in ipairs(all_units) do
		self[name].weapon = self.presets.weapon[preset]
	end
end

function CharacterTweakData:_set_characters_crumble_chance(light_swat_chance, heavy_swat_chance, common_chance)
	local heavy_units ={
		"fbi_heavy_swat",
		"heavy_swat"
	}
	
	local light_units = {
		"swat",
		"fbi_swat",
		"city_swat"
	}
	
	local common_units = {
		"security",
		"security_undominatable",
		"mute_security_undominatable",
		"cop",
		"cop_female",
		"cop_scared",
		"gangster",
		"bolivian",
		"mobster",
		"biker",
		"mobster",
		"bolivian_indoors",
		"bolivian_indoors_mex"
	}

	for _, cname in ipairs(common_units) do
		self[cname].crumble_chance = common_chance
		self[cname].allow_pass_out = true
		self[cname].damage.fire_damage_mul = 3
	end
	
	for _, lname in ipairs(light_units) do
		self[lname].crumble_chance = light_swat_chance
		self[lname].allow_pass_out = true
		self[lname].damage.fire_damage_mul = 2
	end
	
	for _, hname in ipairs(heavy_units) do
		self[hname].crumble_chance = heavy_swat_chance
		self[hname].damage.fire_damage_mul = 1.5
	end
end

function CharacterTweakData:_init_tank(presets) --TODO: Nothing yet. Note: Can't make this a post hook due to the melee glitch fix, figure something out later to fix it WITH posthooks if possible.
	self.tank = deep_clone(presets.base)
	self.tank.tags = {
		"law",
		"tank",
		"special",
		"protected"
	}
	self.tank.experience = {}
	self.tank.damage.tased_response = {
		light = {
			down_time = 0,
			tased_time = 1
		},
		heavy = {
			down_time = 0,
			tased_time = 2
		}
	}
	self.tank.weapon = deep_clone(presets.weapon.civil)
	self.tank.detection = presets.detection.enemymook
	self.tank.HEALTH_INIT = 300
	self.tank.headshot_dmg_mul = 4
	self.tank.damage.explosion_damage_mul = 1 --lowered from base, was 1.1 now just 1, dunno why they thought it was a good idea to make explosives more powerful against him.
	self.tank.damage.fire_damage_mul = 2
	self.tank.move_speed = presets.move_speed.slow_consistency
	self.tank.allowed_stances = {
		cbt = true
	}
	self.tank.allowed_poses = {
		stand = true
	}
	self.tank.crouch_move = false
	self.tank.no_run_start = true
	self.tank.no_run_stop = true
	self.tank.no_retreat = nil
	self.tank.no_arrest = true
	self.tank.surrender = nil
	self.tank.ecm_vulnerability = 0 --no more dozer weirdness due to ecms, also a buff I guess.
	self.tank.ecm_hurts = {
		ears = {
			max_duration = 3,
			min_duration = 1
		}
	}
	self.tank.weapon_voice = "3"
	self.tank.experience.cable_tie = "tie_swat"
	self.tank.access = "tank"
	self.tank.speech_prefix_p1 = self._prefix_data_p1.bulldozer()
	self.tank.speech_prefix_p2 = nil
	self.tank.speech_prefix_count = nil
	self.tank.spawn_sound_event = self._prefix_data_p1.bulldozer() .. "_entrance" --BULLDOZER, COMING THROUGH!!!
	self.tank.priority_shout = "f30"
	self.tank.rescue_hostages = false
	self.tank.deathguard = true
	self.tank.melee_weapon = "fists"
	self.tank.melee_weapon_dmg_multiplier = 2.5
	self.tank.critical_hits = {
		damage_mul = self.tank.headshot_dmg_mul * 1
	}
	self.tank.die_sound_event = "bdz_x02a_any_3p"
	self.tank.damage.hurt_severity = presets.hurt_severities.no_hurts
	self.tank.chatter = presets.enemy_chatter.bulldozer
	self.tank.announce_incomming = "incomming_tank"
	self.tank.steal_loot = nil
	self.tank.calls_in = nil
	self.tank.use_animation_on_fire_damage = false
	self.tank.flammable = true
	self.tank.can_be_tased = false
	self.tank.immune_to_knock_down = true
	self.tank.immune_to_concussion = true

	self.tank_hw = deep_clone(self.tank)
	self.tank_hw.tags = {
		"law",
		"tank",
		"special"
	}
	self.tank_hw.move_speed = presets.move_speed.slow_consistency --lol stop
	self.tank_hw.HEALTH_INIT = 40 --1600 on top difficulty, encourage teamfire against these guys since they're gonna be on the halloween maps
	self.tank_hw.headshot_dmg_mul = 1
	self.tank_hw.ignore_headshot = true
	self.tank_hw.damage.explosion_damage_mul = 8 --explosives can eliminate them very easily
	self.tank_hw.damage.fire_damage_mul = 8
	self.tank_hw.use_animation_on_fire_damage = false
	self.tank_hw.flammable = true
	self.tank_hw.can_be_tased = false
	self.tank_hw.melee_weapon = "helloween"

	self.tank_medic = deep_clone(self.tank)
	self.tank_medic.move_speed = presets.move_speed.simple_consistency --tiny bit faster, their gun is lighter.
	self.tank_medic.weapon = deep_clone(presets.weapon.civil)
	self.tank_medic.spawn_sound_event = self._prefix_data_p1.bulldozer() .. "_entrance_elite"
	self.tank_medic.tags = {
		"law",
		"tank",
		"medic",
		"special",
		"protected"
	}

	self.tank_mini = deep_clone(self.tank)
	self.tank_mini.weapon.mini = {}
	self.tank_mini.move_speed = presets.move_speed.mini_consistency --New movement presets.
	self.tank_mini.spawn_sound_event = self._prefix_data_p1.bulldozer() .. "_entrance_elite"
	self.tank_mini.always_face_enemy = true
	self.tank_mini.damage.fire_damage_mul = 1
	self.tank_mini.melee_weapon = nil
	self.tank_mini.melee_weapon_dmg_multiplier = nil

	self.tank_ftsu = deep_clone(self.tank) --and just like that, ive turned a meme into a real thing
	self.tank_ftsu.tags = {
		"law",
		"tank",
		"special"
	}
	self.tank_ftsu.weapon = presets.weapon.rhythmsniper
	self.tank_ftsu.move_speed = presets.move_speed.mini_consistency
	self.tank_ftsu.spawn_sound_event = self._prefix_data_p1.bulldozer() .. "_entrance_elite"
	self.tank_ftsu.always_face_enemy = nil

	table.insert(self._enemy_list, "tank")
	table.insert(self._enemy_list, "tank_hw")
	table.insert(self._enemy_list, "tank_medic")
	table.insert(self._enemy_list, "tank_mini")
	table.insert(self._enemy_list, "tank_ftsu")
end

function CharacterTweakData:_init_spooc(presets) --Can't make this into a post hook, dodge with grenades gets re-enabled if I do, which isn't good for anybody, destroys framerates and doesn't let him use ninja_complex dodges.
	self.spooc = deep_clone(presets.base)
	self.spooc.tags = {
		"law",
		"spooc",
		"special",
		"takedown"
	}
	self.spooc.experience = {}
	self.spooc.weapon = deep_clone(presets.weapon.civil)
	self.spooc.detection = presets.detection.enemymook
	self.spooc.HEALTH_INIT = 20
	self.spooc.headshot_dmg_mul = 6
	self.spooc.damage.fire_damage_mul = 2
	self.spooc.move_speed = presets.move_speed.lightning_constant
	self.spooc.no_retreat = nil
	self.spooc.no_arrest = true
	self.spooc.damage.hurt_severity = presets.hurt_severities.specialenemy
	self.spooc.surrender_break_time = {
		4,
		6
	}
	self.spooc.damage.no_suppression_crouch = true
	self.spooc.suppression = presets.suppression.stalwart_nil
	self.spooc.no_fumbling = true
	self.spooc.no_suppression_reaction = true
	self.spooc.surrender = presets.surrender.special
	self.spooc.priority_shout = "f33"
	self.spooc.priority_shout_max_dis = 700
	self.spooc.rescue_hostages = false
	self.spooc.spooc_attack_timeout = {
		0.35,
		0.35
	}
	self.spooc.spooc_attack_beating_time = {
		3,
		3
	}
	self.spooc.spooc_attack_use_smoke_chance = 0 --lol stop
	self.spooc.weapon_voice = "3"
	self.spooc.experience.cable_tie = "tie_swat"
	self.spooc.speech_prefix_p1 = self._prefix_data_p1.cloaker()
	self.spooc.speech_prefix_p2 = nil
	self.spooc.speech_prefix_count = nil
	self.spooc.access = "spooc"
	self.spooc.melee_weapon = "baton"
	self.spooc.use_animation_on_fire_damage = true
	self.spooc.flammable = true
	self.spooc.dodge = presets.dodge.ninja
	self.spooc.chatter = presets.enemy_chatter.spooc
	self.spooc.steal_loot = nil
	self.spooc.spawn_sound_event = "cloaker_presence_loop"
	self.spooc.die_sound_event = "cloaker_presence_stop"
	self.spooc.spooc_sound_events = {
		detect_stop = "cloaker_detect_stop",
		detect = "cloaker_detect_mono"
	}
	self.spooc_heavy = deep_clone(self.spooc)

	table.insert(self._enemy_list, "spooc")
	table.insert(self._enemy_list, "spooc_heavy")
end

Hooks:PostHook(CharacterTweakData, "_init_shadow_spooc", "hhpost_s_spooc", function(self, presets)
	self.shadow_spooc = deep_clone(presets.base)
	self.shadow_spooc.tags = {
		"law",
		"takedown"
	}
	self.shadow_spooc.experience = {}
	self.shadow_spooc.weapon = deep_clone(presets.weapon.fbigod)
	self.shadow_spooc.detection = presets.detection.normal
	self.shadow_spooc.HEALTH_INIT = 50
	self.shadow_spooc.headshot_dmg_mul = 4
	self.shadow_spooc.move_speed = presets.move_speed.lightning_constant
	self.shadow_spooc.no_retreat = true
	self.shadow_spooc.no_arrest = true
	self.shadow_spooc.no_fumbling = true
	self.shadow_spooc.no_suppression_reaction = true
	self.shadow_spooc.damage.hurt_severity = presets.hurt_severities.specialenemy
	self.shadow_spooc.surrender_break_time = {
		4,
		6
	}
	self.shadow_spooc.suppression = nil
	self.shadow_spooc.surrender = nil
	self.shadow_spooc.silent_priority_shout = "f37"
	self.shadow_spooc.priority_shout_max_dis = 700
	self.shadow_spooc.rescue_hostages = false
	self.shadow_spooc.spooc_attack_timeout = {
		0.35,
		0.35
	}
	self.shadow_spooc.spooc_attack_beating_time = {
		0.35,
		0.35
	}
	self.shadow_spooc.spooc_attack_use_smoke_chance = 0
	self.shadow_spooc.weapon_voice = "3"
	self.shadow_spooc.experience.cable_tie = "tie_swat"
	self.shadow_spooc.speech_prefix_p1 = "uno_clk"
	self.shadow_spooc.speech_prefix_p2 = nil
	self.shadow_spooc.speech_prefix_count = nil
	self.shadow_spooc.access = "spooc"
	self.shadow_spooc.use_radio = nil
	self.shadow_spooc.use_animation_on_fire_damage = false
	self.shadow_spooc.flammable = false
	self.shadow_spooc.dodge = presets.dodge.ninja_complex
	self.shadow_spooc.chatter = presets.enemy_chatter.no_chatter
	self.shadow_spooc.do_not_drop_ammo = true
	self.shadow_spooc.steal_loot = nil
	self.shadow_spooc.spawn_sound_event = "uno_cloaker_presence_loop"
	self.shadow_spooc.die_sound_event = "uno_cloaker_presence_stop"
	self.shadow_spooc.spooc_sound_events = {
		detect_stop = "uno_cloaker_detect_stop",
		taunt_during_assault = "",
		taunt_after_assault = "",
		detect = "uno_cloaker_detect"
	}

	table.insert(self._enemy_list, "shadow_spooc")
end)

Hooks:PostHook(CharacterTweakData, "_init_shield", "hhpost_shield", function(self, presets) --TODO: Nothing yet.
	self.shield = deep_clone(presets.base)
	self.shield.tags = {
		"law",
		"shield",
		"special",
		"dense"
	}
	self.shield.experience = {}
	self.shield.weapon = presets.weapon.simple
	self.shield.detection = presets.detection.enemymook
	self.shield.HEALTH_INIT = 16
	self.shield.headshot_dmg_mul = 12
	self.shield.allowed_stances = {
		cbt = true
	}
	self.shield.allowed_poses = {
		crouch = true
	}
	self.shield.always_face_enemy = true
	self.shield.move_speed = presets.move_speed.shield_sim
	self.shield.no_run_start = true
	self.shield.no_run_stop = true
	self.shield.no_retreat = nil
	self.shield.no_arrest = true
	self.shield.no_fumbling = true
	self.shield.no_suppression_reaction = true
	self.shield.surrender = nil
	self.shield.priority_shout = "f31"
	self.shield.rescue_hostages = false
	self.shield.deathguard = true
	self.shield.no_equip_anim = true
	self.shield.damage.explosion_damage_mul = 0.8
	self.shield.damage.fire_damage_mul = 0.5
	self.shield.calls_in = nil
	self.shield.ignore_medic_revive_animation = true
	self.shield.damage.shield_knocked = true
	self.shield.use_animation_on_fire_damage = false
	self.shield.flammable = true
	self.shield.speech_prefix_p1 = "l"
	self.shield.speech_prefix_p2 = "d" --uses zeal voice to signal presence at lower difficulties, on higher difficulties, their shield knocking is enough
	self.shield.speech_prefix_count = 5
	self.shield.spawn_sound_event = "shield_identification" --important
	self.shield.access = "shield"
	self.shield.chatter = presets.enemy_chatter.shield
	self.shield.announce_incomming = "incomming_shield"
	self.shield.steal_loot = nil
	self.shield.use_animation_on_fire_damage = false

	table.insert(self._enemy_list, "shield")
	
	self.akuma = deep_clone(self.shield)
	self.akuma.weapon = presets.weapon.akuma
	self.akuma.move_speed = presets.move_speed.lightning_constant
	self.akuma.speech_prefix_p1 = nil
	self.akuma.speech_prefix_p2 = nil
	self.akuma.chatter = presets.enemy_chatter.akuma
	self.akuma.custom_voicework = "akuma"
	self.akuma.no_fumbling = true
	self.akuma.no_suppression_reaction = true
	self.akuma.do_not_drop_ammo = true
	self.akuma.surrender = nil
	table.insert(self._enemy_list, "akuma")
	
end)

Hooks:PostHook(CharacterTweakData, "_init_medic", "hhpost_medic", function(self, presets) --TODO: Nothing right now.
	self.medic.tags = {
		"law",
		"medic",
		"special",
		"dense"
	}
	self.medic.weapon = presets.weapon.civil
	self.medic.detection = presets.detection.enemymook
	self.medic.HEALTH_INIT = 18 --health lowered slightly to keep medics less tanky, tanky medics create unsolvable situations and aren't too fun.
	self.medic.headshot_dmg_mul = 12
	self.medic.damage.hurt_severity = presets.hurt_severities.specialenemy
	self.medic.damage.no_suppression_crouch = true
	self.medic.suppression = presets.suppression.stalwart_nil
	self.medic.no_fumbling = true
	self.medic.no_suppression_reaction = true
	self.medic.no_retreat = nil
	self.medic.surrender = presets.surrender.special
	self.medic.move_speed = presets.move_speed.civil_consistency
	self.medic.surrender_break_time = {
		7,
		12
	}
	self.medic.ecm_vulnerability = 1
	self.medic.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.medic.chatter = presets.enemy_chatter.medic
	self.medic.experience.cable_tie = "tie_swat"
	self.medic.speech_prefix_p1 = self._prefix_data_p1.medic()
	self.medic.speech_prefix_p2 = nil
	self.medic.speech_prefix_count = nil
	self.medic.spawn_sound_event = self._prefix_data_p1.medic() .. "_entrance"
	self.medic.silent_priority_shout = "f37"
	self.medic.access = "swat"
	self.medic.dodge = presets.dodge.athletic
	self.medic.melee_weapon = "knife_1"
	self.medic.deathguard = true
	self.medic.no_arrest = true
end)

Hooks:PostHook(CharacterTweakData, "_init_taser", "hhpost_taser", function(self, presets) --TODO: Nothing right now.
	self.taser.tags = {
		"law",
		"taser",
		"special",
		"takedown"
	}
	self.taser.weapon = presets.weapon.simple
	self.taser.detection = presets.detection.enemymook
	self.taser.HEALTH_INIT = 24 
	self.taser.headshot_dmg_mul = 2
	self.taser.damage.fire_damage_mul = 0.5
	self.taser.damage.hurt_severity = presets.hurt_severities.specialenemy
	self.taser.move_speed = presets.move_speed.civil_consistency
	self.taser.suppression = presets.suppression.stalwart_nil
	self.taser.no_fumbling = true
	self.taser.no_suppression_reaction = true
	self.taser.no_retreat = nil
	self.taser.no_arrest = true
	self.taser.surrender = presets.surrender.special
	self.taser.ecm_vulnerability = 0.9
	self.taser.ecm_hurts = {
		ears = {
			max_duration = 8,
			min_duration = 6
		}
	}
	self.taser.surrender_break_time = {
		4,
		6
	}
	self.taser.suppression = nil
	self.taser.speech_prefix_p1 = self._prefix_data_p1.taser()
	self.taser.speech_prefix_p2 = nil
	self.taser.speech_prefix_count = nil
	self.taser.spawn_sound_event = self._prefix_data_p1.taser() .. "_entrance"
	self.taser.access = "taser"
	self.taser.melee_weapon = "fists"
	self.taser.chatter = presets.enemy_chatter.taser
	self.taser.dodge = presets.dodge.athletic
	self.taser.priority_shout = "f32"
	self.taser.rescue_hostages = false
	self.taser.deathguard = true
	self.taser.announce_incomming = "incomming_taser"
	self.taser.steal_loot = nil
	self.taser.die_sound_event = "tsr_x02a_any_3p"
	
end)

Hooks:PostHook(CharacterTweakData, "_init_swat", "hhpost_swat", function(self, presets)
	self.swat.tags = {
		"law",
		"dense"
	}
	self.swat.weapon = presets.weapon.simple
	self.swat.detection = presets.detection.enemymook
	self.swat.HEALTH_INIT = 4
	self.swat.headshot_dmg_mul = 12
	self.swat.move_speed = presets.move_speed.simple_consistency
	self.swat.damage.hurt_severity = presets.hurt_severities.hordemook
	self.swat.suppression = presets.suppression.hard_agg
	self.swat.surrender = presets.surrender.easy
	self.swat.experience.cable_tie = "tie_swat"
	self.swat.speech_prefix_p1 = self._prefix_data_p1.swat()
	self.swat.speech_prefix_p2 = "n"
	self.swat.speech_prefix_count = 4	
	self.swat.access = "swat"
	self.swat.dodge = presets.dodge.athletic
	self.swat.no_arrest = true
	self.swat.no_retreat = nil
	self.swat.chatter = presets.enemy_chatter.swat
	self.swat.melee_weapon_dmg_multiplier = 1
	self.swat.steal_loot = true

	table.insert(self._enemy_list, "swat")
end)

Hooks:PostHook(CharacterTweakData, "_init_fbi", "hhpost_fbi", function(self, presets)
	self.fbi = deep_clone(presets.base)
	self.fbi.tags = {
		"law",
		"dense"
	}
	self.fbi.experience = {}
	self.fbi.weapon = presets.weapon.complex
	self.fbi.detection = presets.detection.enemymook
	self.fbi.no_fumbling = true
	self.fbi.no_suppression_reaction = true
	self.fbi.no_retreat = nil
	self.fbi.HEALTH_INIT = 16
	self.fbi.headshot_dmg_mul = 6
	self.fbi.move_speed = presets.move_speed.civil_consistency
	self.fbi.damage.no_suppression_crouch = true
	self.fbi.suppression = presets.suppression.stalwart_nil
	self.fbi.surrender = presets.surrender.hard
	self.fbi.damage.hurt_severity = presets.hurt_severities.specialenemy
	self.fbi.ecm_vulnerability = 1
	self.fbi.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.fbi.weapon_voice = "2"
	self.fbi.experience.cable_tie = "tie_swat"
	self.fbi.speech_prefix_p1 = "l"
	self.fbi.speech_prefix_p2 = "n"
	self.fbi.speech_prefix_count = 4
	self.fbi.silent_priority_shout = "f37"
	self.fbi.access = "fbi"
	self.fbi.melee_weapon = "fists"
	self.fbi.dodge = presets.dodge.athletic
	self.fbi.deathguard = true
	self.fbi.no_arrest = true
	self.fbi.chatter = presets.enemy_chatter.swat
	self.fbi.steal_loot = true
	self.fbi_xc45 = deep_clone(self.fbi)
	self.fbi_xc45.damage.hurt_severity = presets.hurt_severities.no_hurts
	self.fbi_xc45.allowed_stances = {
		cbt = true
	}
	self.fbi_xc45.use_animation_on_fire_damage = false
	self.fbi_xc45.melee_weapon = nil
	
end)

Hooks:PostHook(CharacterTweakData, "_init_heavy_swat", "hhpost_hswat", function(self, presets) --TODO: Nothing right now.
	self.heavy_swat = deep_clone(presets.base)
	self.heavy_swat.tags = {
		"law",
		"dense"
	}
	self.heavy_swat.experience = {}
	self.heavy_swat.weapon = presets.weapon.simple
	self.heavy_swat.detection = presets.detection.enemymook
	self.heavy_swat.HEALTH_INIT = 20
	self.heavy_swat.headshot_dmg_mul = 6
	self.heavy_swat.damage.explosion_damage_mul = 1
	self.heavy_swat.move_speed = presets.move_speed.simple_consistency
	self.heavy_swat.damage.hurt_severity = presets.hurt_severities.heavyhordemook
	self.heavy_swat.suppression = presets.suppression.hard_agg
	self.heavy_swat.surrender = presets.surrender.easy
	self.heavy_swat.experience.cable_tie = "tie_swat"
	self.heavy_swat.speech_prefix_p1 = self._prefix_data_p1.heavy_swat()
	self.heavy_swat.speech_prefix_p2 = "n"
	self.heavy_swat.speech_prefix_count = 4
	self.heavy_swat.melee_weapon = "fists"
	self.heavy_swat.access = "swat"
	self.heavy_swat.dodge = presets.dodge.heavy
	self.heavy_swat.no_arrest = true
	self.heavy_swat.no_retreat = nil
	self.heavy_swat.chatter = presets.enemy_chatter.swat
	self.heavy_swat.steal_loot = true
	self.heavy_swat_sniper = deep_clone(self.heavy_swat)
	self.heavy_swat_sniper.weapon = presets.weapon.rhythmsniper --TODO: Custom assault sniper set up, that doesn't suck dick and make the game unfun.

	table.insert(self._enemy_list, "heavy_swat")
	table.insert(self._enemy_list, "heavy_swat_sniper")
end)

Hooks:PostHook(CharacterTweakData, "_init_fbi_swat", "hhpost_fswat", function(self, presets)
	self.fbi_swat.tags = {
		"law",
		"dense"
	}
	self.fbi_swat.weapon = presets.weapon.civil
	self.fbi_swat.detection = presets.detection.enemymook
	self.fbi_swat.HEALTH_INIT = 4
	self.fbi_swat.headshot_dmg_mul = 12
	self.fbi_swat.move_speed = presets.move_speed.simple_consistency
	self.fbi_swat.suppression = presets.suppression.hard_def
	self.fbi_swat.surrender = presets.surrender.easy
	self.fbi_swat.damage.hurt_severity = presets.hurt_severities.hordemook
	self.fbi_swat.speech_prefix_p1 = self._prefix_data_p1.swat()
	self.fbi_swat.speech_prefix_p2 = "n"
	self.fbi_swat.speech_prefix_count = 4
	self.fbi_swat.access = "swat"
	self.fbi_swat.dodge = presets.dodge.athletic
	self.fbi_swat.no_arrest = true
	self.fbi_swat.no_retreat = nil
	self.fbi_swat.chatter = presets.enemy_chatter.swat
	self.fbi_swat.melee_weapon = "knife_1"
	self.fbi_swat.steal_loot = true
	
	table.insert(self._enemy_list, "fbi_swat")
	
	self.armored_swat = deep_clone(self.fbi_swat)
	self.armored_swat.tags = {
		"law",
		"protected_reverse",
		"dense"
	}
	self.armored_swat.HEALTH_INIT = 200
	self.armored_swat.headshot_dmg_mul = 12
	self.armored_swat.move_speed = presets.move_speed.civil_consistency
	self.armored_swat.damage.hurt_severity = presets.hurt_severities.heavyhordemook
	self.armored_swat.surrender = presets.surrender.hard
	table.insert(self._enemy_list, "armored_swat")
	
end)

Hooks:PostHook(CharacterTweakData, "_init_fbi_heavy_swat", "hhpost_fhswat", function(self, presets) --TODO: Nothing right now.
	self.fbi_heavy_swat.tags = {
		"law",
		"dense"
	}
	self.fbi_heavy_swat.weapon = presets.weapon.civil
	self.fbi_heavy_swat.detection = presets.detection.enemymook
	self.fbi_heavy_swat.HEALTH_INIT = 20
	self.fbi_heavy_swat.headshot_dmg_mul = 6
	self.fbi_heavy_swat.damage.explosion_damage_mul = 1
	self.fbi_heavy_swat.move_speed = presets.move_speed.simple_consistency
	self.fbi_heavy_swat.damage.hurt_severity = presets.hurt_severities.heavyhordemook
	self.fbi_heavy_swat.suppression = presets.suppression.hard_agg
	self.fbi_heavy_swat.surrender = presets.surrender.easy
	self.fbi_heavy_swat.speech_prefix_p1 = self._prefix_data_p1.heavy_swat()
	self.fbi_heavy_swat.speech_prefix_p2 = "n"
	self.fbi_heavy_swat.speech_prefix_count = 4
	self.fbi_heavy_swat.access = "swat"
	self.fbi_heavy_swat.dodge = presets.dodge.heavy
	self.fbi_heavy_swat.no_arrest = true
	self.fbi_heavy_swat.no_retreat = nil
	self.fbi_heavy_swat.chatter = presets.enemy_chatter.swat
	self.fbi_heavy_swat.melee_weapon = "knife_1"
	self.fbi_heavy_swat.steal_loot = true
	
end)

Hooks:PostHook(CharacterTweakData, "_init_city_swat", "hhpost_cswat", function(self, presets)
	self.city_swat.tags = {
		"law",
		"dense"
	}
	self.city_swat.weapon = presets.weapon.civil
	self.city_swat.detection = presets.detection.enemymook
	self.city_swat.HEALTH_INIT = 4
	self.city_swat.headshot_dmg_mul = 12	
	self.city_swat.move_speed = presets.move_speed.simple_consistency
	self.city_swat.damage.hurt_severity = presets.hurt_severities.hordemook
	self.city_swat.suppression = presets.suppression.hard_def
	self.city_swat.surrender = presets.surrender.easy
	self.city_swat.silent_priority_shout = "f37"
	self.city_swat.speech_prefix_p1 = self._prefix_data_p1.heavy_swat()
	self.city_swat.speech_prefix_p2 = "n"
	self.city_swat.speech_prefix_count = 4
	self.city_swat.access = "swat"
	self.city_swat.no_retreat = nil
	self.city_swat.dodge = presets.dodge.athletic
	self.city_swat.chatter = presets.enemy_chatter.swat
	self.city_swat.melee_weapon = "knife_1"
	self.city_swat.steal_loot = true
	self.city_swat.has_alarm_pager = true
end)

Hooks:PostHook(CharacterTweakData, "_init_sniper", "hhpost_sniper", function(self, presets)
	self.sniper = deep_clone(presets.base)
	self.sniper.tags = {
		"law",
		"sniper",
		"dense",
		"special"
	}
	self.sniper.experience = {}
	self.sniper.weapon = presets.weapon.rhythmsniper --this is important, makes them use the mini turret sniper mode.
	self.sniper.detection = presets.detection.sniper
	self.sniper.damage.hurt_severity = presets.hurt_severities.no_hurts --minimize sniper annoyance, just shoot the cunts.
	self.sniper.allowed_stances = {
		cbt = true
	}
	self.sniper.HEALTH_INIT = 1
	self.sniper.headshot_dmg_mul = 2	
	self.sniper.move_speed = presets.move_speed.simple_consistency
	self.sniper.shooting_death = false
	self.sniper.no_move_and_shoot = true
	self.sniper.move_and_shoot_cooldown = 1
	self.sniper.suppression = nil --i dont want to put stalwart versions of suppression here due to it hampering the sniper's ability to hold down areas properly.
	self.sniper.ecm_vulnerability = 1
	self.sniper.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.sniper.weapon_voice = "1"
	self.sniper.experience.cable_tie = "tie_swat"
	self.sniper.speech_prefix_p1 = "l"
	self.sniper.speech_prefix_p2 = "n"
	self.sniper.speech_prefix_count = 4
	self.sniper.priority_shout = "f34"
	self.sniper.access = "sniper"
	self.sniper.no_retreat = nil
	self.sniper.no_arrest = true
	self.sniper.chatter = presets.enemy_chatter.no_chatter
	self.sniper.steal_loot = nil
	self.sniper.rescue_hostages = false

	table.insert(self._enemy_list, "sniper")
end)

Hooks:PostHook(CharacterTweakData, "_init_gangster", "hhpost_gangster", function(self, presets)
	local job = Global.level_data and Global.level_data.level_id
	self.gangster.HEALTH_INIT = 6
	self.gangster.headshot_dmg_mul = 12
	if job == "nightclub" or job == "short2_stage1" or job == "jolly" or job == "spa" then
		self.gangster.speech_prefix_p1 = "rt"
		self.gangster.speech_prefix_p2 = nil
		self.gangster.speech_prefix_count = 2
	elseif job == "alex_2" then
		self.gangster.speech_prefix_p1 = "ict"
		self.gangster.speech_prefix_p2 = nil
		self.gangster.speech_prefix_count = 2
	elseif job == "welcome_to_the_jungle_1" then
		self.gangster.speech_prefix_p1 = "bik"
		self.gangster.speech_prefix_p2 = nil
		self.gangster.speech_prefix_count = 2
	else
		self.gangster.speech_prefix_p1 = "lt"
		self.gangster.speech_prefix_p2 = nil
		self.gangster.speech_prefix_count = 2
	end
	self.gangster.chatter = {
		aggressive = true,
		retreat = true,
		contact = true,
		go_go = true,
		suppress = true,
		enemyidlepanic = true
	}
end)

Hooks:PostHook(CharacterTweakData, "_init_biker", "hhpost_biker", function(self, presets)
	self.biker.HEALTH_INIT = 6
	self.biker.headshot_dmg_mul = 12
	self.biker.speech_prefix_p1 = "bik"
	self.biker.speech_prefix_p2 = nil
	self.biker.speech_prefix_count = 2	
	self.biker.chatter = {
		aggressive = true,
		retreat = true,
		contact = true,
		go_go = true,
		suppress = true,
		enemyidlepanic = true
	}
	local job = Global.level_data and Global.level_data.level_id
	if job == "mex" or job == "mex_cooking" then
		self.biker.access = "security"
	else
		self.biker.access = "gangster"
	end
end)

Hooks:PostHook(CharacterTweakData, "_init_bolivians", "hhpost_bolivians", function(self, presets)
	self.bolivian.HEALTH_INIT = 6
	self.bolivian.headshot_dmg_mul = 12
	self.bolivian.speech_prefix_p1 = "lt"
	self.bolivian.speech_prefix_p2 = nil
	self.bolivian.speech_prefix_count = 2
	self.bolivian.chatter = {
		aggressive = true,
		retreat = true,
		contact = true,
		go_go = true,
		suppress = true,
		enemyidlepanic = true
	}
	self.bolivian_indoors.HEALTH_INIT = 6
	self.bolivian_indoors.headshot_dmg_mul = 12
	self.bolivian_indoors.speech_prefix_p1 = "lt"
	self.bolivian_indoors.speech_prefix_p2 = nil
	self.bolivian_indoors.speech_prefix_count = 2
	self.bolivian_indoors.chatter = {
		aggressive = true,
		retreat = true,
		contact = true,
		go_go = true,
		suppress = true,
		enemyidlepanic = true
	}
	self.bolivian_indoors_mex = deep_clone(self.bolivian_indoors)
	self.bolivian_indoors_mex.has_alarm_pager = true
	local job = Global.level_data and Global.level_data.level_id
	if job == "mex" or job == "mex_cooking" then
		self.bolivian_indoors_mex.access = "security"
	else
		self.bolivian_indoors_mex.access = "gangster"
	end
end)

Hooks:PostHook(CharacterTweakData, "_init_old_hoxton_mission", "hhpost_hoxton", function(self, presets)
	self.old_hoxton_mission.move_speed = presets.move_speed.very_fast
	self.old_hoxton_mission.crouch_move = false
	self.old_hoxton_mission.suppression = presets.suppression.stalwart_nil
	self.old_hoxton_mission.weapon = deep_clone(presets.weapon.fbigod)
end)

Hooks:PostHook(CharacterTweakData, "_init_cop", "hhpost_cop", function(self, presets)
	self.cop.HEALTH_INIT = 6
	self.cop.headshot_dmg_mul = 12
	if self.tweak_data and self.tweak_data.levels then
		local faction = self.tweak_data.levels:get_ai_group_type()
		if faction == "america" then
			self.cop.melee_weapon = "baton"
		else
			self.cop.melee_weapon = nil
		end
	end
end)

Hooks:PostHook(CharacterTweakData, "_init_gensec", "hhpost_gensec", function(self, presets)
	self.gensec.HEALTH_INIT = 6
	self.gensec.headshot_dmg_mul = 12
end)

Hooks:PostHook(CharacterTweakData, "_init_security", "hhpost_secsec", function(self, presets)
	self.security.HEALTH_INIT = 6
	self.security.headshot_dmg_mul = 12
end)

Hooks:PostHook(CharacterTweakData, "_init_mobster_boss", "hhpost_mboss", function(self, presets)
	self.mobster_boss.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase
end)

Hooks:PostHook(CharacterTweakData, "_init_biker_boss", "hhpost_bboss", function(self, presets)
	self.biker_boss.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase
end)

Hooks:PostHook(CharacterTweakData, "_init_chavez_boss", "hhpost_cboss", function(self, presets)
	self.chavez_boss.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase
end)

Hooks:PostHook(CharacterTweakData, "_init_drug_lord_boss", "hhpost_dboss", function(self, presets)
	self.drug_lord_boss.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase
end)

--LANDMARK: WITCH

--difficulty tweaks begin here.

function CharacterTweakData:_set_normal()
	self:_multiply_all_hp(2, 3)
	self:_multiply_all_speeds(1, 1)
	self:_set_characters_crumble_chance(0.5, 0.3, 0.9)

	self.hector_boss.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 2.2,
			r = 200,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				1,
				2,
				1
			}
		},
		{
			dmg_mul = 1.75,
			r = 500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1.5,
			r = 1000,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1.25,
			r = 2000,
			acc = {
				0.4,
				0.55
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.hector_boss.HEALTH_INIT = 600
	self.mobster_boss.HEALTH_INIT = 600
	self.biker_boss.HEALTH_INIT = 600
	self.chavez_boss.HEALTH_INIT = 600
	self.presets.gang_member_damage.REGENERATE_TIME = 15
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 10
	self.presets.gang_member_damage.HEALTH_INIT = 500
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35

	self:_set_characters_weapon_preset("simple")

	self.flashbang_multiplier = 1
	self.concussion_multiplier = 1
	
	if self.tweak_data and self.tweak_data.levels then
		local faction = self.tweak_data.levels:get_ai_group_type()
		if faction == "russia" then
			self.swat.speech_prefix_p1 = "r"
			self.swat.speech_prefix_count = 4	
			self.heavy_swat.speech_prefix_p1 = "r"
			self.heavy_swat.speech_prefix_count = 4	
			self.fbi.speech_prefix_p1 = "r"
			self.fbi_swat.speech_prefix_p1 = "r"
			self.city_swat.speech_prefix_p1 = "r"
		end
		if faction == "zombie" then
			self.swat.spawn_scream = "g90"
			self.heavy_swat.spawn_scream = "g90"
			self.fbi_swat.spawn_scream = "g90"
			self.fbi_heavy_swat.spawn_scream = "g90"
			self.city_swat.spawn_scream = "g90"
		end
	end
	
	--Sniper tweak
	self.sniper.weapon.is_rifle.focus_delay = 6
	--FBI tweak
	self.fbi.weapon = self.presets.weapon.complex
	self.fbi.move_speed = self.presets.move_speed.civil_consistency
	--Cop health tweak
	self.cop.HEALTH_INIT = 8 --Their health is sorta pathetic otherwise.
	self.cop_female.HEALTH_INIT = 8
	self.shadow_spooc.shadow_spooc_attack_timeout = {
		0.35,
		0.35
	}
	self.spooc.spooc_attack_timeout = {
		0.35,
		0.35
	}
end

--HARD setup begins here, landmark (POW)

function CharacterTweakData:_set_hard()
	self:_multiply_all_hp(2, 3)
	self:_multiply_all_speeds(1, 1)
	self:_set_characters_crumble_chance(0.5, 0.3, 0.9)
	
	self.hector_boss.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 2.2,
			r = 200,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				1,
				2,
				1
			}
		},
		{
			dmg_mul = 1.75,
			r = 500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1.5,
			r = 1000,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1.25,
			r = 2000,
			acc = {
				0.4,
				0.55
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.hector_boss.HEALTH_INIT = 600
	self.mobster_boss.HEALTH_INIT = 600
	self.biker_boss.HEALTH_INIT = 600
	self.chavez_boss.HEALTH_INIT = 600
	self.presets.gang_member_damage.REGENERATE_TIME = 15
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 10
	self.presets.gang_member_damage.HEALTH_INIT = 500
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35

	self:_set_characters_weapon_preset("simple")

	
	self.flashbang_multiplier = 1
	self.concussion_multiplier = 1
	
	if self.tweak_data and self.tweak_data.levels then
		local faction = self.tweak_data.levels:get_ai_group_type()
		if faction == "russia" then
			self.swat.speech_prefix_p1 = "r"
			self.swat.speech_prefix_count = 4	
			self.heavy_swat.speech_prefix_p1 = "r"
			self.heavy_swat.speech_prefix_count = 4	
			self.fbi.speech_prefix_p1 = "r"
			self.fbi_swat.speech_prefix_p1 = "r"
			self.city_swat.speech_prefix_p1 = "r"
		end
		if faction == "zombie" then
			self.swat.spawn_scream = "g90"
			self.heavy_swat.spawn_scream = "g90"
			self.fbi_swat.spawn_scream = "g90"
			self.fbi_heavy_swat.spawn_scream = "g90"
			self.city_swat.spawn_scream = "g90"
		end
	end
	
	--Sniper tweak
	self.sniper.weapon.is_rifle.focus_delay = 6
	--FBI tweak
	self.fbi.weapon = self.presets.weapon.complex
	self.fbi.move_speed = self.presets.move_speed.civil_consistency
	--Cop health tweak
	self.cop.HEALTH_INIT = 8 --Their health is sorta pathetic otherwise.
	self.cop_female.HEALTH_INIT = 8
	self.shadow_spooc.shadow_spooc_attack_timeout = {
		0.35,
		0.35
	}
	self.spooc.spooc_attack_timeout = {
		0.35,
		0.35
	}
end

--VH setup, landmark (DOG)
function CharacterTweakData:_set_overkill()
	self:_multiply_all_hp(4, 3)
	self:_multiply_all_speeds(1, 1)
	self:_set_characters_crumble_chance(0.4, 0.2, 0.9)
	
	self.tank_mini.HEALTH_INIT = 1800
	self.hector_boss.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 2.2,
			r = 200,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				1,
				2,
				1
			}
		},
		{
			dmg_mul = 1.75,
			r = 500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1.5,
			r = 1000,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1.25,
			r = 2000,
			acc = {
				0.4,
				0.55
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.hector_boss.HEALTH_INIT = 600
	self.mobster_boss.HEALTH_INIT = 600
	self.biker_boss.HEALTH_INIT = 600
	self.chavez_boss.HEALTH_INIT = 600
	self.phalanx_minion.HEALTH_INIT = 100
	self.phalanx_minion.DAMAGE_CLAMP_BULLET = 400
	self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = self.phalanx_minion.DAMAGE_CLAMP_BULLET
	self.phalanx_vip.HEALTH_INIT = 600
	self.phalanx_vip.DAMAGE_CLAMP_BULLET = 800
	self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = self.phalanx_vip.DAMAGE_CLAMP_BULLET
	
	self.presets.gang_member_damage.REGENERATE_TIME = 15
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 10
	self.presets.gang_member_damage.HEALTH_INIT = 500
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35

	self:_set_characters_weapon_preset("civil")

	self.shadow_spooc.shadow_spooc_attack_timeout = {
		0.35,
		0.35
	}
	self.spooc.spooc_attack_timeout = {
		0.35,
		0.35
	}
	
	if self.tweak_data and self.tweak_data.levels then
		local faction = self.tweak_data.levels:get_ai_group_type()
		if faction == "russia" then
			self.swat.speech_prefix_p1 = "r"
			self.swat.speech_prefix_count = 4	
			self.heavy_swat.speech_prefix_p1 = "r"
			self.heavy_swat.speech_prefix_count = 4	
			self.fbi.speech_prefix_p1 = "r"
			self.fbi_swat.speech_prefix_p1 = "r"
			self.city_swat.speech_prefix_p1 = "r"
		end
		if faction == "zombie" then
			self.swat.spawn_scream = "g90"
			self.heavy_swat.spawn_scream = "g90"
			self.fbi_swat.spawn_scream = "g90"
			self.fbi_heavy_swat.spawn_scream = "g90"
			self.city_swat.spawn_scream = "g90"
		end
	end
	
	--fbi setup.
	self.fbi.weapon = self.presets.weapon.complex
	self.fbi.dodge = self.presets.dodge.heavy_complex
	self.fbi.move_speed = self.presets.move_speed.complex_consistency
	self.fbi_xc45.weapon = self.presets.weapon.complex
	self.fbi_xc45.dodge = self.presets.dodge.heavy_complex
	self.fbi_xc45.move_speed = self.presets.move_speed.complex_consistency
	--sniper setup.
	self.sniper.weapon.is_rifle.focus_delay = 2
	--Shield speed setup
	self.shield.move_speed = self.presets.move_speed.shield_civ
	--Movespeed setups.
	self.swat.move_speed = self.presets.move_speed.civil_consistency
	self.city_swat.move_speed = self.presets.move_speed.civil_consistency
	self.fbi_swat.move_speed = self.presets.move_speed.civil_consistency
	self.heavy_swat.move_speed = self.presets.move_speed.civil_consistency
	self.fbi_heavy_swat.move_speed = self.presets.move_speed.civil_consistency
	--special movespeed
	self.taser.move_speed = self.presets.move_speed.civil_consistency
	self.medic.move_speed = self.presets.move_speed.civil_consistency
	--cop health
	self.cop.HEALTH_INIT = 10
	self.cop_female.HEALTH_INIT = 10
	self.flashbang_multiplier = 1.75
	self.concussion_multiplier = 1
end

--OVK setup, landmark (QBY)

function CharacterTweakData:_set_overkill_145()	
	self:_multiply_all_hp(4, 3)
	self:_set_characters_crumble_chance(0.4, 0.2, 0.9)
	
	self.tank_mini.HEALTH_INIT = 1800
	self.hector_boss.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 2.2,
			r = 200,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				1,
				2,
				1
			}
		},
		{
			dmg_mul = 1.75,
			r = 500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1.5,
			r = 1000,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1.25,
			r = 2000,
			acc = {
				0.4,
				0.55
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.hector_boss.HEALTH_INIT = 600
	self.mobster_boss.HEALTH_INIT = 600
	self.biker_boss.HEALTH_INIT = 600
	self.chavez_boss.HEALTH_INIT = 600
	self.phalanx_minion.HEALTH_INIT = 100
	self.phalanx_minion.DAMAGE_CLAMP_BULLET = 400
	self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = self.phalanx_minion.DAMAGE_CLAMP_BULLET
	self.phalanx_vip.HEALTH_INIT = 600
	self.phalanx_vip.DAMAGE_CLAMP_BULLET = 800
	self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = self.phalanx_vip.DAMAGE_CLAMP_BULLET

	self:_multiply_all_speeds(1, 1)

	self.presets.gang_member_damage.REGENERATE_TIME = 15
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 10
	self.presets.gang_member_damage.HEALTH_INIT = 500
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35

	self:_set_characters_weapon_preset("civil")

	self.shadow_spooc.shadow_spooc_attack_timeout = {
		0.35,
		0.35
	}
	self.spooc.spooc_attack_timeout = {
		0.35,
		0.35
	}
	
	if self.tweak_data and self.tweak_data.levels then
		local faction = self.tweak_data.levels:get_ai_group_type()
		if faction == "russia" then
			self.swat.speech_prefix_p1 = "r"
			self.swat.speech_prefix_count = 4	
			self.heavy_swat.speech_prefix_p1 = "r"
			self.heavy_swat.speech_prefix_count = 4	
			self.fbi.speech_prefix_p1 = "r"
			self.fbi_swat.speech_prefix_p1 = "r"
			self.city_swat.speech_prefix_p1 = "r"
		end
		if faction == "zombie" then
			self.swat.spawn_scream = "g90"
			self.heavy_swat.spawn_scream = "g90"
			self.fbi_swat.spawn_scream = "g90"
			self.fbi_heavy_swat.spawn_scream = "g90"
			self.city_swat.spawn_scream = "g90"
		end
	end
	
	if Global.game_settings and Global.game_settings.use_intense_AI then
		--fbi setup
		
		self.fbi.dodge = self.presets.dodge.ninja_complex
		self.fbi.weapon = self.presets.weapon.fbigod
		self.fbi.move_speed = self.presets.move_speed.anarchy_consistency
		self.fbi_xc45.dodge = self.presets.dodge.ninja_complex
		self.fbi_xc45.weapon = self.presets.weapon.fbigod
		self.fbi_xc45.move_speed = self.presets.move_speed.anarchy_consistency
		--sniper setup
		self.sniper.weapon.is_rifle.focus_delay = 1.5
		self.sniper.weapon.is_rifle.aim_delay = {0, 0}
		self.sniper.weapon.is_rifle.FALLOFF = {
			{
				dmg_mul = 3.75,
				r = 700,
				acc = {
					0,
					1
				},
				recoil = {
					0.64,
					0.64
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3.75,
				r = 3500,
				acc = {
					0,
					0.75
				},
				recoil = {
					0.64,
					0.64
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3.75,
				r = 6000,
				acc = {
					0,
					0.5
				},
				recoil = {
					0.64,
					0.64
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
		--Movespeed setups.
		self.swat.move_speed = self.presets.move_speed.anarchy_consistency
		self.city_swat.move_speed = self.presets.move_speed.anarchy_consistency
		self.fbi_swat.move_speed = self.presets.move_speed.anarchy_consistency
		self.heavy_swat.move_speed = self.presets.move_speed.anarchy_consistency
		self.fbi_heavy_swat.move_speed = self.presets.move_speed.anarchy_consistency
		--special movespeed
		self.taser.move_speed = self.presets.move_speed.anarchy_consistency
		self.medic.move_speed = self.presets.move_speed.anarchy_consistency
		self.shield.move_speed = self.presets.move_speed.shield_anarch
		--dodge setup.
		self.swat.dodge = self.presets.dodge.athletic_complex
		self.fbi_swat.dodge = self.presets.dodge.athletic_complex
		self.city_swat.dodge = self.presets.dodge.athletic_complex
		self.heavy_swat.dodge = self.presets.dodge.heavy_complex
		self.fbi_heavy_swat.dodge = self.presets.dodge.heavy_complex
		self.spooc.dodge = self.presets.dodge.ninja_complex
		self.flashbang_multiplier = 2
		self.concussion_multiplier = 1
	else
		--fbi setup.
		self.fbi.weapon = self.presets.weapon.complex
		self.fbi.dodge = self.presets.dodge.heavy_complex
		self.fbi.move_speed = self.presets.move_speed.complex_consistency
		self.fbi_xc45.dodge = self.presets.dodge.heavy_complex
		self.fbi_xc45.weapon = self.presets.weapon.complex
		self.fbi_xc45.move_speed = self.presets.move_speed.complex_consistency
		--sniper setup.
		self.sniper.weapon.is_rifle.focus_delay = 2
		--Shield speed setup
		self.shield.move_speed = self.presets.move_speed.shield_civ
		--Movespeed setups.
		self.swat.move_speed = self.presets.move_speed.civil_consistency
		self.city_swat.move_speed = self.presets.move_speed.civil_consistency
		self.fbi_swat.move_speed = self.presets.move_speed.civil_consistency
		self.heavy_swat.move_speed = self.presets.move_speed.civil_consistency
		self.fbi_heavy_swat.move_speed = self.presets.move_speed.civil_consistency
		--special movespeed
		self.taser.move_speed = self.presets.move_speed.civil_consistency
		self.medic.move_speed = self.presets.move_speed.civil_consistency
		self.flashbang_multiplier = 1.75
		self.concussion_multiplier = 1
	end
	
	if Global.mutators and Global.mutators.telespooc then
		self.spooc.move_speed = self.presets.move_speed.speedofsoundsonic
	end
end

--MH setup, landmark (1ST ATT)

function CharacterTweakData:_set_easy_wish()
	self:_multiply_all_hp(4, 2)
	self:_set_characters_crumble_chance(0.3, 0.15, 0.75)
	
	self.tank_mini.HEALTH_INIT = 1800
	self.hector_boss.HEALTH_INIT = 900
	self.mobster_boss.HEALTH_INIT = 900
	self.biker_boss.HEALTH_INIT = 900
	self.chavez_boss.HEALTH_INIT = 900

	self:_multiply_all_speeds(1, 1)

	self.presets.gang_member_damage.REGENERATE_TIME = 15
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 10
	self.presets.gang_member_damage.HEALTH_INIT = 500
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35

	self:_set_characters_weapon_preset("complex")

	self.shadow_spooc.shadow_spooc_attack_timeout = {
		0.35,
		0.35
	}
	self.spooc.spooc_attack_timeout = {
		0.35,
		0.35
	}
	--STEALTH CHANGES WOO
	self.city_swat.no_arrest = true
	self.security.HEALTH_INIT = 16
	self.security.no_arrest = true
	self.cop.HEALTH_INIT = 16
	self.cop.no_arrest = true
	self.gensec.HEALTH_INIT = 16
	self.gensec.no_arrest = true
	--fbi setup
	self.fbi.weapon = self.presets.weapon.anarchy
	self.fbi.dodge = self.presets.dodge.athletic_complex
	self.fbi.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_xc45.weapon = self.presets.weapon.anarchy
	self.fbi_xc45.dodge = self.presets.dodge.athletic_complex
	self.fbi_xc45.move_speed = self.presets.move_speed.anarchy_consistency
	--sniper setup
	self.sniper.weapon.is_rifle.focus_delay = 2
	self.sniper.weapon.is_rifle.aim_delay = {0, 0}
	if self.tweak_data and self.tweak_data.levels then
		local faction = self.tweak_data.levels:get_ai_group_type()
		if faction == "america" then
			self.fbi_heavy_swat.speech_prefix_p2 = "d"
			self.fbi_heavy_swat.speech_prefix_count = 5
		end
		if faction == "russia" then
			self.swat.speech_prefix_p1 = "r"
			self.swat.speech_prefix_count = 4	
			self.heavy_swat.speech_prefix_p1 = "r"
			self.heavy_swat.speech_prefix_count = 4	
			self.fbi.speech_prefix_p1 = "r"
			self.fbi_swat.speech_prefix_p1 = "r"
			self.city_swat.speech_prefix_p1 = "r"
		end
		if faction == "zombie" then
			self.swat.spawn_scream = "g90"
			self.heavy_swat.spawn_scream = "g90"
			self.fbi_swat.spawn_scream = "g90"
			self.fbi_heavy_swat.spawn_scream = "g90"
			self.city_swat.spawn_scream = "g90"
		end
	end
	--Movespeed setups.
	self.swat.move_speed = self.presets.move_speed.complex_consistency
	self.city_swat.move_speed = self.presets.move_speed.complex_consistency
	self.fbi_swat.move_speed = self.presets.move_speed.complex_consistency
	self.heavy_swat.move_speed = self.presets.move_speed.complex_consistency
	self.fbi_heavy_swat.move_speed = self.presets.move_speed.complex_consistency
	--special movespeed
	self.taser.move_speed = self.presets.move_speed.complex_consistency
	self.medic.move_speed = self.presets.move_speed.complex_consistency
	self.shield.move_speed = self.presets.move_speed.shield_com
	--dodge setups.
	self.swat.dodge = self.presets.dodge.heavy_complex
	self.fbi_swat.dodge = self.presets.dodge.heavy_complex
	self.city_swat.dodge = self.presets.dodge.heavy_complex
	--Shield explosive resist
	self.shield.damage.explosion_damage_mul = 0.5
	self.phalanx_minion.HEALTH_INIT = 200
	self.phalanx_minion.DAMAGE_CLAMP_BULLET = 400
	self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = self.phalanx_minion.DAMAGE_CLAMP_BULLET
	self.phalanx_vip.HEALTH_INIT = 800
	self.phalanx_vip.DAMAGE_CLAMP_BULLET = 800
	self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = self.phalanx_vip.DAMAGE_CLAMP_BULLET
	self.flashbang_multiplier = 2
	self.concussion_multiplier = 1
end

--DW setup, landmark (2ND IMP)

function CharacterTweakData:_set_overkill_290()
	self:_multiply_all_hp(4, 2)
	self:_set_characters_crumble_chance(0.3, 0.15, 0.75)
	
	self.tank_mini.HEALTH_INIT = 1800
	self.hector_boss.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 3.14,
			r = 200,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				1,
				2,
				1
			}
		},
		{
			dmg_mul = 2.5,
			r = 500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 2.1,
			r = 1000,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1.8,
			r = 2000,
			acc = {
				0.4,
				0.55
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1.4,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.hector_boss.HEALTH_INIT = 900
	self.mobster_boss.HEALTH_INIT = 900
	self.biker_boss.HEALTH_INIT = 900
	self.chavez_boss.HEALTH_INIT = 900

	self:_multiply_all_speeds(1, 1)

	self.presets.gang_member_damage.REGENERATE_TIME = 15
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 10
	self.presets.gang_member_damage.HEALTH_INIT = 500
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35

	self:_set_characters_weapon_preset("complex")

	self.shadow_spooc.shadow_spooc_attack_timeout = {
		0.35,
		0.35
	}
	self.spooc.spooc_attack_timeout = {
		0.35,
		0.35
	}
	
	--STEALTH CHANGES WOO
	self.city_swat.no_arrest = true
	self.security.HEALTH_INIT = 16
	self.security.no_arrest = true
	self.cop.HEALTH_INIT = 16
	self.cop.no_arrest = true
	self.gensec.HEALTH_INIT = 16
	self.gensec.no_arrest = true
	--sniper stuff
	self.sniper.weapon.is_rifle.focus_delay = 2
	self.sniper.weapon.is_rifle.aim_delay = {0, 0}
	--fbi setup
	self.fbi.weapon = self.presets.weapon.anarchy
	self.fbi.dodge = self.presets.dodge.athletic_complex
	self.fbi.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_xc45.weapon = self.presets.weapon.anarchy
	self.fbi_xc45.dodge = self.presets.dodge.athletic_complex
	self.fbi_xc45.move_speed = self.presets.move_speed.anarchy_consistency
	--MFR has radio static in this difficulty.
	if self.tweak_data and self.tweak_data.levels then
		local faction = self.tweak_data.levels:get_ai_group_type()
		if faction == "america" then
			self.fbi_heavy_swat.speech_prefix_p2 = "d"
			self.fbi_heavy_swat.speech_prefix_count = 5
		end
		if faction == "russia" then
			self.swat.speech_prefix_p1 = "r"
			self.swat.speech_prefix_count = 4	
			self.heavy_swat.speech_prefix_p1 = "r"
			self.heavy_swat.speech_prefix_count = 4	
			self.fbi.speech_prefix_p1 = "r"
			self.fbi_swat.speech_prefix_p1 = "r"
			self.city_swat.speech_prefix_p1 = "r"
		end
		if faction == "zombie" then
			self.swat.spawn_scream = "g90"
			self.heavy_swat.spawn_scream = "g90"
			self.fbi_swat.spawn_scream = "g90"
			self.fbi_heavy_swat.spawn_scream = "g90"
			self.city_swat.spawn_scream = "g90"
		end
	end
	--Movespeed setups.
	self.swat.move_speed = self.presets.move_speed.complex_consistency
	self.city_swat.move_speed = self.presets.move_speed.complex_consistency
	self.fbi_swat.move_speed = self.presets.move_speed.complex_consistency
	self.heavy_swat.move_speed = self.presets.move_speed.complex_consistency
	self.fbi_heavy_swat.move_speed = self.presets.move_speed.complex_consistency
	--special movespeed
	self.taser.move_speed = self.presets.move_speed.complex_consistency
	self.medic.move_speed = self.presets.move_speed.complex_consistency
	self.shield.move_speed = self.presets.move_speed.shield_com
	--dodge setups.
	self.swat.dodge = self.presets.dodge.heavy_complex
	self.fbi_swat.dodge = self.presets.dodge.heavy_complex
	self.city_swat.dodge = self.presets.dodge.heavy_complex
	--Shield explosive resist
	self.shield.damage.explosion_damage_mul = 0.5
	self.phalanx_minion.HEALTH_INIT = 200
	self.phalanx_minion.DAMAGE_CLAMP_BULLET = 400
	self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = self.phalanx_minion.DAMAGE_CLAMP_BULLET
	self.phalanx_vip.HEALTH_INIT = 800
	self.phalanx_vip.DAMAGE_CLAMP_BULLET = 800
	self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = self.phalanx_vip.DAMAGE_CLAMP_BULLET
	self.flashbang_multiplier = 2
	self.concussion_multiplier = 1
end

--DS setup, the 3rd Strike is what counts. (3RD STR)

function CharacterTweakData:_set_sm_wish()
	self:_multiply_all_hp(4, 1.5)
	self:_set_characters_crumble_chance(0.25, 0.15, 0.6)
	
	self.tank.HEALTH_INIT = 1400
	self.tank_mini.HEALTH_INIT = 2100
	self.tank_medic.HEALTH_INIT = 1400
	self.hector_boss.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 3.14,
			r = 200,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				1,
				2,
				1
			}
		},
		{
			dmg_mul = 2.5,
			r = 500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 2.1,
			r = 1000,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1.8,
			r = 2000,
			acc = {
				0.4,
				0.55
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1.4,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.hector_boss.HEALTH_INIT = 900
	self.mobster_boss.HEALTH_INIT = 900
	self.biker_boss.HEALTH_INIT = 900
	self.chavez_boss.HEALTH_INIT = 900

	self:_multiply_all_speeds(1, 1)

	self.presets.gang_member_damage.REGENERATE_TIME = 15
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 10
	self.presets.gang_member_damage.HEALTH_INIT = 500
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35

	self:_set_characters_weapon_preset("anarchy")

	self.shadow_spooc.shadow_spooc_attack_timeout = {
		0.35,
		0.35
	}
	self.spooc.spooc_attack_timeout = {
		0.35,
		0.35
	}
	
	--STEALTH CHANGES WOO
	self.city_swat.no_arrest = true
	self.security.HEALTH_INIT = 16
	self.security.no_arrest = true
	self.cop.no_arrest = true
	self.cop.HEALTH_INIT = 16
	self.gensec.HEALTH_INIT = 16
	self.gensec.no_arrest = true
	--fbi setup
	self.fbi.dodge = self.presets.dodge.ninja_complex
	self.fbi.weapon = self.presets.weapon.fbigod
	self.fbi.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_xc45.weapon = self.presets.weapon.fbigod
	self.fbi_xc45.dodge = self.presets.dodge.ninja_complex
	self.fbi_xc45.move_speed = self.presets.move_speed.anarchy_consistency
	--sniper setup
	self.sniper.weapon.is_rifle.focus_delay = 3
	self.sniper.weapon.is_rifle.aim_delay = {0.64, 0.64}
	self.sniper.weapon.is_rifle.FALLOFF = {
		{
			dmg_mul = 3.75,
			r = 700,
			acc = {
				0,
				1
			},
			recoil = {
				0.64,
				0.64
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 3.75,
			r = 3500,
			acc = {
				0,
				0.75
			},
			recoil = {
				0.64,
				0.64
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 3.75,
			r = 6000,
			acc = {
				0,
				0.3
			},
			recoil = {
				0.64,
				0.64
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 9000,
			acc = {
				0,
				0.1
			},
			recoil = {
				0.64,
				0.64
			},
			mode = {
				0,
				0,
				0,
				1
			}
		}
	}
	--Anti-Fire DOT setup
	self.taser.DAMAGE_CLAMP_FIREDOT = 5 --Tasers and Shields need significant resistance to fire.
	self.tank.DAMAGE_CLAMP_FIREDOT = 10
	self.shield.DAMAGE_CLAMP_FIREDOT = 5
	--This is weird, but makes snipers technically be active sooner, which is good.
	self.sniper.move_speed = self.presets.move_speed.lightning_constant
	--SWAT Speech prefixes to get some voice variety from ZEALs 'n Gensecs.
	if self.tweak_data and self.tweak_data.levels then
		local faction = self.tweak_data.levels:get_ai_group_type()
		if faction == "america" then
			self.swat.speech_prefix_p2 = "d"
			self.swat.speech_prefix_count = 5	
			self.heavy_swat.speech_prefix_p2 = "d"
			self.heavy_swat.speech_prefix_count = 5	
			self.fbi.speech_prefix_p2 = "n"
			self.fbi_swat.speech_prefix_p2 = "n"
			self.city_swat.speech_prefix_p2 = "n"
		end
		if faction == "russia" then
			self.swat.speech_prefix_p1 = "r"
			self.swat.speech_prefix_count = 4	
			self.heavy_swat.speech_prefix_p1 = "r"
			self.heavy_swat.speech_prefix_count = 4	
			self.fbi.speech_prefix_p1 = "r"
			self.fbi_swat.speech_prefix_p1 = "r"
			self.city_swat.speech_prefix_p1 = "r"
		end
		if faction == "zombie" then
			self.swat.spawn_scream = "g90"
			self.heavy_swat.spawn_scream = "g90"
			self.fbi_swat.spawn_scream = "g90"
			self.fbi_heavy_swat.spawn_scream = "g90"
			self.city_swat.spawn_scream = "g90"
		end
	end
	self.shield.spawn_sound_event = "hos_shield_identification" --Come with me if you want to live.
	--Movespeed setups.
	self.swat.move_speed = self.presets.move_speed.anarchy_consistency
	self.city_swat.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_swat.move_speed = self.presets.move_speed.anarchy_consistency
	self.heavy_swat.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_heavy_swat.move_speed = self.presets.move_speed.anarchy_consistency
	--special movespeed
	self.taser.move_speed = self.presets.move_speed.anarchy_consistency
	self.medic.move_speed = self.presets.move_speed.anarchy_consistency
	self.shield.move_speed = self.presets.move_speed.shield_anarch
	--dodge setup.
	self.swat.dodge = self.presets.dodge.athletic_complex
	self.fbi_swat.dodge = self.presets.dodge.athletic_complex
	self.city_swat.dodge = self.presets.dodge.athletic_complex
	self.heavy_swat.dodge = self.presets.dodge.heavy_complex
	self.fbi_heavy_swat.dodge = self.presets.dodge.heavy_complex
	self.spooc.dodge = self.presets.dodge.ninja_complex
	--Explosive resist for certain enemies.
	self.shield.damage.explosion_damage_mul = 0.25
	self.heavy_swat.damage.explosion_damage_mul = 0.7
	self.fbi_heavy_swat.damage.explosion_damage_mul = 0.7
	self.tank.damage.explosion_damage_mul = 1
	self.tank_medic.damage.explosion_damage_mul = 1
	self.tank_mini.damage.explosion_damage_mul = 0.7
	--heavy swat health clamping for guaranteed two-shot-to-kill ratios
	self.heavy_swat.DAMAGE_CLAMP_BULLET = 79
	self.heavy_swat.DAMAGE_CLAMP_FIREDOT = 30
	self.heavy_swat.DAMAGE_CLAMP_EXPLOSION = self.heavy_swat.DAMAGE_CLAMP_BULLET
	self.fbi_heavy_swat.DAMAGE_CLAMP_BULLET = 79
	self.fbi_heavy_swat.DAMAGE_CLAMP_FIREDOT = 30
	self.fbi_heavy_swat.DAMAGE_CLAMP_EXPLOSION = self.fbi_heavy_swat.DAMAGE_CLAMP_BULLET
	
	
	self.phalanx_minion.HEALTH_INIT = 300
	self.phalanx_minion.DAMAGE_CLAMP_BULLET = 40
	self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = self.phalanx_minion.DAMAGE_CLAMP_BULLET
	self.phalanx_vip.HEALTH_INIT = 80
	self.phalanx_vip.DAMAGE_CLAMP_BULLET = 80
	self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = self.phalanx_vip.DAMAGE_CLAMP_BULLET
	self.flashbang_multiplier = 2.25
	self.concussion_multiplier = 1
end

function CharacterTweakData:_create_table_structure() --vanilla table
	self.weap_ids = {
		"beretta92",
		"c45",
		"raging_bull",
		"m4",
		"m4_yellow",
		"ak47",
		"r870",
		"mossberg",
		"mp5",
		"mp5_tactical",
		"mp9",
		"mac11",
		"m14_sniper_npc",
		"saiga",
		"m249",
		"benelli",
		"g36",
		"ump",
		"scar_murky",
		"rpk_lmg",
		"svd_snp",
		"akmsu_smg",
		"asval_smg",
		"sr2_smg",
		"ak47_ass",
		"x_c45",
		"sg417",
		"svdsil_snp",
		"mini",		
		"heavy_zeal_sniper",
		"smoke",
		"s553_zeal",
		"lazer",
		"blazter",
		"bayou_spas",
		"quagmire",
		"em_disruptor"
	}
	self.weap_unit_names = {
		Idstring("units/payday2/weapons/wpn_npc_beretta92/wpn_npc_beretta92"),
		Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45"),
		Idstring("units/payday2/weapons/wpn_npc_raging_bull/wpn_npc_raging_bull"),
		Idstring("units/payday2/weapons/wpn_npc_m4/wpn_npc_m4"),
		Idstring("units/payday2/weapons/wpn_npc_m4_yellow/wpn_npc_m4_yellow"),
		Idstring("units/payday2/weapons/wpn_npc_ak47/wpn_npc_ak47"),
		Idstring("units/payday2/weapons/wpn_npc_r870/wpn_npc_r870"),
		Idstring("units/payday2/weapons/wpn_npc_sawnoff_shotgun/wpn_npc_sawnoff_shotgun"),
		Idstring("units/payday2/weapons/wpn_npc_mp5/wpn_npc_mp5"),
		Idstring("units/payday2/weapons/wpn_npc_mp5_tactical/wpn_npc_mp5_tactical"),
		Idstring("units/payday2/weapons/wpn_npc_smg_mp9/wpn_npc_smg_mp9"),
		Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11"),
		Idstring("units/payday2/weapons/wpn_npc_sniper/wpn_npc_sniper"),
		Idstring("units/payday2/weapons/wpn_npc_saiga/wpn_npc_saiga"),
		Idstring("units/payday2/weapons/wpn_npc_lmg_m249/wpn_npc_lmg_m249"),
		Idstring("units/payday2/weapons/wpn_npc_benelli/wpn_npc_benelli"),
		Idstring("units/payday2/weapons/wpn_npc_g36/wpn_npc_g36"),
		Idstring("units/payday2/weapons/wpn_npc_ump/wpn_npc_ump"),
		Idstring("units/payday2/weapons/wpn_npc_scar_murkywater/wpn_npc_scar_murkywater"),
		Idstring("units/pd2_dlc_mad/weapons/wpn_npc_rpk/wpn_npc_rpk"),
		Idstring("units/pd2_dlc_mad/weapons/wpn_npc_svd/wpn_npc_svd"),
		Idstring("units/pd2_dlc_mad/weapons/wpn_npc_akmsu/wpn_npc_akmsu"),
		Idstring("units/pd2_dlc_mad/weapons/wpn_npc_asval/wpn_npc_asval"),
		Idstring("units/pd2_dlc_mad/weapons/wpn_npc_sr2/wpn_npc_sr2"),
		Idstring("units/pd2_dlc_mad/weapons/wpn_npc_ak47/wpn_npc_ak47"),
		Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_x_c45"),
		Idstring("units/pd2_dlc_chico/weapons/wpn_npc_sg417/wpn_npc_sg417"),
		Idstring("units/pd2_dlc_spa/weapons/wpn_npc_svd_silenced/wpn_npc_svd_silenced"),
		Idstring("units/pd2_dlc_drm/weapons/wpn_npc_mini/wpn_npc_mini"),
		Idstring("units/pd2_dlc_drm/weapons/wpn_npc_heavy_zeal_sniper/wpn_npc_heavy_zeal_sniper"),
		Idstring("units/pd2_dlc_uno/weapons/wpn_npc_smoke/wpn_npc_smoke"),
		Idstring("units/pd2_dlc_gitgud/weapons/wpn_npc_s553/wpn_npc_s553"),
		Idstring("units/pd2_dlc_gitgud/weapons/wpn_npc_lazer/wpn_npc_lazer"),
		Idstring("units/pd2_dlc_gitgud/weapons/wpn_npc_blazter/wpn_npc_blazter"),
		Idstring("units/payday2/weapons/wpn_npc_bayou/wpn_npc_bayou"),
		Idstring("units/pd2_mod_psc/weapons/wpn_npc_quagmire/wpn_npc_quagmire"),
		Idstring("units/pd2_dlc_drm/weapons/wpn_em_disruptor/wpn_em_disruptor"),
	}
end

function CharacterTweakData:character_map()
	local char_map = origin_charmap(self)
	char_map.additions = {
		path = "units/payday2/characters/",
		list = {
			"ene_fbi_swat_3",
			"ene_swat_3"
		}
	}
	char_map.drm = {
		path = "units/pd2_dlc_drm/characters/",
		list = {
			"ene_bulldozer_medic",
			"ene_bulldozer_minigun",
			"ene_bulldozer_minigun_classic",
			"ene_zeal_swat_heavy_sniper",
			"ene_zeal_armored_light",
			"ene_murky_heavy_ump",
			"ene_fbi_heavy_ump",
			"ene_bulldozer_sniper",
			"ene_spook_heavy",
			"ene_taser_heavy",
			"ene_shield_heavy",
			"ene_medic_heavy_m4",
			"ene_medic_heavy_r870",
			"ene_city_swat_saiga",
			"ene_swat_bronco",
			"ene_true_lotus_master"
		}
	}
	char_map.gitgud = {
		path = "units/pd2_dlc_gitgud/characters/",
		list = {
			"ene_zeal_bulldozer",
			"ene_zeal_bulldozer_2",
			"ene_zeal_bulldozer_3",
			"ene_zeal_cloaker",
			"ene_zeal_swat",
			"ene_zeal_city_1",
			"ene_zeal_city_2",
			"ene_zeal_city_3",
			"ene_zeal_medic",
			"ene_zeal_medic_r870",
			"ene_zeal_swat_heavy",
			"ene_zeal_swat_heavy_hh",
			"ene_zeal_swat_heavy_r870",			
			"ene_zeal_swat_shield",
			"ene_zeal_swat_shield_hh",
			"ene_zeal_tazer",
			"ene_zeal_tazer_hh",
			"ene_zeal_punk_mp5",
			"ene_zeal_punk_moss",
			"ene_zeal_punk_bronco",
			"ene_zeal_fbigod_m4", --COOL JEROME
			"ene_zeal_fbigod_c45"
		}
	}
	char_map.psc = {
		path = "units/pd2_mod_psc/characters/",
		list = {
			"ene_murky_light_rifle",
			"ene_murky_heavy_scar",
			"ene_murky_NH_rifle",
			"ene_murky_NH_r870",
			"ene_murky_light_r870",
			"ene_murky_heavy_r870",
			"ene_murky_light_ump",
			"ene_murky_fbigod_m4",
			"ene_murky_fbigod_c45",
			"ene_murky_fbigod_c45_DS",
			"ene_murky_DS_shield",
			"ene_murky_punk_bronco",
			"ene_murky_punk_mp5",
			"ene_murky_punk_moss"
		}
	}
	char_map.ftsu = {
		path = "units/pd2_mod_ftsu/characters/",
		list = {
			"ene_gensec_fbigod_c45",
			"ene_gensec_fbigod_m4",
			"ene_gensec_punk_mp5",
			"ene_gensec_punk_moss",
			"ene_gensec_punk_bronco"
		}
	}
	char_map.hvh = {
			path = "units/pd2_dlc_hvh/characters/",
			list = {
			"ene_cop_hvh_1",
			"ene_cop_hvh_2",
			"ene_cop_hvh_3",
			"ene_cop_hvh_4",
			"ene_cop_hvh_5",
			"ene_swat_hvh_1",
			"ene_swat_hvh_2",
			"ene_fbi_hvh_1",
			"ene_fbi_hvh_2",
			"ene_fbi_hvh_3",
			"ene_fbigod_hvh_m4",
			"ene_fbigod_hvh_c45",
			"ene_spook_hvh_1",
			"ene_swat_heavy_hvh_1",
			"ene_swat_heavy_hvh_r870",
			"ene_tazer_hvh_1",
			"ene_shield_hvh_1",
			"ene_shield_hvh_2",
			"ene_medic_hvh_r870",
			"ene_medic_hvh_m4",
			"ene_bulldozer_hvh_1",
			"ene_bulldozer_hvh_2",
			"ene_bulldozer_hvh_3",
			"ene_fbi_swat_hvh_1",
			"ene_fbi_swat_hvh_2",
			"ene_fbi_heavy_hvh_1",
			"ene_fbi_heavy_hvh_r870",
			"ene_sniper_hvh_2",
			"ene_zeal_swat_shield_hvh"
		}
	}
	char_map.mad = {
		path = "units/pd2_dlc_mad/characters/",
		list = {
			"civ_male_scientist_01",
			"civ_male_scientist_02",
			"ene_akan_fbi_heavy_g36",
			"ene_akan_fbi_shield_sr2_smg",
			"ene_akan_fbi_spooc_asval_smg",
			"ene_akan_fbi_swat_ak47_ass",
			"ene_akan_fbi_swat_dw_ak47_ass",
			"ene_akan_fbi_swat_dw_r870",
			"ene_akan_fbi_swat_r870",
			"ene_akan_fbi_tank_r870",
			"ene_akan_fbi_tank_rpk_lmg",
			"ene_akan_fbi_tank_saiga",
			"ene_akan_cs_cop_ak47_ass",
			"ene_akan_cs_cop_akmsu_smg",
			"ene_akan_cs_cop_asval_smg",
			"ene_akan_cs_cop_r870",
			"ene_akan_cs_heavy_ak47_ass",
			"ene_akan_cs_shield_c45",
			"ene_akan_cs_swat_ak47_ass",
			"ene_akan_cs_swat_r870",
			"ene_akan_cs_swat_sniper_svd_snp",
			"ene_akan_cs_tazer_ak47_ass",
			"ene_akan_medic_ak47_ass",
			"ene_akan_medic_r870",
			"ene_akan_hyper_fbi_akmsu_smg",
			"ene_akan_hyper_swat_akmsu_smg",
			"ene_akan_hyper_fbininja_ak47_ass",
			"ene_akan_hyper_fbininja_c45",
			"ene_akan_hyper_fbininja_c45_DS",
			"ene_akan_hyper_DS_shield"
		}
	}	
	return char_map
end

function CharacterTweakData:_multiply_all_hp(hp_mul, hs_mul)
	self.fbi.HEALTH_INIT = self.fbi.HEALTH_INIT * hp_mul
	self.swat.HEALTH_INIT = self.swat.HEALTH_INIT * hp_mul
	self.heavy_swat.HEALTH_INIT = self.heavy_swat.HEALTH_INIT * hp_mul
	self.fbi_heavy_swat.HEALTH_INIT = self.fbi_heavy_swat.HEALTH_INIT * hp_mul
	self.sniper.HEALTH_INIT = self.sniper.HEALTH_INIT * hp_mul
	self.gangster.HEALTH_INIT = self.gangster.HEALTH_INIT * hp_mul
	self.biker.HEALTH_INIT = self.biker.HEALTH_INIT * hp_mul
	self.tank.HEALTH_INIT = self.tank.HEALTH_INIT * hp_mul
	self.tank_mini.HEALTH_INIT = self.tank_mini.HEALTH_INIT * hp_mul
	self.tank_ftsu.HEALTH_INIT = self.tank_ftsu.HEALTH_INIT * hp_mul
	self.tank_medic.HEALTH_INIT = self.tank_medic.HEALTH_INIT * hp_mul
	self.spooc.HEALTH_INIT = self.spooc.HEALTH_INIT * hp_mul
	self.spooc_heavy.HEALTH_INIT = self.spooc_heavy.HEALTH_INIT * hp_mul
	self.shadow_spooc.HEALTH_INIT = self.shadow_spooc.HEALTH_INIT * hp_mul
	self.shield.HEALTH_INIT = self.shield.HEALTH_INIT * hp_mul
	self.phalanx_minion.HEALTH_INIT = self.phalanx_minion.HEALTH_INIT * hp_mul
	self.phalanx_vip.HEALTH_INIT = self.phalanx_vip.HEALTH_INIT * hp_mul
	self.taser.HEALTH_INIT = self.taser.HEALTH_INIT * hp_mul
	self.city_swat.HEALTH_INIT = self.city_swat.HEALTH_INIT * hp_mul
	self.biker_escape.HEALTH_INIT = self.biker_escape.HEALTH_INIT * hp_mul
	self.fbi_swat.HEALTH_INIT = self.fbi_swat.HEALTH_INIT * hp_mul
	self.tank_hw.HEALTH_INIT = self.tank_hw.HEALTH_INIT * hp_mul
	self.medic.HEALTH_INIT = self.medic.HEALTH_INIT * hp_mul
	self.bolivian.HEALTH_INIT = self.bolivian.HEALTH_INIT * hp_mul
	self.bolivian_indoors.HEALTH_INIT = self.bolivian_indoors.HEALTH_INIT * hp_mul
	self.drug_lord_boss.HEALTH_INIT = self.drug_lord_boss.HEALTH_INIT * hp_mul
	self.drug_lord_boss_stealth.HEALTH_INIT = self.drug_lord_boss_stealth.HEALTH_INIT * hp_mul
	self.fbi_xc45.HEALTH_INIT = self.fbi_xc45.HEALTH_INIT * hp_mul

	if self.security.headshot_dmg_mul then
		self.security.headshot_dmg_mul = self.security.headshot_dmg_mul * hs_mul
	end

	if self.cop.headshot_dmg_mul then
		self.cop.headshot_dmg_mul = self.cop.headshot_dmg_mul * hs_mul
	end

	if self.fbi.headshot_dmg_mul then
		self.fbi.headshot_dmg_mul = self.fbi.headshot_dmg_mul * hs_mul
	end

	if self.swat.headshot_dmg_mul then
		self.swat.headshot_dmg_mul = self.swat.headshot_dmg_mul * hs_mul
	end

	if self.heavy_swat.headshot_dmg_mul then
		self.heavy_swat.headshot_dmg_mul = self.heavy_swat.headshot_dmg_mul * hs_mul
	end

	if self.fbi_heavy_swat.headshot_dmg_mul then
		self.fbi_heavy_swat.headshot_dmg_mul = self.fbi_heavy_swat.headshot_dmg_mul * hs_mul
	end

	if self.sniper.headshot_dmg_mul then
		self.sniper.headshot_dmg_mul = self.sniper.headshot_dmg_mul * hs_mul
	end

	if self.gangster.headshot_dmg_mul then
		self.gangster.headshot_dmg_mul = self.gangster.headshot_dmg_mul * hs_mul
	end

	if self.biker.headshot_dmg_mul then
		self.biker.headshot_dmg_mul = self.biker.headshot_dmg_mul * hs_mul
	end

	if self.tank.headshot_dmg_mul then
		self.tank.headshot_dmg_mul = self.tank.headshot_dmg_mul * hs_mul
	end

	if self.shadow_spooc.headshot_dmg_mul then
		self.shadow_spooc.headshot_dmg_mul = self.shadow_spooc.headshot_dmg_mul * hs_mul
	end

	if self.spooc.headshot_dmg_mul then
		self.spooc.headshot_dmg_mul = self.spooc.headshot_dmg_mul * hs_mul
	end
	
	if self.spooc_heavy.headshot_dmg_mul then
		self.spooc_heavy.headshot_dmg_mul = self.spooc_heavy.headshot_dmg_mul * hs_mul
	end
	
	if self.shield.headshot_dmg_mul then
		self.shield.headshot_dmg_mul = self.shield.headshot_dmg_mul * hs_mul
	end

	if self.phalanx_minion.headshot_dmg_mul then
		self.phalanx_minion.headshot_dmg_mul = self.phalanx_minion.headshot_dmg_mul * hs_mul
	end

	if self.phalanx_vip.headshot_dmg_mul then
		self.phalanx_vip.headshot_dmg_mul = self.phalanx_vip.headshot_dmg_mul * hs_mul
	end

	if self.taser.headshot_dmg_mul then
		self.taser.headshot_dmg_mul = self.taser.headshot_dmg_mul * hs_mul
	end

	if self.biker_escape.headshot_dmg_mul then
		self.biker_escape.headshot_dmg_mul = self.biker_escape.headshot_dmg_mul * hs_mul
	end

	if self.city_swat.headshot_dmg_mul then
		self.city_swat.headshot_dmg_mul = self.city_swat.headshot_dmg_mul * hs_mul
	end

	if self.fbi_swat.headshot_dmg_mul then
		self.fbi_swat.headshot_dmg_mul = self.fbi_swat.headshot_dmg_mul * hs_mul
	end

	if self.tank_hw.headshot_dmg_mul then
		self.tank_hw.headshot_dmg_mul = self.tank_hw.headshot_dmg_mul * hs_mul
	end

	if self.medic.headshot_dmg_mul then
		self.medic.headshot_dmg_mul = self.medic.headshot_dmg_mul * hs_mul
	end

	if self.drug_lord_boss.headshot_dmg_mul then
		self.drug_lord_boss.headshot_dmg_mul = self.drug_lord_boss.headshot_dmg_mul * hs_mul
	end

	if self.bolivian.headshot_dmg_mul then
		self.bolivian.headshot_dmg_mul = self.bolivian.headshot_dmg_mul * hs_mul
	end

	if self.bolivian_indoors.headshot_dmg_mul then
		self.bolivian_indoors.headshot_dmg_mul = self.bolivian_indoors.headshot_dmg_mul * hs_mul
	end

	if self.tank_medic.headshot_dmg_mul then
		self.tank_medic.headshot_dmg_mul = self.tank_medic.headshot_dmg_mul * hs_mul
	end

	if self.tank_mini.headshot_dmg_mul then
		self.tank_mini.headshot_dmg_mul = self.tank_mini.headshot_dmg_mul * hs_mul
	end
	
	if self.tank_ftsu.headshot_dmg_mul then
		self.tank_ftsu.headshot_dmg_mul = self.tank_ftsu.headshot_dmg_mul * hs_mul
	end
	
	if self.fbi_xc45.headshot_dmg_mul then
		self.fbi_xc45.headshot_dmg_mul = self.fbi_xc45.headshot_dmg_mul * hs_mul
	end
	
end
