{ pkgs, ... }: {
  systemd.tmpfiles.rules = let
    skins = pkgs.writeText "skins.txt" ''
      return {
        {
          texture = "mouse",
          gender = "male",
        },
      }
    '';
  in [
    "d /var/lib/luanti 0755 microvm kvm -"
    "d /var/lib/luanti/certs 0755 microvm kvm -"

    "d /var/lib/luanti/mousy_industry_land 0770 microvm kvm -"
    "d /var/lib/luanti/mousy_industry_land/world 0777 microvm kvm -"
    "f /var/lib/luanti/mousy_industry_land/world/whitelist.txt 0777 microvm kvm -"
    "L /var/lib/luanti/mousy_industry_land/world/skins.txt - - - - ${skins}"
    "d /var/lib/luanti/mousy_industry_land/world/_world_folder_media 0777 microvm kvm -"
    "d /var/lib/luanti/mousy_industry_land/world/_world_folder_media/textures 0777 microvm kvm -"
    "L /var/lib/luanti/mousy_industry_land/world/_world_folder_media/textures/mouse.png - - - - ${./mouse.png}"
  ];
}
