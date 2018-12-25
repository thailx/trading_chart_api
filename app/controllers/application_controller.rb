class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  def register
    @user = User.new(register_params)
    if @user.save
      render json: {
          data: {
              messages: "Created User successfully"
          }
      },status: 200
    else
      render json: {
          data: {
              messages: @user.errors.full_messages
          }
      }, status: 422
    end
  end

  private

  def register_params
    params.permit(:email, :password)
  end
end
