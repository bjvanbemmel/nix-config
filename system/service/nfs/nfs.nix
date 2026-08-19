{ config, pkgs, ... }:

{
  services.nfs.server = {
    enable = true;
    exports = ''
      /export bjvanbemmel.local(insecure,rw,sync,no_subtree_check,no_root_squash)
    '';
  };
}
