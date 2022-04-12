Config = {}
Config.UsingTarget = true -- If you are using qb-target (uses entity zones to target vehicles)
Config.Commission = 0.10 -- Percent that goes to sales person from a full car sale 10%
Config.FinanceCommission = 0.05 -- Percent that goes to sales person from a finance sale 5%
Config.FinanceZone = vector3(-29.53, -1103.67, 26.42) -- Where the finance menu is located
Config.PaymentWarning = 10 -- time in minutes that player has to make payment before repo
Config.PaymentInterval = 24 -- time in hours between payment being due
Config.MinimumDown = 10 -- minimum percentage allowed down
Config.MaximumPayments = 24 -- maximum payments allowed
Config.Shops = {
    ['pdm'] = {
        ['Type'] = 'free-use',  -- no player interaction is required to purchase a car
        ['Zone'] = {
            ['Shape'] = { --polygon that surrounds the shop
                vector2(-56.727394104004, -1086.2325439453),
                vector2(-60.612808227539, -1096.7795410156),
                vector2(-58.26834487915, -1100.572265625),
                vector2(-35.927803039551, -1109.0034179688),
                vector2(-34.427627563477, -1108.5111083984),
                vector2(-32.02657699585, -1101.5877685547),
                vector2(-33.342102050781, -1101.0377197266),
                vector2(-31.292987823486, -1095.3717041016)
            },
            ['minZ'] = 25.0,  -- min height of the shop zone
            ['maxZ'] = 28.0  -- max height of the shop zone
        },
        ['Job'] = 'none', -- Name of job or none
        ['ShopLabel'] = 'Premium Deluxe Motorsport', -- Blip name
        ['showBlip'] = true,  --- true or false
        ['Categories'] = { -- Categories available to browse
            ['sportsclassics'] = 'Sports Classics',
            ['sedans'] = 'Sedans',
            ['coupes'] = 'Coupes',
            ['suvs'] = 'SUVs',
            ['offroad'] = 'Offroad',
            ['muscle'] = 'Muscle',
            ['compacts'] = 'Compacts',
            ['motorcycles'] = 'Motorcycles',
            ['vans'] = 'Vans',
            ['cycles'] = 'Bicycles',
            ['sports'] = 'Sports',
            ['commercial'] = 'Commercial',
            ['industrial'] = 'Industrial',
            ['utility'] = 'Utility',
        },
        ['TestDriveTimeLimit'] = 5, -- Time in minutes until the vehicle gets deleted
        ['Location'] = vector3(-45.67, -1098.34, 26.42), -- Blip Location
        ['ReturnLocation'] = vector3(-44.74, -1082.58, 26.68), -- Location to return vehicle, only enables if the vehicleshop has a job owned
        ['VehicleSpawn'] = vector4(-56.79, -1109.85, 26.43, 71.5), -- Spawn location when vehicle is bought
        ['ShowroomVehicles'] = {
            [1] = {
                coords = vector4(-45.65, -1093.66, 25.44, 69.5), -- where the vehicle will spawn on display
                defaultVehicle = 'adder', -- Default display vehicle
                chosenVehicle = 'adder', -- Same as default but is dynamically changed when swapping vehicles
            },
            [2] = {
                coords = vector4(-48.27, -1101.86, 25.44, 294.5),
                defaultVehicle = 'schafter2',
                chosenVehicle = 'schafter2',
            },
            [3] = {
                coords = vector4(-39.6, -1096.01, 25.44, 66.5),
                defaultVehicle = 'comet2',
                chosenVehicle = 'comet2',
            },
            [4] = {
                coords = vector4(-51.21, -1096.77, 25.44, 254.5),
                defaultVehicle = 'vigero',
                chosenVehicle = 'vigero',
            },
            [5] = {
                coords = vector4(-40.18, -1104.13, 25.44, 338.5),
                defaultVehicle = 't20',
                chosenVehicle = 't20',
            },
            [6] = {
                coords = vector4(-43.31, -1099.02, 25.44, 52.5),
                defaultVehicle = 'bati',
                chosenVehicle = 'bati',
            },
            [7] = {
                coords = vector4(-50.66, -1093.05, 25.44, 222.5),
                defaultVehicle = 'bati',
                chosenVehicle = 'bati',
            },
            [8] = {
                coords = vector4(-44.28, -1102.47, 25.44, 298.5),
                defaultVehicle = 'bati',
                chosenVehicle = 'bati',
            }
        },
    },
   ['luxury'] = {
        ['Type'] = 'managed',  -- meaning a real player has to sell the car
        ['Zone'] = {
            ['Shape'] = {
                vector2(-1260.6973876953, -349.21334838867),
                vector2(-1268.6248779297, -352.87365722656),
                vector2(-1274.1533203125, -358.29794311523),
                vector2(-1273.8425292969, -362.73715209961),
                vector2(-1270.5701904297, -368.6716003418),
                vector2(-1266.0561523438, -375.14080810547),
                vector2(-1244.3684082031, -362.70278930664),
                vector2(-1249.8704833984, -352.03326416016),
                vector2(-1252.9503173828, -345.85726928711)
            },
            ['minZ'] = 36.646457672119,
            ['maxZ'] = 37.516143798828
        },
        ['Job'] = 'cardealer', -- Name of job or none
        ['ShopLabel'] = 'Luxury Vehicle Shop',
        ['showBlip'] = true,  --- true or false
        ['Categories'] = {
            ['sportsclassics'] = 'Sports Classics',
            ['sedans'] = 'Sedans',
            ['coupes'] = 'Coupes',
            ['suvs'] = 'SUVs',
            ['offroad'] = 'Offroad',
            ['muscle'] = 'Muscle',
            ['compacts'] = 'Compacts',
            ['motorcycles'] = 'Motorcycles',
            ['vans'] = 'Vans',
            ['cycles'] = 'Bicycles',
            ['sports'] = 'Sports',
            ['super'] = 'Super',
            ['commercial'] = 'Commercial',
            ['industrial'] = 'Industrial',
            ['military'] = 'Military',
            ['utility'] = 'Utility',
            ['openwheel'] = 'Open Wheel',
        },
        ['TestDriveTimeLimit'] = 5,
        ['Location'] = vector3(-1255.6, -361.16, 36.91),
        ['ReturnLocation'] = vector3(-1231.46, -349.86, 37.33),
        ['VehicleSpawn'] = vector4(-1231.46, -349.86, 37.33, 26.61),
        ['ShowroomVehicles'] = {
            [1] = {
                coords = vector4(-1265.31, -354.44, 36.91 - 1.0, 205.08),
                defaultVehicle = 'italirsx',
                chosenVehicle = 'italirsx',
            },
            [2] = {
                coords = vector4(-1270.06, -358.55, 36.91 - 1.0, 247.08),
                defaultVehicle = 'italigtb',
                chosenVehicle = 'italigtb',
            },
            [3] = {
                coords = vector4(-1269.21, -365.03, 36.91 - 1.0, 297.12),
                defaultVehicle = 'nero',
                chosenVehicle = 'nero',
            },
            [4] = {
                coords = vector4(-1252.07, -364.2, 35.91, 56.44),
                defaultVehicle = 'bati',
                chosenVehicle = 'bati',
            },
            [5] = {
                coords = vector4(-1255.49, -365.91, 35.91, 55.63),
                defaultVehicle = 'carbonrs',
                chosenVehicle = 'carbonrs',
            },
            [6] = {
                coords = vector4(-1249.21, -362.97, 35.91, 53.24),
                defaultVehicle = 'hexer',
                chosenVehicle = 'hexer',
            },
        }
    },
    ['police'] = {
        ['Type'] = 'managed',  -- meaning a real player has to sell the car
        ['Zone'] = {
            ['Shape'] = {
                vector2(-81.724754333496, 72.436462402344),
                vector2(-60.159938812256, 60.576206207275),
                vector2(-55.763122558594, 61.749210357666),
                vector2(-52.965869903564, 69.869110107422),
                vector2(-50.352680206299, 75.886123657227),
                vector2(-61.261016845703, 81.564918518066),
                vector2(-63.812171936035, 75.633102416992),
                vector2(-76.546226501465, 81.189826965332)
            },
            ['minZ'] = 69.0,
            ['maxZ'] = 76.0
        },
        ['Job'] = 'cardealer', -- Name of job or none
        ['ShopLabel'] = 'Emergency Vehicle Shop',
        ['showBlip'] = true,  --- true or false
        ['Categories'] = {
            ['sportsclassics'] = 'Sports Classics',
            ['sedans'] = 'Sedans',
            ['coupes'] = 'Coupes',
            ['suvs'] = 'SUVs',
            ['offroad'] = 'Offroad',
            ['muscle'] = 'Muscle',
            ['compacts'] = 'Compacts',
            ['motorcycles'] = 'Motorcycles',
            ['vans'] = 'Vans',
            ['cycles'] = 'Bicycles',
            ['sports'] = 'Sports',
            ['super'] = 'Super',
            ['emergency'] = 'Emergency',
            ['utility'] = 'Utility',
        },
        ['TestDriveTimeLimit'] = 5,
        ['Location'] = vector3(-63.59, 68.25, 73.06),
        ['ReturnLocation'] = vector3(-65.05, 81.23, 71.16),
        ['VehicleSpawn'] = vector4(-71.13, 84.04, 71.09, 65.23),
        ['ShowroomVehicles'] = {
            [1] = {
                coords = vector4(-75.96, 74.78, 70.90, 221.69),
                defaultVehicle = 'poldem',
                chosenVehicle = 'poldem',
            },
            [2] = {
                coords = vector4(-66.52, 74.33, 70.65, 188.03),
                defaultVehicle = 'qrv',
                chosenVehicle = 'qrv',
            },
            [3] = {
                coords = vector4(-71.83, 68.60, 70.75, 276.57),
                defaultVehicle = 'police',
                chosenVehicle = 'police',
            },
            [4] = {
                coords = vector4(-59.95, 68.61, 70.85, 181.44),
                defaultVehicle = 'flyhoe',
                chosenVehicle = 'flyhoe',
            }
        }
    }, -- Add your next table under this comma
    ['air'] = {
        ['Type'] = 'managed',  -- meaning a real player has to sell the car
        ['Zone'] = {
            ['Shape'] = {
                vector2(-1035.8176269532, -3017.3391113282),
                vector2(-964.78723144532, -2893.7009277344),
                vector2(-945.9535522461, -2895.3244628906),
                vector2(-922.82336425782, -2910.6459960938),
                vector2(-879.90606689454, -2957.9953613282),
                vector2(-878.32110595704, -2980.6787109375),
                vector2(-929.85925292968, -3079.0290527344),
                vector2(-985.96875, -3052.6726074218)
            },
            ['minZ'] = 18.156301498414,
            ['maxZ'] = 52.105125427246
        },
        ['Job'] = 'cardealer', -- Name of job or none
        ['ShopLabel'] = 'Aircraft Shop',
        ['showBlip'] = false,  --- true or false
        ['Categories'] = {
            ['helis'] = 'Helicopters',
            ['planes'] = 'Airplanes',
            ['military'] = 'Military',
        },
        ['TestDriveTimeLimit'] = 15,
        ['Location'] = vector3(-968.0, -2979.05, 13.94),
        ['ReturnLocation'] = vector4(-909.8, -3290.35, 13.94, 59.5),
        ['VehicleSpawn'] = vector4(-909.8, -3290.35, 13.94, 59.5),
        ['ShowroomVehicles'] = {
            [1] = {
                coords = vector4(-961.53, -2969.01, 12.95, 73.5),
                defaultVehicle = 'frogger',
                chosenVehicle = 'frogger',
            },
            [2] = {
                coords = vector4(-966.22, -2946.07, 12.95, 141.26),
                defaultVehicle = 'luxor',
                chosenVehicle = 'luxor',
            }
        }
    },
    ['boats'] = {
        ['Type'] = 'free-use',  
        ['Zone'] = {
            ['Shape'] = {
                vector2(-734.12329101562, -1352.8647460938),
                vector2(-748.60870361328, -1338.7033691406),
                vector2(-736.7437133789, -1324.0876464844),
                vector2(-721.2919921875, -1336.4350585938)
            },
            ['minZ'] = 2.198355436325,
            ['maxZ'] = 3.91277384758
        },
        ['Job'] = 'none', -- Name of job or none
        ['ShopLabel'] = 'Boat Shop',
        ['showBlip'] = true,  --- true or false
        ['Categories'] = {
            ['speed'] = 'Speed Boats',
            ['jetski'] = 'Jet Skis',
            ['sail'] = 'Sail boats',
            ['submersibles'] = 'Submersibles'
        },
        ['TestDriveTimeLimit'] = 15,
        ['Location'] = vector3(-729.15, -1357.71, 1.23),
        ['ReturnLocation'] = vector4(-729.15, -1357.71, 1.23, 134.68),
        ['VehicleSpawn'] = vector4(-731.21, -1360.19, 0.08, 137.06),
        ['ShowroomVehicles'] = {
            [1] = {
                coords = vector4(-730.87, -1335.05, 0.37, 230.99),
                defaultVehicle = 'speeder2',
                chosenVehicle = 'speeder2',
            },
            [2] = {
                coords = vector4(-737.09, -1342.15, 0.37, 227.93),
                defaultVehicle = 'marquis',
                chosenVehicle = 'marquis',
            }
        }
    },
    ['military'] = {
        ['Type'] = 'managed',  -- meaning a real player has to sell the car
        ['Zone'] = {
            ['Shape'] = {
                vector2(-1923.3387451172, 2994.8627929688),
                vector2(-1953.4569091796, 3013.205078125),
                vector2(-1929.3970947266, 3054.7243652344),
                vector2(-1896.9133300782, 3038.072265625)
            },
            ['minZ'] = 34.462337493896,
            ['maxZ'] = 36.44369506836
        },
        ['Job'] = 'cardealer', -- Name of job or none
        ['ShopLabel'] = 'Military Shop',
        ['showBlip'] = false,  --- true or false
        ['Categories'] = {
            ['helis'] = 'Helicopters',
            ['planes'] = 'Airplanes',
            ['military'] = 'Military',
        },
        ['TestDriveTimeLimit'] = 15,
        ['Location'] = vector3(-1918.72, 3028.66, 33.1),
        ['ReturnLocation'] = vector4(-1875.28, 3009.47, 32.77, 151.16),
        ['VehicleSpawn'] = vector4(-1875.28, 3009.47, 32.77, 151.16),
        ['ShowroomVehicles'] = {
            [1] = {
                coords = vector4(-1923.42, 3025.07, 32.83, 141.87),
                defaultVehicle = 'besra',
                chosenVehicle = 'besra',
            }
        }
    },
}
