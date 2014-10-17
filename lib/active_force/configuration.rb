module ActiveForce
  class Configuration
    attr_accessor :sfdc_client

    private

    def initialize
      @sfdc_client ||= Restforce.new
    end
  end
end