require 'base64'
require 'digest'
require 'openssl'

module Shat
  module Crypto
    extend self

    def cipher
      @__cipher__ ||=
        new_cipher.encrypt
    end

    def decipher
      @__decipher__ ||=
        new_cipher.decrypt
    end

    def decrypt(msg, pass, iv)
      crypted = Base64.decode64(msg)

      set_cipher(decipher, pass, iv)
      decipher.update(crypted) << decipher.final
    end

    def encrypt(msg, pass, iv)
      set_cipher(cipher, pass, iv)

      crypted = cipher.update(msg) << cipher.final
      Base64.encode64(crypted)
    end

    private

    def new_cipher
      OpenSSL::Cipher::AES256.new(:CTR)
    end

    def set_cipher(cipher, pass, iv)
      cipher.key = Digest::SHA256.digest(pass)
      cipher.iv  = iv
    end
  end
end
