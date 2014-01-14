class Mxl_config_fixture_with_startupconfig

  attr_accessor :mxl_config, :provider
  def initialize
    @mxl_config = get_mxl_config
    @provider = mxl_config.provider
  end

  private

  def  get_mxl_config
    Puppet::Type.type(:mxl_config).new(
    :name => 'config1',
    :force => 'true',
    :startup_config => 'true',
    :url => 'tftp://10.10.10.10/sss.scr'
    )
  end

end

class Mxl_config_fixture_with_runningconfig

  attr_accessor :mxl_config, :provider
  def initialize
    @mxl_config = get_mxl_config
    @provider = mxl_config.provider
  end

  private

  def  get_mxl_config
    Puppet::Type.type(:mxl_config).new(
    :name => 'config1',
    :force => 'true',
    :startup_config => 'false',
    :url => 'tftp://10.10.10.10/sss.scr'
    )
  end

end