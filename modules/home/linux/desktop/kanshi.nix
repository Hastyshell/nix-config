{
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.outputs = [
          {
            criteria = "Dell Inc. DELL P2723QE FHGCP44";
            status = "enable";
            mode = "3840x2160@60Hz";
            scale = 1.75;
          }
        ];
      }

      {
        profile.outputs = [
          {
            criteria = "Virtual-1";
            status = "enable";
            mode = "3840x2160@60Hz";
            scale = 1.75;
          }
        ];
      }
    ];
  };
}
