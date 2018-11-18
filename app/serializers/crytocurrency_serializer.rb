class CrytocurrencySerializer
  include FastJsonapi::ObjectSerializer
  attributes :cryto_name, :symbol, :description
end
