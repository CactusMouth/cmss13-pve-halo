//-----------------------MISC SUPPLIES BOXES-----------------------

/obj/item/ammo_box/magazine/misc
	name = "\improper miscellaneous equipment box"
	desc = "A box for miscellaneous equipment."
	icon_state = "supply_crate"
	overlay_ammo_type = "blank"
	overlay_gun_type = "blank"
	overlay_content = "blank"
	can_explode = FALSE
	limit_per_tile = 4

//---------------------FIRE HANDLING PROCS

/obj/item/ammo_box/magazine/misc/flamer_fire_act(damage, datum/cause_data/flame_cause_data)
	if(burning)
		return
	burning = TRUE
	process_burning()
	return

/obj/item/ammo_box/magazine/misc/get_severity()
	return

/obj/item/ammo_box/magazine/misc/process_burning(datum/cause_data/flame_cause_data)
	var/obj/structure/magazine_box/host_box
	if(istype(loc, /obj/structure/magazine_box))
		host_box = loc
	handle_side_effects(host_box)
	//need to make sure we delete the structure box if it exists, it will handle the deletion of ammo box inside
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), (host_box ? host_box : src)), 7 SECONDS)
	return

/obj/item/ammo_box/magazine/misc/handle_side_effects(obj/structure/magazine_box/host_box)
	if(host_box)
		host_box.apply_fire_overlay()
		host_box.set_light(3)
		host_box.visible_message(SPAN_WARNING("\The [src] catches on fire!"))
	else
		apply_fire_overlay()
		set_light(3)
		visible_message(SPAN_WARNING("\The [src] catches on fire!"))

/obj/item/ammo_box/magazine/misc/apply_fire_overlay(will_explode = FALSE)
	var/offset_x = 1
	var/offset_y = -6

	var/image/fire_overlay = image(icon, icon_state = will_explode ? "on_fire_explode_overlay" : "on_fire_overlay", pixel_x = offset_x, pixel_y = offset_y)
	overlays.Add(fire_overlay)

/obj/item/ammo_box/magazine/misc/explode(severity, datum/cause_data/flame_cause_data)
	if(!QDELETED(src))
		qdel(src)
	return

//------------------------MRE Box--------------------------

/obj/item/ammo_box/magazine/misc/mre
	name = "\improper box of MREs"
	desc = "A box of MREs. Nutritious, but not delicious."
	magazine_type = /obj/item/storage/box/MRE
	num_of_magazines = 12
	overlay_content = "_mre"

/obj/item/ammo_box/magazine/misc/mre/empty
	empty = TRUE

//------------------------M94 Marking Flare Packs Box--------------------------

/obj/item/ammo_box/magazine/misc/flares
	name = "\improper box of M94 marking flare packs"
	desc = "A box of M94 marking flare packs, to brighten up your day."
	magazine_type = /obj/item/storage/box/m94
	num_of_magazines = 10
	overlay_gun_type = "_m94"
	overlay_content = "_flares"

//------------------------M89 Signal Flare Packs Box--------------------------

/obj/item/ammo_box/magazine/misc/flares/signal
	name = "\improper box of M89 signal flare packs"
	desc = "A box of M89 signal flare packs, to mark up the way."
	magazine_type = /obj/item/storage/box/m94/signal
	overlay_gun_type = "_m89"
	overlay_content = "_flares_signal"

//---------------------FIRE HANDLING PROCS

//flare box has unique stuff
/obj/item/ammo_box/magazine/misc/flares/flamer_fire_act(damage, datum/cause_data/flame_cause_data)
	if(burning)
		return
	burning = TRUE
	process_burning()

/obj/item/ammo_box/magazine/misc/flares/get_severity()
	var/flare_amount = 0
	for(var/obj/item/storage/box/m94/flare_box in contents)
		flare_amount += length(flare_box.contents)
	flare_amount = floor(flare_amount / 14) //10 packs, 14 flares each, maximum total of 10 flares we can throw out
	return flare_amount

/obj/item/ammo_box/magazine/misc/flares/process_burning(datum/cause_data/flame_cause_data)
	var/obj/structure/magazine_box/host_box
	if(istype(loc, /obj/structure/magazine_box))
		host_box = loc
	var/flare_amount = get_severity()
	//need to make sure we delete the structure box if it exists, it will handle the deletion of ammo box inside
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), (host_box ? host_box : src)), 7 SECONDS)
	if(flare_amount > 0)
		handle_side_effects(host_box, TRUE)

		var/list/turf_list = RANGE_TURFS(5, (host_box ? host_box : src))
		for(var/i = 1, i <= flare_amount, i++)
			addtimer(CALLBACK(src, PROC_REF(explode), (host_box ? host_box : src), turf_list), rand(1, 6) SECONDS)
		return
	handle_side_effects(host_box)
	return

/obj/item/ammo_box/magazine/misc/flares/handle_side_effects(obj/structure/magazine_box/host_box, will_explode = FALSE)
	var/shown_message = "\The [src] catches on fire!"
	if(will_explode)
		shown_message = "\The [src] catches on fire and starts shooting out flares!"

	if(host_box)
		host_box.apply_fire_overlay()
		host_box.set_light(3)
		host_box.visible_message(SPAN_WARNING(shown_message))
	else
		apply_fire_overlay()
		set_light(3)
		visible_message(SPAN_WARNING(shown_message))

//for flare box, instead of actually exploding, we throw out a flare at random direction
/obj/item/ammo_box/magazine/misc/flares/explode(obj/structure/magazine_box/host_box, list/turf_list = list())
	var/range = rand(1, 6)
	var/speed = pick(SPEED_SLOW, SPEED_AVERAGE, SPEED_FAST)

	var/turf/target_turf = pick(turf_list)
	var/obj/item/device/flashlight/flare/on/F = new (get_turf(host_box ? host_box : src))
	playsound(src,'sound/handling/flare_activate_2.ogg', 50, 1)

	INVOKE_ASYNC(F, TYPE_PROC_REF(/atom/movable, throw_atom), target_turf, range, speed, null, TRUE)
	return

/obj/item/ammo_box/magazine/misc/flares/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/flares/signal/empty
	empty = TRUE

//------------------------Flashlight Box--------------------------

/obj/item/ammo_box/magazine/misc/flashlight
	name = "\improper box of flashlights"
	desc = "A box of flashlights to brighten your day!"
	magazine_type = /obj/item/device/flashlight
	num_of_magazines = 8
	icon_state = "flashlightbox"
	icon_state_deployed = "flashlightbox_deployed"
	overlay_content = "_flashlight"

/obj/item/ammo_box/magazine/misc/flashlight/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/flashlight/combat
	name = "\improper box of combat flashlights"
	desc = "A box of flashlights to brighten your day!"
	magazine_type = /obj/item/device/flashlight/combat
	num_of_magazines = 8
	icon_state = "flashlightbox_combat"
	icon_state_deployed = "flashlightbox_combat_deployed"
	overlay_content = "_flashlight"

/obj/item/ammo_box/magazine/misc/flashlight/combat/empty
	empty = TRUE


//------------------------Battery Box--------------------------

/obj/item/ammo_box/magazine/misc/power_cell
	name = "\improper box of High-Capacity Power Cells"
	desc = "A box of High-Capacity Power Cells to keep your electronics going all night long!"
	magazine_type = /obj/item/cell/high
	num_of_magazines = 8
	icon_state = "batterybox"
	icon_state_deployed = "batterybox_deployed"
	overlay_content = "_battery"

/obj/item/ammo_box/magazine/misc/power_cell/empty
	empty = TRUE

//-----------------------Halo Boxes-----------------------

/obj/item/ammo_box/magazine/misc/unsc
	name = "\improper UNSC storage crate"
	desc = "A generic storage crate for the UNSC. Looks like it holds...nothing? You shouldn't be seeing this..."
	icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/boxes_and_lids.dmi'
	magazines_icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/magazines.dmi'
	deployed_object = /obj/structure/magazine_box/unsc
	icon_state = "base"
	magazine_type = null
	limit_per_tile = 1
	num_of_magazines = 0
	overlay_content = null

/obj/item/ammo_box/magazine/misc/unsc/mre
	name = "\improper UNSC storage crate - (MRE x 14)"
	desc = "A generic storage crate for the UNSC holding MREs."
	icon_state = "base_mre"
	magazine_type = /obj/item/storage/box/MRE
	num_of_magazines = 14
	overlay_content = "_mre"

/obj/item/ammo_box/magazine/misc/unsc/mre/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/flare
	name = "\improper UNSC storage crate  (Flares x 14)"
	desc = "A generic storage crate for the UNSC holding flares."
	icon_state = "base_flare"
	magazine_type = /obj/item/storage/box/m94
	num_of_magazines = 14
	overlay_content = "_flare"

/obj/item/ammo_box/magazine/misc/unsc/flare/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/flare/signal
	name = "\improper UNSC storage crate - (Signal Flares x 14)"
	desc = "A generic storage crate for the UNSC holding signal flares."
	icon_state = "base_flare"
	magazine_type = /obj/item/storage/box/m94/signal
	num_of_magazines = 14
	overlay_content = "_signal"

/obj/item/ammo_box/magazine/misc/unsc/flare/signal/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/grenade
	name = "\improper UNSC storage crate - (Grenades x 9)"
	desc = "A generic storage crate for the UNSC holding fragmentation grenades."
	icon_state = "base_frag"
	magazine_type = /obj/item/explosive/grenade/high_explosive/m15/unsc
	num_of_magazines = 9
	overlay_content = "_frag"

/obj/item/ammo_box/magazine/misc/unsc/grenade/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/grenade/launchable
	name = "\improper UNSC storage crate - (40mm Grenades x 30)"
	desc = "A generic storage crate for the UNSC holding 40MM grenades."
	icon_state = "base_40mm"
	magazine_type = /obj/item/explosive/grenade/high_explosive/m15/unsc/launchable
	num_of_magazines = 30
	overlay_content = "_40mm"

/obj/item/ammo_box/magazine/misc/unsc/grenade/launchable/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/medical_packets
	name = "\improper UNSC storage crate - (First Aid Packets x 10)"
	desc = "A generic storage crate for the UNSC holding MREs."
	icon_state = "base_medpack"
	magazine_type = /obj/item/storage/box/medical_packet
	num_of_magazines = 10
	overlay_content = "_medpack"

/obj/item/ammo_box/magazine/misc/unsc/medical_packets/empty
	empty = TRUE
