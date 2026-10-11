{den, ...}: {
  den.aspects.btrbk-ssh.nixos = {lib, ...}: {
    services.openssh.settings.AllowUsers = lib.mkAfter [
      "btrbk"
      "btrbk-latest"
      "btrbk-restore"
    ];
  };

  den.policies.btrbk-ssh = {
    den,
    host,
    lib,
    ...
  }:
    lib.optional
    (
      host.hasAspect den.aspects.btrbk
      && host.hasAspect den.aspects.ssh
    )
    (
      den.lib.policy.include den.aspects.btrbk-ssh
    );

  den.schema.host.includes = [
    den.policies.btrbk-ssh
  ];
}
