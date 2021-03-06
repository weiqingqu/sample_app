class UsersController < ApplicationController

  before_filter :signed_in_user, only: [:edit, :update, :index, :destory]
  before_filter :signed_in_user_actions_not_allowed, only: [:new, :create]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: :destroy

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page:params[:page])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end

  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def destroy

    @user = User.find(params[:id])

    #不允许管理员删除自己
    redirect_to(root_path) if current_user?(@user)

    @user.destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  private

    def signed_in_user_actions_not_allowed
      if signed_in?
        redirect_to root_path
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

end
