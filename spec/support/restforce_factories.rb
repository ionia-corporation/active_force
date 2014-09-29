module RestforceFactories
  def build_restforce_collection(array)
    Restforce::Collection.new({ 'records' => array }, nil)
  end

  def build_restforce_sobject(hash)
    Restforce::SObject.new(hash)
  end
end
