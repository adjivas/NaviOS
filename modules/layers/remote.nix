{den, ...}: {
  den.aspects.remote = {
    includes = [
      den.aspects.cage
      den.aspects.wayvnc
      den.aspects.novnc
      den.aspects.sunshine
      den.aspects.moonlight-web-stream
    ];
  };
}
