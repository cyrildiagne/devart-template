class mk.m11s.tribal.Settings extends mk.m11s.base.Settings
  
  setupAssets : ->
    @assets = [
      'assets/items/tribal/head.svg'
    ]

  setupColors : ->
    super()
    @colors.leftLowerLeg = @palette.darkGray
    @colors.rightLowerLeg = @palette.darkGray