{den, ...}: {
  den.aspects.hardware = {
    includes = [
      den.aspects.bluetooth
      den.aspects.lact
      den.aspects.pipewire
      den.aspects.power
    ];
  };
}
