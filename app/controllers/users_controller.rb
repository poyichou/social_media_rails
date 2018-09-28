class UsersController < ApplicationController
  before_action :load_messages, :only => [:index, :edit, :new]
  before_action :load_user, :only => [:index, :edit, :add_post, :update, :create, :destroy]
  def index
    if @user.nil?
      # has not logged in 
      store_user(nil)
      redirect_to new_user_path
    else
      @user_posts = @user.posts
      @post = Post.new
    end
  end

  def edit
    # edit password
  end
  
  def new
    @user = User.new
  end

  def add_post
    @user.posts.build(params.require(:post).permit(:content))
    unless @user.save
      store_messages(@user.errors.full_messages)
    end
    redirect_to users_path
  end

  def update
    # update password
    change_content = params.require(:user).permit(:old_password, :new_password, :password_confirm)
    if change_content[:old_password].eql? session[:user9487]["password"]
      if change_content[:new_password].eql? change_content[:password_confirm]
        if @user.update_attributes(password: change_content[:new_password])
	  session[:user9487]["password"] = change_content[:new_password]
          redirect_to users_path
        else
          store_messages(@user.errors.full_messages)
          redirect_to edit_user_path
        end
      else
        store_messages(["New password and password confirmation not the same"])
        redirect_to edit_user_path
      end
    else
      store_messages(["Old password not correct!!"])
      redirect_to edit_user_path
    end
  end

  def login
    loginer = params.require(:user).permit(:name, :password)
    @user = User.where("name = :name AND password = :password", {name: loginer[:name], password: loginer[:password]}).first
    if @user.nil?
      # note found
      store_messages(["Wrong user name or password"])
      redirect_to new_user_path
    else
      store_user(@user)
      redirect_to users_path
    end
  end

  def logout
    store_user(nil)
    redirect_to users_path
  end

  def create
    newuser = params.require(:user).permit(:name, :email, :password, :password_confirm)
    if @user.nil?
      # no user name conflict, safe to create
      if newuser[:password].eql? newuser[:password_confirm]
        # success
        @user = User.new(:name => newuser[:name], :email => newuser[:email], :password => newuser[:password])
        if @user.save
          store_user(@user)
          redirect_to users_path
        else
          # save fail
          store_messages(@user.errors.full_messages)
          redirect_to new_user_path
        end
      else
        # password and password_confirm not the same
        store_messages(["password and password confirmation are not the same"])
        redirect_to new_user_path
      end
    else
        store_messages(["user exists!!"])
        redirect_to new_user_path
    end
  end

  def delete_post
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to users_path
  end

  def destroy
    # destroy a user and his posts
    @posts = @user.posts
    unless @posts.nil?
      @posts.destroy
    end
    @user.destroy
    store_user(nil)
    redirect_to users_path
  end

  private

  def load_user
    if session[:user9487].nil?
      @user = nil
    else
      @user = User.where("name = ?", session[:user9487]["name"]).first
    end
  end

  def store_user(user)
    if user.nil?
      session[:user9487] = nil
    else
      session[:user9487] = { :name => user.name, :email => user.email, :password => user.password }
    end	
  end

  def load_messages
    @messages = session[:message87]
    session[:message87] = nil
  end

  def store_messages(messages)
    session[:message87] = messages
  end
end
