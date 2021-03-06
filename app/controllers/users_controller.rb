class UsersController < ApplicationController
  before_action :load_messages, :only => [:index, :edit, :new]
  before_action :load_user, :only => [:index, :edit, :add_post, :update, :destroy]
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

    if @user.nil?
      store_messages(["User disappear!!"])
      redirect_to users_path and return
    end
    unless change_content[:old_password].eql? @user.password
      # old password incorrect
      store_messages(["Old password not correct!!"])
      redirect_to edit_user_path and return
    end
    unless change_content[:new_password].eql? change_content[:password_confirm]
      # check new password and password confirmation failed
      store_messages(["New password and password confirmation not the same"])
      redirect_to edit_user_path and return
    end
    # all pass, update database
    if @user.update_attributes(password: change_content[:new_password])
      # success, update session
      session[:user9487]["password"] = change_content[:new_password]
      redirect_to users_path
    else
      # update database failed
      store_messages(@user.errors.full_messages)
      redirect_to edit_user_path
    end
  end

  def login
    loginer = params.require(:user).permit(:name, :password)
    @user = User.where("name = :name", {name: loginer[:name]}).first
    if @user.nil? or not @user.password.eql? loginer[:password]
      # not found
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
    @user = User.where("name = ?", newuser[:name]).first

    unless @user.nil?
      # user name conflict
      store_messages(["User exists!!"])
      redirect_to new_user_path and return
    end
    unless newuser[:password].eql? newuser[:password_confirm]
      # password and password_confirm not the same
      store_messages(["Password and password confirmation are not the same"])
      redirect_to new_user_path and return
    end
    # all pass
    @user = User.new(:name => newuser[:name], :email => newuser[:email], :password => newuser[:password])
    if @user.save
      store_user(@user)
      redirect_to users_path and return
    else
      # save fail
      store_messages(@user.errors.full_messages)
      redirect_to new_user_path and return
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
