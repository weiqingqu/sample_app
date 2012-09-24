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
      before { signin(user) }

      it { should have_selector('title', text: user.name) }
      it { should have_link('Profile', herf: user_path(user)) }
      it { should have_link('Settings', herf: edit_user_path(user))}
      it { should have_link('Sign out', herf: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end

    end

  end

end
