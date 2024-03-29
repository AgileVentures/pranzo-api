RSpec.describe 'Reset Password Flow', type: :request do
  let!(:user) { create(:user, password: 'old_password') }
  let(:user_credentials) { user.create_new_auth_token }
  let(:user_headers) do
    { HTTP_ACCEPT: 'application/json' }.merge!(user_credentials)
  end
  let(:expected_response) do
    { success: true,
      message: "Ett email har skickats till '#{user.email}' med instruktioner för hur du skapar ett nytt lösenord." }.as_json
  end

  let(:missing_redirect_url_response) { { success: false, errors: ['Missing redirect URL.'] }.as_json }

  describe 'step 1' do
    describe 'requesting a password reset' do
      describe 'with a redirect url' do
        before do
          post '/auth/password',
               params: { email: user.email, redirect_url: 'http://example.com/reset' },
               headers: { locale: 'sv' }
        end

        it 'is expected to respond with a success message' do
          expect(response_json).to eq expected_response
        end

        it 'is expected to send out an email' do
          expect(email_queue).to eq 1
        end
      end

      describe 'without a rediredct url' do
        before do
          post '/auth/password', params: { email: user.email }
        end

        it 'is expected to respond with an error message' do
          expect(response_json).to eq missing_redirect_url_response
        end

        it 'is expected to NOT send out an email' do
          expect(email_queue).to eq 0
        end
      end
    end
  end

  describe 'step 2: ' do
    let!(:token) { user.send_reset_password_instructions }

    describe 'clicking the link in email' do
      before do
        get '/auth/password/edit',
            params: { reset_password_token: token, redirect_url: 'https://pranzo.se/auth/change-password' }
      end

      it 'is expected to redirect to reset password ui' do
        expect(response.status).to eq 302
      end
    end

    describe 'sending updated password and token' do
      let(:expected_response) do
        { success: true,
          data:
            { email: user.email,
              provider: 'email',
              uid: user.email,
              id: user.id,
              allow_password_change: false,
              name: user.name,
              role: 'consumer',
              created_at: user.created_at.as_json,
              updated_at: user.updated_at.as_json,
              vendor_id: nil },
          message: 'Ditt lösenord har ändrats.' }.as_json
      end
      before do
        put '/auth/password',
            params: { reset_password_token: token, password: 'new_password_from_reset',
                      password_confirmation: 'new_password_from_reset' },
            headers: { locale: 'sv' }.merge!(user_headers)
        user.reload
      end

      it 'is expected to respond with 200' do
        expect(response.status).to eq 200
      end

      it 'is expected to return expected response' do
        expect(response_json).to eq expected_response
      end

      it 'is expected to update password' do
        expect(user.valid_password?('new_password_from_reset')).to eq true
      end
    end
  end
end
