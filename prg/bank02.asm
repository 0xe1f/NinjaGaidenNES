; PRG file bank 02, switched in at $8000-$BFFF.
; Pictures and how long each one stays up. Bank 07 reads this
; while the bank is in: drawing, stepping an action, and
; placing the enemies and lanterns for the room.

; --- $8000  Picture for each enemy pose. $FFFF is unused.
; Named for the enemy who uses it.
; How many pieces, then for each piece the tile, how far across,
; and how far up or down.
enemy_shape:
        .word boxer_pic_00
        .word boxer_pic_01
        .word boxer_pic_02
        .word bat_pic_03
        .word bat_pic_04
        .word batter_pic_05
        .word batter_pic_06
        .word batter_pic_07
        .word thrower_pic_08
        .word thrower_pic_09
        .word thrower_pic_0A
        .word axe_pic_0B
        .word axe_pic_0C
        .word axe_pic_0D
        .word axe_pic_0E
        .word jetpack_ninja_pic_0F
        .word jetpack_ninja_pic_10
        .word jetpack_ninja_pic_11
        .word jetpack_ninja_pic_12
        .word shuriken_pic_13
        .word shuriken_pic_14
        .word dog_pic_15
        .word dog_pic_16
        .word knife_thrower_pic_17
        .word knife_thrower_pic_18
        .word knife_thrower_pic_19
        .word knife_thrower_pic_1A
        .word knife_thrower_pic_1B
        .word knife_thrower_pic_1C
        .word knife_pic_1D
        .word running_soldier_pic_1E
        .word running_soldier_pic_1F
        .word crouching_soldier_pic_20
        .word crouching_soldier_pic_21
        .word crouching_soldier_pic_22
        .word crouching_soldier_bullet_pic_23
        .word bird_pic_24
        .word bird_pic_25
        .word machine_gunner_pic_26
        .word machine_gunner_pic_27
        .word machine_gunner_pic_28
        .word machine_gunner_pic_29
        .word machine_gun_bullet_pic_2A
        .word ghoul_pic_2B
        .word ghoul_pic_2C
        .word jump_kicker_pic_2D
        .word jump_kicker_pic_2E
        .word jump_kicker_pic_2F
        .word jump_kicker_pic_30
        .word jump_kicker_pic_31
        .word jump_kicker_pic_32
        .word running_ninja_pic_33
        .word running_ninja_pic_34
        .word running_ninja_pic_35
        .word enemy_pic_36
        .word stone_man_pic_37
        .word stone_man_pic_38
        .word stone_man_pic_39
        .word stone_man_pic_3A
        .word stone_man_pic_3B
        .word stone_man_pic_3C
        .word stone_man_pic_3D
        .word stone_man_ring_pic_3E
        .word stone_man_ring_pic_3F
        .word death_pic_40
        .word death_pic_41
        .word death_pic_42
        .word death_pic_43
        .word death_pic_44
        .word barbarian_pic_45
        .word barbarian_pic_46
        .word barbarian_pic_47
        .word barbarian_pic_48
        .word barbarian_pic_49
        .word bomberhead_pic_4A
        .word bomberhead_pic_4B
        .word bomberhead_pic_4C
        .word bomberhead_pic_4D
        .word bomberhead_pic_4E
        .word bomberhead_pic_4F
        .word bomberhead_pic_50
        .word bomberhead_pic_51
        .word basaquer_pic_52
        .word basaquer_pic_53
        .word basaquer_pic_54
        .word kelbeross_pic_55
        .word enemy_pic_56
        .word kelbeross_pic_57
        .word enemy_pic_58
        .word kelbeross_pic_59
        .word kelbeross_pic_5A
        .word bloody_malth_pic_5B
        .word bloody_malth_pic_5C
        .word bloody_malth_pic_5D
        .word enemy_pic_5E
        .word bloody_malth_pic_5F
        .word bloody_malth_pic_60
        .word bloody_malth_pic_61
        .word bloody_malth_lightning_pic_62
        .word bloody_malth_pic_63
        .word bloody_malth_lightning_pic_64
        .word bloody_malth_lightning_pic_65
        .word bloody_malth_lightning_pic_66
        .word bloody_malth_lightning_pic_67
        .word bloody_malth_pic_68
        .word bloody_malth_lightning_pic_69
        .word masked_devil_pic_6A
        .word masked_devil_pic_6B
        .word bomberhead_pic_6C
        .word enemy_pic_6D
        .word enemy_pic_6E
        .word enemy_pic_6F
        .word jaquio_pic_70
        .word enemy_pic_71
        .word enemy_pic_72
        .word jaquio_pic_73
        .word jaquio_pic_74
        .word enemy_pic_75
        .word enemy_pic_76
        .word masked_devil_pic_77
        .word explosion_pic_78
        .word explosion_pic_79
        .word explosion_pic_7A
        .word explosion_pic_7B
        .word final_boss_pic_7C
        .word final_boss_pic_7D
        .word final_boss_fireballs_pic_7E
        .word final_boss_fireballs_pic_7F
        .word final_boss_pic_80
        .word final_boss_pic_81
        .word final_boss_pic_82
        .word final_boss_pic_83
        .word bomberhead_pic_84
        .word masked_devil_fight_pic_85
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF

; --- $8200  Colors for that picture.
; One color for each piece. Some pictures have another set after the first.
; A list shorter than the picture continues into the next one.
enemy_color:
        .word boxer_pal_00
        .word boxer_pal_01
        .word boxer_pal_02
        .word bat_pal_03
        .word bat_pal_04
        .word batter_pal_05
        .word batter_pal_06
        .word batter_pal_07
        .word thrower_pal_08
        .word thrower_pal_09
        .word thrower_pal_0A
        .word axe_pal_0B
        .word axe_pal_0C
        .word axe_pal_0D
        .word axe_pal_0E
        .word jetpack_ninja_pal_0F
        .word jetpack_ninja_pal_10
        .word jetpack_ninja_pal_11
        .word jetpack_ninja_pal_12
        .word shuriken_pal_13
        .word shuriken_pal_14
        .word dog_pal_15
        .word dog_pal_16
        .word knife_thrower_pal_17
        .word knife_thrower_pal_18
        .word knife_thrower_pal_19
        .word knife_thrower_pal_1A
        .word knife_thrower_pal_1B
        .word knife_thrower_pal_1C
        .word knife_pal_1D
        .word running_soldier_pal_1E
        .word running_soldier_pal_1F
        .word crouching_soldier_pal_20
        .word crouching_soldier_pal_21
        .word crouching_soldier_pal_22
        .word crouching_soldier_bullet_pal_23
        .word bird_pal_24
        .word bird_pal_25
        .word machine_gunner_pal_26
        .word machine_gunner_pal_27
        .word machine_gunner_pal_28
        .word machine_gunner_pal_29
        .word machine_gun_bullet_pal_2A
        .word ghoul_pal_2B
        .word ghoul_pal_2C
        .word jump_kicker_pal_2D
        .word jump_kicker_pal_2E
        .word jump_kicker_pal_2F
        .word jump_kicker_pal_30
        .word jump_kicker_pal_31
        .word jump_kicker_pal_32
        .word running_ninja_pal_33
        .word running_ninja_pal_34
        .word running_ninja_pal_35
        .word enemy_pal_36
        .word stone_man_pal_37
        .word stone_man_pal_38
        .word stone_man_pal_39
        .word stone_man_pal_3A
        .word stone_man_pal_3B
        .word stone_man_pal_3C
        .word stone_man_pal_3D
        .word stone_man_ring_pal_3E
        .word stone_man_ring_pal_3F
        .word death_pal_40
        .word death_pal_41
        .word death_pal_41
        .word death_pal_41
        .word death_pal_41
        .word barbarian_pal_45
        .word barbarian_pal_46
        .word barbarian_pal_47
        .word barbarian_pal_48
        .word barbarian_pal_49
        .word bomberhead_pal_4A
        .word bomberhead_pal_4B
        .word bomberhead_pal_4C
        .word bomberhead_pal_4D
        .word bomberhead_pal_4E
        .word bomberhead_pal_4F
        .word bomberhead_pal_50
        .word bomberhead_pal_51
        .word basaquer_pal_52
        .word basaquer_pal_53
        .word basaquer_pal_54
        .word kelbeross_pal_55
        .word enemy_pal_56
        .word kelbeross_pal_57
        .word enemy_pal_58
        .word kelbeross_pal_59
        .word kelbeross_pal_5A
        .word bloody_malth_pal_5B
        .word bloody_malth_pal_5C
        .word bloody_malth_pal_5D
        .word enemy_pal_5E
        .word bloody_malth_pal_5F
        .word bloody_malth_pal_60
        .word bloody_malth_pal_61
        .word bloody_malth_lightning_pal_62
        .word bloody_malth_pal_63
        .word bloody_malth_lightning_pal_64
        .word bloody_malth_lightning_pal_65
        .word bloody_malth_lightning_pal_66
        .word bloody_malth_lightning_pal_67
        .word bloody_malth_pal_68
        .word bloody_malth_lightning_pal_69
        .word masked_devil_pal_6A
        .word masked_devil_pal_6B
        .word bomberhead_pal_6C
        .word enemy_pal_6D
        .word enemy_pal_6E
        .word enemy_pal_6F
        .word jaquio_pal_70
        .word enemy_pal_71
        .word enemy_pal_72
        .word jaquio_pal_73
        .word jaquio_pal_74
        .word enemy_pal_75
        .word enemy_pal_76
        .word masked_devil_pal_77
        .word explosion_pal_78
        .word explosion_pal_79
        .word explosion_pal_7A
        .word explosion_pal_7B
        .word final_boss_pal_7C
        .word final_boss_pal_7D
        .word final_boss_fireballs_pal_7E
        .word final_boss_fireballs_pal_7F
        .word final_boss_pal_80
        .word final_boss_pal_81
        .word final_boss_pal_82
        .word final_boss_pal_83
        .word bomberhead_pal_84
        .word masked_devil_fight_pal_85
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF

; --- $8400  Picture for each of Ryu's poses.
; Named for who uses it.
; How many pieces, then for each piece the tile, how far across,
; and how far up or down.
ryu_shape:
        .word ryu_idle_pic_00
        .word ryu_crouch_pic_01
        .word ryu_walk_pic_02
        .word ryu_walk_pic_03
        .word ryu_walk_pic_04
        .word ryu_pic_05
        .word ryu_pic_06
        .word ryu_sword_pic_07
        .word ryu_sword_pic_08
        .word ryu_crouch_sword_pic_09
        .word ryu_crouch_sword_pic_0A
        .word ryu_crouch_sword_pic_0B
        .word ryu_spin_pic_0C
        .word ryu_spin_pic_0D
        .word ryu_spin_pic_0E
        .word ryu_spin_pic_0F
        .word ryu_jump_pic_10
        .word ryu_throw_pic_11
        .word ryu_pic_12
        .word ryu_climb_pic_13
        .word ryu_knockback_pic_14
        .word ryu_jump_pic_15
        .word ryu_jump_pic_15
        .word ryu_jump_pic_17
        .word ryu_jump_pic_18
        .word ryu_pic_19
        .word ryu_pic_1A
        .word throwing_star_pic_1B
        .word windmill_star_pic_1C
        .word jump_and_slash_pic_1D
        .word fire_wheel_pic_1E
        .word invincible_fire_wheel_pic_1F
        .word ryu_pic_20
        .word ryu_pic_21
        .word ryu_pic_22
        .word throwing_star_pic_23
        .word throwing_star_pic_24
        .word windmill_star_pic_25
        .word windmill_star_pic_26
        .word ryu_sword_pic_07
        .word ryu_crouch_sword_pic_0A
        .word ryu_pic_29
        .word fire_wheel_pic_2A
        .word fire_wheel_pic_2B
        .word fire_wheel_pic_2C
        .word fire_wheel_pic_2D
        .word lantern_pic_2E
        .word lantern_pic_2F
        .word lantern_pic_30
        .word lantern_pic_31
        .word lantern_pic_32
        .word lantern_pic_33
        .word lantern_pic_34
        .word lantern_pic_35
        .word lantern_pic_36
        .word lantern_pic_37
        .word lantern_pic_38
        .word lantern_pic_39
        .word lantern_pic_3A
        .word lantern_pic_3B
        .word lantern_pic_3C
        .word lantern_pic_3D
        .word lantern_pic_3E
        .word lantern_pic_3F
        .word invincible_fire_wheel_pic_40
        .word invincible_fire_wheel_pic_41
        .word invincible_fire_wheel_pic_42
        .word invincible_fire_wheel_pic_43
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF

; --- $8500  Colors for that picture.
; One color for each piece. Some pictures have another set after the first.
; A list shorter than the picture continues into the next one.
ryu_color:
        .word ryu_idle_pal_00
        .word ryu_crouch_pal_01
        .word ryu_walk_pal_02
        .word ryu_walk_pal_03
        .word ryu_walk_pal_04
        .word ryu_pal_05
        .word ryu_pal_06
        .word ryu_sword_pal_07
        .word ryu_sword_pal_08
        .word ryu_crouch_sword_pal_09
        .word ryu_crouch_sword_pal_0A
        .word ryu_crouch_sword_pal_0B
        .word ryu_spin_pal_0C
        .word ryu_spin_pal_0D
        .word ryu_spin_pal_0E
        .word ryu_spin_pal_0F
        .word ryu_jump_pal_10
        .word ryu_throw_pal_11
        .word ryu_pal_12
        .word ryu_climb_pal_13
        .word ryu_knockback_pal_14
        .word ryu_pal_15
        .word ryu_jump_pal_16
        .word ryu_jump_pal_17
        .word ryu_jump_pal_18
        .word ryu_pal_19
        .word ryu_pal_1A
        .word throwing_star_pal_1B
        .word windmill_star_pal_1C
        .word jump_and_slash_pal_1D
        .word fire_wheel_pal_1E
        .word invincible_fire_wheel_pal_1F
        .word ryu_pal_20
        .word ryu_pal_21
        .word ryu_pal_22
        .word throwing_star_pal_23
        .word throwing_star_pal_24
        .word windmill_star_pal_25
        .word windmill_star_pal_26
        .word ryu_sword_pal_07
        .word ryu_crouch_sword_pal_0A
        .word ryu_pal_29
        .word fire_wheel_pal_2A
        .word fire_wheel_pal_2A
        .word fire_wheel_pal_2A
        .word fire_wheel_pal_2A
        .word lantern_pal_2E
        .word lantern_pal_2F
        .word lantern_pal_30
        .word lantern_pal_31
        .word lantern_pal_32
        .word lantern_pal_33
        .word lantern_pal_34
        .word lantern_pal_35
        .word lantern_pal_36
        .word lantern_pal_37
        .word lantern_pal_38
        .word lantern_pal_39
        .word lantern_pal_3A
        .word lantern_pal_3B
        .word lantern_pal_3C
        .word lantern_pal_3D
        .word lantern_pal_3E
        .word lantern_pal_3F
        .word invincible_fire_wheel_pal_40
        .word invincible_fire_wheel_pal_40
        .word invincible_fire_wheel_pal_40
        .word invincible_fire_wheel_pal_40
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF

; --- $8600  How long each picture stays up, then which picture.
; Named for who uses it.
; $00 ends what Ryu is doing. $FF plays that action again from the start.
; An enemy, a lantern, or a thrown weapon starts the action over on $00.
action_script:
        .word ryu_idle  ; idle
        .word ryu_walk  ; walk
        .word ryu_crouch  ; crouch
        .word ryu_sword  ; sword
        .word ryu_crouch_sword  ; sword while crouching
        .word ryu_jump  ; jump
        .word ryu_air_sword  ; regular sword in the air
        .word ryu_spin  ; spinning sword
        .word ryu_throw  ; throw on the ground
        .word ryu_air_throw  ; throw in the air
        .word ryu_hold  ; hold on
        .word ryu_knockback  ; knocked back
        .word ryu_climb  ; climbing
        .word throwing_star_action
        .word windmill_star_action
        .word action_0F
        .word action_10
        .word boxer_action_11
        .word boxer_action_12
        .word machine_gunner_action_13
        .word machine_gunner_action_14
        .word machine_gun_bullet_action_15
        .word thrower_action_16
        .word action_17
        .word thrower_action_18
        .word axe_action_19
        .word batter_action_1A
        .word action_1B
        .word knife_thrower_action_1C
        .word knife_thrower_action_1D
        .word knife_thrower_action_1E
        .word crouching_soldier_action_1F
        .word crouching_soldier_action_20
        .word crouching_soldier_bullet_action_21
        .word action_22
        .word jump_kicker_action_23
        .word jump_kicker_action_24
        .word jump_kicker_action_25
        .word running_soldier_action_26
        .word running_soldier_action_27
        .word bat_action_28
        .word waiting_dog_action_29
        .word dog_action_2A
        .word bird_action_2B
        .word action_2C
        .word action_2D
        .word jetpack_ninja_action_2E
        .word jetpack_ninja_action_2F
        .word shuriken_action_30
        .word running_ninja_action_31
        .word action_32
        .word running_ninja_action_33
        .word stone_man_action_34
        .word stone_man_action_35
        .word stone_man_action_36
        .word stone_man_action_37
        .word stone_man_action_38
        .word stone_man_ring_action_39
        .word ghoul_action_3A
        .word ghoul_action_3B
        .word death_action_3C
        .word barbarian_action_3D
        .word barbarian_action_3E
        .word bomberhead_action_3F
        .word bomberhead_action_40
        .word masked_devil_action_41
        .word masked_devil_action_42
        .word basaquer_action_43
        .word basaquer_action_44
        .word basaquer_action_45
        .word kelbeross_action_46
        .word kelbeross_action_47
        .word action_48
        .word kelbeross_action_49
        .word action_4A
        .word bloody_malth_action_4B
        .word bloody_malth_action_4C
        .word bloody_malth_action_4D
        .word bloody_malth_action_4E
        .word bloody_malth_lightning_action_4F
        .word bloody_malth_lightning_action_50
        .word fire_wheel_action
        .word explosion_action_52
        .word action_53
        .word action_54
        .word action_55
        .word jaquio_action_56
        .word jaquio_action_57
        .word action_58
        .word action_59
        .word final_boss_action_5A
        .word final_boss_action_5B
        .word action_5C
        .word final_boss_fireballs_action_5D
        .word knife_action_5E
        .word lantern_action_5F
        .word lantern_action_60
        .word lantern_action_61
        .word lantern_action_62
        .word lantern_action_63
        .word lantern_action_64
        .word lantern_action_65
        .word lantern_action_66
        .word lantern_action_67
        .word invincible_fire_wheel_action
        .word masked_devil_fight_action_69
        .word bomberhead_action_6A
        .word final_boss_action_6B
        .word final_boss_action_6C
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF
        .word $FFFF

; --- $8700  Where the lanterns are in this room.
lantern_at:
        .word lantern_at_00
        .word lantern_at_01
        .word lantern_at_02
        .word lantern_at_03
        .word lantern_at_04
        .word lantern_at_05
        .word lantern_at_06
        .word lantern_at_07
        .word lantern_at_08
        .word lantern_at_09
        .word lantern_at_0A
        .word lantern_at_0B
        .word lantern_at_0C
        .word lantern_at_0D
        .word lantern_at_0E
        .word lantern_at_0F
        .word lantern_at_10
        .word lantern_at_11
        .word lantern_at_12
        .word lantern_at_13
        .word lantern_at_14
        .word lantern_at_15
        .word lantern_at_16
        .word lantern_at_17
        .word lantern_at_18
        .word lantern_at_19
        .word lantern_at_1A
        .word lantern_at_1B
        .word lantern_at_1C
        .word lantern_at_1D
        .word lantern_at_1E
        .word lantern_at_1F
        .word lantern_at_20
        .word lantern_at_21
        .word lantern_at_22
        .word lantern_at_23
        .word lantern_at_24
        .word lantern_at_25
        .word lantern_at_26
        .word lantern_at_27
        .word lantern_at_28
        .word lantern_at_29
        .word lantern_at_2A
        .word lantern_at_2B
        .word lantern_at_2C
        .word lantern_at_2D
        .word lantern_at_2E
        .word lantern_at_2F

; --- $8760  What is inside each lantern. The low half is the power-up.
; The high half is how high it hangs.
lantern_in:
        .word lantern_in_00
        .word lantern_in_01
        .word lantern_in_02
        .word lantern_in_03
        .word lantern_in_04
        .word lantern_in_05
        .word lantern_in_06
        .word lantern_in_07
        .word lantern_in_08
        .word lantern_in_09
        .word lantern_in_0A
        .word lantern_in_0B
        .word lantern_in_0C
        .word lantern_in_0D
        .word lantern_in_0E
        .word lantern_in_0F
        .word lantern_in_10
        .word lantern_in_11
        .word lantern_in_12
        .word lantern_in_13
        .word lantern_in_14
        .word lantern_in_15
        .word lantern_in_16
        .word lantern_in_17
        .word lantern_in_18
        .word lantern_in_19
        .word lantern_in_1A
        .word lantern_in_1B
        .word lantern_in_1C
        .word lantern_in_1D
        .word lantern_in_1E
        .word lantern_in_1F
        .word lantern_in_20
        .word lantern_in_21
        .word lantern_in_22
        .word lantern_in_23
        .word lantern_in_24
        .word lantern_in_25
        .word lantern_in_26
        .word lantern_in_27
        .word lantern_in_28
        .word lantern_in_29
        .word lantern_in_2A
        .word lantern_in_2B
        .word lantern_in_2C
        .word lantern_in_2D
        .word lantern_in_2E
        .word lantern_in_2F

; --- $87C0  The screen column where each enemy appears.
appear_col:
        .word appear_col_00
        .word appear_col_01
        .word appear_col_02
        .word appear_col_03
        .word appear_col_04
        .word appear_col_05
        .word appear_col_06
        .word appear_col_07
        .word appear_col_08
        .word appear_col_09
        .word appear_col_0A
        .word appear_col_0B
        .word appear_col_0C
        .word appear_col_0D
        .word appear_col_0E
        .word appear_col_0F
        .word appear_col_10
        .word appear_col_11
        .word appear_col_12
        .word appear_col_13
        .word appear_col_14
        .word appear_col_15
        .word appear_col_16
        .word appear_col_17
        .word appear_col_18
        .word appear_col_19
        .word appear_col_1A
        .word appear_col_1B
        .word appear_col_1C
        .word appear_col_1D
        .word appear_col_1E
        .word appear_col_1F
        .word appear_col_20
        .word appear_col_21
        .word appear_col_22
        .word appear_col_23
        .word appear_col_24
        .word appear_col_25
        .word appear_col_26
        .word appear_col_27
        .word appear_col_28
        .word appear_col_29
        .word appear_col_2A
        .word appear_col_2B
        .word appear_col_2C
        .word appear_col_2D
        .word appear_col_2E
        .word appear_col_2F

; --- $8820  Where he stands. The high half is his height, the low half is across the screen.
stand_at:
        .word stand_at_00
        .word stand_at_01
        .word stand_at_02
        .word stand_at_03
        .word stand_at_04
        .word stand_at_05
        .word stand_at_06
        .word stand_at_07
        .word stand_at_08
        .word stand_at_09
        .word stand_at_0A
        .word stand_at_0B
        .word stand_at_0C
        .word stand_at_0D
        .word stand_at_0E
        .word stand_at_0F
        .word stand_at_10
        .word stand_at_11
        .word stand_at_12
        .word stand_at_13
        .word stand_at_14
        .word stand_at_15
        .word stand_at_16
        .word stand_at_17
        .word stand_at_18
        .word stand_at_19
        .word stand_at_1A
        .word stand_at_1B
        .word stand_at_1C
        .word stand_at_1D
        .word stand_at_1E
        .word stand_at_1F
        .word stand_at_20
        .word stand_at_21
        .word stand_at_22
        .word stand_at_23
        .word stand_at_24
        .word stand_at_25
        .word stand_at_26
        .word stand_at_27
        .word stand_at_28
        .word stand_at_29
        .word stand_at_2A
        .word stand_at_2B
        .word stand_at_2C
        .word stand_at_2D
        .word stand_at_2E
        .word stand_at_2F

; --- $8880  Which enemy appears there.
; Each byte is one enemy, in the order they appear.
foe_kind:
        .word foe_kind_00
        .word foe_kind_01
        .word foe_kind_02
        .word foe_kind_03
        .word foe_kind_04
        .word foe_kind_05
        .word foe_kind_06
        .word foe_kind_07
        .word foe_kind_08
        .word foe_kind_09
        .word foe_kind_0A
        .word foe_kind_0B
        .word foe_kind_0C
        .word foe_kind_0D
        .word foe_kind_0E
        .word foe_kind_0F
        .word foe_kind_10
        .word foe_kind_11
        .word foe_kind_12
        .word foe_kind_13
        .word foe_kind_14
        .word foe_kind_15
        .word foe_kind_16
        .word foe_kind_17
        .word foe_kind_18
        .word foe_kind_19
        .word foe_kind_1A
        .word foe_kind_1B
        .word foe_kind_1C
        .word foe_kind_1D
        .word foe_kind_1E
        .word foe_kind_1F
        .word foe_kind_20
        .word foe_kind_21
        .word foe_kind_22
        .word foe_kind_23
        .word foe_kind_24
        .word foe_kind_25
        .word foe_kind_26
        .word foe_kind_27
        .word foe_kind_28
        .word foe_kind_29
        .word foe_kind_2A
        .word foe_kind_2B
        .word foe_kind_2C
        .word foe_kind_2D
        .word foe_kind_2E
        .word foe_kind_2F

; Idle.
ryu_idle:
        .byte $01, $00                  ; how long, which picture
        .byte $FF                        ; play it again
; Walk.
ryu_walk:
        .byte $04, $02
        .byte $04, $03
        .byte $04, $04
        .byte $FF
; Crouch.
ryu_crouch:
        .byte $01, $01
        .byte $FF
; Sword.
ryu_sword:
        .byte $06, $06
        .byte $01, $07
        .byte $03, $27
        .byte $06, $08
        .byte $00                        ; the action ends
; Sword while crouching.
ryu_crouch_sword:
        .byte $06, $09
        .byte $01, $0A
        .byte $03, $28
        .byte $06, $0B
        .byte $00
; Jump.
ryu_jump:
        .byte $03, $10
        .byte $03, $16
        .byte $03, $17
        .byte $03, $18
        .byte $FF
; Regular sword in the air.
ryu_air_sword:
        .byte $01, $07
        .byte $03, $27
        .byte $10, $08
        .byte $00
; Spinning sword.
ryu_spin:
        .byte $02, $0C
        .byte $02, $0D
        .byte $02, $0E
        .byte $02, $0F
        .byte $02, $0C
        .byte $02, $0D
        .byte $02, $0E
        .byte $02, $0F
        .byte $FF
; Throw on the ground.
ryu_throw:
        .byte $06, $06
        .byte $0A, $11
        .byte $00
; Throw in the air.
ryu_air_throw:
        .byte $10, $11
        .byte $00
; Hold on.
ryu_hold:
        .byte $01, $12
        .byte $FF
; Knocked back.
ryu_knockback:
        .byte $3C, $14
        .byte $00
; Climbing.
ryu_climb:
        .byte $06, $12
        .byte $06, $13
        .byte $FF
; Throwing Star.
throwing_star_action:
        .byte $02, $23
        .byte $02, $24
        .byte $00                        ; start over
; Windmill Throwing Star.
windmill_star_action:
        .byte $02, $25
        .byte $02, $26
        .byte $00
action_0F:
        .byte $14, $7C
        .byte $0A, $7D
        .byte $00
action_10:
        .byte $05, $1D
        .byte $00
; The boxer.
boxer_action_11:
        .byte $0D, $00
        .byte $0D, $01
        .byte $00
; The boxer.
boxer_action_12:
        .byte $04, $02
        .byte $00
; The machine gunner.
machine_gunner_action_13:
        .byte $0D, $26
        .byte $0D, $27
        .byte $00
; The machine gunner.
machine_gunner_action_14:
        .byte $01, $28
        .byte $01, $29
        .byte $00
; The machine gunner's shot.
machine_gun_bullet_action_15:
        .byte $00, $2A
        .byte $00
; The thrower.
thrower_action_16:
        .byte $0C, $08
        .byte $0C, $09
        .byte $00
action_17:
        .byte $06, $09
        .byte $06, $08
        .byte $00
; The thrower.
thrower_action_18:
        .byte $0C, $0A
        .byte $00
; The thrower's axe.
axe_action_19:
        .byte $07, $0B
        .byte $07, $0C
        .byte $07, $0D
        .byte $07, $0E
        .byte $00
; The batter.
batter_action_1A:
        .byte $0E, $05
        .byte $0E, $06
        .byte $0E, $05
        .byte $0E, $07
        .byte $00
action_1B:
        .byte $00, $17
        .byte $00
; The knife thrower.
knife_thrower_action_1C:
        .byte $0F, $18
        .byte $0F, $17
        .byte $00
; The knife thrower.
knife_thrower_action_1D:
        .byte $0F, $19
        .byte $0C, $1A
        .byte $00
; The knife thrower.
knife_thrower_action_1E:
        .byte $0F, $1B
        .byte $0C, $1C
        .byte $00
; The crouching soldier.
crouching_soldier_action_1F:
        .byte $00, $20
        .byte $00
; The crouching soldier.
crouching_soldier_action_20:
        .byte $03, $21
        .byte $06, $22
        .byte $00
; The crouching soldier's shot.
crouching_soldier_bullet_action_21:
        .byte $00, $23
        .byte $00
action_22:
        .byte $05, $30
        .byte $00
; The jump kicker.
jump_kicker_action_23:
        .byte $10, $2D
        .byte $10, $2E
        .byte $00
; The jump kicker.
jump_kicker_action_24:
        .byte $02, $2D
        .byte $02, $2F
        .byte $02, $30
        .byte $04, $31
        .byte $00
; The jump kicker.
jump_kicker_action_25:
        .byte $01, $2E
        .byte $01, $2F
        .byte $01, $30
        .byte $01, $32
        .byte $00
; The running soldier.
running_soldier_action_26:
        .byte $0A, $1E
        .byte $0A, $1F
        .byte $00
; The running soldier.
running_soldier_action_27:
        .byte $00, $1F
        .byte $00
; The bat.
bat_action_28:
        .byte $06, $03
        .byte $06, $04
        .byte $00
; The waiting dog.
waiting_dog_action_29:
        .byte $00, $15
        .byte $00
; The dog.
dog_action_2A:
        .byte $0A, $15
        .byte $0A, $16
        .byte $00
; The bird.
bird_action_2B:
        .byte $02, $24
        .byte $02, $25
        .byte $00
action_2C:
        .byte $00, $25
        .byte $00
action_2D:
        .byte $02, $24
        .byte $02, $25
        .byte $00
; The jetpack ninja.
jetpack_ninja_action_2E:
        .byte $02, $0F
        .byte $02, $10
        .byte $00
; The jetpack ninja.
jetpack_ninja_action_2F:
        .byte $04, $11
        .byte $04, $12
        .byte $00
; The jetpack ninja's shuriken.
shuriken_action_30:
        .byte $04, $13
        .byte $04, $14
        .byte $00
; The running ninja.
running_ninja_action_31:
        .byte $00, $35
        .byte $00
action_32:
        .byte $00, $36
        .byte $00
; The running ninja.
running_ninja_action_33:
        .byte $06, $33
        .byte $06, $34
        .byte $00
; The stone man.
stone_man_action_34:
        .byte $08, $38
        .byte $08, $39
        .byte $00
; The stone man.
stone_man_action_35:
        .byte $08, $37
        .byte $08, $38
        .byte $00
; The stone man.
stone_man_action_36:
        .byte $08, $39
        .byte $06, $3A
        .byte $06, $3B
        .byte $00
; The stone man.
stone_man_action_37:
        .byte $08, $3C
        .byte $08, $3D
        .byte $00
; The stone man.
stone_man_action_38:
        .byte $00, $3C
        .byte $00
; The stone man's ring.
stone_man_ring_action_39:
        .byte $06, $3E
        .byte $06, $3F
        .byte $00
; The ghoul.
ghoul_action_3A:
        .byte $00, $2B
        .byte $00
; The ghoul.
ghoul_action_3B:
        .byte $00, $2C
        .byte $00
; When an enemy dies.
death_action_3C:
        .byte $01, $40
        .byte $01, $41
        .byte $01, $42
        .byte $01, $43
        .byte $01, $44
        .byte $00
; The Barbarian.
barbarian_action_3D:
        .byte $18, $45
        .byte $18, $46
        .byte $18, $45
        .byte $18, $46
; The Barbarian.
barbarian_action_3E:
        .byte $1E, $47
        .byte $04, $48
        .byte $14, $49
        .byte $1E, $47
        .byte $04, $48
        .byte $14, $49
        .byte $00
; Bomberhead.
bomberhead_action_3F:
        .byte $18, $4A
        .byte $18, $4B
        .byte $00
; Bomberhead.
bomberhead_action_40:
        .byte $30, $4C
        .byte $60, $4D
        .byte $00
; The Masked Devil.
masked_devil_action_41:
        .byte $18, $6A
        .byte $18, $6B
        .byte $00
; The Masked Devil.
masked_devil_action_42:
        .byte $00, $77
        .byte $00
; Basaquer.
basaquer_action_43:
        .byte $00, $52
        .byte $00
; Basaquer.
basaquer_action_44:
        .byte $00, $53
        .byte $00
; Basaquer.
basaquer_action_45:
        .byte $00, $54
        .byte $00
; Kelbeross.
kelbeross_action_46:
        .byte $00, $55
        .byte $00
; Kelbeross.
kelbeross_action_47:
        .byte $00, $57
        .byte $00
action_48:
        .byte $10, $56
        .byte $00
; Kelbeross.
kelbeross_action_49:
        .byte $06, $59
        .byte $06, $5A
        .byte $00
action_4A:
        .byte $00, $58
        .byte $00
; Bloody Malth.
bloody_malth_action_4B:
        .byte $00, $5C
        .byte $00
; Bloody Malth.
bloody_malth_action_4C:
        .byte $20, $5C
        .byte $20, $5D
        .byte $00
; Bloody Malth.
bloody_malth_action_4D:
        .byte $0A, $5B
        .byte $0A, $5F
        .byte $00
; Bloody Malth.
bloody_malth_action_4E:
        .byte $10, $60
        .byte $02, $68
        .byte $02, $61
        .byte $02, $68
        .byte $08, $63
        .byte $02, $68
        .byte $00
; Bloody Malth's lightning.
bloody_malth_lightning_action_4F:
        .byte $02, $62
        .byte $02, $65
        .byte $02, $64
        .byte $02, $67
        .byte $02, $68
        .byte $02, $66
        .byte $02, $69
        .byte $02, $68
        .byte $00
; Bloody Malth's lightning.
bloody_malth_lightning_action_50:
        .byte $04, $64
        .byte $04, $69
        .byte $00
; Art of the Fire Wheel.
fire_wheel_action:
        .byte $01, $2A
        .byte $01, $2B
        .byte $01, $2C
        .byte $01, $2D
        .byte $00
; An explosion around a boss.
explosion_action_52:
        .byte $04, $78
        .byte $02, $79
        .byte $04, $7A
        .byte $02, $7B
        .byte $00
action_53:
        .byte $00, $6D
        .byte $00
action_54:
        .byte $00, $6E
        .byte $00
action_55:
        .byte $00, $6F
        .byte $00
; Jaquio.
jaquio_action_56:
        .byte $00, $70
        .byte $00
; Jaquio.
jaquio_action_57:
        .byte $08, $73
        .byte $06, $74
        .byte $00
action_58:
        .byte $06, $71
        .byte $08, $72
        .byte $00
action_59:
        .byte $02, $87
        .byte $02, $8A
        .byte $00
; The last boss.
final_boss_action_5A:
        .byte $30, $7C
        .byte $18, $7D
        .byte $00
; The last boss.
final_boss_action_5B:
        .byte $10, $80
        .byte $08, $81
        .byte $04, $82
        .byte $10, $83
        .byte $04, $82
        .byte $10, $83
        .byte $08, $82
        .byte $08, $81
        .byte $00
action_5C:
        .byte $02, $80
        .byte $02, $81
        .byte $02, $82
        .byte $02, $83
        .byte $02, $82
        .byte $02, $83
        .byte $02, $82
        .byte $02, $81
        .byte $00
; The last boss's fireballs.
final_boss_fireballs_action_5D:
        .byte $08, $7E
        .byte $08, $7F
        .byte $00
; A thrown knife.
knife_action_5E:
        .byte $00, $1D
        .byte $00
; A lantern.
lantern_action_5F:
        .byte $04, $30
        .byte $04, $31
        .byte $00
; A lantern.
lantern_action_60:
        .byte $04, $32
        .byte $04, $33
        .byte $00
; A lantern.
lantern_action_61:
        .byte $04, $34
        .byte $04, $35
        .byte $00
; A lantern.
lantern_action_62:
        .byte $04, $36
        .byte $04, $37
        .byte $00
; A lantern.
lantern_action_63:
        .byte $04, $38
        .byte $04, $39
        .byte $00
; A lantern.
lantern_action_64:
        .byte $04, $3A
        .byte $04, $3B
        .byte $00
; A lantern.
lantern_action_65:
        .byte $04, $3C
        .byte $04, $3D
        .byte $00
; A lantern.
lantern_action_66:
        .byte $04, $3E
        .byte $04, $3F
        .byte $00
; A lantern.
lantern_action_67:
        .byte $04, $2E
        .byte $04, $2F
        .byte $00
; Invincible Fire-Wheel.
invincible_fire_wheel_action:
        .byte $01, $40
        .byte $01, $41
        .byte $01, $42
        .byte $01, $43
        .byte $00
; The Masked Devil.
masked_devil_fight_action_69:
        .byte $00, $85
        .byte $00
; Bomberhead.
bomberhead_action_6A:
        .byte $02, $4E
        .byte $02, $4F
        .byte $02, $50
        .byte $02, $51
        .byte $02, $6C
        .byte $02, $84
        .byte $00
; The last boss and his head.
final_boss_action_6B:
        .byte $08, $7C
        .byte $04, $7D
        .byte $00
; The last boss.
final_boss_action_6C:
        .byte $28, $7C
        .byte $14, $7D
        .byte $00
; Idle.
ryu_idle_pic_00:
        .byte $04                        ; how many pieces
        .byte $02, $F9, $E9             ; tile, across, up or down
        .byte $04, $01, $E9
        .byte $0A, $F8, $F9
        .byte $0C, $00, $F9
; Crouch.
ryu_crouch_pic_01:
        .byte $04
        .byte $02, $F9, $F1
        .byte $04, $01, $F1
        .byte $1C, $F8, $01
        .byte $1E, $00, $01
; Walk.
ryu_walk_pic_02:
        .byte $05
        .byte $20, $F9, $E8
        .byte $22, $01, $E8
        .byte $28, $F5, $F8
        .byte $2A, $FD, $F8
        .byte $2C, $05, $F8
; Walk.
ryu_walk_pic_03:
        .byte $05
        .byte $20, $F9, $E8
        .byte $22, $01, $E8
        .byte $30, $F5, $F8
        .byte $32, $FD, $F8
        .byte $2E, $05, $F8
; Walk.
ryu_walk_pic_04:
        .byte $04
        .byte $20, $F9, $E8
        .byte $22, $01, $E8
        .byte $24, $F5, $F8
        .byte $26, $FD, $F8
ryu_pic_05:
        .byte $04
        .byte $20, $F9, $E9
        .byte $22, $01, $E9
        .byte $28, $F5, $F9
        .byte $2A, $FD, $F9
; Sword, and a throw on the ground.
ryu_pic_06:
        .byte $04
        .byte $06, $FA, $E9
        .byte $10, $02, $E9
        .byte $0A, $F8, $F9
        .byte $0C, $00, $F9
; Sword.
ryu_sword_pic_07:
        .byte $08
        .byte $12, $FA, $EB
        .byte $14, $02, $EB
        .byte $0E, $F8, $FB
        .byte $18, $00, $FB
        .byte $38, $12, $EB
        .byte $3A, $1A, $EB
        .byte $16, $0A, $EB
        .byte $1A, $08, $FB
; Sword.
ryu_sword_pic_08:
        .byte $07
        .byte $12, $FA, $EB
        .byte $40, $02, $EB
        .byte $0E, $F8, $FB
        .byte $18, $00, $FB
        .byte $4A, $0E, $E5
        .byte $42, $0A, $EB
        .byte $1A, $08, $FB
; Sword while crouching.
ryu_crouch_sword_pic_09:
        .byte $04
        .byte $06, $FA, $F1
        .byte $10, $02, $F1
        .byte $1C, $F8, $01
        .byte $1E, $00, $01
; Sword while crouching.
ryu_crouch_sword_pic_0A:
        .byte $07
        .byte $12, $F9, $F1
        .byte $14, $01, $F1
        .byte $1C, $F8, $01
        .byte $1E, $00, $01
        .byte $38, $11, $F1
        .byte $3A, $19, $F1
        .byte $16, $09, $F1
; Sword while crouching.
ryu_crouch_sword_pic_0B:
        .byte $06
        .byte $12, $FA, $F1
        .byte $40, $02, $F1
        .byte $1C, $F8, $01
        .byte $1E, $00, $01
        .byte $4A, $0E, $EB
        .byte $42, $0A, $F1
; Spinning sword.
ryu_spin_pic_0C:
        .byte $05
        .byte $4C, $07, $E4
        .byte $34, $F7, $E7
        .byte $36, $FF, $E7
        .byte $3E, $FF, $F7
        .byte $3C, $F7, $E7
; Spinning sword.
ryu_spin_pic_0D:
        .byte $05
        .byte $48, $FD, $F6
        .byte $4A, $05, $F6
        .byte $46, $F2, $E6
        .byte $50, $FA, $E6
        .byte $52, $02, $E6
; Spinning sword.
ryu_spin_pic_0E:
        .byte $05
        .byte $4C, $F2, $ED
        .byte $3E, $FA, $DA
        .byte $3C, $02, $DA
        .byte $36, $FA, $EA
        .byte $34, $02, $EA
; Spinning sword.
ryu_spin_pic_0F:
        .byte $05
        .byte $4A, $F4, $DB
        .byte $48, $FC, $DB
        .byte $52, $F7, $EB
        .byte $50, $FF, $EB
        .byte $46, $07, $EB
; Jump.
ryu_jump_pic_10:
        .byte $04
        .byte $34, $F7, $E4
        .byte $36, $FF, $E4
        .byte $3E, $FF, $F4
        .byte $3C, $F8, $F4
; A throw.
ryu_throw_pic_11:
        .byte $06
        .byte $12, $FA, $EB
        .byte $40, $02, $EB
        .byte $44, $0A, $EB
        .byte $0E, $F8, $FB
        .byte $18, $00, $FB
        .byte $1A, $08, $FB
; Holding on, and climbing.
ryu_pic_12:
        .byte $04
        .byte $54, $F8, $E9
        .byte $56, $00, $E9
        .byte $5C, $F8, $F9
        .byte $5E, $00, $F9
; Climbing.
ryu_climb_pic_13:
        .byte $04
        .byte $54, $F8, $E9
        .byte $5A, $00, $E9
        .byte $4E, $F8, $F9
        .byte $58, $00, $F9
; Knocked back.
ryu_knockback_pic_14:
        .byte $04
        .byte $34, $F8, $F1
        .byte $36, $00, $F1
        .byte $3C, $F8, $01
        .byte $3E, $00, $01
; Jump.
ryu_jump_pic_15:
        .byte $03
        .byte $46, $F2, $E6
        .byte $50, $FA, $E6
        .byte $52, $02, $E6
; Jump.
ryu_jump_pic_17:
        .byte $04
        .byte $3E, $FA, $DA
        .byte $3C, $02, $DA
        .byte $36, $FA, $EA
        .byte $34, $02, $EA
; Jump.
ryu_jump_pic_18:
        .byte $03
        .byte $52, $F7, $EB
        .byte $50, $FF, $EB
        .byte $46, $07, $EB
ryu_pic_19:
        .byte $02
        .byte $60, $F8, $F8
        .byte $62, $00, $F8
ryu_pic_1A:
        .byte $02
        .byte $6C, $F8, $F8
        .byte $6E, $00, $F8
; Throwing Star, next to the life bar.
throwing_star_pic_1B:
        .byte $02
        .byte $64, $F8, $F8
        .byte $64, $00, $F8
; Windmill Throwing Star, next to the life bar.
windmill_star_pic_1C:
        .byte $02
        .byte $66, $F8, $F8
        .byte $66, $00, $F8
; Jump & Slash.
jump_and_slash_pic_1D:
        .byte $02
        .byte $7C, $F8, $F8
        .byte $7C, $00, $F8
; Art of the Fire Wheel, next to the life bar.
fire_wheel_pic_1E:
        .byte $02
        .byte $7A, $F8, $F8
        .byte $7A, $00, $F8
; Invincible Fire-Wheel, next to the life bar.
invincible_fire_wheel_pic_1F:
        .byte $02
        .byte $70, $F8, $F8
        .byte $72, $00, $F8
ryu_pic_20:
        .byte $02
        .byte $68, $F8, $F8
        .byte $68, $00, $F8
ryu_pic_21:
        .byte $02
        .byte $6A, $F8, $F8
        .byte $6A, $00, $F8
ryu_pic_22:
        .byte $02
        .byte $08, $F8, $F8
        .byte $08, $00, $F8
; Throwing Star.
throwing_star_pic_23:
        .byte $01
        .byte $74, $FC, $F4
; Throwing Star.
throwing_star_pic_24:
        .byte $01
        .byte $74, $FC, $F4
; Windmill Throwing Star.
windmill_star_pic_25:
        .byte $02
        .byte $76, $F8, $F8
        .byte $76, $00, $F8
; Windmill Throwing Star.
windmill_star_pic_26:
        .byte $02
        .byte $76, $00, $F8
        .byte $76, $F8, $F8
ryu_pic_29:
        .byte $01
        .byte $78, $FC, $F8
; Art of the Fire Wheel.
fire_wheel_pic_2A:
        .byte $03
        .byte $7E, $00, $E4
        .byte $7E, $09, $F6
        .byte $7E, $F5, $F5
; Art of the Fire Wheel.
fire_wheel_pic_2B:
        .byte $03
        .byte $7E, $06, $E6
        .byte $7E, $05, $FA
        .byte $7E, $F4, $EF
; Art of the Fire Wheel.
fire_wheel_pic_2C:
        .byte $03
        .byte $7E, $0A, $EA
        .byte $7E, $FF, $FB
        .byte $7E, $F6, $E9
; Art of the Fire Wheel.
fire_wheel_pic_2D:
        .byte $03
        .byte $7E, $0B, $F0
        .byte $7E, $F9, $F9
        .byte $7E, $FA, $E5
; A lantern.
lantern_pic_2E:
        .byte $02
        .byte $F1, $F9, $F8
        .byte $F3, $01, $F8
; A lantern.
lantern_pic_2F:
        .byte $02
        .byte $F5, $F9, $F8
        .byte $F7, $01, $F8
; A lantern.
lantern_pic_30:
        .byte $02
        .byte $F1, $F9, $F8
        .byte $F3, $01, $F8
; A lantern.
lantern_pic_31:
        .byte $02
        .byte $F5, $F9, $F8
        .byte $F7, $01, $F8
; A lantern.
lantern_pic_32:
        .byte $02
        .byte $ED, $F9, $F8
        .byte $EF, $01, $F8
; A lantern.
lantern_pic_33:
        .byte $02
        .byte $F9, $F9, $F8
        .byte $FB, $01, $F8
; A lantern.
lantern_pic_34:
        .byte $02
        .byte $F5, $F9, $F8
        .byte $F7, $01, $F8
; A lantern.
lantern_pic_35:
        .byte $02
        .byte $F9, $F9, $F8
        .byte $FB, $01, $F8
; A lantern.
lantern_pic_36:
        .byte $02
        .byte $F1, $F9, $F8
        .byte $F3, $01, $F8
; A lantern.
lantern_pic_37:
        .byte $02
        .byte $F5, $F9, $F8
        .byte $F7, $01, $F8
; A lantern.
lantern_pic_38:
        .byte $02
        .byte $79, $F9, $F8
        .byte $7B, $01, $F8
; A lantern.
lantern_pic_39:
        .byte $02
        .byte $7D, $F9, $F8
        .byte $7F, $01, $F8
; A lantern.
lantern_pic_3A:
        .byte $02
        .byte $ED, $F9, $F8
        .byte $EF, $01, $F8
; A lantern.
lantern_pic_3B:
        .byte $02
        .byte $F9, $F9, $F8
        .byte $FB, $01, $F8
; A lantern.
lantern_pic_3C:
        .byte $02
        .byte $F1, $F9, $F8
        .byte $F3, $01, $F8
; A lantern.
lantern_pic_3D:
        .byte $02
        .byte $F5, $F9, $F8
        .byte $F7, $01, $F8
; A lantern.
lantern_pic_3E:
        .byte $02
        .byte $ED, $F9, $F8
        .byte $EF, $01, $F8
; A lantern.
lantern_pic_3F:
        .byte $02
        .byte $F9, $F9, $F8
        .byte $FB, $01, $F8
; Invincible Fire-Wheel.
invincible_fire_wheel_pic_40:
        .byte $03
        .byte $7E, $00, $E8
        .byte $7E, $0C, $00
        .byte $7E, $F2, $FF
; Invincible Fire-Wheel.
invincible_fire_wheel_pic_41:
        .byte $03
        .byte $7E, $08, $EB
        .byte $7E, $07, $05
        .byte $7E, $F0, $F7
; Invincible Fire-Wheel.
invincible_fire_wheel_pic_42:
        .byte $03
        .byte $7E, $0D, $F0
        .byte $7E, $FF, $07
        .byte $7E, $F3, $EF
; Invincible Fire-Wheel.
invincible_fire_wheel_pic_43:
        .byte $03
        .byte $7E, $0F, $F8
        .byte $7E, $F7, $04
        .byte $7E, $F8, $EA
; The boxer.
boxer_pic_00:
        .byte $04                        ; how many pieces
        .byte $C2, $F8, $E8             ; tile, across, up or down
        .byte $C0, $00, $E8
        .byte $CA, $F8, $F8
        .byte $C8, $00, $F8
; The boxer.
boxer_pic_01:
        .byte $04
        .byte $C2, $F8, $E8
        .byte $C0, $00, $E8
        .byte $CE, $F8, $F8
        .byte $CC, $00, $F8
; The boxer.
boxer_pic_02:
        .byte $05
        .byte $C2, $F9, $E8
        .byte $C4, $01, $E8
        .byte $96, $09, $E8
        .byte $CA, $F8, $F8
        .byte $C8, $00, $F8
; The bat.
bat_pic_03:
        .byte $02
        .byte $82, $F9, $FC
        .byte $80, $01, $FC
; The bat.
bat_pic_04:
        .byte $02
        .byte $8A, $F9, $F9
        .byte $88, $01, $F9
; The batter.
batter_pic_05:
        .byte $05
        .byte $86, $F8, $E8
        .byte $84, $00, $E8
        .byte $94, $08, $E8
        .byte $9A, $F8, $F8
        .byte $98, $00, $F8
; The batter.
batter_pic_06:
        .byte $05
        .byte $86, $F8, $E8
        .byte $84, $00, $E8
        .byte $94, $08, $E8
        .byte $8E, $F8, $F8
        .byte $8C, $00, $F8
; The batter.
batter_pic_07:
        .byte $06
        .byte $9E, $F7, $D8
        .byte $9C, $FF, $D8
        .byte $92, $F8, $E8
        .byte $90, $00, $E8
        .byte $8E, $F8, $F8
        .byte $8C, $00, $F8
; The thrower.
thrower_pic_08:
        .byte $05
        .byte $A2, $F8, $E8
        .byte $A0, $00, $E8
        .byte $A6, $08, $E8
        .byte $AA, $F8, $F8
        .byte $A8, $00, $F8
; The thrower.
thrower_pic_09:
        .byte $05
        .byte $A2, $F8, $E8
        .byte $A0, $00, $E8
        .byte $A6, $08, $E8
        .byte $AE, $F8, $F8
        .byte $AC, $00, $F8
; The thrower.
thrower_pic_0A:
        .byte $05
        .byte $A2, $F8, $E8
        .byte $A4, $00, $E8
        .byte $A6, $F8, $DC
        .byte $AA, $F8, $F8
        .byte $A8, $00, $F8
; The thrower's axe.
axe_pic_0B:
        .byte $01
        .byte $A6, $FD, $F9
; The thrower's axe.
axe_pic_0C:
        .byte $01
        .byte $A6, $FD, $F9
; The thrower's axe.
axe_pic_0D:
        .byte $01
        .byte $A6, $FD, $F9
; The thrower's axe.
axe_pic_0E:
        .byte $01
        .byte $A6, $FD, $F9
; The jetpack ninja.
jetpack_ninja_pic_0F:
        .byte $07
        .byte $FA, $F0, $E8
        .byte $F8, $F8, $E8
        .byte $D6, $00, $E8
        .byte $F6, $F0, $F8
        .byte $F4, $F8, $F8
        .byte $F2, $00, $F8
        .byte $F0, $08, $F8
; The jetpack ninja.
jetpack_ninja_pic_10:
        .byte $06
        .byte $FA, $F8, $E8
        .byte $D6, $00, $E8
        .byte $F6, $F0, $F8
        .byte $F4, $F8, $F8
        .byte $F2, $00, $F8
        .byte $F0, $08, $F8
; The jetpack ninja.
jetpack_ninja_pic_11:
        .byte $07
        .byte $FA, $F0, $E8
        .byte $F8, $F8, $E8
        .byte $D6, $00, $E8
        .byte $F6, $F0, $F8
        .byte $F4, $F8, $F8
        .byte $EE, $00, $F8
        .byte $EC, $08, $F8
; The jetpack ninja.
jetpack_ninja_pic_12:
        .byte $06
        .byte $FA, $F8, $E8
        .byte $D6, $00, $E8
        .byte $F6, $F0, $F8
        .byte $F4, $F8, $F8
        .byte $EE, $00, $F8
        .byte $EC, $08, $F8
; The jetpack ninja's shuriken.
shuriken_pic_13:
        .byte $01
        .byte $74, $FD, $F5
; The jetpack ninja's shuriken.
shuriken_pic_14:
        .byte $01
        .byte $74, $FD, $F5
; The dog.
dog_pic_15:
        .byte $03
        .byte $D4, $F4, $F8
        .byte $D2, $FC, $F8
        .byte $D0, $04, $F8
; The dog.
dog_pic_16:
        .byte $04
        .byte $DE, $F0, $F8
        .byte $DC, $F8, $F8
        .byte $DA, $00, $F8
        .byte $D8, $08, $F8
; The knife thrower.
knife_thrower_pic_17:
        .byte $04
        .byte $E6, $F8, $E8
        .byte $E4, $00, $E8
        .byte $9A, $F8, $F8
        .byte $98, $00, $F8
; The knife thrower.
knife_thrower_pic_18:
        .byte $04
        .byte $E6, $F8, $E8
        .byte $E4, $00, $E8
        .byte $8E, $F8, $F8
        .byte $8C, $00, $F8
; The knife thrower.
knife_thrower_pic_19:
        .byte $04
        .byte $B2, $F8, $E8
        .byte $B0, $00, $E8
        .byte $9A, $F8, $F8
        .byte $98, $00, $F8
; The knife thrower.
knife_thrower_pic_1A:
        .byte $04
        .byte $BA, $F8, $E8
        .byte $B8, $00, $E8
        .byte $9A, $F8, $F8
        .byte $98, $00, $F8
; The knife thrower.
knife_thrower_pic_1B:
        .byte $04
        .byte $B6, $F8, $E8
        .byte $B4, $00, $E8
        .byte $BE, $F8, $F8
        .byte $BC, $00, $F8
; The knife thrower.
knife_thrower_pic_1C:
        .byte $04
        .byte $E0, $00, $E8
        .byte $E2, $F8, $E8
        .byte $E8, $00, $F8
        .byte $EA, $F8, $F8
; A thrown knife.
knife_pic_1D:
        .byte $01
        .byte $C6, $FC, $F5
; The running soldier.
running_soldier_pic_1E:
        .byte $04
        .byte $F4, $00, $E8
        .byte $F6, $F8, $E8
        .byte $F8, $00, $F8
        .byte $FA, $F8, $F8
; The running soldier.
running_soldier_pic_1F:
        .byte $04
        .byte $F6, $F8, $E8
        .byte $F4, $00, $E8
        .byte $F2, $F8, $F8
        .byte $F0, $00, $F8
; The crouching soldier.
crouching_soldier_pic_20:
        .byte $05
        .byte $C6, $F8, $E8
        .byte $C4, $00, $E8
        .byte $C2, $08, $E8
        .byte $CE, $F8, $F8
        .byte $CC, $00, $F8
; The crouching soldier.
crouching_soldier_pic_21:
        .byte $06
        .byte $C0, $10, $E8
        .byte $C2, $08, $E8
        .byte $C4, $00, $E8
        .byte $C6, $F8, $E8
        .byte $CE, $F8, $F8
        .byte $CC, $00, $F8
; The crouching soldier.
crouching_soldier_pic_22:
        .byte $05
        .byte $C6, $F5, $E8
        .byte $C4, $FD, $E8
        .byte $C2, $05, $E8
        .byte $CA, $F8, $F8
        .byte $C8, $00, $F8
; The crouching soldier's shot.
crouching_soldier_bullet_pic_23:
        .byte $01
        .byte $96, $FC, $F5
; The bird.
bird_pic_24:
        .byte $02
        .byte $D6, $F9, $00
        .byte $BA, $01, $00
; The bird.
bird_pic_25:
        .byte $04
        .byte $E6, $F8, $EB
        .byte $E4, $00, $EB
        .byte $EE, $F9, $FB
        .byte $EC, $01, $FB
; The machine gunner.
machine_gunner_pic_26:
        .byte $04
        .byte $B6, $F8, $E8
        .byte $B4, $00, $E8
        .byte $EA, $F8, $F8
        .byte $E8, $00, $F8
; The machine gunner.
machine_gunner_pic_27:
        .byte $04
        .byte $B6, $F8, $E8
        .byte $B4, $00, $E8
        .byte $BE, $F8, $F8
        .byte $BC, $00, $F8
; The machine gunner.
machine_gunner_pic_28:
        .byte $05
        .byte $B2, $08, $E8
        .byte $B4, $00, $E8
        .byte $B6, $F8, $E8
        .byte $EA, $F8, $F8
        .byte $E8, $00, $F8
; The machine gunner.
machine_gunner_pic_29:
        .byte $05
        .byte $B0, $08, $E8
        .byte $E0, $00, $E8
        .byte $E2, $F8, $E8
        .byte $EA, $F8, $F8
        .byte $E8, $00, $F8
; The machine gunner's shot.
machine_gun_bullet_pic_2A:
        .byte $01
        .byte $B8, $FC, $F7
; The ghoul.
ghoul_pic_2B:
        .byte $02
        .byte $F6, $F8, $F8
        .byte $F4, $00, $F8
; The ghoul.
ghoul_pic_2C:
        .byte $04
        .byte $F2, $F8, $E8
        .byte $F0, $00, $E8
        .byte $FA, $F8, $F8
        .byte $F8, $00, $F8
; The jump kicker.
jump_kicker_pic_2D:
        .byte $04
        .byte $86, $F7, $E8
        .byte $84, $FF, $E8
        .byte $8E, $F8, $F8
        .byte $8C, $00, $F8
; The jump kicker.
jump_kicker_pic_2E:
        .byte $04
        .byte $86, $F7, $E8
        .byte $84, $FF, $E8
        .byte $98, $00, $F8
        .byte $9A, $F8, $F8
; The jump kicker.
jump_kicker_pic_2F:
        .byte $05
        .byte $84, $F8, $E8
        .byte $86, $00, $E8
        .byte $92, $EF, $F8
        .byte $90, $F7, $F8
        .byte $8E, $FF, $F8
; The jump kicker.
jump_kicker_pic_30:
        .byte $04
        .byte $DA, $F8, $E8
        .byte $D8, $00, $E8
        .byte $DE, $F8, $F8
        .byte $DC, $00, $F8
; The jump kicker.
jump_kicker_pic_31:
        .byte $05
        .byte $9E, $FB, $E8
        .byte $9C, $03, $E8
        .byte $D4, $FB, $F8
        .byte $D2, $03, $F8
        .byte $D0, $0B, $F8
; The jump kicker.
jump_kicker_pic_32:
        .byte $05
        .byte $86, $F9, $E8
        .byte $94, $01, $E8
        .byte $8E, $FA, $F8
        .byte $90, $02, $F8
        .byte $92, $0A, $F8
; The running ninja.
running_ninja_pic_33:
        .byte $06
        .byte $E2, $F8, $E8
        .byte $E0, $00, $E8
        .byte $C0, $08, $E8
        .byte $96, $10, $E8
        .byte $BE, $F8, $F8
        .byte $BC, $00, $F8
; The running ninja.
running_ninja_pic_34:
        .byte $06
        .byte $E2, $F8, $E8
        .byte $E0, $00, $E8
        .byte $C0, $08, $E8
        .byte $96, $10, $E8
        .byte $EA, $F8, $F8
        .byte $E8, $00, $F8
; The running ninja.
running_ninja_pic_35:
        .byte $04
        .byte $B6, $F8, $E8
        .byte $B4, $00, $E8
        .byte $B2, $F8, $F8
        .byte $B0, $00, $F8
enemy_pic_36:
        .byte $04
        .byte $B6, $F8, $EB
        .byte $B4, $00, $EB
        .byte $DE, $F8, $FB
        .byte $DC, $00, $FB
; The stone man.
stone_man_pic_37:
        .byte $06
        .byte $DA, $F8, $E8
        .byte $D8, $00, $E8
        .byte $CE, $F8, $F8
        .byte $CC, $00, $F8
        .byte $B8, $FC, $E4
        .byte $B8, $04, $E4
; The stone man.
stone_man_pic_38:
        .byte $06
        .byte $DA, $F8, $E8
        .byte $D8, $00, $E8
        .byte $CA, $F8, $F8
        .byte $C8, $00, $F8
        .byte $B8, $FC, $E4
        .byte $B8, $04, $E4
; The stone man.
stone_man_pic_39:
        .byte $06
        .byte $DA, $F8, $E8
        .byte $D8, $00, $E8
        .byte $CA, $F8, $F8
        .byte $C8, $00, $F8
        .byte $B8, $FC, $E4
        .byte $B8, $04, $E4
; The stone man.
stone_man_pic_3A:
        .byte $07
        .byte $B8, $E9, $EC
        .byte $B8, $F1, $EC
        .byte $D4, $F0, $E8
        .byte $D2, $F8, $E8
        .byte $D0, $00, $E8
        .byte $CA, $F8, $F8
        .byte $C8, $00, $F8
; The stone man.
stone_man_pic_3B:
        .byte $07
        .byte $B8, $04, $F0
        .byte $B8, $0C, $F0
        .byte $C6, $F8, $E8
        .byte $C4, $00, $E8
        .byte $C2, $08, $E8
        .byte $CA, $F8, $F8
        .byte $C8, $00, $F8
; The stone man.
stone_man_pic_3C:
        .byte $05
        .byte $C6, $F8, $E8
        .byte $C4, $00, $E8
        .byte $C2, $08, $E8
        .byte $CA, $F8, $F8
        .byte $C8, $00, $F8
; The stone man.
stone_man_pic_3D:
        .byte $05
        .byte $C6, $F8, $E8
        .byte $C4, $00, $E8
        .byte $C2, $08, $E8
        .byte $CE, $F8, $F8
        .byte $CC, $00, $F8
; The stone man's ring.
stone_man_ring_pic_3E:
        .byte $02
        .byte $B8, $F9, $F9
        .byte $B8, $01, $F9
; The stone man's ring.
stone_man_ring_pic_3F:
        .byte $02
        .byte $B8, $F9, $F9
        .byte $B8, $01, $F9
; When an enemy dies.
death_pic_40:
        .byte $02
        .byte $FC, $F9, $F0
        .byte $FC, $01, $F0
; When an enemy dies.
death_pic_41:
        .byte $04
        .byte $FE, $F9, $F0
        .byte $FE, $01, $F0
        .byte $FE, $F9, $F0
        .byte $FE, $01, $F0
; When an enemy dies.
death_pic_42:
        .byte $04
        .byte $FE, $F4, $EC
        .byte $FE, $04, $EC
        .byte $FE, $F4, $F4
        .byte $FE, $04, $F4
; When an enemy dies.
death_pic_43:
        .byte $04
        .byte $FE, $F0, $E8
        .byte $FE, $08, $E8
        .byte $FE, $F0, $F8
        .byte $FE, $08, $F8
; When an enemy dies.
death_pic_44:
        .byte $04
        .byte $FE, $E8, $E0
        .byte $FE, $10, $E0
        .byte $FE, $E8, $00
        .byte $FE, $10, $00
; The Barbarian.
barbarian_pic_45:
        .byte $0C
        .byte $C2, $F9, $D8
        .byte $C4, $01, $D8
        .byte $C6, $09, $D8
        .byte $D0, $F1, $E8
        .byte $D2, $F9, $E8
        .byte $D4, $01, $E8
        .byte $D6, $09, $E8
        .byte $DA, $F9, $F8
        .byte $DC, $01, $F8
        .byte $DE, $09, $F8
        .byte $E4, $11, $F8
        .byte $E6, $19, $F8
; The Barbarian.
barbarian_pic_46:
        .byte $0B
        .byte $C2, $F9, $D8
        .byte $C4, $01, $D8
        .byte $C6, $09, $D8
        .byte $CA, $F0, $E8
        .byte $CC, $F8, $E8
        .byte $CE, $00, $E8
        .byte $D8, $08, $E8
        .byte $B6, $F5, $F8
        .byte $E0, $FD, $F8
        .byte $E2, $05, $F8
        .byte $E6, $09, $F9
; The Barbarian.
barbarian_pic_47:
        .byte $0B
        .byte $B8, $FB, $D8
        .byte $C2, $F9, $D8
        .byte $C4, $01, $D8
        .byte $C6, $09, $D8
        .byte $A8, $F1, $E8
        .byte $AA, $F9, $E8
        .byte $AC, $01, $E8
        .byte $AE, $09, $E8
        .byte $B6, $F5, $F8
        .byte $BC, $FD, $F8
        .byte $BE, $05, $F8
; The Barbarian.
barbarian_pic_48:
        .byte $0D
        .byte $C2, $F9, $D8
        .byte $C4, $01, $D8
        .byte $C6, $09, $D8
        .byte $CA, $F0, $E8
        .byte $CC, $F8, $E8
        .byte $CE, $00, $E8
        .byte $E8, $08, $E8
        .byte $EA, $10, $E8
        .byte $EC, $18, $E8
        .byte $EE, $20, $E8
        .byte $B6, $F5, $F8
        .byte $E0, $FD, $F8
        .byte $E2, $05, $F8
; The Barbarian.
barbarian_pic_49:
        .byte $0B
        .byte $C2, $F9, $D8
        .byte $C4, $01, $D8
        .byte $C6, $09, $D8
        .byte $CA, $F0, $E8
        .byte $CC, $F8, $E8
        .byte $CE, $00, $E8
        .byte $F0, $08, $E8
        .byte $B6, $F5, $F8
        .byte $E0, $FD, $F8
        .byte $E2, $05, $F8
        .byte $EE, $0F, $DE
; Bomberhead.
bomberhead_pic_4A:
        .byte $08
        .byte $80, $F9, $D8
        .byte $82, $01, $D8
        .byte $84, $09, $D8
        .byte $86, $11, $D8
        .byte $88, $F9, $E8
        .byte $8A, $01, $E8
        .byte $A0, $F9, $F8
        .byte $A2, $01, $F8
; Bomberhead.
bomberhead_pic_4B:
        .byte $08
        .byte $80, $F9, $D8
        .byte $82, $01, $D8
        .byte $84, $09, $D8
        .byte $86, $11, $D8
        .byte $8C, $F9, $E8
        .byte $8E, $01, $E8
        .byte $A4, $F9, $F8
        .byte $A6, $01, $F8
; Bomberhead.
bomberhead_pic_4C:
        .byte $09
        .byte $9C, $F1, $D8
        .byte $9E, $F9, $D8
        .byte $82, $01, $D8
        .byte $84, $09, $D8
        .byte $86, $11, $D8
        .byte $88, $F9, $E8
        .byte $8A, $01, $E8
        .byte $A0, $F9, $F8
        .byte $A2, $01, $F8
; Bomberhead.
bomberhead_pic_4D:
        .byte $08
        .byte $B0, $F9, $D8
        .byte $B2, $01, $D8
        .byte $B4, $09, $D8
        .byte $B6, $11, $DB
        .byte $88, $F9, $E8
        .byte $8A, $01, $E8
        .byte $A0, $F9, $F8
        .byte $A2, $01, $F8
; Bomberhead.
bomberhead_pic_4E:
        .byte $02
        .byte $94, $F1, $F1
        .byte $96, $F9, $F1
; Bomberhead.
bomberhead_pic_4F:
        .byte $04
        .byte $90, $F9, $E1
        .byte $92, $01, $E1
        .byte $98, $F9, $F1
        .byte $9A, $01, $F1
; Bomberhead.
bomberhead_pic_50:
        .byte $02
        .byte $96, $00, $F1
        .byte $94, $08, $F1
; Bomberhead.
bomberhead_pic_51:
        .byte $02
        .byte $96, $00, $00
        .byte $94, $08, $00
; Basaquer.
basaquer_pic_52:
        .byte $0B
        .byte $80, $EF, $D8
        .byte $82, $F7, $D8
        .byte $84, $FF, $D8
        .byte $86, $07, $D8
        .byte $88, $F1, $E8
        .byte $8A, $F9, $E8
        .byte $8C, $01, $E8
        .byte $8E, $09, $E8
        .byte $A0, $F1, $F8
        .byte $A2, $F9, $F8
        .byte $A4, $01, $F8
; Basaquer.
basaquer_pic_53:
        .byte $0E
        .byte $90, $EE, $C8
        .byte $92, $F6, $C8
        .byte $84, $FE, $C8
        .byte $96, $06, $C8
        .byte $C0, $0E, $C8
        .byte $98, $EE, $D8
        .byte $9A, $F6, $D8
        .byte $9C, $FE, $D8
        .byte $9E, $06, $D8
        .byte $C8, $0E, $D8
        .byte $B0, $F1, $E8
        .byte $B2, $F9, $E8
        .byte $B4, $01, $E8
        .byte $BA, $F9, $F8
; Basaquer.
basaquer_pic_54:
        .byte $01
        .byte $94, $FD, $F8
; Kelbeross.
kelbeross_pic_55:
        .byte $08
        .byte $D0, $F1, $E8
        .byte $D2, $F9, $E8
        .byte $D4, $01, $E8
        .byte $D6, $09, $E8
        .byte $D8, $F1, $F8
        .byte $DA, $F9, $F8
        .byte $DC, $01, $F8
        .byte $DE, $09, $F8
enemy_pic_56:
        .byte $08
        .byte $D0, $F1, $E8
        .byte $C6, $F9, $E8
        .byte $AC, $01, $E8
        .byte $AE, $09, $E8
        .byte $D8, $F1, $F8
        .byte $DA, $F9, $F8
        .byte $CC, $01, $F8
        .byte $CE, $09, $F8
; Kelbeross.
kelbeross_pic_57:
        .byte $0A
        .byte $A8, $F1, $D8
        .byte $AA, $F9, $D8
        .byte $AC, $01, $D8
        .byte $AE, $09, $D8
        .byte $B8, $F1, $E8
        .byte $BA, $F9, $E8
        .byte $BC, $01, $E8
        .byte $BE, $09, $E8
        .byte $E8, $F1, $F8
        .byte $EA, $F9, $F8
enemy_pic_58:
        .byte $01
        .byte $CA, $FD, $F8
; Kelbeross.
kelbeross_pic_59:
        .byte $02
        .byte $EE, $F9, $F8
        .byte $EC, $01, $F8
; Kelbeross.
kelbeross_pic_5A:
        .byte $02
        .byte $EE, $F9, $F8
        .byte $EC, $01, $F8
; Bloody Malth.
bloody_malth_pic_5B:
        .byte $0B
        .byte $D4, $F9, $C8
        .byte $D4, $01, $C8
        .byte $DA, $F1, $D8
        .byte $DC, $F9, $D8
        .byte $DE, $01, $D8
        .byte $E4, $F9, $E8
        .byte $E6, $01, $E8
        .byte $EC, $F9, $F8
        .byte $EE, $01, $F8
        .byte $F2, $09, $E0
        .byte $F0, $09, $F0
; Bloody Malth.
bloody_malth_pic_5C:
        .byte $0B
        .byte $D4, $F9, $C8
        .byte $D4, $01, $C8
        .byte $DA, $F1, $D8
        .byte $DC, $F9, $D8
        .byte $D6, $01, $D8
        .byte $E4, $F9, $E8
        .byte $D2, $01, $E8
        .byte $EC, $F9, $F8
        .byte $EE, $01, $F8
        .byte $F2, $09, $D8
        .byte $F0, $09, $E8
; Bloody Malth.
bloody_malth_pic_5D:
        .byte $0B
        .byte $D4, $F9, $C8
        .byte $D4, $01, $C8
        .byte $DA, $F1, $D8
        .byte $DC, $F9, $D8
        .byte $D6, $01, $D8
        .byte $E0, $F9, $E8
        .byte $E2, $01, $E8
        .byte $E8, $F9, $F8
        .byte $EA, $01, $F8
        .byte $F2, $09, $D8
        .byte $F0, $09, $E8
enemy_pic_5E:
        .byte $0B
        .byte $D4, $F9, $C8
        .byte $D4, $01, $C8
        .byte $DA, $F1, $D8
        .byte $DC, $F9, $D8
        .byte $DE, $01, $D8
        .byte $E0, $F9, $E8
        .byte $E2, $01, $E8
        .byte $E8, $F9, $F8
        .byte $EA, $01, $F8
        .byte $F2, $09, $E0
        .byte $F0, $09, $F0
; Bloody Malth.
bloody_malth_pic_5F:
        .byte $0A
        .byte $D4, $FC, $C8
        .byte $D4, $05, $C8
        .byte $C4, $F9, $D8
        .byte $C6, $01, $D8
        .byte $D0, $09, $D8
        .byte $CC, $F9, $E8
        .byte $CE, $01, $E8
        .byte $D8, $09, $E8
        .byte $EC, $F9, $F8
        .byte $EE, $01, $F8
; Bloody Malth.
bloody_malth_pic_60:
        .byte $0A
        .byte $B0, $F8, $98
        .byte $90, $F6, $A8
        .byte $B4, $00, $A8
        .byte $94, $FE, $B8
        .byte $96, $06, $B8
        .byte $9C, $00, $C8
        .byte $9E, $08, $C8
        .byte $92, $03, $D8
        .byte $98, $00, $E8
        .byte $90, $FD, $F8
; Bloody Malth.
bloody_malth_pic_61:
        .byte $07
        .byte $B0, $FD, $B8
        .byte $98, $F7, $C8
        .byte $90, $FB, $D8
        .byte $9C, $F9, $E8
        .byte $9E, $01, $E8
        .byte $94, $F7, $F8
        .byte $96, $FF, $F8
; Bloody Malth's lightning.
bloody_malth_lightning_pic_62:
        .byte $02
        .byte $CA, $F9, $F8
        .byte $C8, $01, $F8
; Bloody Malth.
bloody_malth_pic_63:
        .byte $02
        .byte $B0, $F9, $E8
        .byte $98, $FF, $F8
; Bloody Malth's lightning.
bloody_malth_lightning_pic_64:
        .byte $02
        .byte $C0, $F9, $F8
        .byte $C2, $01, $F8
; Bloody Malth's lightning.
bloody_malth_lightning_pic_65:
        .byte $08
        .byte $C8, $F1, $F0
        .byte $CA, $F9, $F0
        .byte $C8, $01, $F0
        .byte $CA, $09, $F0
        .byte $CA, $F1, $00
        .byte $C8, $F9, $00
        .byte $CA, $01, $00
        .byte $C8, $09, $00
; Bloody Malth's lightning.
bloody_malth_lightning_pic_66:
        .byte $02
        .byte $C8, $F9, $F8
        .byte $CA, $01, $F8
; Bloody Malth's lightning.
bloody_malth_lightning_pic_67:
        .byte $08
        .byte $CA, $F1, $F0
        .byte $C8, $F9, $F0
        .byte $CA, $01, $F0
        .byte $C8, $09, $F0
        .byte $C8, $F1, $00
        .byte $CA, $F9, $00
        .byte $C8, $01, $00
        .byte $CA, $09, $00
; Bloody Malth and his lightning.
bloody_malth_pic_68:
        .byte $01
        .byte $86, $FD, $F8
; Bloody Malth's lightning.
bloody_malth_lightning_pic_69:
        .byte $02
        .byte $C2, $F9, $F8
        .byte $C0, $01, $F8
; The Masked Devil.
masked_devil_pic_6A:
        .byte $10
        .byte $80, $E9, $C8
        .byte $82, $F9, $C8
        .byte $84, $01, $C8
        .byte $80, $11, $C9
        .byte $88, $ED, $D8
        .byte $8A, $F9, $D8
        .byte $8C, $01, $D8
        .byte $88, $0D, $D9
        .byte $B2, $F1, $E8
        .byte $A4, $F9, $E8
        .byte $B6, $01, $E8
        .byte $8E, $09, $E8
        .byte $B8, $E9, $F8
        .byte $BA, $F1, $F8
        .byte $BC, $F9, $F8
        .byte $BE, $01, $F8
; The Masked Devil.
masked_devil_pic_6B:
        .byte $10
        .byte $80, $E9, $C8
        .byte $82, $F9, $C8
        .byte $84, $01, $C8
        .byte $80, $11, $C9
        .byte $88, $ED, $D8
        .byte $8A, $F9, $D8
        .byte $8C, $01, $D8
        .byte $88, $0D, $D9
        .byte $A2, $F1, $E8
        .byte $A4, $F9, $E8
        .byte $A6, $01, $E8
        .byte $8E, $09, $E8
        .byte $A8, $E9, $F8
        .byte $AA, $F1, $F8
        .byte $AC, $F9, $F8
        .byte $AE, $01, $F8
; Bomberhead.
bomberhead_pic_6C:
        .byte $04
        .byte $9A, $F8, $00
        .byte $98, $00, $00
        .byte $92, $F8, $0F
        .byte $90, $00, $0F
enemy_pic_6D:
        .byte $15
        .byte $F0, $E9, $E8
        .byte $F2, $F1, $E8
        .byte $86, $F9, $E8
        .byte $90, $01, $E8
        .byte $CA, $09, $E8
        .byte $9E, $E9, $F8
        .byte $C8, $F1, $F8
        .byte $CA, $F9, $F8
        .byte $CC, $01, $F8
        .byte $CE, $09, $F8
        .byte $D8, $11, $F8
        .byte $C6, $EC, $08
        .byte $D0, $F4, $08
        .byte $D2, $FC, $08
        .byte $D4, $04, $08
        .byte $D6, $0C, $08
        .byte $AA, $E9, $18
        .byte $AC, $F1, $18
        .byte $AE, $F9, $18
        .byte $B8, $01, $18
        .byte $BA, $09, $18
enemy_pic_6E:
        .byte $18
        .byte $80, $E1, $EF
        .byte $82, $E9, $E8
        .byte $84, $F1, $E8
        .byte $86, $F9, $E8
        .byte $90, $01, $E8
        .byte $92, $09, $E8
        .byte $94, $11, $E8
        .byte $96, $19, $EC
        .byte $8A, $E9, $F8
        .byte $8C, $F1, $F8
        .byte $8E, $F9, $F8
        .byte $98, $01, $F8
        .byte $9A, $09, $F8
        .byte $9C, $11, $F8
        .byte $A2, $EC, $08
        .byte $AE, $F4, $08
        .byte $A6, $FC, $08
        .byte $B0, $04, $08
        .byte $B2, $0C, $08
        .byte $AA, $E9, $18
        .byte $AC, $F1, $18
        .byte $AE, $F9, $18
        .byte $B8, $01, $18
        .byte $BA, $09, $18
enemy_pic_6F:
        .byte $1A
        .byte $80, $E1, $DF
        .byte $82, $E9, $D8
        .byte $84, $F1, $D8
        .byte $86, $F9, $D8
        .byte $90, $01, $D8
        .byte $92, $09, $D8
        .byte $94, $11, $D8
        .byte $96, $19, $DC
        .byte $8A, $E9, $E8
        .byte $8C, $F1, $E8
        .byte $8E, $F9, $E8
        .byte $98, $01, $E8
        .byte $9A, $09, $E8
        .byte $9C, $11, $E8
        .byte $A2, $EC, $F8
        .byte $A4, $F4, $F8
        .byte $A6, $FC, $F8
        .byte $B0, $04, $F8
        .byte $B2, $0C, $F8
        .byte $E0, $F1, $08
        .byte $E2, $F9, $08
        .byte $E4, $01, $08
        .byte $E6, $09, $08
        .byte $E8, $F1, $18
        .byte $EA, $F9, $18
        .byte $EC, $01, $18
; Jaquio.
jaquio_pic_70:
        .byte $1A
        .byte $88, $E1, $DF
        .byte $82, $E9, $D8
        .byte $84, $F1, $D8
        .byte $86, $F9, $D8
        .byte $90, $01, $D8
        .byte $92, $09, $D8
        .byte $94, $11, $D8
        .byte $A0, $19, $E0
        .byte $8A, $E9, $E8
        .byte $8C, $F1, $E8
        .byte $8E, $F9, $E8
        .byte $98, $01, $E8
        .byte $9A, $09, $E8
        .byte $9C, $11, $E8
        .byte $A2, $EC, $F8
        .byte $A4, $F4, $F8
        .byte $A6, $FC, $F8
        .byte $B0, $04, $F8
        .byte $B2, $0C, $F8
        .byte $E0, $F1, $08
        .byte $E2, $F9, $08
        .byte $E4, $01, $08
        .byte $E6, $09, $08
        .byte $E8, $F1, $18
        .byte $EA, $F9, $18
        .byte $EC, $01, $18
enemy_pic_71:
        .byte $02
        .byte $BC, $F9, $F8
        .byte $BE, $01, $F8
enemy_pic_72:
        .byte $02
        .byte $B4, $F9, $F8
        .byte $B6, $01, $F8
; Jaquio.
jaquio_pic_73:
        .byte $02
        .byte $BE, $F9, $F8
        .byte $BC, $01, $F8
; Jaquio.
jaquio_pic_74:
        .byte $02
        .byte $B6, $F9, $F8
        .byte $B4, $01, $F8
enemy_pic_75:
        .byte $02
        .byte $A6, $F9, $F8
        .byte $A6, $01, $F8
enemy_pic_76:
        .byte $02
        .byte $A6, $F9, $F8
        .byte $A6, $01, $F8
; The Masked Devil.
masked_devil_pic_77:
        .byte $01
        .byte $9A, $FD, $F8
; An explosion around a boss.
explosion_pic_78:
        .byte $02
        .byte $FC, $07, $F9
        .byte $FC, $FF, $F9
; An explosion around a boss.
explosion_pic_79:
        .byte $08
        .byte $F4, $F1, $F0
        .byte $F6, $F9, $F0
        .byte $FA, $01, $F0
        .byte $F8, $09, $F0
        .byte $F8, $F1, $00
        .byte $FA, $F9, $00
        .byte $F6, $01, $00
        .byte $F4, $09, $00
; An explosion around a boss.
explosion_pic_7A:
        .byte $02
        .byte $FC, $01, $F9
        .byte $FC, $F9, $F9
; An explosion around a boss.
explosion_pic_7B:
        .byte $08
        .byte $F8, $F1, $F0
        .byte $FA, $F9, $F0
        .byte $F6, $01, $F0
        .byte $F4, $09, $F0
        .byte $F4, $F1, $00
        .byte $F6, $F9, $00
        .byte $FA, $01, $00
        .byte $F8, $09, $00
; The last boss and his head.
final_boss_pic_7C:
        .byte $11
        .byte $01, $E9, $C8
        .byte $03, $F1, $C8
        .byte $05, $F9, $C8
        .byte $07, $01, $C8
        .byte $09, $E9, $D8
        .byte $0B, $F1, $D8
        .byte $0D, $F9, $D8
        .byte $0F, $01, $D8
        .byte $19, $09, $D8
        .byte $21, $E9, $E8
        .byte $23, $F1, $E8
        .byte $25, $F9, $E8
        .byte $27, $01, $E8
        .byte $57, $09, $E8
        .byte $2B, $F1, $F8
        .byte $2D, $F9, $F8
        .byte $2F, $01, $F8
; The last boss and his head.
final_boss_pic_7D:
        .byte $12
        .byte $01, $E9, $C8
        .byte $03, $F1, $C8
        .byte $05, $F9, $C8
        .byte $07, $01, $C8
        .byte $81, $E9, $D8
        .byte $83, $F1, $D8
        .byte $85, $F9, $D8
        .byte $87, $01, $D8
        .byte $19, $09, $D8
        .byte $89, $E9, $E8
        .byte $8B, $F1, $E8
        .byte $8D, $F9, $E8
        .byte $8F, $01, $E8
        .byte $29, $09, $E8
        .byte $A1, $F1, $F8
        .byte $A3, $F9, $F8
        .byte $A5, $01, $F8
        .byte $A7, $09, $F8
; The last boss's fireballs.
final_boss_fireballs_pic_7E:
        .byte $02
        .byte $A9, $F9, $F8
        .byte $AB, $01, $F8
; The last boss's fireballs.
final_boss_fireballs_pic_7F:
        .byte $02
        .byte $AB, $F9, $F8
        .byte $A9, $01, $F8
; The last boss.
final_boss_pic_80:
        .byte $04
        .byte $13, $F9, $D8
        .byte $15, $01, $D8
        .byte $1B, $F9, $E8
        .byte $1D, $01, $E8
; The last boss.
final_boss_pic_81:
        .byte $03
        .byte $17, $F9, $D0
        .byte $1F, $F9, $E0
        .byte $11, $01, $E8
; The last boss.
final_boss_pic_82:
        .byte $04
        .byte $41, $E9, $E0
        .byte $43, $F1, $E0
        .byte $45, $F9, $E0
        .byte $47, $01, $E6
; The last boss.
final_boss_pic_83:
        .byte $03
        .byte $51, $F9, $E0
        .byte $53, $F9, $F0
        .byte $55, $01, $EE
; Bomberhead.
bomberhead_pic_84:
        .byte $02
        .byte $94, $F1, $00
        .byte $96, $F9, $00
; The Masked Devil.
masked_devil_fight_pic_85:
        .byte $02
        .byte $DD, $F9, $F9
        .byte $DF, $01, $F9
; Idle.
ryu_idle_pal_00:
        .byte $00, $00, $00, $00        ; one color for each piece
; Crouch.
ryu_crouch_pal_01:
        .byte $00, $00, $00, $00
; Walk.
ryu_walk_pal_02:
        .byte $00, $00, $00
; Walk.
ryu_walk_pal_03:
        .byte $00, $00, $00, $00
; Walk.
ryu_walk_pal_04:
        .byte $00, $00, $00
ryu_pal_05:
        .byte $00, $00, $00
; Sword, and a throw on the ground.
ryu_pal_06:
        .byte $00, $00, $00, $00
; Sword.
ryu_sword_pal_07:
        .byte $00, $00, $00, $00, $01, $01, $00, $00
; Sword.
ryu_sword_pal_08:
        .byte $00, $00, $00, $00, $81, $00, $00
; Sword while crouching.
ryu_crouch_sword_pal_09:
        .byte $00, $00, $00, $00
; Sword while crouching.
ryu_crouch_sword_pal_0A:
        .byte $00, $00, $00, $00, $01, $01, $00
; Sword while crouching.
ryu_crouch_sword_pal_0B:
        .byte $00, $00, $00, $00, $81, $00
; Spinning sword.
ryu_spin_pal_0C:
        .byte $01, $00, $00, $00, $00
; Spinning sword.
ryu_spin_pal_0D:
        .byte $01, $01, $00, $00, $00
; Spinning sword.
ryu_spin_pal_0E:
        .byte $C1, $C0, $C0, $C0, $C0
; Spinning sword.
ryu_spin_pal_0F:
        .byte $C1, $C1, $C0, $C0, $C0
; Jump.
ryu_jump_pal_10:
        .byte $00, $00, $00, $00
; A throw.
ryu_throw_pal_11:
        .byte $00, $00, $00, $00, $00, $00
; Holding on, and climbing.
ryu_pal_12:
        .byte $00, $00, $00, $00
; Climbing.
ryu_climb_pal_13:
        .byte $00, $00, $00, $00
; Knocked back.
ryu_knockback_pal_14:
        .byte $00, $00, $00, $00
ryu_pal_15:
        .byte $00, $00, $00, $00
; Jump.
ryu_jump_pal_16:
        .byte $00, $00, $00
; Jump.
ryu_jump_pal_17:
        .byte $C0, $C0, $C0, $C0
; Jump.
ryu_jump_pal_18:
        .byte $C0, $C0, $C0
ryu_pal_19:
        .byte $00, $00
        .byte $01, $01        ; another set of colors
ryu_pal_1A:
        .byte $00, $00
; Throwing Star, next to the life bar.
throwing_star_pal_1B:
        .byte $00, $C0
; Windmill Throwing Star, next to the life bar.
windmill_star_pal_1C:
        .byte $01, $C1
; Jump & Slash.
jump_and_slash_pal_1D:
        .byte $00, $C0
; Art of the Fire Wheel, next to the life bar.
fire_wheel_pal_1E:
        .byte $01, $41
; Invincible Fire-Wheel, next to the life bar.
invincible_fire_wheel_pal_1F:
        .byte $01, $01
ryu_pal_20:
        .byte $01, $41
ryu_pal_21:
        .byte $01, $41
ryu_pal_22:
        .byte $00, $40
        .byte $01, $41        ; another set of colors
; Throwing Star.
throwing_star_pal_23:
        .byte $01
; Throwing Star.
throwing_star_pal_24:
        .byte $41
; Windmill Throwing Star.
windmill_star_pal_25:
        .byte $C1, $01
; Windmill Throwing Star.
windmill_star_pal_26:
        .byte $81, $41
ryu_pal_29:
        .byte $01
; Art of the Fire Wheel.
fire_wheel_pal_2A:
        .byte $01, $01, $01
; A lantern.
lantern_pal_2E:
        .byte $03, $00
; A lantern.
lantern_pal_2F:
        .byte $03, $00
; A lantern.
lantern_pal_30:
        .byte $00, $00
        .byte $01, $00        ; another set of colors
; A lantern.
lantern_pal_31:
        .byte $00, $00
        .byte $01, $00        ; another set of colors
; A lantern.
lantern_pal_32:
        .byte $01, $00
; A lantern.
lantern_pal_33:
        .byte $01, $00
; A lantern.
lantern_pal_34:
        .byte $00, $00
; A lantern.
lantern_pal_35:
        .byte $00, $00
; A lantern.
lantern_pal_36:
        .byte $01, $01
; A lantern.
lantern_pal_37:
        .byte $01, $01
; A lantern.
lantern_pal_38:
        .byte $00, $00
; A lantern.
lantern_pal_39:
        .byte $00, $00
; A lantern.
lantern_pal_3A:
        .byte $01, $01
; A lantern.
lantern_pal_3B:
        .byte $01, $01
; A lantern.
lantern_pal_3C:
        .byte $01, $01
; A lantern.
lantern_pal_3D:
        .byte $01, $01
; A lantern.
lantern_pal_3E:
        .byte $01, $01
; A lantern.
lantern_pal_3F:
        .byte $01, $01
; Invincible Fire-Wheel.
invincible_fire_wheel_pal_40:
        .byte $01, $01, $01
; The boxer.
boxer_pal_00:
        .byte $02, $02, $03, $03        ; one color for each piece
; The boxer.
boxer_pal_01:
        .byte $02, $02, $03, $03
; The boxer.
boxer_pal_02:
        .byte $02, $02, $02, $03, $03
; The bat.
bat_pal_03:
        .byte $02, $02
        .byte $03, $03        ; another set of colors
; The bat.
bat_pal_04:
        .byte $02, $02
        .byte $03, $03        ; another set of colors
; The batter.
batter_pal_05:
        .byte $02, $02, $00, $02, $02
        .byte $02, $02, $02, $02, $02        ; another set of colors
; The batter.
batter_pal_06:
        .byte $02, $02, $00, $02, $02
        .byte $02, $02, $02, $02, $02        ; another set of colors
; The batter.
batter_pal_07:
        .byte $00, $00, $02, $02, $02, $02
        .byte $02, $02, $02, $02, $02, $02        ; another set of colors
; The thrower.
thrower_pal_08:
        .byte $03, $03, $02, $03, $03
        .byte $02, $02, $00, $02, $02        ; another set of colors
        .byte $00, $00, $02, $00, $00        ; another set of colors
        .byte $02, $02, $00, $03, $03        ; another set of colors
; The thrower.
thrower_pal_09:
        .byte $03, $03, $02, $03, $03
        .byte $02, $02, $00, $02, $02        ; another set of colors
        .byte $00, $00, $02, $00, $00        ; another set of colors
        .byte $02, $02, $00, $03, $03        ; another set of colors
; The thrower.
thrower_pal_0A:
        .byte $03, $03, $42, $03, $03
        .byte $02, $02, $40, $02, $02        ; another set of colors
        .byte $00, $00, $42, $00, $00        ; another set of colors
        .byte $02, $02, $40, $03, $03        ; another set of colors
; The thrower's axe.
axe_pal_0B:
        .byte $02
        .byte $00        ; another set of colors
; The thrower's axe.
axe_pal_0C:
        .byte $82
        .byte $80        ; another set of colors
; The thrower's axe.
axe_pal_0D:
        .byte $C2
        .byte $C0        ; another set of colors
; The thrower's axe.
axe_pal_0E:
        .byte $42
        .byte $40        ; another set of colors
; The jetpack ninja.
jetpack_ninja_pal_0F:
        .byte $01, $01, $00, $03, $03, $03, $03
; The jetpack ninja.
jetpack_ninja_pal_10:
        .byte $01, $00, $03, $03, $03, $03
; The jetpack ninja.
jetpack_ninja_pal_11:
        .byte $01, $01, $00, $03, $03, $03, $03
; The jetpack ninja.
jetpack_ninja_pal_12:
        .byte $01, $00, $03, $03, $03, $03
; The jetpack ninja's shuriken.
shuriken_pal_13:
        .byte $00
; The jetpack ninja's shuriken.
shuriken_pal_14:
        .byte $40
; The dog.
dog_pal_15:
        .byte $00, $00, $03
        .byte $02, $02, $02        ; another set of colors
; The dog.
dog_pal_16:
        .byte $00, $00, $00, $03
        .byte $02, $02, $02, $02        ; another set of colors
; The knife thrower.
knife_thrower_pal_17:
        .byte $03, $03, $03, $03
; The knife thrower.
knife_thrower_pal_18:
        .byte $03, $03, $03, $03
; The knife thrower.
knife_thrower_pal_19:
        .byte $03, $03, $03, $03
; The knife thrower.
knife_thrower_pal_1A:
        .byte $03, $03, $03, $03
; The knife thrower.
knife_thrower_pal_1B:
        .byte $03, $03, $03, $03
; The knife thrower.
knife_thrower_pal_1C:
        .byte $03, $03, $03, $03
; A thrown knife.
knife_pal_1D:
        .byte $00
; The running soldier.
running_soldier_pal_1E:
        .byte $03, $03, $03, $03
; The running soldier.
running_soldier_pal_1F:
        .byte $03, $03, $03, $03
; The crouching soldier.
crouching_soldier_pal_20:
        .byte $03, $03, $03, $03, $03
        .byte $02, $02, $02, $02, $02        ; another set of colors
; The crouching soldier.
crouching_soldier_pal_21:
        .byte $01, $03, $03, $03, $03, $03
        .byte $01, $02, $02, $02, $02, $00        ; another set of colors
; The crouching soldier.
crouching_soldier_pal_22:
        .byte $03, $03, $03, $03, $03
        .byte $02, $02, $02, $02, $02        ; another set of colors
; The crouching soldier's shot.
crouching_soldier_bullet_pal_23:
        .byte $00
        .byte $01        ; another set of colors
; The bird.
bird_pal_24:
        .byte $02, $02
; The bird.
bird_pal_25:
        .byte $02, $02, $02, $02
; The machine gunner.
machine_gunner_pal_26:
        .byte $03, $03, $03, $03
; The machine gunner.
machine_gunner_pal_27:
        .byte $03, $03, $03, $03
; The machine gunner.
machine_gunner_pal_28:
        .byte $01, $03, $03, $03, $03
; The machine gunner.
machine_gunner_pal_29:
        .byte $01, $03, $03, $03, $03
; The machine gunner's shot.
machine_gun_bullet_pal_2A:
        .byte $00
; The ghoul.
ghoul_pal_2B:
        .byte $03, $03
        .byte $00, $00        ; another set of colors
; The ghoul.
ghoul_pal_2C:
        .byte $03, $03, $03, $03
        .byte $00, $00, $00, $00        ; another set of colors
; The jump kicker.
jump_kicker_pal_2D:
        .byte $02, $02, $02, $02
; The jump kicker.
jump_kicker_pal_2E:
        .byte $02, $02, $02, $02
; The jump kicker.
jump_kicker_pal_2F:
        .byte $42, $42, $02, $02, $42
; The jump kicker.
jump_kicker_pal_30:
        .byte $02, $02, $02, $02
; The jump kicker.
jump_kicker_pal_31:
        .byte $02, $02, $02, $02, $02
; The jump kicker.
jump_kicker_pal_32:
        .byte $02, $02, $02, $42, $42
; The running ninja.
running_ninja_pal_33:
        .byte $03, $03, $03, $03, $03, $03
; The running ninja.
running_ninja_pal_34:
        .byte $03, $03, $03, $03, $03, $03
; The running ninja.
running_ninja_pal_35:
        .byte $03, $03, $03, $03
enemy_pal_36:
        .byte $03, $03, $03, $03
; The stone man.
stone_man_pal_37:
        .byte $02, $02, $02, $02, $42, $82
; The stone man.
stone_man_pal_38:
        .byte $02, $02, $02, $02, $C2, $02
; The stone man.
stone_man_pal_39:
        .byte $02, $02, $02, $02, $42, $82
; The stone man.
stone_man_pal_3A:
        .byte $C2, $02, $02, $02, $02, $02, $02
; The stone man.
stone_man_pal_3B:
        .byte $42, $82, $02, $02, $02, $02, $02
; The stone man.
stone_man_pal_3C:
        .byte $02, $02, $02, $02, $02
; The stone man.
stone_man_pal_3D:
        .byte $02, $02, $02, $02, $02
; The stone man's ring.
stone_man_ring_pal_3E:
        .byte $C2, $02
; The stone man's ring.
stone_man_ring_pal_3F:
        .byte $42, $82
; When an enemy dies.
death_pal_40:
        .byte $C1, $01
; When an enemy dies.
death_pal_41:
        .byte $41, $01, $C1, $81
; The Barbarian.
barbarian_pal_45:
        .byte $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $03, $03
; The Barbarian.
barbarian_pal_46:
        .byte $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $03
; The Barbarian.
barbarian_pal_47:
        .byte $03, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
; The Barbarian.
barbarian_pal_48:
        .byte $02, $02, $02, $02, $02, $02, $02, $02, $03, $03, $02, $02, $02
; The Barbarian.
barbarian_pal_49:
        .byte $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $83
; Bomberhead.
bomberhead_pal_4A:
        .byte $02, $02, $02, $02, $02, $02, $02, $02
; Bomberhead.
bomberhead_pal_4B:
        .byte $02, $02, $02, $02, $02, $02, $02, $02
; Bomberhead.
bomberhead_pal_4C:
        .byte $02, $02, $02, $02, $02, $02, $02, $02, $02
; Bomberhead.
bomberhead_pal_4D:
        .byte $02, $02, $02, $02, $02, $02, $02, $02
; Bomberhead.
bomberhead_pal_4E:
        .byte $03, $03
; Bomberhead.
bomberhead_pal_4F:
        .byte $03, $03, $03, $03
; Bomberhead.
bomberhead_pal_50:
        .byte $43, $43
; Bomberhead.
bomberhead_pal_51:
        .byte $C3, $C3
; Basaquer.
basaquer_pal_52:
        .byte $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
; Basaquer.
basaquer_pal_53:
        .byte $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
; Basaquer.
basaquer_pal_54:
        .byte $03
; Kelbeross.
kelbeross_pal_55:
        .byte $02, $02, $02, $02, $02, $02, $02, $02
enemy_pal_56:
        .byte $02, $02, $02, $02, $02, $02, $02, $02
; Kelbeross.
kelbeross_pal_57:
        .byte $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
enemy_pal_58:
        .byte $03
; Kelbeross.
kelbeross_pal_59:
        .byte $43, $43
; Kelbeross.
kelbeross_pal_5A:
        .byte $C3, $C3
; Bloody Malth.
bloody_malth_pal_5B:
        .byte $02, $02, $02, $02, $02, $03, $03, $03, $03, $02, $02
; Bloody Malth.
bloody_malth_pal_5C:
        .byte $02, $02, $02, $02, $02, $03, $03, $03, $03, $02, $02
; Bloody Malth.
bloody_malth_pal_5D:
        .byte $02, $02, $02, $02, $02, $03, $03, $03, $03, $02, $02
enemy_pal_5E:
        .byte $02, $02, $02, $02, $02, $03, $03, $03, $03, $02, $02
; Bloody Malth.
bloody_malth_pal_5F:
        .byte $02, $02, $02, $02, $02, $03, $03, $02, $03, $03
; Bloody Malth.
bloody_malth_pal_60:
        .byte $01, $01, $01, $01, $01, $01, $01, $01, $01
; Bloody Malth.
bloody_malth_pal_61:
        .byte $01, $C1, $C1, $81, $81, $81, $81
; Bloody Malth's lightning.
bloody_malth_lightning_pal_62:
        .byte $81, $C1
; Bloody Malth.
bloody_malth_pal_63:
        .byte $41, $81
; Bloody Malth's lightning.
bloody_malth_lightning_pal_64:
        .byte $01, $01
; Bloody Malth's lightning.
bloody_malth_lightning_pal_65:
        .byte $81, $81, $01, $01, $41, $41, $C1, $C1
; Bloody Malth's lightning.
bloody_malth_lightning_pal_66:
        .byte $01, $01
; Bloody Malth's lightning.
bloody_malth_lightning_pal_67:
        .byte $C1, $C1, $41, $41, $81, $81, $01, $01
; Bloody Malth and his lightning.
bloody_malth_pal_68:
        .byte $00
; Bloody Malth's lightning.
bloody_malth_lightning_pal_69:
        .byte $C1, $C1
; The Masked Devil.
masked_devil_pal_6A:
        .byte $03, $02, $02, $43, $03, $02, $02, $43, $03, $02, $02, $03, $03, $03, $02, $02
; The Masked Devil.
masked_devil_pal_6B:
        .byte $03, $02, $02, $43, $03, $02, $02, $43, $03, $02, $02, $03, $03, $03, $02, $02
; Bomberhead.
bomberhead_pal_6C:
        .byte $C3, $C3, $C3, $C3
enemy_pal_6D:
        .byte $02, $02, $02, $02, $02, $02, $02, $03, $03, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
enemy_pal_6E:
        .byte $03, $02, $02, $02, $02, $02, $02, $03, $02, $02, $03, $03, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
enemy_pal_6F:
        .byte $03, $02, $02, $02, $02, $02, $02, $03, $02, $02, $03, $03, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
; Jaquio.
jaquio_pal_70:
        .byte $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $03, $03, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
enemy_pal_71:
        .byte $01, $01
enemy_pal_72:
        .byte $01, $01
; Jaquio.
jaquio_pal_73:
        .byte $41, $41
; Jaquio.
jaquio_pal_74:
        .byte $41, $41
enemy_pal_75:
        .byte $03, $C3
enemy_pal_76:
        .byte $83, $43
; The Masked Devil.
masked_devil_pal_77:
        .byte $01
; An explosion around a boss.
explosion_pal_78:
        .byte $01, $C1
; An explosion around a boss.
explosion_pal_79:
        .byte $01, $01, $C1, $C1, $01, $01, $C1, $C1
; An explosion around a boss.
explosion_pal_7A:
        .byte $81, $41
; An explosion around a boss.
explosion_pal_7B:
        .byte $81, $81, $41, $41, $81, $81, $41, $41
; The last boss and his head.
final_boss_pal_7C:
        .byte $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
; The last boss and his head.
final_boss_pal_7D:
        .byte $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
; The last boss's fireballs.
final_boss_fireballs_pal_7E:
        .byte $03, $03
; The last boss's fireballs.
final_boss_fireballs_pal_7F:
        .byte $C3, $C3
; The last boss.
final_boss_pal_80:
        .byte $02, $02, $02, $02
; The last boss.
final_boss_pal_81:
        .byte $02, $02, $02
; The last boss.
final_boss_pal_82:
        .byte $02, $02, $02, $02
; The last boss.
final_boss_pal_83:
        .byte $02, $02, $02
; Bomberhead.
bomberhead_pal_84:
        .byte $83, $83
; The Masked Devil.
masked_devil_fight_pal_85:
        .byte $01, $01
        .byte $03, $03        ; another set of colors
lantern_at_00:
        .byte $18, $1C, $29, $2F, $35, $41, $44, $47, $5C, $5F, $64, $6A, $6D, $7B, $7E, $8D
        .byte $8D, $A1
lantern_in_00:
        .byte $B0, $B0                      ; 5 ninpo
        .byte $91                           ; 10 ninpo
        .byte $58                           ; the Throwing Star
        .byte $95                           ; 5 points
        .byte $70, $70                      ; 5 ninpo
        .byte $B6                           ; 10 points
        .byte $B5                           ; 5 points
        .byte $5A                           ; Art of the Fire Wheel
        .byte $5B                           ; Jump & Slash
        .byte $A0                           ; 5 ninpo
        .byte $87                           ; the Invincible Fire-Wheel
        .byte $54                           ; the Hourglass
        .byte $A5                           ; 5 points
        .byte $89                           ; the Windmill Throwing Star
        .byte $B0, $A0                      ; 5 ninpo
lantern_at_01:
        .byte $FF
lantern_in_01:
        .byte $00
lantern_at_02:
        .byte $15, $1B, $20, $25, $2A, $31, $33, $38, $43, $49, $49, $52, $54
lantern_in_02:
        .byte $71                           ; 10 ninpo
        .byte $A0, $70                      ; 5 ninpo
        .byte $78                           ; the Throwing Star
        .byte $96                           ; 10 points
        .byte $9A                           ; Art of the Fire Wheel
        .byte $96                           ; 10 points
        .byte $91                           ; 10 ninpo
        .byte $60                           ; 5 ninpo
        .byte $69                           ; the Windmill Throwing Star
        .byte $A6                           ; 10 points
        .byte $A5                           ; 5 points
        .byte $71                           ; 10 ninpo
lantern_at_03:
        .byte $11, $22, $25, $2A, $2F, $38, $42
lantern_in_03:
        .byte $71                           ; 10 ninpo
        .byte $65                           ; 5 points
        .byte $6B                           ; Jump & Slash
        .byte $86                           ; 10 points
        .byte $80                           ; 5 ninpo
        .byte $88                           ; the Throwing Star
        .byte $65                           ; 5 points
lantern_at_04:
        .byte $03
lantern_in_04:
        .byte $A3                           ; health
lantern_at_05:
        .byte $0B, $1A, $1F, $2B
lantern_in_05:
        .byte $70                           ; 5 ninpo
        .byte $69                           ; the Windmill Throwing Star
        .byte $A5                           ; 5 points
        .byte $96                           ; 10 points
lantern_at_06:
        .byte $06, $10, $1A, $26, $2A
lantern_in_06:
        .byte $71                           ; 10 ninpo
        .byte $A8                           ; the Throwing Star
        .byte $65                           ; 5 points
        .byte $81                           ; 10 ninpo
        .byte $80                           ; 5 ninpo
lantern_at_07:
        .byte $06, $11, $1B, $25, $29
lantern_in_07:
        .byte $85                           ; 5 points
        .byte $81                           ; 10 ninpo
        .byte $80                           ; 5 ninpo
        .byte $67                           ; the Invincible Fire-Wheel
        .byte $83                           ; health
lantern_at_08:
        .byte $1B, $27, $32, $3B, $44, $52, $58, $61, $65
lantern_in_08:
        .byte $66                           ; 10 points
        .byte $85                           ; 5 points
        .byte $70                           ; 5 ninpo
        .byte $8A                           ; Art of the Fire Wheel
        .byte $A1                           ; 10 ninpo
        .byte $6B                           ; Jump & Slash
        .byte $65                           ; 5 points
        .byte $80, $80                      ; 5 ninpo
lantern_at_09:
        .byte $FF
lantern_in_09:
        .byte $00
lantern_at_0A:
        .byte $15, $1B, $24, $28, $30, $38, $48, $4A, $53, $68, $74
lantern_in_0A:
        .byte $A0, $A0                      ; 5 ninpo
        .byte $A1                           ; 10 ninpo
        .byte $94                           ; the Hourglass
        .byte $88                           ; the Throwing Star
        .byte $66                           ; 10 points
        .byte $A1                           ; 10 ninpo
        .byte $6A                           ; Art of the Fire Wheel
        .byte $61                           ; 10 ninpo
        .byte $A3                           ; health
        .byte $A5                           ; 5 points
lantern_at_0B:
        .byte $16, $1C, $2C, $3F, $48, $57, $5E, $69, $72, $82, $89, $94, $9C, $A4, $B1
lantern_in_0B:
        .byte $80                           ; 5 ninpo
        .byte $61                           ; 10 ninpo
        .byte $55                           ; 5 points
        .byte $69                           ; the Windmill Throwing Star
        .byte $A1                           ; 10 ninpo
        .byte $66                           ; 10 points
        .byte $60                           ; 5 ninpo
        .byte $9A                           ; Art of the Fire Wheel
        .byte $A5                           ; 5 points
        .byte $76                           ; 10 points
        .byte $60                           ; 5 ninpo
        .byte $81                           ; 10 ninpo
        .byte $85                           ; 5 points
        .byte $79                           ; the Windmill Throwing Star
        .byte $61                           ; 10 ninpo
lantern_at_0C:
        .byte $FF
lantern_in_0C:
        .byte $00
lantern_at_0D:
        .byte $11, $1D, $26, $2D, $38, $3B, $3F, $49, $55, $69, $72, $82
lantern_in_0D:
        .byte $91                           ; 10 ninpo
        .byte $90                           ; 5 ninpo
        .byte $96                           ; 10 points
        .byte $95                           ; 5 points
        .byte $5B                           ; Jump & Slash
        .byte $89                           ; the Windmill Throwing Star
        .byte $A2                           ; a 1-UP
        .byte $61                           ; 10 ninpo
        .byte $57                           ; the Invincible Fire-Wheel
        .byte $50                           ; 5 ninpo
        .byte $65                           ; 5 points
        .byte $66                           ; 10 points
lantern_at_0E:
        .byte $FF
lantern_in_0E:
        .byte $00
lantern_at_0F:
        .byte $FF
lantern_in_0F:
        .byte $00
lantern_at_10:
        .byte $13, $1B, $2B, $2C, $30, $31, $3B, $3E, $42, $48, $4E, $4E, $57, $8B, $92, $93
        .byte $A0, $A4, $AC, $AE, $BA
lantern_in_10:
        .byte $70                           ; 5 ninpo
        .byte $71                           ; 10 ninpo
        .byte $69                           ; the Windmill Throwing Star
        .byte $A0                           ; 5 ninpo
        .byte $61                           ; 10 ninpo
        .byte $A0                           ; 5 ninpo
        .byte $AA                           ; Art of the Fire Wheel
        .byte $66                           ; 10 points
        .byte $65                           ; 5 points
        .byte $A0                           ; 5 ninpo
        .byte $61                           ; 10 ninpo
        .byte $A8                           ; the Throwing Star
        .byte $A4                           ; the Hourglass
        .byte $69                           ; the Windmill Throwing Star
        .byte $66                           ; 10 points
        .byte $A3                           ; health
        .byte $62                           ; a 1-UP
        .byte $8B                           ; Jump & Slash
        .byte $A5                           ; 5 points
        .byte $51                           ; 10 ninpo
        .byte $89                           ; the Windmill Throwing Star
lantern_at_11:
        .byte $FF
lantern_in_11:
        .byte $00
lantern_at_12:
        .byte $11, $11, $1D, $25, $2B, $2F, $35
lantern_in_12:
        .byte $7A                           ; Art of the Fire Wheel
        .byte $B0                           ; 5 ninpo
        .byte $B5                           ; 5 points
        .byte $71                           ; 10 ninpo
        .byte $60                           ; 5 ninpo
        .byte $A9                           ; the Windmill Throwing Star
        .byte $66                           ; 10 points
lantern_at_13:
        .byte $13, $1B, $1E, $2D, $33, $38, $47
lantern_in_13:
        .byte $99                           ; the Windmill Throwing Star
        .byte $96                           ; 10 points
        .byte $90                           ; 5 ninpo
        .byte $83                           ; health
        .byte $6A                           ; Art of the Fire Wheel
        .byte $65                           ; 5 points
        .byte $86                           ; 10 points
lantern_at_14:
        .byte $13, $13, $1D, $29
lantern_in_14:
        .byte $69                           ; the Windmill Throwing Star
        .byte $95                           ; 5 points
        .byte $61                           ; 10 ninpo
        .byte $60                           ; 5 ninpo
lantern_at_15:
        .byte $FF
lantern_in_15:
        .byte $00
lantern_at_16:
        .byte $13, $17, $17, $21, $25, $29, $2E, $36, $3B, $41, $49, $56, $67, $88, $A1, $AC
        .byte $BA
lantern_in_16:
        .byte $A0                           ; 5 ninpo
        .byte $68                           ; the Throwing Star
        .byte $A0                           ; 5 ninpo
        .byte $65                           ; 5 points
        .byte $61                           ; 10 ninpo
        .byte $A6                           ; 10 points
        .byte $A9                           ; the Windmill Throwing Star
        .byte $80, $80                      ; 5 ninpo
        .byte $65                           ; 5 points
        .byte $86                           ; 10 points
        .byte $7A                           ; Art of the Fire Wheel
        .byte $81                           ; 10 ninpo
        .byte $69                           ; the Windmill Throwing Star
        .byte $53                           ; health
        .byte $A6                           ; 10 points
        .byte $A1                           ; 10 ninpo
lantern_at_17:
        .byte $09, $13, $16, $1E
lantern_in_17:
        .byte $7B                           ; Jump & Slash
        .byte $65                           ; 5 points
        .byte $61                           ; 10 ninpo
        .byte $90                           ; 5 ninpo
lantern_at_18:
        .byte $14, $14, $18, $20, $23
lantern_in_18:
        .byte $60                           ; 5 ninpo
        .byte $AA                           ; Art of the Fire Wheel
        .byte $66                           ; 10 points
        .byte $88                           ; the Throwing Star
        .byte $85                           ; 5 points
lantern_at_19:
        .byte $06, $0E, $12, $1A, $1C, $1E
lantern_in_19:
        .byte $90                           ; 5 ninpo
        .byte $89                           ; the Windmill Throwing Star
        .byte $86                           ; 10 points
        .byte $A5                           ; 5 points
        .byte $67                           ; the Invincible Fire-Wheel
        .byte $A0                           ; 5 ninpo
lantern_at_1A:
        .byte $10, $14, $1C, $23
lantern_in_1A:
        .byte $53                           ; health
        .byte $65                           ; 5 points
        .byte $B6                           ; 10 points
        .byte $61                           ; 10 ninpo
lantern_at_1B:
        .byte $0C, $0F, $14, $19
lantern_in_1B:
        .byte $7A                           ; Art of the Fire Wheel
        .byte $A0                           ; 5 ninpo
        .byte $51                           ; 10 ninpo
        .byte $A0                           ; 5 ninpo
lantern_at_1C:
        .byte $12, $1C, $1F, $21
lantern_in_1C:
        .byte $60                           ; 5 ninpo
        .byte $56                           ; 10 points
        .byte $91                           ; 10 ninpo
        .byte $55                           ; 5 points
lantern_at_1D:
        .byte $09, $11, $13, $1B, $1F, $1F
lantern_in_1D:
        .byte $57                           ; the Invincible Fire-Wheel
        .byte $51                           ; 10 ninpo
        .byte $55                           ; 5 points
        .byte $56                           ; 10 points
        .byte $52                           ; a 1-UP
        .byte $A8                           ; the Throwing Star
lantern_at_1E:
        .byte $15, $1D, $27
lantern_in_1E:
        .byte $70                           ; 5 ninpo
        .byte $69                           ; the Windmill Throwing Star
        .byte $88                           ; the Throwing Star
lantern_at_1F:
        .byte $04, $0B, $0F
lantern_in_1F:
        .byte $90                           ; 5 ninpo
        .byte $56                           ; 10 points
        .byte $5A                           ; Art of the Fire Wheel
lantern_at_20:
        .byte $10, $17, $1A
lantern_in_20:
        .byte $AA                           ; Art of the Fire Wheel
        .byte $A9                           ; the Windmill Throwing Star
        .byte $70                           ; 5 ninpo
lantern_at_21:
        .byte $FF
lantern_in_21:
        .byte $00
lantern_at_22:
        .byte $FF
lantern_in_22:
        .byte $00
lantern_at_23:
        .byte $07, $0F, $17, $21, $29, $32, $3C, $40, $4C, $5B
lantern_in_23:
        .byte $61                           ; 10 ninpo
        .byte $60                           ; 5 ninpo
        .byte $65                           ; 5 points
        .byte $8B                           ; Jump & Slash
        .byte $80                           ; 5 ninpo
        .byte $89                           ; the Windmill Throwing Star
        .byte $A5                           ; 5 points
        .byte $A1                           ; 10 ninpo
        .byte $A0                           ; 5 ninpo
        .byte $A8                           ; the Throwing Star
lantern_at_24:
        .byte $04, $10, $1B, $22, $28, $32, $3C, $42, $43, $4D
lantern_in_24:
        .byte $70                           ; 5 ninpo
        .byte $89                           ; the Windmill Throwing Star
        .byte $5B                           ; Jump & Slash
        .byte $60                           ; 5 ninpo
        .byte $65                           ; 5 points
        .byte $B1                           ; 10 ninpo
        .byte $A6                           ; 10 points
        .byte $A0                           ; 5 ninpo
        .byte $79                           ; the Windmill Throwing Star
        .byte $A0                           ; 5 ninpo
lantern_at_25:
        .byte $0B, $14, $1B, $1E, $22, $26, $2D
lantern_in_25:
        .byte $68                           ; the Throwing Star
        .byte $A0                           ; 5 ninpo
        .byte $69                           ; the Windmill Throwing Star
        .byte $95                           ; 5 points
        .byte $8A                           ; Art of the Fire Wheel
        .byte $66                           ; 10 points
        .byte $61                           ; 10 ninpo
lantern_at_26:
        .byte $03
lantern_in_26:
        .byte $79                           ; the Windmill Throwing Star
lantern_at_27:
        .byte $11, $14, $1B, $22, $26
lantern_in_27:
        .byte $60, $60                      ; 5 ninpo
        .byte $65                           ; 5 points
        .byte $61                           ; 10 ninpo
        .byte $86                           ; 10 points
lantern_at_28:
        .byte $13, $18, $20, $23, $29
lantern_in_28:
        .byte $90                           ; 5 ninpo
        .byte $53                           ; health
        .byte $A1                           ; 10 ninpo
        .byte $A7                           ; the Invincible Fire-Wheel
        .byte $65                           ; 5 points
lantern_at_29:
        .byte $14, $14, $1F, $22, $25, $2B
lantern_in_29:
        .byte $6A                           ; Art of the Fire Wheel
        .byte $90                           ; 5 ninpo
        .byte $65                           ; 5 points
        .byte $61                           ; 10 ninpo
        .byte $66                           ; 10 points
        .byte $AB                           ; Jump & Slash
lantern_at_2A:
        .byte $FF
lantern_in_2A:
        .byte $00
lantern_at_2B:
        .byte $04, $0D, $10, $16, $20, $2C, $34, $41, $45, $4D, $52, $57, $59, $60, $68, $6A
        .byte $6E
lantern_in_2B:
        .byte $60, $90                      ; 5 ninpo
        .byte $51                           ; 10 ninpo
        .byte $A5                           ; 5 points
        .byte $5A                           ; Art of the Fire Wheel
        .byte $50                           ; 5 ninpo
        .byte $B4                           ; the Hourglass
        .byte $55                           ; 5 points
        .byte $59                           ; the Windmill Throwing Star
        .byte $66                           ; 10 points
        .byte $61                           ; 10 ninpo
        .byte $80, $80                      ; 5 ninpo
        .byte $9A                           ; Art of the Fire Wheel
        .byte $65, $65                      ; 5 points
        .byte $88                           ; the Throwing Star
lantern_at_2C:
        .byte $12, $19, $21, $24, $27, $2C, $33, $37, $3B
lantern_in_2C:
        .byte $53                           ; health
        .byte $A4                           ; the Hourglass
        .byte $B1                           ; 10 ninpo
        .byte $50, $50                      ; 5 ninpo
        .byte $8A                           ; Art of the Fire Wheel
        .byte $A8                           ; the Throwing Star
        .byte $A9                           ; the Windmill Throwing Star
        .byte $AA                           ; Art of the Fire Wheel
lantern_at_2D:
        .byte $FF
lantern_in_2D:
        .byte $00
lantern_at_2E:
        .byte $FF
lantern_in_2E:
        .byte $00
lantern_at_2F:
        .byte $FF
lantern_in_2F:
        .byte $00
appear_col_00:
        .byte $02, $04, $06, $13, $17, $19, $20, $21, $25, $2F, $36, $44, $48, $50, $5C, $68
        .byte $6C, $74, $7C, $86, $8B, $94, $96, $A5, $A3, $A7, $AB
stand_at_00:
        .byte $DF, $DF, $DF, $DF, $D1, $DF, $CF, $6F, $6F, $DF, $9F, $DF, $D1, $9F, $DF, $CF
        .byte $CF, $DF, $5F, $CF, $CF, $DF, $C1, $D1, $DF, $DF, $DF
foe_kind_00:
        .byte $03, $03, $03, $03            ; the batter
        .byte $09                           ; the attacking dog
        .byte $04                           ; the knife thrower
        .byte $09                           ; the attacking dog
        .byte $03, $03                      ; the batter
        .byte $04                           ; the knife thrower
        .byte $00                           ; the boxer
        .byte $03                           ; the batter
        .byte $09                           ; the attacking dog
        .byte $03                           ; the batter
        .byte $09                           ; the attacking dog
        .byte $00, $00, $00                 ; the boxer
        .byte $03, $03, $03                 ; the batter
        .byte $04, $04                      ; the knife thrower
        .byte $09                           ; the attacking dog
        .byte $00, $00, $00                 ; the boxer
appear_col_01:
        .byte $00
stand_at_01:
        .byte $DD
foe_kind_01:
        .byte $17                           ; the Barbarian
appear_col_02:
        .byte $08, $13, $15, $1D, $26, $28, $33, $34, $40, $4D, $51
stand_at_02:
        .byte $AF, $AF, $A1, $DF, $C1, $BF, $71, $8F, $DF, $61, $9F
foe_kind_02:
        .byte $03                           ; the batter
        .byte $04                           ; the knife thrower
        .byte $09                           ; the attacking dog
        .byte $00                           ; the boxer
        .byte $03                           ; the batter
        .byte $08, $08                      ; the bat
        .byte $00                           ; the boxer
        .byte $04                           ; the knife thrower
        .byte $09                           ; the attacking dog
        .byte $08                           ; the bat
appear_col_03:
        .byte $03, $06, $1C, $1E, $2E, $32, $37, $3A
stand_at_03:
        .byte $AF, $A1, $61, $AF, $AF, $8F, $8F, $61
foe_kind_03:
        .byte $03                           ; the batter
        .byte $08                           ; the bat
        .byte $09                           ; the attacking dog
        .byte $00                           ; the boxer
        .byte $04, $04                      ; the knife thrower
        .byte $00                           ; the boxer
        .byte $08                           ; the bat
appear_col_04:
        .byte $FF
stand_at_04:
        .byte $85
foe_kind_04:
        .byte $02                           ; the thrower
appear_col_05:
        .byte $2D, $2C, $28, $24, $0A, $09
stand_at_05:
        .byte $AE, $C1, $A1, $A1, $A1, $A1
foe_kind_05:
        .byte $09                           ; the attacking dog
        .byte $04                           ; the knife thrower
        .byte $03                           ; the batter
        .byte $04                           ; the knife thrower
        .byte $03                           ; the batter
        .byte $09                           ; the attacking dog
appear_col_06:
        .byte $2B, $21, $1E, $18, $17, $0D, $0C
stand_at_06:
        .byte $A1, $AE, $81, $81, $AE, $8E, $C1
foe_kind_06:
        .byte $02                           ; the thrower
        .byte $07                           ; the running soldier
        .byte $01                           ; the machine gunner
        .byte $03                           ; the batter
        .byte $07, $07                      ; the running soldier
        .byte $01                           ; the machine gunner
appear_col_07:
        .byte $2A, $20, $13, $0C, $04
stand_at_07:
        .byte $91, $81, $C1, $81, $A1
foe_kind_07:
        .byte $08                           ; the bat
        .byte $07                           ; the running soldier
        .byte $01                           ; the machine gunner
        .byte $07                           ; the running soldier
        .byte $03                           ; the batter
appear_col_08:
        .byte $6E, $62, $5A, $58, $51, $4C, $4A, $42, $36, $34, $24, $1C, $0F, $0D, $0A, $07
stand_at_08:
        .byte $51, $A1, $CF, $81, $AF, $8F, $A1, $C1, $A1, $CF, $A1, $81, $8F, $C1, $C1, $C1
foe_kind_08:
        .byte $08                           ; the bat
        .byte $03                           ; the batter
        .byte $07                           ; the running soldier
        .byte $02                           ; the thrower
        .byte $07, $07                      ; the running soldier
        .byte $03, $03                      ; the batter
        .byte $01                           ; the machine gunner
        .byte $07                           ; the running soldier
        .byte $02, $02                      ; the thrower
        .byte $07                           ; the running soldier
        .byte $03, $03, $03                 ; the batter
appear_col_09:
        .byte $00
stand_at_09:
        .byte $CD
foe_kind_09:
        .byte $18                           ; Bomberhead
appear_col_0A:
        .byte $01, $04, $07, $0D, $0E, $14, $1E, $24, $26, $2A, $3A, $3D, $41, $41, $42, $47
        .byte $4C, $4E, $5D, $61, $66, $67, $6C
stand_at_0A:
        .byte $CF, $CF, $CF, $CF, $C1, $6F, $6F, $AF, $A1, $8F, $81, $8F, $CF, $71, $8F, $CF
        .byte $8F, $6F, $6F, $71, $6F, $CF, $CF
foe_kind_0A:
        .byte $03, $03, $03, $03            ; the batter
        .byte $09                           ; the attacking dog
        .byte $0B, $0B                      ; the bird
        .byte $02                           ; the thrower
        .byte $08                           ; the bat
        .byte $09, $09                      ; the attacking dog
        .byte $02                           ; the thrower
        .byte $09                           ; the attacking dog
        .byte $0B                           ; the bird
        .byte $03                           ; the batter
        .byte $01                           ; the machine gunner
        .byte $03, $03                      ; the batter
        .byte $0B, $0B, $0B                 ; the bird
        .byte $03, $03                      ; the batter
appear_col_0B:
        .byte $04, $0A, $12, $1A, $28, $2A, $34, $3A, $3A, $3E, $4A, $4E, $54, $59, $59, $64
        .byte $68, $74, $80, $87, $8C, $98, $99, $AA, $AB, $AC
stand_at_0B:
        .byte $AF, $AF, $8F, $6F, $AF, $4F, $CF, $6F, $CF, $CF, $5F, $AF, $8F, $41, $6F, $61
        .byte $6F, $AF, $CF, $5F, $CF, $5F, $AF, $81, $CF, $5F
foe_kind_0B:
        .byte $03, $03                      ; the batter
        .byte $05, $05                      ; the crouching soldier
        .byte $03                           ; the batter
        .byte $0B                           ; the bird
        .byte $02, $02                      ; the thrower
        .byte $03, $03                      ; the batter
        .byte $0B                           ; the bird
        .byte $05                           ; the crouching soldier
        .byte $07                           ; the running soldier
        .byte $0B                           ; the bird
        .byte $07, $07                      ; the running soldier
        .byte $03                           ; the batter
        .byte $05, $05                      ; the crouching soldier
        .byte $0B                           ; the bird
        .byte $05                           ; the crouching soldier
        .byte $0B                           ; the bird
        .byte $05                           ; the crouching soldier
        .byte $09                           ; the attacking dog
        .byte $03                           ; the batter
        .byte $0B                           ; the bird
appear_col_0C:
        .byte $00
stand_at_0C:
        .byte $5D
foe_kind_0C:
        .byte $19                           ; Basaquer
appear_col_0D:
        .byte $08, $14, $16, $1A, $24, $32, $34, $36, $42, $44, $50, $56, $59, $5E, $66, $6A
        .byte $7A
stand_at_0D:
        .byte $BF, $BF, $5F, $51, $8F, $DF, $6F, $61, $8F, $AF, $81, $61, $AF, $BF, $6F, $8F
        .byte $7F
foe_kind_0D:
        .byte $01                           ; the machine gunner
        .byte $09                           ; the attacking dog
        .byte $0B, $0B                      ; the bird
        .byte $02                           ; the thrower
        .byte $01                           ; the machine gunner
        .byte $09, $09                      ; the attacking dog
        .byte $08                           ; the bat
        .byte $05                           ; the crouching soldier
        .byte $08                           ; the bat
        .byte $09                           ; the attacking dog
        .byte $08, $08                      ; the bat
        .byte $07                           ; the running soldier
        .byte $01                           ; the machine gunner
        .byte $08                           ; the bat
appear_col_0E:
        .byte $FF, $FF, $FF
stand_at_0E:
        .byte $88, $88, $88
foe_kind_0E:
        .byte $00, $00, $00                 ; the boxer
appear_col_0F:
        .byte $00, $05, $08, $16, $18
stand_at_0F:
        .byte $51, $AF, $8F, $81, $8F
foe_kind_0F:
        .byte $0B                           ; the bird
        .byte $03                           ; the batter
        .byte $05                           ; the crouching soldier
        .byte $09, $09                      ; the attacking dog
appear_col_10:
        .byte $02, $06, $08, $0C, $19, $1A, $28, $2D, $32, $3A, $3C, $45, $58, $5C, $5C, $61
        .byte $66, $6E, $70, $74, $77, $81, $85, $8F, $8F, $93, $9D, $A9
stand_at_10:
        .byte $CF, $4E, $CF, $9F, $AF, $8F, $44, $AF, $61, $81, $8F, $8F, $43, $4F, $DF, $4F
        .byte $41, $4C, $7F, $EB, $CF, $7F, $7F, $42, $4C, $5F, $4F, $48
foe_kind_10:
        .byte $03                           ; the batter
        .byte $0D                           ; the running ninja
        .byte $03                           ; the batter
        .byte $08, $08                      ; the bat
        .byte $02                           ; the thrower
        .byte $0D                           ; the running ninja
        .byte $08, $08                      ; the bat
        .byte $03                           ; the batter
        .byte $02, $02                      ; the thrower
        .byte $0D                           ; the running ninja
        .byte $0B, $0B                      ; the bird
        .byte $0D                           ; the running ninja
        .byte $0B                           ; the bird
        .byte $0D                           ; the running ninja
        .byte $0B, $0B, $0B                 ; the bird
        .byte $08, $08                      ; the bat
        .byte $0D, $0D                      ; the running ninja
        .byte $0B                           ; the bird
        .byte $0D, $0D                      ; the running ninja
appear_col_11:
        .byte $FF
stand_at_11:
        .byte $88
foe_kind_11:
        .byte $00                           ; the boxer
appear_col_12:
        .byte $02, $03, $06, $0C, $16, $17, $1B, $24, $2C
stand_at_12:
        .byte $C1, $DF, $DF, $6F, $AF, $DF, $8F, $D1, $44
foe_kind_12:
        .byte $08                           ; the bat
        .byte $00, $00                      ; the boxer
        .byte $04                           ; the knife thrower
        .byte $03                           ; the batter
        .byte $04                           ; the knife thrower
        .byte $02                           ; the thrower
        .byte $09                           ; the attacking dog
        .byte $02                           ; the thrower
appear_col_13:
        .byte $08, $12, $14, $18, $1A, $1E, $26, $2B, $31, $3A
stand_at_13:
        .byte $AF, $DF, $DF, $6F, $6F, $6F, $71, $8F, $6F, $DF
foe_kind_13:
        .byte $01                           ; the machine gunner
        .byte $06, $06                      ; the jump kicker
        .byte $05                           ; the crouching soldier
        .byte $06                           ; the jump kicker
        .byte $05                           ; the crouching soldier
        .byte $08                           ; the bat
        .byte $01                           ; the machine gunner
        .byte $05                           ; the crouching soldier
        .byte $02                           ; the thrower
appear_col_14:
        .byte $06, $0A, $10, $15, $1F
stand_at_14:
        .byte $DF, $DF, $7F, $6F, $81
foe_kind_14:
        .byte $06, $06                      ; the jump kicker
        .byte $02                           ; the thrower
        .byte $05                           ; the crouching soldier
        .byte $08                           ; the bat
appear_col_15:
        .byte $00
stand_at_15:
        .byte $DD
foe_kind_15:
        .byte $1B                           ; Kelbeross
appear_col_16:
        .byte $02, $05, $09, $0B, $0C, $18, $20, $29, $2C, $2D, $33, $3D, $41, $49, $4D, $60
        .byte $61, $64, $69, $72, $78, $7D, $7E, $8F, $98, $A3, $A4, $A8, $AD
stand_at_16:
        .byte $CF, $DF, $DF, $8F, $C1, $4C, $DF, $AF, $AF, $43, $4D, $BF, $A1, $4E, $DF, $8F
        .byte $44, $7F, $6F, $DB, $DF, $8F, $DF, $7F, $8F, $D1, $6F, $61, $DF
foe_kind_16:
        .byte $08                           ; the bat
        .byte $03, $03                      ; the batter
        .byte $02                           ; the thrower
        .byte $08                           ; the bat
        .byte $0D                           ; the running ninja
        .byte $0F                           ; the crouched ghoul
        .byte $03, $03                      ; the batter
        .byte $0B                           ; the bird
        .byte $0D                           ; the running ninja
        .byte $02                           ; the thrower
        .byte $08                           ; the bat
        .byte $0D                           ; the running ninja
        .byte $0E                           ; the stone man
        .byte $03                           ; the batter
        .byte $0D                           ; the running ninja
        .byte $08, $08                      ; the bat
        .byte $0B                           ; the bird
        .byte $03                           ; the batter
        .byte $02                           ; the thrower
        .byte $0F                           ; the crouched ghoul
        .byte $08                           ; the bat
        .byte $03                           ; the batter
        .byte $02                           ; the thrower
        .byte $03                           ; the batter
        .byte $08                           ; the bat
        .byte $0E                           ; the stone man
appear_col_17:
        .byte $1E, $1B, $14, $0C, $03
stand_at_17:
        .byte $C1, $C1, $81, $61, $C1
foe_kind_17:
        .byte $03, $03, $03, $03            ; the batter
        .byte $10                           ; the waiting ghoul
appear_col_18:
        .byte $02, $0A, $0B, $0E, $17, $1A
stand_at_18:
        .byte $4F, $4F, $CF, $44, $4E, $EA
foe_kind_18:
        .byte $0B                           ; the bird
        .byte $0D                           ; the running ninja
        .byte $03                           ; the batter
        .byte $0D, $0D                      ; the running ninja
        .byte $0B                           ; the bird
appear_col_19:
        .byte $1E, $1A, $18, $12, $11, $0F, $0D, $04
stand_at_19:
        .byte $C1, $C1, $CE, $A1, $61, $A1, $61, $71
foe_kind_19:
        .byte $06, $06, $06                 ; the jump kicker
        .byte $05, $05, $05, $05            ; the crouching soldier
        .byte $08                           ; the bat
appear_col_1A:
        .byte $01, $03, $06, $12, $1C
stand_at_1A:
        .byte $CF, $43, $8F, $BF, $6F
foe_kind_1A:
        .byte $06                           ; the jump kicker
        .byte $0B                           ; the bird
        .byte $02                           ; the thrower
        .byte $08                           ; the bat
        .byte $0B                           ; the bird
appear_col_1B:
        .byte $1E, $13, $10, $10, $0E, $07, $04, $02
stand_at_1B:
        .byte $71, $D1, $D1, $71, $DE, $D1, $D1, $7F
foe_kind_1B:
        .byte $00, $00, $00                 ; the boxer
        .byte $03                           ; the batter
        .byte $04                           ; the knife thrower
        .byte $03                           ; the batter
        .byte $09                           ; the attacking dog
        .byte $03                           ; the batter
appear_col_1C:
        .byte $01, $05, $09, $11, $17, $1B
stand_at_1C:
        .byte $9F, $6F, $8F, $6F, $7F, $BF
foe_kind_1C:
        .byte $02                           ; the thrower
        .byte $0C, $0C, $0C, $0C            ; the jetpack ninja
        .byte $02                           ; the thrower
appear_col_1D:
        .byte $1E, $16, $14, $19, $17, $15, $0C, $0A, $05, $06, $02, $00
stand_at_1D:
        .byte $D1, $D1, $C1, $7F, $7F, $7F, $C1, $C1, $6F, $D1, $6F, $9F
foe_kind_1D:
        .byte $03                           ; the batter
        .byte $01                           ; the machine gunner
        .byte $08                           ; the bat
        .byte $07, $07, $07                 ; the running soldier
        .byte $08                           ; the bat
        .byte $09                           ; the attacking dog
        .byte $07                           ; the running soldier
        .byte $03, $03                      ; the batter
        .byte $0B                           ; the bird
appear_col_1E:
        .byte $04, $07, $08, $0E, $0F, $10, $17, $18
stand_at_1E:
        .byte $5F, $AF, $8F, $AF, $8F, $6F, $9F, $BF
foe_kind_1E:
        .byte $0B                           ; the bird
        .byte $05                           ; the crouching soldier
        .byte $07                           ; the running soldier
        .byte $08                           ; the bat
        .byte $05                           ; the crouching soldier
        .byte $07                           ; the running soldier
        .byte $08                           ; the bat
        .byte $01                           ; the machine gunner
appear_col_1F:
        .byte $0E, $0C, $0A, $06, $04, $02, $00
stand_at_1F:
        .byte $D1, $9E, $81, $6F, $6F, $6F, $DE
foe_kind_1F:
        .byte $10                           ; the waiting ghoul
        .byte $0B                           ; the bird
        .byte $02                           ; the thrower
        .byte $03, $03, $03                 ; the batter
        .byte $0E                           ; the stone man
appear_col_20:
        .byte $01, $01, $04, $06, $08
stand_at_20:
        .byte $7F, $DF, $7F, $A1, $DF
foe_kind_20:
        .byte $03                           ; the batter
        .byte $0E                           ; the stone man
        .byte $03                           ; the batter
        .byte $10                           ; the waiting ghoul
        .byte $03                           ; the batter
appear_col_21:
        .byte $FF
stand_at_21:
        .byte $88
foe_kind_21:
        .byte $00                           ; the boxer
appear_col_22:
        .byte $00
stand_at_22:
        .byte $D3
foe_kind_22:
        .byte $1E                           ; Bloody Malth
appear_col_23:
        .byte $65, $63, $56, $54, $53, $50, $48, $46, $42, $36, $32, $2E, $2A, $19, $19, $12
        .byte $0D, $0A, $08, $07, $03
stand_at_23:
        .byte $D1, $BE, $B1, $8E, $B1, $91, $B1, $B1, $81, $B1, $B1, $B1, $41, $91, $BE, $91
        .byte $D1, $91, $41, $9E, $D1
foe_kind_23:
        .byte $01                           ; the machine gunner
        .byte $08                           ; the bat
        .byte $10                           ; the waiting ghoul
        .byte $0B                           ; the bird
        .byte $01                           ; the machine gunner
        .byte $08                           ; the bat
        .byte $06                           ; the jump kicker
        .byte $05                           ; the crouching soldier
        .byte $08                           ; the bat
        .byte $05, $05, $05                 ; the crouching soldier
        .byte $0B                           ; the bird
        .byte $02                           ; the thrower
        .byte $0F                           ; the crouched ghoul
        .byte $06                           ; the jump kicker
        .byte $0B                           ; the bird
        .byte $10                           ; the waiting ghoul
        .byte $0B                           ; the bird
        .byte $06                           ; the jump kicker
        .byte $0B                           ; the bird
appear_col_24:
        .byte $4E, $4A, $48, $46, $43, $3F, $3A, $38, $2F, $2C, $27, $21, $1C, $18, $16, $13
        .byte $0F, $0E, $06
stand_at_24:
        .byte $D1, $81, $D1, $DE, $D1, $D1, $D1, $A1, $81, $61, $81, $81, $51, $91, $61, $51
        .byte $91, $71, $A1, $A1
foe_kind_24:
        .byte $03                           ; the batter
        .byte $02                           ; the thrower
        .byte $04                           ; the knife thrower
        .byte $09                           ; the attacking dog
        .byte $04                           ; the knife thrower
        .byte $09                           ; the attacking dog
        .byte $04                           ; the knife thrower
        .byte $02                           ; the thrower
        .byte $08                           ; the bat
        .byte $0A                           ; the waiting dog
        .byte $03, $03                      ; the batter
        .byte $0C, $0C, $0C, $0C, $0C, $0C  ; the jetpack ninja
        .byte $03                           ; the batter
        .byte $00                           ; the boxer
appear_col_25:
        .byte $2B, $23, $21, $1C, $15, $12, $0B, $03
stand_at_25:
        .byte $81, $71, $E7, $D1, $D1, $D1, $81, $D1
foe_kind_25:
        .byte $01                           ; the machine gunner
        .byte $08                           ; the bat
        .byte $0B                           ; the bird
        .byte $10                           ; the waiting ghoul
        .byte $05, $05                      ; the crouching soldier
        .byte $02                           ; the thrower
        .byte $10                           ; the waiting ghoul
appear_col_26:
        .byte $FF
stand_at_26:
        .byte $88
foe_kind_26:
        .byte $00                           ; the boxer
appear_col_27:
        .byte $02, $08, $09, $0B, $0C, $13, $15, $1A
stand_at_27:
        .byte $8F, $7F, $81, $E9, $7F, $8F, $4C, $7F
foe_kind_27:
        .byte $03                           ; the batter
        .byte $08                           ; the bat
        .byte $07                           ; the running soldier
        .byte $0B                           ; the bird
        .byte $08                           ; the bat
        .byte $02                           ; the thrower
        .byte $0B                           ; the bird
        .byte $07                           ; the running soldier
appear_col_28:
        .byte $02, $0A, $0B, $0D, $10, $12, $12, $13, $14, $1B
stand_at_28:
        .byte $9F, $4D, $DF, $DF, $6F, $44, $6F, $DF, $6F, $D1
foe_kind_28:
        .byte $0B, $0B                      ; the bird
        .byte $0F                           ; the crouched ghoul
        .byte $03, $03                      ; the batter
        .byte $0D                           ; the running ninja
        .byte $03                           ; the batter
        .byte $02                           ; the thrower
        .byte $03                           ; the batter
        .byte $0F                           ; the crouched ghoul
appear_col_29:
        .byte $02, $06, $0B, $0F, $12, $14, $16, $1E
stand_at_29:
        .byte $BF, $DF, $B1, $8F, $DF, $8F, $BF, $DF
foe_kind_29:
        .byte $08                           ; the bat
        .byte $06                           ; the jump kicker
        .byte $08                           ; the bat
        .byte $02, $02                      ; the thrower
        .byte $05                           ; the crouching soldier
        .byte $08                           ; the bat
        .byte $01                           ; the machine gunner
appear_col_2A:
        .byte $FF
stand_at_2A:
        .byte $88
foe_kind_2A:
        .byte $00                           ; the boxer
appear_col_2B:
        .byte $6E, $69, $62, $5B, $59, $58, $50, $4C, $4B, $3B, $2C, $2A, $22, $1E, $10, $15
        .byte $0E, $09, $04
stand_at_2B:
        .byte $A1, $91, $71, $C1, $8E, $43, $4A, $E7, $81, $81, $42, $81, $D1, $81, $81, $D1
        .byte $D1, $D1, $D2
foe_kind_2B:
        .byte $0F                           ; the crouched ghoul
        .byte $08, $08                      ; the bat
        .byte $0E                           ; the stone man
        .byte $0F, $0F                      ; the crouched ghoul
        .byte $0D                           ; the running ninja
        .byte $0B                           ; the bird
        .byte $03                           ; the batter
        .byte $02                           ; the thrower
        .byte $0D                           ; the running ninja
        .byte $03                           ; the batter
        .byte $0E                           ; the stone man
        .byte $02                           ; the thrower
        .byte $03, $03, $03                 ; the batter
        .byte $02                           ; the thrower
        .byte $0B                           ; the bird
appear_col_2C:
        .byte $06, $0D, $0D, $0D, $17, $1A, $1F, $26, $29, $2A, $2B, $2D
stand_at_2C:
        .byte $8F, $4B, $4D, $4F, $6F, $6F, $DF, $DF, $5F, $8F, $43, $DF
foe_kind_2C:
        .byte $10                           ; the waiting ghoul
        .byte $0F, $0F, $0F                 ; the crouched ghoul
        .byte $05, $05                      ; the crouching soldier
        .byte $02                           ; the thrower
        .byte $06                           ; the jump kicker
        .byte $0B                           ; the bird
        .byte $06                           ; the jump kicker
        .byte $0F                           ; the crouched ghoul
        .byte $10                           ; the waiting ghoul
appear_col_2D:
        .byte $00, $00
stand_at_2D:
        .byte $DD, $48
foe_kind_2D:
        .byte $21                           ; the Masked Devil
        .byte $24                           ; the Masked Devil
appear_col_2E:
        .byte $00
stand_at_2E:
        .byte $48
foe_kind_2E:
        .byte $25                           ; Jaquio
appear_col_2F:
        .byte $00
stand_at_2F:
        .byte $88
foe_kind_2F:
        .byte $28                           ; the last boss
; Unused.
        .res 7526, $FF

; --- $BFDA  Same first instructions as reset.
reset_copy:
        inc $FFDA
        jmp $C03E
        .res 26, $FF
        .byte $DA, $FF, $DA, $FF, $DA, $FF
