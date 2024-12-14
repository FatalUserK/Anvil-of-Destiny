table.insert(ALL_ENTITIES, {
  name="Anvil of Destiny",
  desc="Entities added by Anvil of Destiny",
  icon="mods/config_plus/files/conjurer_plus/anvil_of_destiny/icon.png",
  icon_off="mods/config_plus/files/conjurer_plus/anvil_of_destiny/icon_off.png",  -- The greyed-out unselected variant
  entities={
    {
      name="Anvil of Destiny",
      desc="Can be used to combine and modify wands",
      path="mods/anvil_of_destiny/files/entities/anvil/anvil.xml",
      image="mods/config_plus/files/conjurer_plus/anvil_of_destiny/anvil.png",  -- This should be a 16*16px icon
    },
    {
      name="Left-Facing Statue",
      desc="Statue that sits on the right-hand side of the Anvil of Destiny",
      path="mods/anvil_of_destiny/files/entities/statue/statue_facing_left.xml",
      image="mods/config_plus/files/conjurer_plus/anvil_of_destiny/statue_right.png",  -- This should be a 16*16px icon
    },
    {
      name="Right-Facing Statue",
      desc="Statue that sits on the left-hand side of the Anvil of Destiny",
      path="mods/anvil_of_destiny/files/entities/statue/statue_facing_right.xml",
      image="mods/config_plus/files/conjurer_plus/anvil_of_destiny/statue_left.png",  -- This should be a 16*16px icon
    },
    {
      name="Anvil of Density",
      desc="Mimic version of the Anvil of Destiny, created for the Mimic-Themed 2023 October Mod-Jam",
      path="mods/anvil_of_destiny/files/entities/anvil/mimic/anvil.xml",
      image="mods/config_plus/files/conjurer_plus/anvil_of_destiny/anvil.png",  -- This should be a 16*16px icon
    },
    {
      name="Portable Anvil of Destiny",
      desc="Throw it on the ground to spawn a room with an Anvil of Destiny",
      path="mods/anvil_of_destiny/files/entities/portable_anvil/item.xml",
      image="mods/config_plus/files/conjurer_plus/anvil_of_destiny/anvil_item.png",  -- This should be a 16*16px icon
    },
    {
      name="Error Book",
      desc="lmao",
      path="mods/anvil_of_destiny/files/entities/error_book.xml",
      image="mods/config_plus/files/conjurer_plus/anvil_of_destiny/monke.png",  -- This should be a 16*16px icon
    },
  },
})