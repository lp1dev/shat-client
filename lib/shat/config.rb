module Config
  extend self

  def load
    Bundler.require(:default)

    # loads .env file variable according to SHAT_ENV, then exposes
    # a public method for each variable
    Dotenv.load(*[".env.#{ENV['SHAT_ENV'] || 'dev'}"]).each do |k,v|
      define_method(k.to_sym) { v }
    end
  end
end

Config.load
