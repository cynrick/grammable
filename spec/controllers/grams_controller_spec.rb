require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#new action" do
    it "should successfully show the new form" do
      user = User.create(
        email: 'test@outlook.com',
        password: 'password',
        password_confirmation: 'password'
      )
      sign_in user

      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#create action" do
    it "should successfully create a new gram in the database" do
      user = User.create(
        email: 'test@outlook.com',
        password: 'password',
        password_confirmation: 'password'
      )
      sign_in user

      post :create, gram: { message: 'Hello!' }
      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq('Hello!')
      expect(gram.user).to eq(user)
    end

    it "should properly deal with empty message field" do
      user = User.create(
        email: 'test@outlook.com',
        password: 'password',
        password_confirmation: 'password'
      )
      sign_in user

      post :create, gram: { message: '' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Gram.count).to eq(0)
    end

    it "should properly deal with message field with input less than 3 characters long" do
      user = User.create(
        email: 'test@outlook.com',
        password: 'password',
        password_confirmation: 'password'
      )
      sign_in user

      post :create, gram: { message: 'Hi' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Gram.count).to eq(0)
    end
  end
end
