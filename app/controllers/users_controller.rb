class UsersController < ApplicationController
  before_action :load_messages, :only => [:index, :edit, :new]
  before_action :load_user, :only => [:add_post, :update, :create, :destroy]
  def index
    # has not logged in 
    if session[:user9487].nil?
      redirect_to new_user_path
    else
      @user = session[:user9487]
      puts "@user=#{@user}"
      @user_posts = @user.posts
    end
  end

  def edit
    # edit password
    @user = session[:user9487]
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
    if change_content[:new_password].eql? change_content[:password_confirm]
      if @user.update_attributes(password: change_content[:new_password])
        redirect_to users_path
      else
        store_messages(@user.errors.full_messages)
        redirect_to edit_user_path
      end
    else
      store_messages(["Password and password confirmation no the same"])
      redirect_to edit_user_path
    end
  end
  
  def new
    @user = User.new
  end

  def login
    loginer = login_params
    @user = User.where("name = :name AND password = :password", {name: loginer[:name], password: loginer[:password]}).first
    if @user.nil?
      # note found
      store_messages(["Wrong user name or password"])
      redirect_to new_user_path
    else
      session[:user9487] = @user
      redirect_to users_path
    end
  end

  def logout
    session[:user9487] = nil
      redirect_to users_path
  end

  def create
    newuser = new_user_params
    if @user.nil?
      # no user name conflict, safe to create
      if newuser[:password].eql? newuser[:password_confirm]
        # success
        @user = User.new(:name => newuser[:name], :email => newuser[:email], :password => newuser[:password])
        if @user.save
          session[:user9487] = @user
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

  def destroy
    # destroy a user and his posts
    @posts = @user.posts
    if @posts
      @post.destroy
    end
    @user.destroy
    session[:user9487] = nil
    redirect_to users_path
  end

  private

  def load_user
    @user = session[:user9487]
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

  def store_messages(messages)
        session[:message87] = serialize_error(messages)
  end

  def new_user_params
    params.require(:user).permit(:name, :email, :password, :password_confirm)
  end

  def login_params
    params.require(:user).permit(:name, :password)
  end

  def serialize_error(messages)
    all_messages = messages.each { |message|
      {:message => message}
    }
    {:error => all_messages}
  end
end
