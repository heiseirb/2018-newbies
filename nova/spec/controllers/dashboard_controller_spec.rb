# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) { create(:user) }

  describe 'GET #show' do
    subject { get :show }

    context 'without logged in' do
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context 'with logged in' do
      before { sign_in(user) }

      it { is_expected.to have_http_status(:ok) }
    end
  end
end
