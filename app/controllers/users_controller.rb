class UsersController < ApplicationController
  before_action :load_message, :only => [:index, :edit, :new]
  before_action :load_user, :only => [:add_post, :update, :create, :destroy]
  def index
    # has not logged in 
    if session[:user9487].nil?
      redirect_to new_user_path
    else
      @user = User.where("name = ?", session[:user9487][:user_info][:name])
      @user_posts = @user.posts
    end
  end

  def edit
    # edit password
    @user = User.where("name = ?", session[:user9487][:user_info][:name])
  end

  def add_post
    @user.posts.build(params.require(:post).permit(:content))
    unless @user.save
        store_message(@user.errors.full_messages)
    end
    redirect_to user_index_path
  end

  def update
    # update password
    change_content = params.require(:user).permit(:old_password, :new_password, :password_confirm)
    if change_content[:new_password].eql? change_content[:password_confirm]
      if @user.update_attributes(password: change_content[:new_password])
        redirect_to user_index_path
      else
        store_message(@user.errors.full_messages)
        redirect_to edit_user_path
      end
    else
      store_message(["Password and password confirmation no the same"])
      redirect_to edit_user_path
    end
  end
  
  def new
  end

  def login
    @loginer = login_params
    @user = User.where("name = :name AND password = :password", {name: loginer[:name], password: loginer[:password]}).first
    if @user.nil?
      # note found
      store_message(["Wrong user name or password"])
      redirect_to new_user_path
    else
      session[:user9487] = serialize(@user)
      redirect_to user_index_path
    end
  end

  def logout
    session[:user9487] = nil
      redirect_to user_index_path
  end

  def create
    newuser = new_user_params
    if @user.nil?
      # no user name conflict, safe to create
      if newuser[:password].eql? newuser[:password_confirm]
        # success
        @user = User.new(:name => newuser[:name], :email => newuser[:email], :password => newuser[:password])
        if @user.save
          session[:user9487] = serialize(@user)
          redirect_to user_index_path
        else
          # save fail
          store_message(@user.errors.full_messages)
          redirect_to new_user_path
        end
      else
        # password and password_confirm not the same
        store_message(["password and password confirmation are not the same"])
        redirect_to new_user_path
      end
    else
        store_message(["user exists!!"])
        redirect_to new_user_path
    end
  end

  def destroy
    # destroy a user and his posts
    @posts = @user.posts
    if @posts
      @post.destroy
    end
    @user.destroy
    session[:user9487] = nil
    redirect_to user_index_path
  end

  private

  def load_user
    @user = User.where("name = ?", session[:user9487][:user_info][:name])
  end
  def load_messages
    if not session[:message87].nil?
      @messages = []
      session[:message87][:error].map { |hash|
        @messages << hash[:message]
      }
      session[:message87] = nil
    else
      @messages = nil
    end
  end

  def store_message(messages)
        session[:message87] = serialize_error(messages)
  end

  def new_user_params
    params.require(:newuser).permit(:name, :email, :password, :password_confirm)
  end

  def login_params
    params.require(:login).permit(:name, :password)
  end

  def serialize(user)
    user_info = { :name => user.name, :email => user.email }
    { :user_info => user_info }
  end

  def serialize_error(messages)
    all_messages = messages.each { |message|
      {:message => message}
    }
    {:error => all_messages}
  end
end
