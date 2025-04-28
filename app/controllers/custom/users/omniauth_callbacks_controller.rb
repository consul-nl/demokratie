require_dependency Rails.root.join("app", "controllers", "users", "omniauth_callbacks_controller").to_s
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # START Ergänzung für Keycloak-Anbindung
  def openid_connect
    keycloak_id_token = request.env["omniauth.auth"].credentials.id_token

    info = request.env["omniauth.auth"].info
    extra = request.env["omniauth.auth"].extra

    email = info["email"]
    username = info["name"]

    first_name = info.first_name
    last_name = info.last_name
    gender = get_gender(extra)
    plz = extra.raw_info&.address&.postal_code
    dob_array = extra.raw_info.birthdate.split("-").map(&:to_i)
    dob = Date.new(dob_array[0], dob_array[1], dob_array[2])

    authlevel = extra.raw_info[:authlevel]
    keycloak_link = extra.raw_info["preferred_username"]

    if User.only_hidden.find_by(email: email)
      redirect_to new_user_registration_path(reason: "uh") and return
    end

    if user = User.find_by(keycloak_link: keycloak_link, username: username, registering_with_oauth: true) #keycloak user logged in in the past but didn't finish registration
      sign_in user
      redirect_to finish_signup_path
      return

    elsif user = User.find_by(keycloak_link: keycloak_link) #keycloak user logged in in the past
      if user.email == email #keycloak user didn't change his email in keycloak
        sign_in user

      else #email changed in keycloak after logging in with old email
        if User.find_by(email: email) #new keycloak email already taken by other user
          redirect_to new_user_session_url(reason: "ee") and return
        else
          user.assign_attributes(
            email: email,
            keycloak_id_token: keycloak_id_token)
          user.skip_reconfirmation!
          user.save!

          sign_in user
        end
      end

    else
      if user = User.find_by(email: email) #keycloak email already taken by other user
        redirect_to new_user_session_url(reason: "ee") and return
      else
        password = SecureRandom.base64(15)
        user = User.create!({
          email: email,
          username: username,
          first_name: first_name,
          last_name: last_name,
          gender: gender,
          plz: plz,
          date_of_birth: dob,
          oauth_email: email,
          terms_older_than_14: true,
          terms_data_storage: true,
          terms_data_protection: true,
          terms_general: true,
          password: password,
          password_confirmation: password,
          keycloak_link: keycloak_link,
          keycloak_id_token: keycloak_id_token,
          confirmed_at: Time.zone.now,
          registering_with_oauth: true
        })

        if User.find_by(username: username, registering_with_oauth: false)
          sign_in user
          redirect_to finish_signup_path
          return
        else
          user.verify! if ["STORK-QAA-Level-3", "STORK-QAA-Level-4"].include?(authlevel)
        end
      end

      sign_in user
    end

    redirect_to after_sign_in_path_for(user), notice: t("cli.devise.success")
  end
  # ENDE Ergänzung für Keycloak-Anbindung

  def after_sign_in_path_for(resource)
    # if resource.registering_with_oauth && !resource.valid?
    #   finish_signup_path
    # else
      resource.update!(registering_with_oauth: false)
      super(resource)
    # end
  end

  alias_method :bayern_id, :openid_connect

  private

    def get_gender(extra)
      return "male" if extra.raw_info[:gender] == "1"
      return "female" if extra.raw_info[:gender] == "2"

      nil
    end
end
