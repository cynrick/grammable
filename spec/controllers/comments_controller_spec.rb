require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  describe "comments#create action" do
    it "should allow users to create comments" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, gram_id: gram.id, comment: { message: 'Comment' }
      expect(response).to redirect_to gram_path(gram)
      expect(gram.comments.length).to eq(1)
      expect(gram.comments.first.message).to eq('Comment')
    end

    it "should require a user to be logged in to comment on a gram" do
      gram = FactoryGirl.create(:gram)

      post :create, gram_id: gram.id, comment: { message: 'Comment' }
      expect(response).to redirect_to new_user_session_path
    end

    it "should return http status code of not found if the gram is not found" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, gram_id: 'integer', comment: { message: 'Comment' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
