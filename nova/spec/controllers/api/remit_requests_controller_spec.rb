# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::RemitRequestsController, type: :controller do
  include_context 'request from nova site'

  let(:user) { create(:user) }
  let(:requested_user) { create(:user) }
  let(:remit_request) { create(:remit_request, user: user, requested_user: requested_user) }

  describe 'GET #index' do
    subject { get :index }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { sign_in(user) }

      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'POST #create' do
    subject { post :create, params: { emails: [requested_user.email], amount: 3000 } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { sign_in(user) }

      it { is_expected.to have_http_status(:created) }
    end
  end

  describe 'POST #accept' do
    subject { post :accept, params: { id: remit_request.id } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before do
        sign_in(user)
        requested_user.balance.update_attribute(:amount, 1_000_000)
      end

      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'POST #reject' do
    subject { post :reject, params: { id: remit_request.id } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { sign_in(user) }

      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'POST #cancel' do
    subject { post :cancel, params: { id: remit_request.id } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { sign_in(user) }

      it { is_expected.to have_http_status(:ok) }
    end
  end
end
