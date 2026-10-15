{ config, ... }:

{
  nix.gc = {
    automatic = true;
    dates = "daily";
    # nix-collect-garbage has no generation-count flag (`--delete-generations` belongs to nix-env, which is why
    # the unit failed with "unrecognised flag"). The generation limit is applied first, below; the collector then
    # only removes what is no longer referenced.
    options = "";
  };

  # Keep the newest 10 system generations.
  systemd.services.nix-gc.serviceConfig.ExecStartPre =
    "${config.nix.package}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations +10";
}
