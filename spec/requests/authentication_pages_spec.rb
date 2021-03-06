require 'spec_helper'

describe "AuthenticationPages" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_selector('h1',    text: 'Sign in') }
    it { should have_selector('title', text: 'Sign in') }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_selector('title', text:'Sign in')}
      it { should have_error_message('Invalid')}

      describe "after visiting another page" do
        before { click_link "Home" }
        it{ should_not have_error_message('Invalid')}
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in(user) }

      it { should have_selector('title', text: user.name) }
      it { should have_link('Users', herf: users_path) }
      it { should have_link('Profile', herf: user_path(user)) }
      it { should have_link('Settings', herf: edit_user_path(user))}
      it { should have_link('Sign out', herf: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "submitting a GET request to the Users#new action" do
        before { get new_user_path }
        specify { response.should redirect_to(root_path) }
      end

      describe "submitting a POST request to the Users#create action" do
        before { post users_path }
        specify { response.should redirect_to(root_path) }
      end

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end

    end

  end

  describe "authorization" do
    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text:'Sign in') }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_selector('title', text:'Sign in') }
        end

      end

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email", with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do
          it "should render the desired protected page" do
            page.should have_selector('title', text:'Edit user')
          end
        end

      end

      describe "check links that only appear when user signed in" do
        before { visit root_path }
        it { should_not have_link('Profile', herf: user_path(user)) }
        it { should_not have_link('Settings', herf: edit_user_path(user))}
      end

      describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before { post microposts_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { response.should redirect_to(signin_path) }
        end

      end


    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector('title', text: full_title('Edit user')) }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end

    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before{ sign_in non_admin }

      describe "submitting a DELETE request ot the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }
      end

    end

  end
end
