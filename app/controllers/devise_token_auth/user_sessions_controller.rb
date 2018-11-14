module DeviseTokenAuth
  class UserSessionsController < ::DeviseTokenAuth::SessionsController
    def create
      # Check
      field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

      @resource = nil
      if field
        q_value = resource_params[field]

        if resource_class.case_insensitive_keys.include?(field)
          q_value.downcase!
        end

        q = "#{field.to_s} = ? AND provider='email'"

        if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? "mysql"
          q = "BINARY " + q
        end

        # LOG IN BY EMAIL AND USERNAME
        if field == :login
          @resource = resource_class.where("email = ? OR username = ?", q_value, q_value).first
        else
          @resource = resource_class.where(q, q_value).first
        end
        # LOG IN BY EMAIL AND USERNAME END
      end

      if @resource && valid_params?(field, q_value) && (!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
        valid_password = @resource.valid_password?(resource_params[:password])
        if (@resource.respond_to?(:valid_for_authentication?) && !@resource.valid_for_authentication? { valid_password }) || !valid_password
          render_create_error_bad_credentials
          return
        end
        # create client id
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @resource.tokens[@client_id] = {
            token: BCrypt::Password.create(@token),
            expiry: (Time.now + ::DeviseTokenAuth.token_lifespan).to_i
        }
        @resource.save

        sign_in(:user, @resource, store: false, bypass: false)

        yield @resource if block_given?

        render_create_success
      elsif @resource && !(!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
        render_create_error_not_confirmed
      else
        render_create_error_bad_credentials
      end
    end
  end
end