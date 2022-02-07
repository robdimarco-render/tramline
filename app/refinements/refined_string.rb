module RefinedString
  refine String do
    def encode
      ActiveSupport::MessageEncryptor
        .new(Rails.application.secrets.secret_key_base[0..31])
        .encrypt_and_sign(self)
    end

    def decode
      ActiveSupport::MessageEncryptor
        .new(Rails.application.secrets.secret_key_base[0..31])
        .decrypt_and_verify(self)
    end

    def in_tz(tz)
      ActiveSupport::TimeZone.new(tz).parse(self)
    rescue NoMethodError
      Time.parse(self)
    end

    def safe_json_parse
      JSON.parse(self)
    rescue JSON::ParserError
      {}
    end
  end
end