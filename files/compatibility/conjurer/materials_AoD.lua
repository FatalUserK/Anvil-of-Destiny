table.insert(ALL_MATERIALS, {
  name="Anvil of Destiny",
  desc="Materials added by Anvil of Destiny, all 3 of them.\nHang on does this really need its own category-",
  icon="mods/config_plus/files/conjurer_plus/anvil_of_destiny/icon.png",
  icon_off="mods/config_plus/files/conjurer_plus/anvil_of_destiny/icon_off.png",  -- The greyed-out unselected variant
  materials={
    {
      image="mods/config_plus/files/conjurer_plus/anvil_of_destiny/anvilofdestinium.png",  -- This should be a 16*16px icon
      name="Anvilofdestinium",
      id="anvilofdestinium"  -- The material ID. Must match exactly materials.xml
    },
    {
      image="mods/config_plus/files/conjurer_plus/anvil_of_destiny/anvilofdestinium_mimic.png",
      name="Anvilofdensitium",
      id="anvilofdestinium_mimic"
    },
    {
      image="mods/config_plus/files/conjurer_plus/anvil_of_destiny/item_box2d_anvil_of_destiny.png",
      name="Anvilofdestinium [box2d]",
      id="item_box2d_anvil_of_destiny"
    },
  }
})