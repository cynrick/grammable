require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#new action" do
    it "should require users to be logged in" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the new form" do
      user = FactoryGirl.create(:user)
      sign_in user

      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#create action" do
    it "should require users to be logged in" do
      post :create, gram: {
        message: 'Hello!',
        picture: fixture_file_upload('/picture.png', 'image/png')
      }
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully create a new gram in the database" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, gram: {
        message: 'Hello!',
        picture: fixture_file_upload('/picture.png', 'image/png')
      }
      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq('Hello!')
      expect(gram.user).to eq(user)
    end

    it "should properly deal with empty message field" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, gram: { message: '' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Gram.count).to eq(0)
    end

    it "should properly deal with message field with input less than 3 characters long" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, gram: { message: 'Hi' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Gram.count).to eq(0)
    end
  end

  describe "grams#show action" do
    it "should successfully show the page if the gram is found" do
      gram = FactoryGirl.create(:gram)

      get :show, id: gram.id
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error if the gram is not found" do
      get :show, id: 'integer'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#edit action" do
    it "should not let a user who did not create the gram edit the gram" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user

      get :edit, id: gram.id
      expect(response).to have_http_status(:forbidden)
    end

    it "should not allow unauthenticated users to edit grams" do
      gram = FactoryGirl.create(:gram)

      get :edit, id: gram.id
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the edit form if the gram is found" do
      gram = FactoryGirl.create(:gram)
      sign_in gram.user

      get :edit, id: gram.id
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error if the gram is not found" do
      user = FactoryGirl.create(:user)
      sign_in user

      get :edit, id: 'integer'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#update action" do
    it "should not let users who did not create the gram update the gram" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user

      patch :update, id: gram.id, gram: { message: 'Changed' }
      expect(response).to have_http_status(:forbidden)
    end

    it "should not allow unauthenticated users to update grams" do
      gram = FactoryGirl.create(:gram)

      patch :update, id: gram.id, gram: { message: 'Changed' }
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow users to successfully update grams" do
      gram = FactoryGirl.create(:gram, message: 'Initial Value')
      sign_in gram.user

      patch :update, id: gram.id, gram: { message: 'Changed' }
      expect(response).to redirect_to gram_path(gram)
      gram.reload
      expect(gram.message).to eq('Changed')
    end

    it "should return a 404 error if the gram is not found" do
      user = FactoryGirl.create(:user)
      sign_in user

      patch :update, id: 'integer', gram: { message: 'Changed' }
      expect(response).to have_http_status(:not_found)
    end

    it "should render the edit form with an http status of unprocessable_entity if there are validation errors" do
      gram = FactoryGirl.create(:gram, message: 'Initial Value')
      sign_in gram.user

      patch :update, id: gram.id, gram: { message: '' }
      expect(response).to have_http_status(:unprocessable_entity)
      gram.reload
      expect(gram.message).to eq('Initial Value')
    end
  end

  describe "grams#destroy action" do
    it "should not let user who did not create the gram destroy the gram" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user

      delete :destroy, id: gram.id
      expect(response).to have_http_status(:forbidden)
    end

    it "should not allow unauthenticated users to destroy grams" do
      gram = FactoryGirl.create(:gram)

      delete :destroy, id: gram.id
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow users to destroy grams" do
      gram = FactoryGirl.create(:gram)
      sign_in gram.user

      delete :destroy, id: gram.id
      expect(response).to redirect_to root_path
      deleted_gram = Gram.find_by_id(gram.id)
      expect(deleted_gram).to eq(nil)
    end

    it "should return a 404 error if the gram is not found" do
      user = FactoryGirl.create(:user)
      sign_in user

      delete :destroy, id: 'integer'
      expect(response).to have_http_status(:not_found)
    end
  end
end
