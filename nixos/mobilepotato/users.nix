{
  imports =
    (map (p: ../users + p) [
      /atlas/user.nix
    ]);
}
