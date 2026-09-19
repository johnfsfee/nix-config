{ lib, ... }:
{
  imports =
    (map (p: ../users + p) [
      /anon/user.nix
    ]);

  users.users.nobody = {
    group = lib.mkForce "users";
    extraGroups = [ "users" ];
  };

  boot.initrd.systemd = {
    enable = true; # (Ensure this is here if you use systemd initrd)

    # Define the missing group inside the initrd environment
    groups.users = { };
  };
}
